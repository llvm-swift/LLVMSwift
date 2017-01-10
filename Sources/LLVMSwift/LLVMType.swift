import cllvm

/// An `IRType` is a type that is capable of lowering itself to an `LLVMTypeRef`
/// object for use with LLVM's C API.
public protocol IRType {
  /// Retrieves the underlying LLVM type object.
  func asLLVM() -> LLVMTypeRef
}

public extension IRType {
  /// Returns the special `null` value for this type.
  public func null() -> IRValue {
    return LLVMConstNull(asLLVM())
  }

  /// Returns the special LLVM `undef` value for this type.
  ///
  /// The `undef` value can be used anywhere a constant is expected, and
  /// indicates that the user of the value may receive an unspecified 
  /// bit-pattern.
  public func undef() -> IRValue {
    return LLVMGetUndef(asLLVM())
  }

  /// Returns the special LLVM constant `null` pointer value for this type
  /// initialized to `null`.
  public func constPointerNull() -> IRValue {
    return LLVMConstPointerNull(asLLVM())
  }

  /// Dumps a representation of this type to stderr.
  public func dump() {
    LLVMDumpType(asLLVM())
  }
}

internal func convertType(_ type: LLVMTypeRef) -> IRType {
  switch LLVMGetTypeKind(type) {
  case LLVMVoidTypeKind:
    return VoidType()
  case LLVMHalfTypeKind:
    return FloatType.half
  case LLVMFloatTypeKind: return FloatType.float
  case LLVMDoubleTypeKind: return FloatType.double
  case LLVMX86_FP80TypeKind: return FloatType.x86FP80
  case LLVMFP128TypeKind: return FloatType.fp128
  case LLVMPPC_FP128TypeKind: return FloatType.fp128
  case LLVMLabelTypeKind: return LabelType()
  case LLVMIntegerTypeKind:
    let width = LLVMGetIntTypeWidth(type)
    return IntType(width: Int(width))
  case LLVMFunctionTypeKind:
    var params = [IRType]()
    let count = Int(LLVMCountParamTypes(type))
    let paramsPtr = UnsafeMutablePointer<LLVMTypeRef?>.allocate(capacity: count)
    defer { free(paramsPtr) }
    LLVMGetParamTypes(type, paramsPtr)
    for i in 0..<count {
      let ty = paramsPtr[i]!
      params.append(convertType(ty))
    }
    let ret = convertType(LLVMGetReturnType(type))
    let isVarArg = LLVMIsFunctionVarArg(type) != 0
    return FunctionType(argTypes: params, returnType: ret, isVarArg: isVarArg)
  case LLVMStructTypeKind:
    return StructType(llvm: type)
  case LLVMArrayTypeKind:
    let elementType = convertType(LLVMGetElementType(type))
    let count = Int(LLVMGetArrayLength(type))
    return ArrayType(elementType: elementType, count: count)
  case LLVMPointerTypeKind:
    let pointee = convertType(LLVMGetElementType(type))
    let addressSpace = Int(LLVMGetPointerAddressSpace(type))
    return PointerType(pointee: pointee, addressSpace: addressSpace)
  case LLVMVectorTypeKind:
    let elementType = convertType(LLVMGetElementType(type))
    let count = Int(LLVMGetVectorSize(type))
    return VectorType(elementType: elementType, count: count)
  case LLVMMetadataTypeKind:
    return MetadataType(llvm: type)
  case LLVMX86_MMXTypeKind:
    return X86MMXType()
  case LLVMTokenTypeKind:
    return TokenType(llvm: type)
  default: fatalError("unknown type kind for type \(type)")
  }
}

/// The `Void` type represents any value and has no size.
public struct VoidType: IRType {
  /// Creates an instance of the `Void` type.
  public init() {}

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return LLVMVoidType()
  }
}

/// The `IntType` represents an integral value of a specified bit width.
///
/// The `IntType` is a very simple type that simply specifies an arbitrary bit 
/// width for the integer type desired. Any bit width from 1 bit to (2^23)-1 
/// (about 8 million) can be specified.
public struct IntType: IRType {
  /// Retrieves the bit width of this integer type.
  public let width: Int

  /// Creates an integer type with the specified bit width.
  public init(width: Int) { self.width = width }

  /// Retrieves the `i1` type.
  public static let int1 = IntType(width: 1)
  /// Retrieves the `i8` type.
  public static let int8 = IntType(width: 8)
  /// Retrieves the `i16` type.
  public static let int16 = IntType(width: 16)
  /// Retrieves the `i32` type.
  public static let int32 = IntType(width: 32)
  /// Retrieves the `i64` type.
  public static let int64 = IntType(width: 64)
  /// Retrieves the `i128` type.
  public static let int128 = IntType(width: 128)

  /// Retrieves an integer value of this type's bit width consisting of all 
  /// zero-bits.
  ///
  /// - returns: A value consisting of all zero-bits of this type's bit width.
  public func zero() -> IRValue {
    return null()
  }

