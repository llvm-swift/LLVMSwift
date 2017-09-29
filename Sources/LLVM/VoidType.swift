#if SWIFT_PACKAGE
import cllvm
#endif

/// The `Void` type represents any value and has no size.
public struct VoidType: IRType {

  /// Returns the context associated with this type.
  public let context: Context

  /// Creates an instance of the `Void` type.
  ///
  /// - parameter context: The context to create this type in
  /// - SeeAlso: http://llvm.org/docs/ProgrammersManual.html#achieving-isolation-with-llvmcontext
  public init(in context: Context = Context.global) {
    self.context = context
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return LLVMVoidTypeInContext(context.llvm)
  }
}
