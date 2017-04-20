import cllvm

/// A `TargetData` encapsulates information about the data requirements of a
/// particular target architecture and can be used to retrieve information about
/// sizes and offsets of types with respect to this target.
public class TargetData {
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
  public func offsetOfElement(at index: Int, type: StructType) -> Int {
    return Int(LLVMOffsetOfElement(llvm, type.asLLVM(), UInt32(index)))
  }

  /// Computes the index of the struct element at the provided offset in a
  /// struct type for a target.
  ///
  /// - parameter element: The index of the element in the given structure to
  //    compute.
  /// - parameter type: The type of the structure to compute the offset with.
  ///
  /// - returns: The offset of the given element within the structure.
  public func elementAtOffset(_ offset: Int, type: StructType) -> Int {
    return Int(LLVMElementAtOffset(llvm, type.asLLVM(), UInt64(offset)))
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

  /// Computes the minimum ABI-required number of bits necessary to hold a value
  /// of the given type for this target environment.
  ///
  /// - parameter type: The type to compute the size of.
  ///
  /// - returns: The minimum ABI-required size of the type in bytes.
  public func abiSizeOfType(_ type: IRType) -> Int {
    return Int(LLVMABISizeOfType(llvm, type.asLLVM()))
  }

  /// The current platform byte order, either big or little endian.
  public var byteOrder: ByteOrder {
    return ByteOrder(llvm: LLVMByteOrder(llvm))
  }

  /// Creates a string representation of the target data.
  public var layoutString: String {
    let str = LLVMCopyStringRepOfTargetData(llvm)!
    defer { free(str) }
    return String(cString: str)
  }

  /// The integer type that is the same size as a pointer on this target.
  /// This is analoguous to the `intptr_t` type in C++.
  /// - parameters:
  ///   - context: The context in which to derive the type (optional).
  ///   - addressSpace: The address space in which to derive the type.
  /// - returns: An IntegerType that is the same size as the pointer type
  ///            on this target.
  public func intPointerType(context: Context? = nil, addressSpace: Int? = nil) -> IntType {
    let type: LLVMTypeRef
    switch (context, addressSpace) {
    case let (context?, addressSpace?):
      type = LLVMIntPtrTypeForASInContext(context.llvm, llvm, UInt32(addressSpace))
    case let (nil, addressSpace?):
      type = LLVMIntPtrTypeForAS(llvm, UInt32(addressSpace))
    case let (context?, nil):
      type = LLVMIntPtrTypeInContext(context.llvm, llvm)
    case (nil, nil):
      type = LLVMIntPtrType(llvm)
    }
    return convertType(type) as! IntType // Guaranteed to succeed
  }

  /// Computes the preferred alignment of the given global for this target
  ///
  /// - parameter global: The global variable
  /// - returns: The variable's preferred alignment in this target
  public func preferredAlignment(of global: Global) -> Int {
    return Int(LLVMPreferredAlignmentOfGlobal(llvm, global.asLLVM()))
  }

  /// Computes the preferred alignment of the given type for this target
  ///
  /// - parameter type: The type for which you're computing the alignment
  /// - returns: The type's preferred alignment in this target
  public func preferredAlignment(of type: IRType) -> Int {
    return Int(LLVMPreferredAlignmentOfType(llvm, type.asLLVM()))
  }

  /// Computes the minimum ABI-required alignment for the specified type.
  ///
  /// - parameter type: The type to whose ABI alignment you wish to compute.
  /// - returns: The minimum ABI-required alignment for the specified type.
  public func abiAlignment(of type: IRType) -> Int {
    return Int(LLVMABIAlignmentOfType(llvm, type.asLLVM()))
  }

  /// Computes the minimum ABI-required alignment for the specified type.
  ///
  /// This function is equivalent to `TargetData.abiAlignment(of:)`.
  ///
  /// - parameter type: The type to whose ABI alignment you wish to compute.
  /// - returns: The minimum ABI-required alignment for the specified type.
  public func callFrameAlignment(of type: IRType) -> Int {
    return Int(LLVMCallFrameAlignmentOfType(llvm, type.asLLVM()))
  }

  /// Computes the ABI size of a type in bytes for a target.
  ///
  /// - parameter type: The type to whose ABI size you wish to compute.
  /// - returns: The ABI size for the specified type.
  public func abiSize(of type: IRType) -> Int {
    return Int(LLVMABISizeOfType(llvm, type.asLLVM()))
  }
  /// Computes the maximum number of bytes that may be overwritten by
  /// storing the specified type.
  ///
  /// - parameter type: The type to whose store size you wish to compute.
  /// - returns: The store size of the type in the given target.
  public func storeSize(of type: IRType) -> Int {
    return Int(LLVMStoreSizeOfType(llvm, type.asLLVM()))
  }

  /// Computes the pointer size for the platform, optionally in a given
  /// address space.
  ///
  /// - parameter addressSpace: The address space in which to compute
  ///                           pointer size.
  /// - returns: The size of a pointer in the target address space.
  public func pointerSize(addressSpace: Int? = nil) -> Int {
    if let addressSpace = addressSpace {
      return Int(LLVMPointerSizeForAS(llvm, UInt32(addressSpace)))
    } else {
      return Int(LLVMPointerSize(llvm))
    }
  }
}

/// `ByteOrder` enumerates the ordering semantics of sequences of bytes on a
/// particular target architecture.
public enum ByteOrder {
  /// Little-endian byte order. In a little-endian platform, the _least_
  /// significant bytes come before the _most_ significant bytes in a series,
  /// so the 16-bit number 1234 would look like:
  /// ```
  /// 11010010 00000100
  /// ^ lower  ^ higher order
  /// ```
  case littleEndian

  /// Big-endian byte order. In a big-endian platform, the _most_
  /// significant bytes come before the _least_ significant bytes in a series,
  /// so the 16-bit number 1234 would look like:
  /// ```
  /// 00000100 11010010
  /// ^ higher  ^ lower order
  /// ```
  /// Big-endian byte order is the most natural order for humans to understand.
  case bigEndian

  /// Converts this ByteOrder to the equivalent LLVMByteOrdering
  internal func asLLVM() -> LLVMByteOrdering {
    switch self {
    case .littleEndian: return LLVMLittleEndian
    case .bigEndian: return LLVMBigEndian
    }
  }

  /// Creates a ByteOrder from an LLVMByteOrdering.
  /// This will call fatalError if it's not passed LLVMLittleEndian or
  /// LLVMBigEndian.
  internal init(llvm: LLVMByteOrdering) {
    switch llvm {
    case LLVMLittleEndian: self = .littleEndian
    case LLVMBigEndian: self = .bigEndian
    default: fatalError("unknown byte order \(llvm)")
    }
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