  /// Creates an integer constant value with the given Swift integer value.
  ///
  /// - parameter value: A Swift integer value.
  /// - parameter signExtend: Whether to sign-extend this value to fit this
  ///   type's bit width.  Defaults to `false`.
  public func constant<IntTy: Integer>(_ value: IntTy, signExtend: Bool = false) -> IRValue {
    return LLVMConstInt(asLLVM(),
                        unsafeBitCast(value.toIntMax(), to: UInt64.self),
                        signExtend.llvm)
  }

  /// Retrieves an integer value of this type's bit width consisting of all
  /// one-bits.
  ///
  /// - returns: A value consisting of all one-bits of this type's bit width.
  public func allOnes() -> IRValue {
    return LLVMConstAllOnes(asLLVM())
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return LLVMIntType(UInt32(width))
  }
}

/// `ArrayType` is a very simple derived type that arranges elements 
/// sequentially in memory. `ArrayType` requires a size (number of elements) and
/// an underlying data type.
public struct ArrayType: IRType {
  /// The type of elements in this array.
  public let elementType: IRType
  /// The number of elements in this array.
  public let count: Int

  /// Creates an array type from an underlying element type and count.
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

/// The `MetadataType` type represents embedded metadata. No derived types may 
/// be created from metadata except for function arguments.
public struct MetadataType: IRType {
  internal let llvm: LLVMTypeRef

  /// Creates an embedded metadata type for the given LLVM type object.
  public init(llvm: LLVMTypeRef) {
    self.llvm = llvm
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}

/// `LabelType` represents code labels.
public struct LabelType: IRType {
  /// Creates a code label.
  public init() {}

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return LLVMLabelType()
  }
}


/// `FloatType` enumerates representations of a floating value of a particular 
// bit width and semantics.
public enum FloatType: IRType {
  /// 16-bit floating point value
  case half
  /// 32-bit floating point value
  case float
  /// 64-bit floating point value
  case double
  /// 80-bit floating point value (X87)
  case x86FP80
  /// 128-bit floating point value (112-bit mantissa)
  case fp128
  /// 128-bit floating point value (two 64-bits)
  case ppcFP128

  /// Creates a constant floating value of this type from a Swift `Double` value.
  public func constant(_ value: Double) -> IRValue {
    return LLVMConstReal(asLLVM(), value)
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    switch self {
    case .half: return LLVMHalfType()
    case .float: return LLVMFloatType()
    case .double: return LLVMDoubleType()
    case .x86FP80: return LLVMX86FP80Type()
    case .fp128: return LLVMFP128Type()
    case .ppcFP128: return LLVMPPCFP128Type()
    }
  }
}

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

/// `StructType` is used to represent a collection of data members together in 
/// memory. The elements of a structure may be any type that has a size.
///
/// Structures in memory are accessed using `load` and `store` by getting a
/// pointer to a field with the ‘getelementptr‘ instruction. Structures in 
/// registers are accessed using the `extractvalue` and `insertvalue` 
/// instructions.
///
/// Structures may optionally be "packed" structures, which indicate that the
/// alignment of the struct is one byte, and that there is no padding between 
/// the elements. In non-packed structs, padding between field types is inserted
/// as defined by the `DataLayout` of the module, which is required to match 
/// what the underlying code generator expects.
///
/// Structures can either be "literal" or "identified". A literal structure is 
/// defined inline with other types (e.g. {i32, i32}*) whereas identified types 
/// are always defined at the top level with a name. Literal types are uniqued 
/// by their contents and can never be recursive or opaque since there is no way
/// to write one. Identified types can be recursive, can be opaqued, and are 
/// never uniqued.
public struct StructType: IRType {
  internal let llvm: LLVMTypeRef

  /// Initializes a structure type from the given LLVM type object.
  public init(llvm: LLVMTypeRef) {
    self.llvm = llvm
  }

  /// Invalidates and resets the member types of this structure.
  ///
  /// - parameter types: A list of types of members of this structure.
  /// - parameter isPacked: Whether or not this structure is 1-byte aligned with
  /// - no packing between fields.  Defaults to `false`.
  public func setBody(_ types: [IRType], isPacked: Bool = false) {
    var _types = types.map { $0.asLLVM() as Optional }
    _types.withUnsafeMutableBufferPointer { buf in
      LLVMStructSetBody(asLLVM(), buf.baseAddress, UInt32(buf.count), isPacked.llvm)
    }
  }

  /// Creates a constant value of this structure type initialized with the given
  /// list of values.
  ///
  /// - parameter values: A list of values of members of this structure.
  /// - parameter isPacked: Whether or not this structure is 1-byte aligned with
  /// - no packing between fields.  Defaults to `false`.
  ///
  /// - returns: A value representing a constant value of this structure type.
  public static func constant(values: [IRValue], isPacked: Bool = false) -> IRValue {
    var vals = values.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMConstStruct(buf.baseAddress, UInt32(buf.count), isPacked.llvm)
    }
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}

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
