import cllvm

/// The supported types of files codegen can produce.
public enum CodegenFileType {
  /// An object file (.o).
  case object
  /// An assembly file (.asm).
  case assembly
  /// An LLVM Bitcode file (.bc).
  case bitCode

  /// Returns the underlying `LLVMCodeGenFileType` associated with this file
  /// type.
  public func asLLVM() -> LLVMCodeGenFileType {
    switch self {
    case .object: return LLVMObjectFile
    case .assembly: return LLVMAssemblyFile
    case .bitCode: fatalError("not handled here")
    }
  }

  /// The name of the file type.
  internal var name: String {
    switch self {
    case .object:
      return "object"
    case .assembly:
      return "assembly"
    case .bitCode:
      return "bitcode"
    }
  }
}

/// Represents one of a few errors that can be thrown by a `TargetMachine`
public enum TargetMachineError: Error, CustomStringConvertible {
  /// The target machine failed to emit the specified file type.
  /// This case also contains the message emitted by LLVM explaining the
  /// failure.
  case couldNotEmit(String, CodegenFileType)

  /// The target machine failed to emit the bitcode for this module.
  case couldNotEmitBitCode

  /// The specified target triple was invalid.
  case invalidTriple(String)

  /// The Target is could not be created.
  /// This case also contains the message emitted by LLVM explaining the
  /// failure.
  case couldNotCreateTarget(String, String)

  public var description: String {
    switch self {
    case .couldNotCreateTarget(let triple, let message):
      return "could not create target for '\(triple)': \(message)"
    case .invalidTriple(let target):
      return "invalid target triple '\(target)'"
    case .couldNotEmit(let message, let fileType):
      return "could not emit \(fileType.name) file: \(message)"
    case .couldNotEmitBitCode:
      return "could not emit bitcode for an unknown reason"
    }
  }
}

/// A `Target` object represents an object that encapsulates information about
/// a host architecture, vendor, ABI, etc.
public class Target {
  internal let llvm: LLVMTargetRef

  /// Creates a `Target` object from an LLVM target object.
  public init(llvm: LLVMTargetRef) {
    self.llvm = llvm
  }
}

/// A `TargetMachine` object represents an object that encapsulates information
/// about a particular machine (i.e. CPU type) associated with a target
/// environment.
public class TargetMachine {
  internal let llvm: LLVMTargetMachineRef

  /// The target information associated with this target machine.
  public let target: Target

  /// The data layout semantics associated with this target machine
  public let dataLayout: TargetData

  /// A string representing the target triple for this target machine.  In the
  /// form `<arch><sub>-<vendor>-<sys>-<abi>` where
  ///
  /// - arch = x86_64, i386, arm, thumb, mips, etc.
  /// - sub = for ex. on ARM: v5, v6m, v7a, v7m, etc.
  /// - vendor = pc, apple, nvidia, ibm, etc.
  /// - sys = none, linux, win32, darwin, cuda, etc.
  /// - abi = eabi, gnu, android, macho, elf, etc.
  public let triple: String

  /// Creates a Target Machine with information about its target environment.
  ///
  /// - parameter triple: An optional target triple to target.  If this is not
  ///   provided the target triple of the host machine will be assumed.
  /// - parameter cpu: An optional CPU type to target.  If this is not provided
  ///   the host CPU will be inferred.
  /// - parameter features: An optional string containing the features a
  ///   particular target provides.
  /// - parameter optLevel: The optimization level for generated code.  If no
  ///   value is provided, the default level of optimization is assumed.
  /// - parameter relocMode: The relocation mode of the target environment.  If
  ///   no mode is provided, the default mode for the target architecture is
  ///   assumed.
  /// - parameter codeModel: The kind of code to produce for this target.  If
  ///   no model is provided, the default model for the target architecture is
  ///   assumed.
  public init(triple: String? = nil, cpu: String = "", features: String = "",
              optLevel: CodeGenOptLevel = .default, relocMode: RelocMode = .default,
              codeModel: CodeModel = .default) throws {
    self.triple = triple ?? String(cString: LLVMGetDefaultTargetTriple()!)
    var target: LLVMTargetRef?
    var error: UnsafeMutablePointer<Int8>?
    LLVMGetTargetFromTriple(self.triple, &target, &error)
    if let error = error {
      defer { LLVMDisposeMessage(error) }
      throw TargetMachineError.couldNotCreateTarget(self.triple,
                                                    String(cString: error))
    }
    self.target = Target(llvm: target!)
    self.llvm = LLVMCreateTargetMachine(target!, self.triple, cpu, features,
                                        optLevel.asLLVM(),
                                        relocMode.asLLVM(),
                                        codeModel.asLLVM())
    self.dataLayout = TargetData(llvm: LLVMCreateTargetDataLayout(self.llvm))
  }

  /// Emits an LLVM Bitcode, ASM, or object file for the given module to the
  /// provided filename.
  ///
  /// Failure during any part of the compilation process or the process of
  /// writing the results to disk will result in a `TargetMachineError` being
  /// thrown describing the error in detail.
  ///
  /// - parameter module: The module whose contents will be codegened.
  /// - parameter type: The type of codegen to perform on the given module.
  /// - parameter path: The path to write the resulting file.
  public func emitToFile(module: Module, type: CodegenFileType, path: String) throws {
    if case .bitCode = type {
      if LLVMWriteBitcodeToFile(module.llvm, path) != 0 {
        throw TargetMachineError.couldNotEmitBitCode
      }
      return
    }
    var err: UnsafeMutablePointer<Int8>?
    let status = path.withCString { cStr -> LLVMBool in
      var mutable = strdup(cStr)
      defer { free(mutable) }
      return LLVMTargetMachineEmitToFile(llvm, module.llvm, mutable, type.asLLVM(), &err)
    }
    if let err = err, status != 0 {
      defer { LLVMDisposeMessage(err) }
      throw TargetMachineError.couldNotEmit(String(cString: err), type)
    }
  }

  deinit {
    LLVMDisposeTargetMachine(llvm)
  }
}
