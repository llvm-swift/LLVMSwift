import cllvm

/// `Use` represents an iterator over the uses and users of a particular value
/// in an LLVM program.
public struct Use {
  internal let llvm: LLVMUseRef

  /// Retrieves the next use of a value.
  public func next() -> Use? {
    guard let next = LLVMGetNextUse(llvm) else { return nil }
    return Use(llvm: next)
  }

  /// Obtain the user value for this `User` object.
  public func user() -> IRValue? {
    return LLVMGetUser(llvm)
  }

  /// Obtain the value this `User` object corresponds to.
  public func usedValue() -> IRValue? {
    return LLVMGetUsedValue(llvm)
  }
}
