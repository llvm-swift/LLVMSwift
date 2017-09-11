#if !NO_SWIFTPM
import cllvm
#endif

/// `FloatType` enumerates representations of a floating value of a particular
/// bit width and semantics.
public struct FloatType: IRType {

  /// The kind of floating point type this is
  public var kind: Kind

  /// Returns the context associated with this module.
  public let context: Context?

  /// Creates a float type of a particular kind
  ///
  /// - parameter kind: The kind of floating point type to create
  /// - parameter context: The context to create this type in
  /// - SeeAlso: http://llvm.org/docs/ProgrammersManual.html#achieving-isolation-with-llvmcontext
  public init(kind: Kind, in context: Context? = nil) {
    self.kind = kind
    self.context = context
  }

  public enum Kind {
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
  }

  /// 16-bit floating point value in the global context
  public static let half = FloatType(kind: .half)
  /// 32-bit floating point value in the global context
  public static let float = FloatType(kind: .float)
  /// 64-bit floating point value in the global context
  public static let double = FloatType(kind: .double)
  /// 80-bit floating point value (X87) in the global context
  public static let x86FP80 = FloatType(kind: .x86FP80)
  /// 128-bit floating point value (112-bit mantissa) in the global context
  public static let fp128 = FloatType(kind: .fp128)
  /// 128-bit floating point value (two 64-bits) in the global context
  public static let ppcFP128 = FloatType(kind: .ppcFP128)

  /// Creates a constant floating value of this type from a Swift `Double` value.
  public func constant(_ value: Double) -> Constant<Floating> {
    return Constant(llvm: LLVMConstReal(asLLVM(), value))
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    if let context = context {
        switch kind {
        case .half: return LLVMHalfTypeInContext(context.llvm)
        case .float: return LLVMFloatTypeInContext(context.llvm)
        case .double: return LLVMDoubleTypeInContext(context.llvm)
        case .x86FP80: return LLVMX86FP80TypeInContext(context.llvm)
        case .fp128: return LLVMFP128TypeInContext(context.llvm)
        case .ppcFP128: return LLVMPPCFP128TypeInContext(context.llvm)
        }
    }
    switch kind {
    case .half: return LLVMHalfType()
    case .float: return LLVMFloatType()
    case .double: return LLVMDoubleType()
    case .x86FP80: return LLVMX86FP80Type()
    case .fp128: return LLVMFP128Type()
    case .ppcFP128: return LLVMPPCFP128Type()
    }
  }
}
