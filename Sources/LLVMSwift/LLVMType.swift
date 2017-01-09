import cllvm

public protocol IRType {
  func asLLVM() -> LLVMTypeRef
}

public extension IRType {
  public func null() -> IRValue {
    return LLVMConstNull(asLLVM())
  }
  
  public func undef() -> IRValue {
    return LLVMGetUndef(asLLVM())
  }
  
  public func constPointerNull() -> IRValue {
    return LLVMConstPointerNull(asLLVM())
  }
  
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

public struct VoidType: IRType {
  public init() {}
  public func asLLVM() -> LLVMTypeRef {
    return LLVMVoidType()
  }
}

public struct IntType: IRType {
  public let width: Int
  
  public init(width: Int) { self.width = width }
  
  public static let int1 = IntType(width: 1)
  public static let int8 = IntType(width: 8)
  public static let int16 = IntType(width: 16)
  public static let int32 = IntType(width: 32)
  public static let int64 = IntType(width: 64)
  public static let int128 = IntType(width: 128)
  
  public func zero() -> IRValue {
    return null()
  }
  
  public func constant<IntTy: Integer>(_ value: IntTy, signExtend: Bool = false) -> LLVMValueRef {
    return LLVMConstInt(asLLVM(),
                        unsafeBitCast(value.toIntMax(), to: UInt64.self),
                        signExtend.llvm)
  }
  
  public func allOnes() -> IRValue {
    return LLVMConstAllOnes(asLLVM())
  }
  
  public func asLLVM() -> LLVMTypeRef {
    return LLVMIntType(UInt32(width))
  }
}

public struct ArrayType: IRType {
  public let elementType: IRType
  public let count: Int
  
  public init(elementType: IRType, count: Int) {
    self.elementType = elementType
    self.count = count
  }
  
  public static func constant(_ values: [IRValue], type: IRType) -> IRValue {
    var vals = values.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMConstArray(type.asLLVM(), buf.baseAddress, UInt32(buf.count))
    }
  }
  
  public func asLLVM() -> LLVMTypeRef {
    return LLVMArrayType(elementType.asLLVM(), UInt32(count))
  }
}

public struct MetadataType: IRType {
  internal let llvm: LLVMTypeRef
  public init(llvm: LLVMTypeRef) {
    self.llvm = llvm
  }
  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}

public struct LabelType: IRType {
  public init() {}
  public func asLLVM() -> LLVMTypeRef {
    return LLVMLabelType()
  }
}

public enum FloatType: IRType {
  case half, float, double, x86FP80, fp128, ppcFP128
  
  public func constant(_ value: Double) -> IRValue {
    return LLVMConstReal(asLLVM(), value)
  }
  
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

public struct PointerType: IRType {
  public let pointee: IRType
  public let addressSpace: Int
  public init(pointee: IRType, addressSpace: Int = 0) {
    self.pointee = pointee
    self.addressSpace = addressSpace
  }
  
  public static let toVoid = PointerType(pointee: IntType.int8)
  
  public func asLLVM() -> LLVMTypeRef {
    return LLVMPointerType(pointee.asLLVM(), UInt32(addressSpace))
  }
}

public struct FunctionType: IRType {
  public let argTypes: [IRType]
  public let returnType: IRType
  public let isVarArg: Bool
  
  public init(argTypes: [IRType], returnType: IRType, isVarArg: Bool = false) {
    self.argTypes = argTypes
    self.returnType = returnType
    self.isVarArg = isVarArg
  }
  
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

public class StructType: IRType {
  internal let llvm: LLVMTypeRef

  public init(llvm: LLVMTypeRef) {
    self.llvm = llvm
  }

  public init(elementTypes: [IRType], isPacked: Bool = false, llvm: LLVMValueRef? = nil) {
    if let llvm = llvm {
      self.llvm = llvm
    } else {
      var types = elementTypes.map { $0.asLLVM() as Optional }
      self.llvm = types.withUnsafeMutableBufferPointer { buf in
        return LLVMStructType(buf.baseAddress, UInt32(buf.count), isPacked.llvm)
      }
    }
  }

  public func setBody(_ types: [IRType], isPacked: Bool = false) {
    var _types = types.map { $0.asLLVM() as Optional }
    _types.withUnsafeMutableBufferPointer { buf in
      LLVMStructSetBody(asLLVM(), buf.baseAddress, UInt32(buf.count), isPacked.llvm)
    }
  }
  
  public static func constant(values: [IRValue], isPacked: Bool = false) -> IRValue {
    var vals = values.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMConstStruct(buf.baseAddress, UInt32(buf.count), isPacked.llvm)
    }
  }

  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}

public struct X86MMXType: IRType {
  public init() {}
  public func asLLVM() -> LLVMTypeRef {
    return LLVMX86MMXType()
  }
}

public struct TokenType: IRType {
  internal let llvm: LLVMTypeRef
  public init(llvm: LLVMTypeRef) { self.llvm = llvm }
  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}

public struct VectorType: IRType {
  public let elementType: IRType
  public let count: Int
  
  public init(elementType: IRType, count: Int) {
    self.elementType = elementType
    self.count = count
  }

  public func asLLVM() -> LLVMTypeRef {
    return LLVMVectorType(elementType.asLLVM(), UInt32(count))
  }
}
