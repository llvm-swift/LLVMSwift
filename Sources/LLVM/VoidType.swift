#if !NO_SWIFTPM
import cllvm
#endif

/// The `Void` type represents any value and has no size.
public struct VoidType: IRType {

  /// Returns the context associated with this module.
  public let context: Context?

  /// Creates an instance of the `Void` type.
  ///
  /// - parameter context: The context to create this type in
  /// - SeeAlso: http://llvm.org/docs/ProgrammersManual.html#achieving-isolation-with-llvmcontext
  public init(in context: Context? = nil) {
    self.context = context
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    if let context = context {
      return LLVMVoidTypeInContext(context.llvm)
    }
    return LLVMVoidType()
  }
}
