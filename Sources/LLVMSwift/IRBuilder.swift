import cllvm

public enum OverflowBehavior {
  case `default`, noSignedWrap, noUnsignedWrap
}

public enum IntPredicate {
  case eq, ne, ugt, uge, ult, ule, sgt, sge, slt, sle
  static let predicateMapping: [IntPredicate: LLVMIntPredicate] = [
    .eq: LLVMIntEQ, .ne: LLVMIntNE, .ugt: LLVMIntUGT, .uge: LLVMIntUGE,
    .ult: LLVMIntULT, .ule: LLVMIntULE, .sgt: LLVMIntSGT, .sge: LLVMIntSGE,
    .slt: LLVMIntSLT, .sle: LLVMIntSLE
  ]
  public var llvm: LLVMIntPredicate {
    return IntPredicate.predicateMapping[self]!
  }
}

public enum RealPredicate {
  case `false`, oeq, ogt, oge, olt, ole, one, ord, uno, ueq, ugt, uge, ult, ule
  case une, `true`
  
  static let predicateMapping: [RealPredicate: LLVMRealPredicate] = [
    .false: LLVMRealPredicateFalse, .oeq: LLVMRealOEQ, .ogt: LLVMRealOGT,
    .oge: LLVMRealOGE, .olt: LLVMRealOLT, .ole: LLVMRealOLE,
    .one: LLVMRealONE, .ord: LLVMRealORD, .uno: LLVMRealUNO,
    .ueq: LLVMRealUEQ, .ugt: LLVMRealUGT, .uge: LLVMRealUGE,
    .ult: LLVMRealULT, .ule: LLVMRealULE, .une: LLVMRealUNE,
    .true: LLVMRealPredicateTrue,
  ]
  
  public var llvm: LLVMRealPredicate {
    return RealPredicate.predicateMapping[self]!
  }
}

public class IRBuilder {
  internal let llvm: LLVMBuilderRef
  public let module: Module
  
  public init(module: Module) {
    self.module = module
    self.llvm = LLVMCreateBuilderInContext(module.context.llvm)
  }
  
  public var insertBlock: BasicBlock? {
    guard let blockRef = LLVMGetInsertBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }
  
  public func buildAdd(_ lhs: IRValue, _ rhs: IRValue,
                overflowBehavior: OverflowBehavior = .default,
                name: String = "") -> IRValue {
    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    if lhs.type is IntType {
      switch overflowBehavior {
      case .noSignedWrap:
        return LLVMBuildNSWAdd(llvm, lhsVal, rhsVal, name)
      case .noUnsignedWrap:
        return LLVMBuildNUWAdd(llvm, lhsVal, rhsVal, name)
      case .default:
        return LLVMBuildAdd(llvm, lhsVal, rhsVal, name)
      }
    } else if lhs.type is FloatType {
      return LLVMBuildFAdd(llvm, lhsVal, rhsVal, name)
    }
    fatalError("Can only add value of int, float, or vector types")
  }
  
  public func buildNeg(_ value: IRValue,
                overflowBehavior: OverflowBehavior = .default,
                name: String = "") -> IRValue {
    let val = value.asLLVM()
    if value.type is IntType {
      switch overflowBehavior {
      case .noSignedWrap:
        return LLVMBuildNSWNeg(llvm, val, name)
      case .noUnsignedWrap:
        return LLVMBuildNUWNeg(llvm, val, name)
      case .default:
        return LLVMBuildNeg(llvm, val, name)
      }
    } else if value.type is FloatType {
      return LLVMBuildFNeg(llvm, val, name)
    }
    fatalError("Can only negate value of int or float types")
  }
  
  public func buildNot(_ val: IRValue, name: String = "") -> IRValue {
    return LLVMBuildNot(llvm, val.asLLVM(), name)
  }
  
