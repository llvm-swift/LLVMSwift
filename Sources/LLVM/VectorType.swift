#if !NO_SWIFTPM
import cllvm
#endif

/// A `VectorType` is a simple derived type that represents a vector of
/// elements. `VectorType`s are used when multiple primitive data are operated
/// in parallel using a single instruction (SIMD). A vector type requires a size
/// (number of elements) and an underlying primitive data type.
public struct VectorType: IRType {
  /// Returns the type of elements in the vector.
  public let elementType: IRType
  /// Returns the number of elements in the vector.
  public let count: Int

  /// Creates a vector type of the given element type and size.
  ///
  /// - parameter elementType: The type of elements of this vector.
  /// - parameter count: The number of elements in this vector.
  public init(elementType: IRType, count: Int) {
    self.elementType = elementType
    self.count = count
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return LLVMVectorType(elementType.asLLVM(), UInt32(count))
  }
}
