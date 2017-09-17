#if !NO_SWIFTPM
import cllvm
#endif

/// A SymbolResolver is an object that has special logic for looking up symbols
/// in the JIT.
public protocol SymbolResolver {
  /// Determines the callable address of the provided function in the JIT's
  /// address space.
  ///
  /// - Parameters:
  ///   - symbol: The name of the symbol to look up.
  ///   - jit: The JIT in which the resolver is looking.
  /// - Returns: `nil` if the symbol could not be found, otherwise the opaque
  ///            address of a C function pointer that can be called to execute
  ///            the compiled code.
  func address(of symbol: String, in jit: ORCJIT) -> UInt64?
}


/// A SimpleSymbolResolver looks through the JIT's symbol table to find
/// addresses.
public struct SimpleSymbolResolver: SymbolResolver {
  public func address(of symbol: String, in jit: ORCJIT) -> UInt64? {
    var target: LLVMOrcTargetAddress = 0
    let err = LLVMOrcGetSymbolAddress(jit.llvm, &target, symbol)
    guard err == LLVMOrcErrSuccess else {
      return nil
    }
    return target
  }
}

/// Runs a series of symbol resolvers in order, stopping when the first resolver
/// finds a valid symbol.
public struct CompoundSymbolResolver: SymbolResolver {
  private let resolverChain: [SymbolResolver]

  /// Create a symbol resolver that will run the provided resolvers in order
  /// until a symbol is resolved.
  ///
  /// - Parameter resolvers: The resolvers to run. Each one will be queried for
  ///                        each address they're resolving -- if they return
  ///                        a non-nil value, then the resolution stops and
  ///                        that result is returned. If none of the provided
  ///                        resolvers return an address, then this resolver
  ///                        returns no address.
  public init(resolvers: [SymbolResolver]) {
    self.resolverChain = resolvers
  }

  /// Create a symbol resolver that will run the provided resolvers in order
  /// until a symbol is resolved.
  ///
  /// - Parameter resolvers: The resolvers to run. Each one will be queried for
  ///                        each address they're resolving -- if they return
  ///                        a non-nil value, then the resolution stops and
  ///                        that result is returned. If none of the provided
  ///                        resolvers return an address, then this resolver
  ///                        returns no address.
  public init(resolvers: SymbolResolver...) {
    self.init(resolvers: resolvers)
  }

  public func address(of symbol: String, in jit: ORCJIT) -> UInt64? {
    for resolver in resolverChain {
      if let addr = resolver.address(of: symbol, in: jit) { return addr }
    }
    return nil
  }
}


/// A C-compatible function handler that wraps a JIT's symbol resolution
/// callback.
///
/// - Parameters:
///   - symbol: The symbol being looked up.
///   - ctx: A void pointer pointing to a retained ORCJIT instance.
/// - Returns: A callable address of a compiled function, or 0 if no such
///            function was found.
func orcjitSymbolResolver(symbol: UnsafePointer<Int8>?,
                          ctx: UnsafeMutableRawPointer?) -> UInt64 {
  guard let ctx = ctx else { return 0 }
  let handle = Unmanaged<ORCJIT>.fromOpaque(ctx)
  guard let cString = symbol else { return 0 }
  let jit = handle.takeRetainedValue()
  return jit.resolver.address(of: String(cString: cString), in: jit) ?? 0
}

public class ORCJIT {
  let llvm: LLVMOrcJITStackRef
  let resolver: SymbolResolver

  /// The strategy that ORCJIT should use to compile a specific module.
  public enum CompilationStrategy {
    /// The IR will be compiled lazily, one function at a time.
    case lazy

    /// The IR will be compiled eagerly, when it's added to the JIT.
    case eager
  }

  /// Keeps track of the mapping between module handles and their modules.
  private var handleMap = [LLVMModuleRef: LLVMOrcModuleHandle]()

  private var sharedObjectBuffers = [LLVMSharedObjectBufferRef]()

  public enum Error: Swift.Error {
    case platformDoesNotHaveJIT
    case generic(String)
    case couldNotFindModule(Module)
  }

