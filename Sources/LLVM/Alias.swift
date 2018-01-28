#if SWIFT_PACKAGE
import cllvm
#endif

/// An `Alias` represents a global alias in an LLVM module - a new symbol and
/// corresponding metadata for an existing global value.
public struct Alias: IRGlobal {
  internal let llvm: LLVMValueRef

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}
