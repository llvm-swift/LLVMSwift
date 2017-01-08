import cllvm

public protocol LLVMType {
  func asLLVM() -> LLVMTypeRef
}

public extension LLVMType {
  public func null() -> LLVMValue {
    return LLVMConstNull(asLLVM())
  }
  
  public func undef() -> LLVMValue {
    return LLVMGetUndef(asLLVM())
  }
  
  public func constPointerNull() -> LLVMValue {
    return LLVMConstPointerNull(asLLVM())
  }
  
  public func dump() {
    LLVMDumpType(asLLVM())
  }
}

internal func convertType(_ type: LLVMTypeRef) -> LLVMType {
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
    var params = [LLVMType]()
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

public struct VoidType: LLVMType {
  public init() {}
  public func asLLVM() -> LLVMTypeRef {
    return LLVMVoidType()
  }
}

public struct IntType: LLVMType {
  public let width: Int
  
  public init(width: Int) { self.width = width }
  
  public static let int1 = IntType(width: 1)
  public static let int8 = IntType(width: 8)
  public static let int16 = IntType(width: 16)
  public static let int32 = IntType(width: 32)
  public static let int64 = IntType(width: 64)
  public static let int128 = IntType(width: 128)
  
  public func zero() -> LLVMValue {
    return null()
  }
  
  public func constant<IntTy: Integer>(_ value: IntTy, signExtend: Bool = false) -> LLVMValueRef {
    return LLVMConstInt(asLLVM(),
                        unsafeBitCast(value.toIntMax(), to: UInt64.self),
                        signExtend.llvm)
  }
  
  public func allOnes() -> LLVMValue {
    return LLVMConstAllOnes(asLLVM())
  }
  
  public func asLLVM() -> LLVMTypeRef {
    return LLVMIntType(UInt32(width))
  }
}

public struct ArrayType: LLVMType {
  public let elementType: LLVMType
  public let count: Int
  
  public init(elementType: LLVMType, count: Int) {
    self.elementType = elementType
    self.count = count
  }
  
  public static func constant(_ values: [LLVMValue], type: LLVMType) -> LLVMValue {
    var vals = values.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMConstArray(type.asLLVM(), buf.baseAddress, UInt32(buf.count))
    }
  }
  
  public func asLLVM() -> LLVMTypeRef {
    return LLVMArrayType(elementType.asLLVM(), UInt32(count))
  }
}

public struct MetadataType: LLVMType {
  internal let llvm: LLVMTypeRef
  public init(llvm: LLVMTypeRef) {
    self.llvm = llvm
  }
  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}

public struct LabelType: LLVMType {
  public init() {}
  public func asLLVM() -> LLVMTypeRef {
    return LLVMLabelType()
  }
}

public enum FloatType: LLVMType {
  case half, float, double, x86FP80, fp128, ppcFP128
  
  public func constant(_ value: Double) -> LLVMValue {
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

public struct PointerType: LLVMType {
  public let pointee: LLVMType
  public let addressSpace: Int
  public init(pointee: LLVMType, addressSpace: Int = 0) {
    self.pointee = pointee
    self.addressSpace = addressSpace
  }
  
  public static let toVoid = PointerType(pointee: IntType.int8)
  
  public func asLLVM() -> LLVMTypeRef {
    return LLVMPointerType(pointee.asLLVM(), UInt32(addressSpace))
  }
}

public struct FunctionType: LLVMType {
  public let argTypes: [LLVMType]
  public let returnType: LLVMType
  public let isVarArg: Bool
  
  public init(argTypes: [LLVMType], returnType: LLVMType, isVarArg: Bool = false) {
    self.argTypes = argTypes
    self.returnType = returnType
    self.isVarArg = isVarArg
  }
  
  public func asLLVM() -> LLVMTypeRef {
    var argLLVMTypes = argTypes.map { $0.asLLVM() as Optional }
    return argLLVMTypes.withUnsafeMutableBufferPointer { buf in
      return LLVMFunctionType(returnType.asLLVM(),
                              buf.baseAddress,
                              UInt32(buf.count),
                              isVarArg.llvm)!
    }
  }
}

public class StructType: LLVMType {
  internal let llvm: LLVMTypeRef

  public init(llvm: LLVMTypeRef) {
    self.llvm = llvm
  }

  public init(elementTypes: [LLVMType], isPacked: Bool = false, llvm: LLVMValueRef? = nil) {
    if let llvm = llvm {
      self.llvm = llvm
    } else {
      var types = elementTypes.map { $0.asLLVM() as Optional }
      self.llvm = types.withUnsafeMutableBufferPointer { buf in
        return LLVMStructType(buf.baseAddress, UInt32(buf.count), isPacked.llvm)
      }
    }
  }

  public func setBody(_ types: [LLVMType], isPacked: Bool = false) {
    var _types = types.map { $0.asLLVM() as Optional }
    _types.withUnsafeMutableBufferPointer { buf in
      LLVMStructSetBody(asLLVM(), buf.baseAddress, UInt32(buf.count), isPacked.llvm)
    }
  }
  
  public static func constant(values: [LLVMValue], isPacked: Bool = false) -> LLVMValue {
    var vals = values.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMConstStruct(buf.baseAddress, UInt32(buf.count), isPacked.llvm)
    }
  }

  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}

public struct X86MMXType: LLVMType {
  public init() {}
  public func asLLVM() -> LLVMTypeRef {
    return LLVMX86MMXType()
  }
}

public struct TokenType: LLVMType {
  internal let llvm: LLVMTypeRef
  public init(llvm: LLVMTypeRef) { self.llvm = llvm }
  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}

public struct VectorType: LLVMType {
  public let elementType: LLVMType
  public let count: Int
  
  public init(elementType: LLVMType, count: Int) {
    self.elementType = elementType
    self.count = count
  }

  public func asLLVM() -> LLVMTypeRef {
    return LLVMVectorType(elementType.asLLVM(), UInt32(count))
  }
}