  /// Creates an ORC JIT for the provided target machine. It optionally will
  /// take a symbol resolver to use instead of the standard symbol resolver
  /// to look up the addresses of compiled functions.
  ///
  /// - Parameters:
  ///   - machine: The target machine of the host.
  ///   - symbolResolver: An optional symbol resolver that you wish to use
  ///                     to resolve symbols. Defaults to a simple symbol
  ///                     resolver that just looks up the symbols in the JIT's
  ///                     compiled modules.
  /// - Throws: An error if any of the underlying JIT operations failed.
  public init(machine: TargetMachine,
              symbolResolver: SymbolResolver? = nil) throws {
    if LLVMTargetHasJIT(machine.llvm) == 0 {
      throw Error.platformDoesNotHaveJIT
    }

    /// Clone the machine so we can transfer the clone's ownership to the JIT.
    let clone = try machine.clone()
    clone.ownsLLVMRef = false
    llvm = LLVMOrcCreateInstance(clone.llvm)
    resolver = symbolResolver ?? SimpleSymbolResolver()
  }

  func opaqueSelf() -> UnsafeMutableRawPointer {
    let unmanaged = Unmanaged.passRetained(self)
    return unmanaged.toOpaque()
  }

  /// Gets the address of a given symbol in the JIT. This function can then
  /// be cast to the expected C function pointer type and called directly.
  ///
  /// - Parameter symbol: The symbol you're looking up.
  /// - Returns: A callable C function pointer address, or `nil` if the symbol
  ///            was not found.
  public func address(of symbol: String) -> UnsafeRawPointer? {
    var addr = LLVMOrcTargetAddress()
    do {
      try promoteError {
        LLVMOrcGetSymbolAddress(llvm, &addr, symbol)
      }
      guard addr != 0 else {
        return nil
      }
      return UnsafeRawPointer(bitPattern: UInt(addr))
    } catch {
      return nil
    }
  }

  /* TODO: Uncomment this when LLVMOrcAddObjectFile is implemented.
  func addObjectFile(_ objectFile: ObjectFile) throws {
    var handle = LLVMOrcModuleHandle()
    let sharedBuffer = LLVMOrcMakeSharedObjectBuffer(objectFile.buffer.llvm)!
    sharedObjectBuffers.append(sharedBuffer)
    try withError {
      LLVMOrcAddObjectFile(llvm, &handle, sharedBuffer,
                           orcjitSymbolResolver, opaqueSelf())
    }
  }
  */

  /// Turns a closure that returns an LLVMOrcErrorCode into a full throwing
  /// Swift function.
  ///
  /// - Parameter orcOperation: A closure that, when called, will result in
  ///                           an LLVMOrcErrorCode.
  /// - Throws: An error if the underlying operation did not return
  ///           `LLVMOrcErrorSuccess`.
  func promoteError(_ orcOperation: () -> LLVMOrcErrorCode) throws {
    let errCode = orcOperation()
    if errCode != LLVMOrcErrSuccess, let err = LLVMOrcGetErrorMsg(llvm) {
      throw Error.generic(String(cString: err))
    }
  }


  /// Removes the provided module from the JIT if it has been added already.
  ///
  /// - Parameter module: The module to remove from the JIT.
  /// - Throws: `Error.couldNotFindModule` if the module hasn't been registered
  ///           with this JIT.
  public func removeModule(_ module: Module) throws {
    guard let handle = handleMap[module.llvm] else {
      throw Error.couldNotFindModule(module)
    }
    try promoteError {
      LLVMOrcRemoveModule(llvm, handle)
    }
  }


  /// Adds the given module to the JIT, with the option of lazily compiling the
  /// functions in the module.
  ///
  /// - Parameters:
  ///   - module: The module you're compiling.
  ///   - strategy: The compilation strategy (currently `eager` or `lazy`) used
  ///               to compile this code. Defaults to `eager`.
  /// - Throws: An error if the underlying ORC operations fail.
  public func addModule(_ module: Module,
                        strategy: CompilationStrategy = .eager) throws {
    // Transfer ownership of the module to the JIT.
    module.ownsLLVMRef = false

    let sharedModule = LLVMOrcMakeSharedModule(module.llvm)!

    defer {
      // Destroy this shared reference once we've added it to the JIT -- the JIT
      // keeps a reference to it anyway.
      LLVMOrcDisposeSharedModuleRef(sharedModule)
    }
    var handle = LLVMOrcModuleHandle()
    try promoteError {
      switch strategy {
      case .lazy:
        return LLVMOrcAddLazilyCompiledIR(llvm, &handle, sharedModule,
                                          orcjitSymbolResolver, opaqueSelf())
      case .eager:
        return LLVMOrcAddEagerlyCompiledIR(llvm, &handle, sharedModule,
                                           orcjitSymbolResolver, opaqueSelf())
      }
    }
    handleMap[module.llvm] = handle
  }

  deinit {
    for ref in sharedObjectBuffers {
      LLVMOrcDisposeSharedObjectBufferRef(ref)
    }
    LLVMOrcDisposeInstance(llvm)
  }
}