  public func buildSub(_ lhs: IRValue, _ rhs: IRValue,
                overflowBehavior: OverflowBehavior = .default,
                name: String = "") -> IRValue {
    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    if lhs.type is IntType {
      switch overflowBehavior {
      case .noSignedWrap:
        return LLVMBuildNSWSub(llvm, lhsVal, rhsVal, name)
      case .noUnsignedWrap:
        return LLVMBuildNSWSub(llvm, lhsVal, rhsVal, name)
      case .default:
        return LLVMBuildSub(llvm, lhsVal, rhsVal, name)
      }
    } else if lhs.type is FloatType {
      return LLVMBuildFSub(llvm, lhsVal, rhsVal, name)
    }
    fatalError("Can only subtract value of int or float types")
  }
  
  public func buildMul(_ lhs: IRValue, _ rhs: IRValue,
                overflowBehavior: OverflowBehavior = .default,
                name: String = "") -> IRValue {
    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    if lhs.type is IntType {
      switch overflowBehavior {
      case .noSignedWrap:
        return LLVMBuildNSWMul(llvm, lhsVal, rhsVal, name)
      case .noUnsignedWrap:
        return LLVMBuildNUWMul(llvm, lhsVal, rhsVal, name)
      case .default:
        return LLVMBuildMul(llvm, lhsVal, rhsVal, name)
      }
    } else if lhs.type is FloatType {
      return LLVMBuildFMul(llvm, lhsVal, rhsVal, name)
    }
    fatalError("Can only multiply value of int or float types")
  }
  
