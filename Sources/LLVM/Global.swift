import cllvm

/// A `Global` represents a region of memory allocated at compile time instead
/// of at runtime.  A global variable must either have an initializer, or make
/// reference to an external definition that has an initializer.
public struct Global: IRValue {
  internal let llvm: LLVMValueRef

  /// Returns whether this global variable has no initializer because it makes
  /// reference to an initialized value in another translation unit.
  public var isExternallyInitialized: Bool {
    get { return LLVMIsExternallyInitialized(llvm) != 0 }
    set { LLVMSetExternallyInitialized(llvm, newValue.llvm) }
  }

  /// Retrieves the initializer for this global variable, if it exists.
  public var initializer: IRValue? {
    get { return LLVMGetInitializer(asLLVM()) }
    set { LLVMSetInitializer(asLLVM(), newValue!.asLLVM()) }
  }

  /// Returns whether this global variable is a constant, whether or not the
  /// final definition of the global is not.
  public var isGlobalConstant: Bool {
    get { return LLVMIsGlobalConstant(asLLVM()) != 0 }
    set { LLVMSetGlobalConstant(asLLVM(), newValue.llvm) }
  }

  /// Returns whether this global variable is thread-local.  That is, returns
  /// if this variable is not shared by multiple threads.
  public var isThreadLocal: Bool {
    get { return LLVMIsThreadLocal(asLLVM()) != 0 }
    set { LLVMSetThreadLocal(asLLVM(), newValue.llvm) }
  }

  /// Deletes the global variable from its containing module.
  /// - note: This does not remove references to this global from the
  ///         module. Ensure you have removed all insructions that reference
  ///         this global before deleting it.
  public func delete() {
    LLVMDeleteGlobal(llvm)
  }

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}
