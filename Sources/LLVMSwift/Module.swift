import cllvm

/// A `Context` represents execution states for the core LLVM IR system.
public class Context {
  internal let llvm: LLVMContextRef

  /// Retrieves the global context instance.
  public static let global = Context(llvm: LLVMGetGlobalContext()!)

  /// Creates a `Context` object from an `LLVMContextRef` object.
  public init(llvm: LLVMContextRef) {
    self.llvm = llvm
  }
}

/// Represents the possible errors that can be thrown while interacting with a 
/// `Module` object.
public enum ModuleError: Error, CustomStringConvertible {
  /// Thrown when a module does not pass the module verification process.  
  /// Includes the reason the module did not pass verification.
  case didNotPassVerification(String)
  /// Thrown when a module cannot be printed at a given path.  Provides the
  /// erroneous path and a deeper reason why printing to that path failed.
  case couldNotPrint(path: String, error: String)
  /// Thrown when a module cannot emit bitcode because it contains erroneous
  /// declarations.
  case couldNotEmitBitCode(path: String)

  public var description: String {
    switch self {
    case .didNotPassVerification(let message):
      return "module did not pass verification: \(message)"
    case .couldNotPrint(let path, let error):
      return "could not print to file \(path): \(error)"
    case .couldNotEmitBitCode(let path):
      return "could not emit bitcode to file \(path) for an unknown reason"
    }
  }
}

/// A `Module` represents the top-level structure of an LLVM program. An LLVM
/// module is effectively a translation unit or a collection of translation 
/// units merged together.
public final class Module {
  internal let llvm: LLVMModuleRef

  /// Creates a `Module` with the given name.
  ///
  /// - parameter name: The name of the module.
  /// - parameter context: The context to associate this module with.  If no
  ///   context is provided, one will be inferred.
  public init(name: String, context: Context? = nil) {
    if let context = context {
      llvm = LLVMModuleCreateWithNameInContext(name, context.llvm)
      self.context = context
    } else {
      llvm = LLVMModuleCreateWithName(name)
      self.context = Context(llvm: LLVMGetModuleContext(llvm)!)
    }
  }

  /// Returns the context associated with this module.
  public let context: Context

  /// Obtain the data layout for this module.
  public var dataLayout: TargetData {
    return TargetData(llvm: LLVMGetModuleDataLayout(llvm))
  }

  /// Print a representation of a module to a file at the given path.
  ///
  /// If the provided path is not suitable for writing, this function will throw
  /// `ModuleError.couldNotPrint`.
  ///
  /// - parameter path: The path to write the module's representation to.
  public func print(to path: String) throws {
    var err: UnsafeMutablePointer<Int8>?
    path.withCString { cString in
      let mutable = strdup(cString)
      LLVMPrintModuleToFile(llvm, mutable, &err)
      free(mutable)
    }
    if let err = err {
      defer { LLVMDisposeMessage(err) }
      throw ModuleError.couldNotPrint(path: path, error: String(cString: err))
    }
  }

  /// Writes the bitcode of elements in this module to a file at the given path.
  ///
  /// If the provided path is not suitable for writing, this function will throw
  /// `ModuleError.couldNotEmitBitCode`.
  ///
  /// - parameter path: The path to write the module's representation to.
  public func emitBitCode(to path: String) throws {
    let status = path.withCString { cString -> Int32 in
      let mutable = strdup(cString)
      defer { free(mutable) }
      return LLVMWriteBitcodeToFile(llvm, mutable)
    }
    
    if status != 0 {
      throw ModuleError.couldNotEmitBitCode(path: path)
    }
  }

  /// Creates a type with the given name in this module if that name does not
  /// conflict with an existing type name.
  ///
  /// - parameter name: The name of the type to create.
  ///
  /// - returns: A representation of the newly created type with the given name
  ///   or nil if such a representation could not be created.
  public func type(named name: String) -> IRType? {
    guard let type = LLVMGetTypeByName(llvm, name) else { return nil }
    return convertType(type)
  }

  /// Creates a function with the given name in this module if that name does 
  /// not conflict with an existing type name.
  ///
  /// - parameter name: The name of the function to create.
  ///
  /// - returns: A representation of the newly created function with the given 
  /// name or nil if such a representation could not be created.
  public func function(named name: String) -> Function? {
    guard let fn = LLVMGetNamedFunction(llvm, name) else { return nil }
    return Function(llvm: fn)
  }

  /// Verifies that this module is valid, taking the specified action if not.
  /// If this module did not pass verification, a description of any invalid
  /// constructs is provided with the thrown 
  /// `ModuleError.didNotPassVerification` error.
  public func verify() throws {
    var message: UnsafeMutablePointer<Int8>?
    let status = Int(LLVMVerifyModule(llvm, LLVMReturnStatusAction, &message))
    if let message = message, status == 1 {
      defer { LLVMDisposeMessage(message) }
      throw ModuleError.didNotPassVerification(String(cString: message))
    }
  }

  /// Dump a representation of this module to stderr.
  public func dump() {
    LLVMDumpModule(llvm)
  }
}

extension Bool {
  internal var llvm: LLVMBool {
    return self ? 1 : 0
  }
}
