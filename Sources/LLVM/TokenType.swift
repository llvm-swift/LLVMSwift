#if SWIFT_PACKAGE
import cllvm
#endif

/// `TokenType` is used when a value is associated with an instruction but all
/// uses of the value must not attempt to introspect or obscure it. As such, it
/// is not appropriate to have a `PHI` or `select` of type `TokenType`.
public struct TokenType: IRType {
  internal let llvm: LLVMTypeRef

  /// Initializes a token type from the given LLVM type object.
  public init(llvm: LLVMTypeRef) { self.llvm = llvm }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}
