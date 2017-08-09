import cllvm

/// The `MetadataType` type represents embedded metadata. No derived types may
/// be created from metadata except for function arguments.
public struct MetadataType: IRType {
  internal let llvm: LLVMTypeRef

  /// Creates an embedded metadata type for the given LLVM type object.
  public init(llvm: LLVMTypeRef) {
    self.llvm = llvm
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}