  public func buildXor(_ lhs: IRValue, _ rhs: IRValue, name: String = "") -> IRValue {
    return LLVMBuildXor(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }
  
  public func buildOr(_ lhs: IRValue, _ rhs: IRValue, name: String = "") -> IRValue {
    return LLVMBuildOr(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }
  
  public func buildAnd(_ lhs: IRValue, _ rhs: IRValue, name: String = "") -> IRValue {
    return LLVMBuildAnd(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }
  
  public func buildShl(_ lhs: IRValue, _ rhs: IRValue,
                name: String = "") -> IRValue {
    return LLVMBuildShl(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }
  
  public func buildShr(_ lhs: IRValue, _ rhs: IRValue,
                 isArithmetic: Bool = false,
                 name: String = "") -> IRValue {
    if isArithmetic {
      return LLVMBuildAShr(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
    } else {
      return LLVMBuildLShr(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
    }
  }
  
  public func buildRem(_ lhs: IRValue, _ rhs: IRValue,
                signed: Bool = true,
                name: String = "") -> IRValue {
    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    if lhs.type is IntType {
      if signed {
        return LLVMBuildSRem(llvm, lhsVal, rhsVal, name)
      } else {
        return LLVMBuildURem(llvm, lhsVal, rhsVal, name)
      }
    } else if lhs.type is FloatType {
      return LLVMBuildFRem(llvm, lhsVal, rhsVal, name)
    }
    fatalError("Can only take remainder of int or float types")
  }
  
  public func buildDiv(_ lhs: IRValue, _ rhs: IRValue,
                signed: Bool = true, name: String = "") -> IRValue {
    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    if lhs.type is IntType {
      if signed {
        return LLVMBuildSDiv(llvm, lhsVal, rhsVal, name)
      } else {
        return LLVMBuildUDiv(llvm, lhsVal, rhsVal, name)
      }
    } else if lhs.type is FloatType {
      return LLVMBuildFDiv(llvm, lhsVal, rhsVal, name)
    }
    fatalError("Can only divide values of int or float types")
  }
  
  public func buildICmp(_ lhs: IRValue, _ rhs: IRValue,
                 _ predicate: IntPredicate,
                 name: String = "") -> IRValue {
    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    guard lhs.type is IntType else {
      fatalError("Can only build ICMP instruction with int types")
    }
    return LLVMBuildICmp(llvm, predicate.llvm, lhsVal, rhsVal, name)
  }
  
  public func buildFCmp(_ lhs: IRValue, _ rhs: IRValue,
                 _ predicate: RealPredicate,
                 name: String = "") -> IRValue {
    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    guard lhs.type is FloatType else {
      fatalError("Can only build FCMP instruction with float types")
    }
    return LLVMBuildFCmp(llvm, predicate.llvm, lhsVal, rhsVal, name)
  }
  
  public func buildPhi(_ type: IRType, name: String = "") -> PhiNode {
    let value = LLVMBuildPhi(llvm, type.asLLVM(), name)!
    return PhiNode(llvm: value)
  }
  
  public func addFunction(_ name: String, type: FunctionType) -> Function {
    return Function(llvm: LLVMAddFunction(module.llvm, name, type.asLLVM()))
  }
  
  public func addGlobal(_ name: String, type: IRType) -> Global {
    return Global(llvm: LLVMAddGlobal(module.llvm, type.asLLVM(), name))
  }
    
  public func addGlobalString(name: String, value: String) -> Global {
    let length = value.utf8.count
    
    var global = addGlobal(name, type:
      ArrayType(elementType: IntType.int8, count: length + 1))
    
    global.alignment = 1
    global.initializer = value
    
    return global
  }
  
  public func buildAlloca(type: IRType, name: String = "") -> IRValue {
    return LLVMBuildAlloca(llvm, type.asLLVM(), name)
  }
  
  @discardableResult
  public func buildBr(_ block: BasicBlock) -> IRValue {
    return LLVMBuildBr(llvm, block.llvm)
  }
  
  @discardableResult
  public func buildCondBr(condition: IRValue, then: BasicBlock, `else`: BasicBlock) -> IRValue {
    return LLVMBuildCondBr(llvm, condition.asLLVM(), then.asLLVM(), `else`.asLLVM())
  }
  
  @discardableResult
  public func buildRet(_ val: IRValue) -> IRValue {
    return LLVMBuildRet(llvm, val.asLLVM())
  }
  
  @discardableResult
  public func buildRetVoid() -> IRValue {
    return LLVMBuildRetVoid(llvm)
  }
  
  @discardableResult
  public func buildUnreachable() -> IRValue {
    return LLVMBuildUnreachable(llvm)
  }
  
  @discardableResult
  public func buildCall(_ fn: IRValue, args: [IRValue], name: String = "") -> IRValue {
    var args = args.map { $0.asLLVM() as Optional }
    return args.withUnsafeMutableBufferPointer { buf in
      return LLVMBuildCall(llvm, fn.asLLVM(), buf.baseAddress!, UInt32(buf.count), name)
    }
  }
  
  public func buildSwitch(_ value: IRValue, else: BasicBlock, caseCount: Int) -> Switch {
    return Switch(llvm: LLVMBuildSwitch(llvm,
                                        value.asLLVM(),
                                        `else`.asLLVM(),
                                        UInt32(caseCount))!)
  }
  
  public func createStruct(name: String, types: [IRType]? = nil, isPacked: Bool = false) -> StructType {
    let named = LLVMStructCreateNamed(module.context.llvm, name)!
    let type = StructType(llvm: named)
    if let types = types {
      type.setBody(types)
    }
    return type
  }
  
  @discardableResult
  public func buildStore(_ val: IRValue, to ptr: IRValue) -> IRValue {
    return LLVMBuildStore(llvm, val.asLLVM(), ptr.asLLVM())
  }
  
  public func buildLoad(_ ptr: IRValue, name: String = "") -> IRValue {
    return LLVMBuildLoad(llvm, ptr.asLLVM(), name)
  }
  
  public func buildInBoundsGEP(_ ptr: IRValue, indices: [IRValue], name: String = "") -> IRValue {
    var vals = indices.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMBuildInBoundsGEP(llvm, ptr.asLLVM(), buf.baseAddress, UInt32(buf.count), name)
    }
  }
  
  public func buildGEP(_ ptr: IRValue, indices: [IRValue], name: String = "") -> IRValue {
    var vals = indices.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMBuildGEP(llvm, ptr.asLLVM(), buf.baseAddress, UInt32(buf.count), name)
    }
  }
  
  public func buildStructGEP(_ ptr: IRValue, index: Int, name: String = "") -> IRValue {
      return LLVMBuildStructGEP(llvm, ptr.asLLVM(), UInt32(index), name)
  }
  
  public func buildIsNull(_ val: IRValue, name: String = "") -> IRValue {
    return LLVMBuildIsNull(llvm, val.asLLVM(), name)
  }
  
  public func buildIsNotNull(_ val: IRValue, name: String = "") -> IRValue {
    return LLVMBuildIsNotNull(llvm, val.asLLVM(), name)
  }
  
  public func buildTruncOrBitCast(_ val: IRValue, type: IRType, name: String = "") -> IRValue {
    return LLVMBuildTruncOrBitCast(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildBitCast(_ val: IRValue, type: IRType, name: String = "") -> IRValue {
    return LLVMBuildBitCast(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildSExt(_ val: IRValue, type: IRType, name: String = "") -> IRValue {
    return LLVMBuildSExt(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildZExt(_ val: IRValue, type: IRType, name: String = "") -> IRValue {
    return LLVMBuildZExt(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildTrunc(_ val: IRValue, type: IRType, name: String = "") -> IRValue {
    return LLVMBuildTrunc(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildIntToPtr(_ val: IRValue, type: PointerType, name: String = "") -> IRValue {
    return LLVMBuildIntToPtr(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildPtrToInt(_ val: IRValue, type: IntType, name: String = "") -> IRValue {
    return LLVMBuildIntToPtr(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildIntToFP(_ val: IRValue, type: FloatType, signed: Bool, name: String = "") -> IRValue {
    if signed {
      return LLVMBuildSIToFP(llvm, val.asLLVM(), type.asLLVM(), name)
    } else {
      return LLVMBuildUIToFP(llvm, val.asLLVM(), type.asLLVM(), name)
    }
  }
  
  public func buildFPToInt(_ val: IRValue, type: IntType, signed: Bool, name: String = "") -> IRValue {
    if signed {
      return LLVMBuildFPToSI(llvm, val.asLLVM(), type.asLLVM(), name)
    } else {
      return LLVMBuildFPToUI(llvm, val.asLLVM(), type.asLLVM(), name)
    }
  }
  
  public func buildSizeOf(_ val: IRType) -> IRValue {
    return LLVMSizeOf(val.asLLVM())
  }
  
  public func buildInsertValue(aggregate: IRValue, element: IRValue, index: Int, name: String = "") -> IRValue {
    return LLVMBuildInsertValue(llvm, aggregate.asLLVM(), element.asLLVM(), UInt32(index), name)
  }
  
  public func buildInsertElement(vector: IRValue, element: IRValue, index: IRValue, name: String = "") -> IRValue {
    return LLVMBuildInsertElement(llvm, vector.asLLVM(), element.asLLVM(), index.asLLVM(), name)
  }
  
  public func buildGlobalString(_ string: String, name: String = "") -> IRValue {
    return LLVMBuildGlobalString(llvm, string, name)
  }
  
  public func buildGlobalStringPtr(_ string: String, name: String = "") -> IRValue {
    return LLVMBuildGlobalStringPtr(llvm, string, name)
  }
  
  public func positionAtEnd(of block: BasicBlock) {
    LLVMPositionBuilderAtEnd(llvm, block.llvm)
  }
  
  public func positionBefore(_ inst: IRValue) {
    LLVMPositionBuilderBefore(llvm, inst.asLLVM())
  }
  
  public func position(_ inst: IRValue, block: BasicBlock) {
    LLVMPositionBuilder(llvm, block.llvm, inst.asLLVM())
  }
  
  public func insert(_ inst: IRValue, name: String? = nil) {
    if let name = name {
      LLVMInsertIntoBuilderWithName(llvm, inst.asLLVM(), name)
    } else {
      LLVMInsertIntoBuilder(llvm, inst.asLLVM())
    }
  }
  
  public func clearInsertionPosition() {
    LLVMClearInsertionPosition(llvm)
  }
}
