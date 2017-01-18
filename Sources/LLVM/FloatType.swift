#if !NO_SWIFTPM
import cllvm
#endif

/// `FloatType` enumerates representations of a floating value of a particular
/// bit width and semantics.
public enum FloatType: IRType {
  /// 16-bit floating point value
  case half
  /// 32-bit floating point value
  case float
  /// 64-bit floating point value
  case double
  /// 80-bit floating point value (X87)
  case x86FP80
  /// 128-bit floating point value (112-bit mantissa)
  case fp128
  /// 128-bit floating point value (two 64-bits)
  case ppcFP128

  /// Creates a constant floating value of this type from a Swift `Double` value.
  public func constant(_ value: Double) -> IRValue {
    return LLVMConstReal(asLLVM(), value)
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    switch self {
    case .half: return LLVMHalfType()
    case .float: return LLVMFloatType()
    case .double: return LLVMDoubleType()
    case .x86FP80: return LLVMX86FP80Type()
    case .fp128: return LLVMFP128Type()
    case .ppcFP128: return LLVMPPCFP128Type()
    }
  }
}
