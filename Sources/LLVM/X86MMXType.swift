import cllvm

/// `X86MMXType` represents a value held in an MMX register on an x86 machine.
///
/// The operations allowed on it are quite limited: parameters and return
/// values, load and store, and bitcast. User-specified MMX instructions are
/// represented as intrinsic or asm calls with arguments and/or results of this
/// type. There are no arrays, vectors or constants of this type.
public struct X86MMXType: IRType {
  /// Creates an `X86MMXType`.
  public init() {}

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return LLVMX86MMXType()
  }
}
