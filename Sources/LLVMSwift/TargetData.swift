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
}

public enum TargetMachineError: Error, CustomStringConvertible {
  case couldNotEmit(String)
  case couldNotEmitBitCode
  case invalidTriple(String)
  case couldNotCreateTarget(String, String)

  public var description: String {
    switch self {
    case .couldNotCreateTarget(let triple, let message):
      return "could not create target for '\(triple)': \(message)"
    case .invalidTriple(let target):
      return "invalid target triple '\(target)'"
    case .couldNotEmit(let message):
      return "could not emit object file: \(message)"
    case .couldNotEmitBitCode:
      return "could not emit bitcode for an unknown reason"
    }
  }
}

/// A `Target` object represents an object that encapsulates information about
/// a host architecture, vendor, ABI, etc.
public class Target {
  internal let llvm: LLVMTargetRef
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
  public  let target: Target

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
    var error: UnsafeMutablePointer<Int8>? = nil
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
      throw TargetMachineError.couldNotEmit(String(cString: err))
    }
  }
}

/// A `TargetData` encapsulates information about the data requirements of a
/// particular target architecture and can be used to retrieve information about
/// sizes and offsets of types with respect to this target.
public struct TargetData {
  internal let llvm: LLVMTargetDataRef

  /// Creates a Target Data object from an `LLVMTargetDataRef` object.
  public init(llvm: LLVMTargetDataRef) {
    self.llvm = llvm
  }

  /// Computes the byte offset of the indexed struct element for a target.
  ///
  /// - parameter element: The index of the element in the given structure to
  //    compute.
  /// - parameter type: The type of the structure to compute the offset with.
  ///
  /// - returns: The offset of the given element within the structure.
  public func offsetOfElement(_ element: Int, type: StructType) -> Int {
    return Int(LLVMOffsetOfElement(llvm, type.asLLVM(), UInt32(element)))
  }

  /// Computes the number of bits necessary to hold a value of the given type 
  /// for this target environment.
  ///
  /// - parameter type: The type to compute the size of.
  ///
  /// - returns: The size of the type in bits.
  public func sizeOfTypeInBits(_ type: IRType) -> Int {
    return Int(LLVMSizeOfTypeInBits(llvm, type.asLLVM()))
  }
}

/// LLVM-provided high-level optimization levels.
///
/// Each level has a specific goal and rationale.
public enum CodeGenOptLevel {
  /// Disable as many optimizations as possible. This doesn't completely
  /// disable the optimizer in all cases, for example always_inline functions
  /// can be required to be inlined for correctness.
  case none
  /// Optimize quickly without destroying debuggability.
  ///
  /// This level is tuned to produce a result from the optimizer as quickly
  /// as possible and to avoid destroying debuggability. This tends to result
  /// in a very good development mode where the compiled code will be
  /// immediately executed as part of testing. As a consequence, where
  /// possible, we would like to produce efficient-to-execute code, but not
  /// if it significantly slows down compilation or would prevent even basic
  /// debugging of the resulting binary.
  ///
  /// As an example, complex loop transformations such as versioning,
  /// vectorization, or fusion might not make sense here due to the degree to
  /// which the executed code would differ from the source code, and the
  /// potential compile time cost.
  case less
  /// Optimize for fast execution as much as possible without triggering
  /// significant incremental compile time or code size growth.
  ///
  /// The key idea is that optimizations at this level should "pay for
  /// themselves". So if an optimization increases compile time by 5% or
  /// increases code size by 5% for a particular benchmark, that benchmark
  /// should also be one which sees a 5% runtime improvement. If the compile
  /// time or code size penalties happen on average across a diverse range of
  /// LLVM users' benchmarks, then the improvements should as well.
  ///
  /// And no matter what, the compile time needs to not grow superlinearly
  /// with the size of input to LLVM so that users can control the runtime of
  /// the optimizer in this mode.
  ///
  /// This is expected to be a good default optimization level for the vast
  /// majority of users.
  case `default`

  /// Optimize for fast execution as much as possible.
  ///
  /// This mode is significantly more aggressive in trading off compile time
  /// and code size to get execution time improvements. The core idea is that
  /// this mode should include any optimization that helps execution time on
  /// balance across a diverse collection of benchmarks, even if it increases
  /// code size or compile time for some benchmarks without corresponding
  /// improvements to execution time.
  ///
  /// Despite being willing to trade more compile time off to get improved
  /// execution time, this mode still tries to avoid superlinear growth in
  /// order to make even significantly slower compile times at least scale
  /// reasonably. This does not preclude very substantial constant factor
  /// costs though.
  case aggressive

