import cllvm

/// JITError represents the different kinds of errors the JIT compiler can
/// throw.
public enum JITError: Error, CustomStringConvertible {
    /// The JIT was unable to be initialized. A message is provided explaining
    /// the failure.
    case couldNotInitialize(String)
    case couldNotRemoveModule(String, Module)

    /// A human-readable description of the error.
    public var description: String {
        switch self {
        case .couldNotInitialize(let message):
            return "could not initialize JIT: \(message)"
        case .couldNotRemoveModule(let message, let module):
            return "could not remove module '\(module.name)': \(message)"
        }
    }
}

private let linkInMCJIT: Void = {
    LLVMLinkInMCJIT()
}()

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
        _ = linkInMCJIT
        var jit: LLVMExecutionEngineRef?
        var error: UnsafeMutablePointer<Int8>?
        var options = LLVMMCJITCompilerOptions()
        LLVMInitializeMCJITCompilerOptions(&options,
                                           MemoryLayout<LLVMMCJITCompilerOptions>.size)
        if LLVMCreateMCJITCompilerForModule(&jit, module.llvm, &options,
                                            MemoryLayout<LLVMMCJITCompilerOptions>.size,
                                            &error) != 0 {
            let str = String(cString: error!)
            throw JITError.couldNotInitialize(str)
        }
        guard let _jit = jit else {
            throw JITError.couldNotInitialize("JIT was NULL")
        }
        self.llvm = _jit
    }

    /// Looks in the JIT's registered modules for a function with the given
    /// name.
    ///
    /// - parameter name: The desired function's name.
    /// - returns: A `Function` with that name, or `nil` if none exists.
    public func function(named name: String) -> IRValue? {
        var out: LLVMValueRef?
        if LLVMFindFunction(llvm, name, &out) != 0 { return nil }
        return Function(llvm: out!)
    }

    /// Looks in the JIT's registered modules for the provided function, and
    /// compiles it if it hasn't already been compiled. Returns an OpaquePointer
    /// to that function.
    ///
    /// You must `unsafeBitCast` this pointer to the appropriate
    /// `@convention(c)` function type before you're able to call it.
    ///
    /// - parameter function: The function you're looking up.
    /// - returns: An opaque C function pointer to that function, or `gnil if it
    ///            didn't exist.
    public func addressOfFunction(_ function: Function) -> OpaquePointer? {
        return addressOfFunction(named: function.name)
    }


    /// Looks in the JIT's registered modules for a function with the provided
    /// name, and compiles it if it hasn't already been compiled. Returns an
    /// `OpaquePointer` to that function.
    ///
    /// You must `unsafeBitCast` this pointer to the appropriate
    /// `@convention(c)` function type before you're able to call it.
    ///
    /// - parameter function: The function you're looking up.
    /// - returns: An opaque C function pointer to that function, or nil if it
    ///            didn't exist.
    public func addressOfFunction(named name: String) -> OpaquePointer? {
        return OpaquePointer(bitPattern: UInt(LLVMGetFunctionAddress(llvm, name)))
    }

    /// Adds the provided module to the JIT's registered module list. This
    /// results in the compilation of all top-level declarations in the module.
    ///
    /// - parameter module: The module you're attempting to register.
    public func addModule(_ module: Module) {
        LLVMAddModule(llvm, module.llvm)
    }

    /// Removes the provided module from the JIT's registered module list. If
    /// there was an error, then this method will `throw`.
    ///
    /// - parameter module: The module you're attempting to register.
    /// - throws: JITError.couldNotRemoveModule with a message if the removal
    ///           fails.
    public func removeModule(_ module: Module) throws {
        var mod: LLVMValueRef? = module.llvm
        var error: UnsafeMutablePointer<Int8>?
        if LLVMRemoveModule(llvm, module.llvm, &mod, &error) != 0 {
            throw JITError.couldNotRemoveModule(String(cString: error!), module)
        }
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
