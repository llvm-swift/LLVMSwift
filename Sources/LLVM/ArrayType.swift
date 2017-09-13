#if !NO_SWIFTPM
import cllvm
#endif

/// `ArrayType` is a very simple derived type that arranges elements
/// sequentially in memory. `ArrayType` requires a size (number of elements) and
/// an underlying data type.
public struct ArrayType: IRType {
  /// The type of elements in this array.
  public let elementType: IRType
  /// The number of elements in this array.
  public let count: Int

  /// Creates an array type from an underlying element type and count.
  /// - note: The context of this type is taken from it's `elementType`
  public init(elementType: IRType, count: Int) {
    self.elementType = elementType
    self.count = count
  }

  /// Creates a constant array value from a list of IR values of a common type.
  ///
  /// - parameter values: A list of IR values of the same type.
  /// - parameter type: The type of the provided IR values.
  ///
  /// - returns: A constant array value containing the given values.
  public static func constant(_ values: [IRValue], type: IRType) -> IRValue {
    var vals = values.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMConstArray(type.asLLVM(), buf.baseAddress, UInt32(buf.count))
    }
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return LLVMArrayType(elementType.asLLVM(), UInt32(count))
  }
}