  /// Returns the underlying `LLVMCodeGenOptLevel` associated with this
  /// optimization level.
  public func asLLVM() -> LLVMCodeGenOptLevel {
    switch self {
    case .none: return LLVMCodeGenLevelNone
    case .less: return LLVMCodeGenLevelLess
    case .default: return LLVMCodeGenLevelDefault
    case .aggressive: return LLVMCodeGenLevelAggressive
    }
  }
}

/// The relocation model types supported by LLVM.
public enum RelocMode {
  /// Generated code will assume the default for a particular target architecture.
  case `default`
  /// Generated code will exist at static offsets.
  case `static`
  /// Generated code will be Position-Independent.
  case pic
  /// Generated code will not be Position-Independent and may be used in static
  /// or dynamic executables but not necessarily a shared library.
  case dynamicNoPIC

  /// Returns the underlying `LLVMRelocMode` associated with this
  /// relocation model.
  public func asLLVM() -> LLVMRelocMode {
    switch self {
    case .default: return LLVMRelocDefault
    case .static: return LLVMRelocStatic
    case .pic: return LLVMRelocPIC
    case .dynamicNoPIC: return LLVMRelocDynamicNoPic
    }
  }
}

/// The model that generated code should follow.  Code Models enables particular
/// styles of generated code that may be more suitable for each enumerated 
/// domain.  Code Models differ in addressing (absolute versus position 
/// independent), code size, data size and address range.
///
/// Documentation of these modes paraphrases the [Intel System V ABI AMD64
/// Architecture Processor Supplement](https://software.intel.com/sites/default/files/article/402129/mpx-linux64-abi.pdf).
public enum CodeModel {
  /// Generated code will assume the default for a particular target architecture.
  case `default`
  /// Generated code will assume the default for JITed code on a particular 
  /// target architecture.
  case jitDefault
  /// The virtual address of code executed is known at link time. Additionally
  /// all symbols are known to be located in the virtual addresses in the range
  /// from 0 to 2^31 − 2^24 − 1 or from 0x00000000 to 0x7effffff.
  ///
  /// This allows the compiler to encode symbolic references with offsets in the
  /// range from −(2^31) to 2^24 or from 0x80000000 to 0x01000000 directly in
  /// the sign extended immediate operands, with offsets in the range from 0 to
  /// 2^31 − 2^24 or from 0x00000000 to 0x7f000000 in the zero extended
  /// immediate operands and use instruction pointer relative addressing for the
  /// symbols with offsets in the range −(2^24) to 2^24 or 0xff000000 to
  /// 0x01000000.
  ///
  /// This is the fastest code model and is suitable for the vast majority of
  /// programs.
  case small
  /// The kernel of an operating system is usually rather small but runs in the 
  /// negative half of the address space. So all symbols are defined to be in 
  /// the range from 2^64 − 2^31 to 2^64 − 2^24 or from 0xffffffff80000000 to 
  /// 0xffffffffff000000.
  ///
  /// This code model has advantages similar to those of the small model, but 
  /// allows encoding of zero extended symbolic references only for offsets from
  /// 2^31 to 2^31 + 2^24 or from 0x80000000 to 0x81000000. The range offsets 
  /// for sign extended reference changes to 0 to 2^31 + 2^24 or 0x00000000 to 
  /// 0x81000000.
  case kernel
  /// In the medium model, the data section is split into two parts — the data
  /// section still limited in the same way as in the small code model and the 
  /// large data section having no limits except for available addressing
  /// space. The program layout must be set in a way so that large data sections
  /// (.ldata, .lrodata, .lbss) come after the text and data sections.
  ///
  /// This model requires the compiler to use `movabs` instructions to access
  /// large static data and to load addresses into registers, but keeps the 
  /// advantages of the small code model for manipulation of addresses in the 
  /// small data and text sections (specially needed for branches).
  ///
  /// By default only data larger than 65535 bytes will be placed in the large 
  /// data section.
  case medium
  /// The large code model makes no assumptions about addresses and sizes of 
  /// sections.
  ///
  /// The compiler is required to use the movabs instruction, as in the medium 
  /// code model, even for dealing with addresses inside the text section. 
  /// Additionally, indirect branches are needed when branching to addresses 
  /// whose offset from the current instruction pointer is unknown.
  ///
  /// It is possible to avoid the limitation on the text section in the small 
  /// and medium models by breaking up the program into multiple shared 
  /// libraries, so this model is strictly only required if the text of a single
  /// function becomes larger than what the medium model allows.
  case large

  /// Returns the underlying `LLVMCodeModel` associated with this
  /// code model.
  public func asLLVM() -> LLVMCodeModel {
    switch self {
    case .default: return LLVMCodeModelDefault
    case .jitDefault: return LLVMCodeModelJITDefault
    case .small: return LLVMCodeModelSmall
    case .kernel: return LLVMCodeModelKernel
    case .medium: return LLVMCodeModelMedium
    case .large: return LLVMCodeModelLarge
    }
  }
}
