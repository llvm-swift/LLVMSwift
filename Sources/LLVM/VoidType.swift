#if !NO_SWIFTPM
import cllvm
#endif

/// The `Void` type represents any value and has no size.
public struct VoidType: IRType {
  /// Creates an instance of the `Void` type.
  public init() {}

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return LLVMVoidType()
  }
}
