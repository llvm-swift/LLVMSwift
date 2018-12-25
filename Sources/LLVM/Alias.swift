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

  /// Access the target value of this alias.
  public var aliasee: IRValue {
    get { return LLVMAliasGetAliasee(llvm) }
    set { LLVMAliasSetAliasee(llvm, newValue.asLLVM()) }
  }

  /// Retrieves the previous alias in the module, if there is one.
  public func previous() -> Alias? {
    guard let previous = LLVMGetPreviousGlobalAlias(llvm) else { return nil }
    return Alias(llvm: previous)
  }

  /// Retrieves the next alias in the module, if there is one.
  public func next() -> Alias? {
    guard let next = LLVMGetNextGlobalAlias(llvm) else { return nil }
    return Alias(llvm: next)
  }
}
