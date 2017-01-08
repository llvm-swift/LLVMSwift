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
  
  public func buildAdd(_ lhs: LLVMValue, _ rhs: LLVMValue,
                overflowBehavior: OverflowBehavior = .default,
                name: String = "") -> LLVMValue {
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
  
  public func buildNeg(_ value: LLVMValue,
                overflowBehavior: OverflowBehavior = .default,
                name: String = "") -> LLVMValue {
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
  
  public func buildNot(_ val: LLVMValue, name: String = "") -> LLVMValue {
    return LLVMBuildNot(llvm, val.asLLVM(), name)
  }
  
  public func buildSub(_ lhs: LLVMValue, _ rhs: LLVMValue,
                overflowBehavior: OverflowBehavior = .default,
                name: String = "") -> LLVMValue {
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
  
  public func buildMul(_ lhs: LLVMValue, _ rhs: LLVMValue,
                overflowBehavior: OverflowBehavior = .default,
                name: String = "") -> LLVMValue {
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
  
  public func buildXor(_ lhs: LLVMValue, _ rhs: LLVMValue, name: String = "") -> LLVMValue {
    return LLVMBuildXor(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }
  
  public func buildOr(_ lhs: LLVMValue, _ rhs: LLVMValue, name: String = "") -> LLVMValue {
    return LLVMBuildOr(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }
  
  public func buildAnd(_ lhs: LLVMValue, _ rhs: LLVMValue, name: String = "") -> LLVMValue {
    return LLVMBuildAnd(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }
  
  public func buildShl(_ lhs: LLVMValue, _ rhs: LLVMValue,
                name: String = "") -> LLVMValue {
    return LLVMBuildShl(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }
  
  public func buildShr(_ lhs: LLVMValue, _ rhs: LLVMValue,
                 isArithmetic: Bool = false,
                 name: String = "") -> LLVMValue {
    if isArithmetic {
      return LLVMBuildAShr(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
    } else {
      return LLVMBuildLShr(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
    }
  }
  
  public func buildRem(_ lhs: LLVMValue, _ rhs: LLVMValue,
                signed: Bool = true,
                name: String = "") -> LLVMValue {
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
  
  public func buildDiv(_ lhs: LLVMValue, _ rhs: LLVMValue,
                signed: Bool = true, name: String = "") -> LLVMValue {
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
  
  public func buildICmp(_ lhs: LLVMValue, _ rhs: LLVMValue,
                 _ predicate: IntPredicate,
                 name: String = "") -> LLVMValue {
    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    guard lhs.type is IntType else {
      fatalError("Can only build ICMP instruction with int types")
    }
    return LLVMBuildICmp(llvm, predicate.llvm, lhsVal, rhsVal, name)
  }
  
  public func buildFCmp(_ lhs: LLVMValue, _ rhs: LLVMValue,
                 _ predicate: RealPredicate,
                 name: String = "") -> LLVMValue {
    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    guard lhs.type is FloatType else {
      fatalError("Can only build FCMP instruction with float types")
    }
    return LLVMBuildFCmp(llvm, predicate.llvm, lhsVal, rhsVal, name)
  }
  
  public func buildPhi(_ type: LLVMType, name: String = "") -> PhiNode {
    let value = LLVMBuildPhi(llvm, type.asLLVM(), name)!
    return PhiNode(llvm: value)
  }
  
  public func addFunction(_ name: String, type: FunctionType) -> Function {
    return Function(llvm: LLVMAddFunction(module.llvm, name, type.asLLVM()))
  }
  
  public func addGlobal(_ name: String, type: LLVMType) -> Global {
    return Global(llvm: LLVMAddGlobal(module.llvm, type.asLLVM(), name))
  }
  
  public func buildAlloca(type: LLVMType, name: String = "") -> LLVMValue {
    return LLVMBuildAlloca(llvm, type.asLLVM(), name)
  }
  
  @discardableResult
  public func buildBr(_ block: BasicBlock) -> LLVMValue {
    return LLVMBuildBr(llvm, block.llvm)
  }
  
  @discardableResult
  public func buildCondBr(condition: LLVMValue, then: BasicBlock, `else`: BasicBlock) -> LLVMValue {
    return LLVMBuildCondBr(llvm, condition.asLLVM(), then.asLLVM(), `else`.asLLVM())
  }
  
  @discardableResult
  public func buildRet(_ val: LLVMValue) -> LLVMValue {
    return LLVMBuildRet(llvm, val.asLLVM())
  }
  
  @discardableResult
  public func buildRetVoid() -> LLVMValue {
    return LLVMBuildRetVoid(llvm)
  }
  
  @discardableResult
  public func buildUnreachable() -> LLVMValue {
    return LLVMBuildUnreachable(llvm)
  }
  
  @discardableResult
  public func buildCall(_ fn: LLVMValue, args: [LLVMValue], name: String = "") -> LLVMValue {
    var args = args.map { $0.asLLVM() as Optional }
    return args.withUnsafeMutableBufferPointer { buf in
      return LLVMBuildCall(llvm, fn.asLLVM(), buf.baseAddress!, UInt32(buf.count), name)
    }
  }
  
  public func buildSwitch(_ value: LLVMValue, else: BasicBlock, caseCount: Int) -> Switch {
    return Switch(llvm: LLVMBuildSwitch(llvm,
                                        value.asLLVM(),
                                        `else`.asLLVM(),
                                        UInt32(caseCount))!)
  }
  
  public func createStruct(name: String, types: [LLVMType]? = nil, isPacked: Bool = false) -> StructType {
    let named = LLVMStructCreateNamed(module.context.llvm, name)!
    let type = StructType(llvm: named)
    if let types = types {
      type.setBody(types)
    }
    return type
  }
  
  @discardableResult
  public func buildStore(_ val: LLVMValue, to ptr: LLVMValue) -> LLVMValue {
    return LLVMBuildStore(llvm, val.asLLVM(), ptr.asLLVM())
  }
  
  public func buildLoad(_ ptr: LLVMValue, name: String = "") -> LLVMValue {
    return LLVMBuildLoad(llvm, ptr.asLLVM(), name)
  }
  
  public func buildInBoundsGEP(_ ptr: LLVMValue, indices: [LLVMValue], name: String = "") -> LLVMValue {
    var vals = indices.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMBuildInBoundsGEP(llvm, ptr.asLLVM(), buf.baseAddress, UInt32(buf.count), name)
    }
  }
  
  public func buildGEP(_ ptr: LLVMValue, indices: [LLVMValue], name: String = "") -> LLVMValue {
    var vals = indices.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMBuildGEP(llvm, ptr.asLLVM(), buf.baseAddress, UInt32(buf.count), name)
    }
  }
  
  public func buildStructGEP(_ ptr: LLVMValue, index: Int, name: String = "") -> LLVMValue {
      return LLVMBuildStructGEP(llvm, ptr.asLLVM(), UInt32(index), name)
  }
  
  public func buildIsNull(_ val: LLVMValue, name: String = "") -> LLVMValue {
    return LLVMBuildIsNull(llvm, val.asLLVM(), name)
  }
  
  public func buildIsNotNull(_ val: LLVMValue, name: String = "") -> LLVMValue {
    return LLVMBuildIsNotNull(llvm, val.asLLVM(), name)
  }
  
  public func buildTruncOrBitCast(_ val: LLVMValue, type: LLVMType, name: String = "") -> LLVMValue {
    return LLVMBuildTruncOrBitCast(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildBitCast(_ val: LLVMValue, type: LLVMType, name: String = "") -> LLVMValue {
    return LLVMBuildBitCast(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildSExt(_ val: LLVMValue, type: LLVMType, name: String = "") -> LLVMValue {
    return LLVMBuildSExt(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildZExt(_ val: LLVMValue, type: LLVMType, name: String = "") -> LLVMValue {
    return LLVMBuildZExt(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildTrunc(_ val: LLVMValue, type: LLVMType, name: String = "") -> LLVMValue {
    return LLVMBuildTrunc(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildIntToPtr(_ val: LLVMValue, type: PointerType, name: String = "") -> LLVMValue {
    return LLVMBuildIntToPtr(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildPtrToInt(_ val: LLVMValue, type: IntType, name: String = "") -> LLVMValue {
    return LLVMBuildIntToPtr(llvm, val.asLLVM(), type.asLLVM(), name)
  }
  
  public func buildIntToFP(_ val: LLVMValue, type: FloatType, signed: Bool, name: String = "") -> LLVMValue {
    if signed {
      return LLVMBuildSIToFP(llvm, val.asLLVM(), type.asLLVM(), name)
    } else {
      return LLVMBuildUIToFP(llvm, val.asLLVM(), type.asLLVM(), name)
    }
  }
  
  public func buildFPToInt(_ val: LLVMValue, type: IntType, signed: Bool, name: String = "") -> LLVMValue {
    if signed {
      return LLVMBuildFPToSI(llvm, val.asLLVM(), type.asLLVM(), name)
    } else {
      return LLVMBuildFPToUI(llvm, val.asLLVM(), type.asLLVM(), name)
    }
  }
  
  public func buildSizeOf(_ val: LLVMType) -> LLVMValue {
    return LLVMSizeOf(val.asLLVM())
  }
  
  public func buildInsertValue(aggregate: LLVMValue, element: LLVMValue, index: Int, name: String = "") -> LLVMValue {
    return LLVMBuildInsertValue(llvm, aggregate.asLLVM(), element.asLLVM(), UInt32(index), name)
  }
  
  public func buildInsertElement(vector: LLVMValue, element: LLVMValue, index: LLVMValue, name: String = "") -> LLVMValue {
    return LLVMBuildInsertElement(llvm, vector.asLLVM(), element.asLLVM(), index.asLLVM(), name)
  }
  
  public func buildGlobalString(_ string: String, name: String = "") -> LLVMValue {
    return LLVMBuildGlobalString(llvm, string, name)
  }
  
  public func buildGlobalStringPtr(_ string: String, name: String = "") -> LLVMValue {
    return LLVMBuildGlobalStringPtr(llvm, string, name)
  }
  
  public func positionAtEnd(of block: BasicBlock) {
    LLVMPositionBuilderAtEnd(llvm, block.llvm)
  }
  
  public func positionBefore(_ inst: LLVMValue) {
    LLVMPositionBuilderBefore(llvm, inst.asLLVM())
  }
  
  public func position(_ inst: LLVMValue, block: BasicBlock) {
    LLVMPositionBuilder(llvm, block.llvm, inst.asLLVM())
  }
  
  public func insert(_ inst: LLVMValue, name: String? = nil) {
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
