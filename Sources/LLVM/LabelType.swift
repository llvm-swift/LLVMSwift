#if !NO_SWIFTPM
import cllvm
#endif

/// `LabelType` represents code labels.
public struct LabelType: IRType {

  /// Returns the context associated with this type.
  public let context: Context

  /// Creates a code label.
  ///
  /// - parameter context: The context to create this type in
  /// - SeeAlso: http://llvm.org/docs/ProgrammersManual.html#achieving-isolation-with-llvmcontext
  public init(in context: Context = Context.global) {
      self.context = context
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
   return LLVMLabelTypeInContext(context.llvm)
  }
}
