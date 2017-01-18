#if !NO_SWIFTPM
import cllvm
#endif

/// `PointerType` is used to specify memory locations. Pointers are commonly
/// used to reference objects in memory.
///
/// `PointerType` may have an optional address space attribute defining the
/// numbered address space where the pointed-to object resides. The default
/// address space is number zero. The semantics of non-zero address spaces are
/// target-specific.
///
/// Note that LLVM does not permit pointers to void `(void*)` nor does it permit
/// pointers to labels `(label*)`.  Use `i8*` instead.
public struct PointerType: IRType {
  /// Retrieves the type of the value being pointed to.
  public let pointee: IRType
  /// Retrieves the address space where the pointed-to object resides.
  public let addressSpace: Int

  /// Creates a `PointerType` from a pointee type and an optional address space.
  ///
  /// - parameter pointee: The type of the pointed-to object.
  /// - parameter addressSpace: The optional address space where the pointed-to
  ///   object resides.
  public init(pointee: IRType, addressSpace: Int = 0) {
    self.pointee = pointee
    self.addressSpace = addressSpace
  }

  //// Creates a type that simulates a pointer to void `(void*)`.
  public static let toVoid = PointerType(pointee: IntType.int8)

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return LLVMPointerType(pointee.asLLVM(), UInt32(addressSpace))
  }
}
