import cllvm

/// `LabelType` represents code labels.
public struct LabelType: IRType {
  /// Creates a code label.
  public init() {}

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return LLVMLabelType()
  }
}
