import cllvm

/// An `Alias` represents a global alias in an LLVM module - a new symbol and 
/// corresponding metadata for an existing position
public struct Alias: IRValue {
  internal let llvm: LLVMValueRef

  /// Retrieves the linkage information for this alias.
  public var linkage: Linkage {
    get { return Linkage(llvm: LLVMGetLinkage(asLLVM())) }
    set { LLVMSetLinkage(asLLVM(), newValue.llvm) }
  }

  /// Retrieves the visibility style for this alias.
  public var visibility: Visibility {
    get { return Visibility(llvm: LLVMGetVisibility(asLLVM())) }
    set { LLVMSetVisibility(asLLVM(), newValue.llvm) }
  }

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}
