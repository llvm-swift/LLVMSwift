#if !NO_SWIFTPM
import cllvm
#endif

/// `FunctionType` represents a function's type signature.  It consists of a
/// return type and a list of formal parameter types. The return type of a
/// function type is a `void` type or first class type — except for `LabelType`
/// and `MetadataType`.
public struct FunctionType: IRType {
  /// The list of argument types.
  public let argTypes: [IRType]
  /// The return type of this function type.
  public let returnType: IRType
  /// Returns whether this function is variadic.
  public let isVarArg: Bool

  /// Creates a function type with the given argument types and return type.
  ///
  /// - parameter argTypes: A list of the argument types of the function type.
  /// - parameter returnType: The return type of the function type.
  /// - parameter isVarArg: Indicates whether this function type is variadic.
  ///   Defaults to `false`.
  /// - note: The context of this type is taken from it's `returnType`
  public init(argTypes: [IRType], returnType: IRType, isVarArg: Bool = false) {
    self.argTypes = argTypes
    self.returnType = returnType
    self.isVarArg = isVarArg
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    var argIRTypes = argTypes.map { $0.asLLVM() as Optional }
    return argIRTypes.withUnsafeMutableBufferPointer { buf in
      return LLVMFunctionType(returnType.asLLVM(),
                              buf.baseAddress,
                              UInt32(buf.count),
                              isVarArg.llvm)!
    }
  }
}
