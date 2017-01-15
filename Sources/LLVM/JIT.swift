import cllvm

/// JITError represents the different kinds of errors the JIT compiler can
/// throw.
public enum JITError: Error, CustomStringConvertible {
  /// The JIT was unable to be initialized. A message is provided explaining
  /// the failure.
  case couldNotInitialize(String)

  /// A human-readable description of the error.
  public var description: String {
    switch self {
    case .couldNotInitialize(let message):
      return "could not initialize JIT: \(message)"
    }
  }
}

/// A `JIT` is a Just-In-Time compiler that will compile and execute LLVM IR
/// that has been generated in a `Module`. It can execute arbitrary functions
/// and return the value the function generated, allowing you to write
/// interactive programs that will run as soon as they are compiled.
public final class JIT {
  /// The underlying LLVMExecutionEngineRef backing this JIT.
  internal let llvm: LLVMExecutionEngineRef

  /// Creates a Just In Time compiler that will compile the code in the
  /// provided `Module` to the architecture of the provided `TargetMachine`,
  /// and execute it.
  ///
  /// - parameters:
  ///   - module: The module containing code you wish to execute
  ///   - machine: The target machine which you're compiling for
  /// - throws: JITError
  public init(module: Module, machine: TargetMachine) throws {
    var jit: LLVMExecutionEngineRef?
    var error: UnsafeMutablePointer<Int8>?
    if LLVMCreateExecutionEngineForModule(&jit, module.llvm, &error) != 0 {
      let str = String(cString: error!)
      throw JITError.couldNotInitialize(str)
    }
    guard let _jit = jit else {
      throw JITError.couldNotInitialize("JIT was NULL")
    }
    self.llvm = _jit
  }

  /// Runs the specified function with the provided arguments by compiling
  /// it to machine code for the target architecture used to initialize this
  /// JIT.
  ///
  /// - parameters:
  ///   - function: The function you wish to execute
  ///   - args: The arguments you wish to pass to the function
  /// - returns: The LLVM value that the function returned
  public func runFunction(_ function: Function, args: [IRValue]) -> IRValue {
    var irArgs = args.map { $0.asLLVM() as Optional }
    return irArgs.withUnsafeMutableBufferPointer { buf in
      return LLVMRunFunction(llvm, function.asLLVM(),
                             UInt32(buf.count), buf.baseAddress)
    }
  }

  /// Runs the specified function as if it were the `main` function in an
  /// executable. It takes an array of argument strings and passes them
  /// into the function as `argc` and `argv`.
  ///
  /// - parameters:
  ///   - function: The `main` function you wish to execute
  ///   - args: The string arguments you wish to pass to the function
  /// - returns: The numerical exit code returned by the function
  public func runFunctionAsMain(_ function: Function, args: [String]) -> Int {
    // FIXME: Also add in envp.
    return withCArrayOfCStrings(args) { buf in
      return Int(LLVMRunFunctionAsMain(llvm, function.asLLVM(),
                                       UInt32(buf.count),
                                       buf.baseAddress, nil))
    }
  }
}

/// Runs the provided block with the equivalent C strings copied from the
/// passed-in array. The C strings will only be alive for the duration
/// of the block, and they will be freed when the block exits.
///
/// - parameters:
///   - strings: The strings you intend to convert to C strings
///   - block: A block that uses the C strings
/// - returns: The result of the passed-in block.
/// - throws: Will only throw if the passed-in block throws.
internal func withCArrayOfCStrings<T>(_ strings: [String], _ block:
  (UnsafeBufferPointer<UnsafePointer<Int8>?>) throws -> T) rethrows -> T {
  var cStrings = [UnsafeMutablePointer<Int8>?]()
  for string in strings {
    string.withCString {
      cStrings.append(strdup($0))
    }
  }
  defer {
    for cStr in cStrings {
      free(cStr)
    }
  }
  return try cStrings.withUnsafeBufferPointer { buf in
    // We need to make this "immutable" but that doesn't change
    // their size or contents.
    let constPtr = unsafeBitCast(buf.baseAddress,
                                 to: UnsafePointer<UnsafePointer<Int8>?>.self)
    return try block(UnsafeBufferPointer(start: constPtr, count: buf.count))
  }
}
