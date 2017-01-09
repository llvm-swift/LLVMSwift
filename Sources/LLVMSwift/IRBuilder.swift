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

/// An `IRBuilder` is a helper object that generates LLVM instructions.  IR 
/// Builders keep track of a position within a function or basic block and has
/// methods to insert instructions at that position.
///
///
public class IRBuilder {
  internal let llvm: LLVMBuilderRef
  public let module: Module

  /// Initialize an `IRBuilder` object with the given module.
  public init(module: Module) {
    self.module = module
    self.llvm = LLVMCreateBuilderInContext(module.context.llvm)
  }

  // MARK: IR Navigation

  /// Gets the basic block built instructions will be inserted into.
  public var insertBlock: BasicBlock? {
    guard let blockRef = LLVMGetInsertBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  /// Repositions the IR Builder at the end of the given basic block.
  public func positionAtEnd(of block: BasicBlock) {
    LLVMPositionBuilderAtEnd(llvm, block.llvm)
  }

  /// Repositions the IR Builder before the start of the given instruction.
  public func positionBefore(_ inst: IRValue) {
    LLVMPositionBuilderBefore(llvm, inst.asLLVM())
  }

  /// Repositions the IR Builder at the point specified by the given instruction
  /// in the given basic block.
  public func position(_ inst: IRValue, block: BasicBlock) {
    LLVMPositionBuilder(llvm, block.llvm, inst.asLLVM())
  }

  /// Inserts the given instruction into the IR Builder.
  public func insert(_ inst: IRValue, name: String? = nil) {
    if let name = name {
      LLVMInsertIntoBuilderWithName(llvm, inst.asLLVM(), name)
    } else {
      LLVMInsertIntoBuilder(llvm, inst.asLLVM())
    }
  }

  /// Clears the insertion point.
  ///
  /// Subsequent instructions will not be inserted into a block.
  public func clearInsertionPosition() {
    LLVMClearInsertionPosition(llvm)
  }

  // MARK: Arithmetic Instructions

  /// Builds an add instruction with the given values as operands.
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

  // Builds a negation instruction with the given value as an operand.
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

  /// Builds a subtract instruction with the given values as operands.
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

  /// Builds a multiply instruction with the given values as operands.
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

  /// Build a remainder instruction that provides the remainder after divison of
  /// the first value by the second value.
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

  /// Build a division instruction that divides the first value by the second
  /// value.
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

  /// Build an integer comparison between the two provided values using the
  /// given predicate.
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

  /// Build a floating comparison between the two provided values using the
  /// given predicate.
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

  // MARK: Logical Instructions

  /// Builds a logical not with the given value as an operand.
  public func buildNot(_ val: IRValue, name: String = "") -> IRValue {
    return LLVMBuildNot(llvm, val.asLLVM(), name)
  }

  /// Builds a exclusive OR with the given values as operands.
  public func buildXor(_ lhs: IRValue, _ rhs: IRValue, name: String = "") -> IRValue {
    return LLVMBuildXor(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }

  /// Builds a logical OR with the given values as operands.
  public func buildOr(_ lhs: IRValue, _ rhs: IRValue, name: String = "") -> IRValue {
    return LLVMBuildOr(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }

  /// Builds a logical AND with the given values as operands.
  public func buildAnd(_ lhs: IRValue, _ rhs: IRValue, name: String = "") -> IRValue {
    return LLVMBuildAnd(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }

  /// Builds a left-shift instruction of the first value by an amount in the
  /// second value.
  public func buildShl(_ lhs: IRValue, _ rhs: IRValue,
                       name: String = "") -> IRValue {
    return LLVMBuildShl(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
  }

  /// Builds a right-shift instruction of the first value by an amount in the
  /// second value.
  public func buildShr(_ lhs: IRValue, _ rhs: IRValue,
                       isArithmetic: Bool = false,
                       name: String = "") -> IRValue {
    if isArithmetic {
      return LLVMBuildAShr(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
    } else {
      return LLVMBuildLShr(llvm, lhs.asLLVM(), rhs.asLLVM(), name)
    }
  }


  // MARK: Declaration Instructions

  /// Build a phi node with the given type acting as the result of any incoming
  /// basic blocks.
  public func buildPhi(_ type: IRType, name: String = "") -> PhiNode {
    let value = LLVMBuildPhi(llvm, type.asLLVM(), name)!
    return PhiNode(llvm: value)
  }

  /// Build a named function body with the given type.
  public func addFunction(_ name: String, type: FunctionType) -> Function {
    return Function(llvm: LLVMAddFunction(module.llvm, name, type.asLLVM()))
  }

  /// Build a named global of the given type.
  public func addGlobal(_ name: String, type: IRType) -> Global {
    return Global(llvm: LLVMAddGlobal(module.llvm, type.asLLVM(), name))
  }

  /// Build a named global string of the given type.
  public func addGlobalString(name: String, value: String) -> Global {
    let length = value.utf8.count
    
    var global = addGlobal(name, type:
      ArrayType(elementType: IntType.int8, count: length + 1))
    
    global.alignment = 1
    global.initializer = value
    
    return global
  }

  /// Build a branch table that branches on the given value with the given
  /// default basic block.
  public func buildSwitch(_ value: IRValue, else: BasicBlock, caseCount: Int) -> Switch {
    return Switch(llvm: LLVMBuildSwitch(llvm,
                                        value.asLLVM(),
                                        `else`.asLLVM(),
                                        UInt32(caseCount))!)
  }

  /// Build a named structure definition.
  public func createStruct(name: String, types: [IRType]? = nil, isPacked: Bool = false) -> StructType {
    let named = LLVMStructCreateNamed(module.context.llvm, name)!
    let type = StructType(llvm: named)
    if let types = types {
      type.setBody(types)
    }
    return type
  }

  // MARK: Terminator Instructions

  /// Build an `alloca` to allocate stack memory to hold a value of the given
  /// type.
  public func buildAlloca(type: IRType, name: String = "") -> IRValue {
    return LLVMBuildAlloca(llvm, type.asLLVM(), name)
  }

  /// Build an unconditional branch to the given basic block.
  @discardableResult
  public func buildBr(_ block: BasicBlock) -> IRValue {
    return LLVMBuildBr(llvm, block.llvm)
  }

  /// Build a condition branch that branches to the first basic block if the 
  /// provided condition is `true`, otherwise to the second basic block.
  @discardableResult
  public func buildCondBr(condition: IRValue, then: BasicBlock, `else`: BasicBlock) -> IRValue {
    return LLVMBuildCondBr(llvm, condition.asLLVM(), then.asLLVM(), `else`.asLLVM())
  }

  /// Builds a return from the current function with the given value.
  @discardableResult
  public func buildRet(_ val: IRValue) -> IRValue {
    return LLVMBuildRet(llvm, val.asLLVM())
  }

  /// Builds a void return from the current function.
  @discardableResult
  public func buildRetVoid() -> IRValue {
    return LLVMBuildRetVoid(llvm)
  }

  /// Builds an unreachable instruction in the current function.
  @discardableResult
  public func buildUnreachable() -> IRValue {
    return LLVMBuildUnreachable(llvm)
  }

  /// Build a call to the given function with the given arguments.
  @discardableResult
  public func buildCall(_ fn: IRValue, args: [IRValue], name: String = "") -> IRValue {
    var args = args.map { $0.asLLVM() as Optional }
    return args.withUnsafeMutableBufferPointer { buf in
      return LLVMBuildCall(llvm, fn.asLLVM(), buf.baseAddress!, UInt32(buf.count), name)
    }
  }

  // MARK: Memory Access Instructions

  /// Build a store instruction that stores the first value into the location
  /// given in the second value.
  @discardableResult
  public func buildStore(_ val: IRValue, to ptr: IRValue) -> IRValue {
    return LLVMBuildStore(llvm, val.asLLVM(), ptr.asLLVM())
  }

  /// Builds a load instruction that loads a value from the location in the
  /// given value.
  public func buildLoad(_ ptr: IRValue, name: String = "") -> IRValue {
    return LLVMBuildLoad(llvm, ptr.asLLVM(), name)
  }

  /// Builds a GEP (Get Element Pointer) instruction with a resultant value that
  /// is undefined if the address is outside the actual underlying allocated 
  /// object and not the address one-past-the-end.
  public func buildInBoundsGEP(_ ptr: IRValue, indices: [IRValue], name: String = "") -> IRValue {
    var vals = indices.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMBuildInBoundsGEP(llvm, ptr.asLLVM(), buf.baseAddress, UInt32(buf.count), name)
    }
  }

  /// Builds a GEP (Get Element Pointer) instruction.
  public func buildGEP(_ ptr: IRValue, indices: [IRValue], name: String = "") -> IRValue {
    var vals = indices.map { $0.asLLVM() as Optional }
    return vals.withUnsafeMutableBufferPointer { buf in
      return LLVMBuildGEP(llvm, ptr.asLLVM(), buf.baseAddress, UInt32(buf.count), name)
    }
  }

  /// Builds a GEP (Get Element Pointer) instruction suitable for indexing into
  /// a struct.
  public func buildStructGEP(_ ptr: IRValue, index: Int, name: String = "") -> IRValue {
      return LLVMBuildStructGEP(llvm, ptr.asLLVM(), UInt32(index), name)
  }

  // MARK: Null Test Instructions

  public func buildIsNull(_ val: IRValue, name: String = "") -> IRValue {
    return LLVMBuildIsNull(llvm, val.asLLVM(), name)
  }
  
  public func buildIsNotNull(_ val: IRValue, name: String = "") -> IRValue {
    return LLVMBuildIsNotNull(llvm, val.asLLVM(), name)
  }

  // MARK: Conversion Instructions
  
  public func buildTruncOrBitCast(_ val: IRValue, type: IRType, name: String = "") -> IRValue {
    return LLVMBuildTruncOrBitCast(llvm, val.asLLVM(), type.asLLVM(), name)
  }

  /// Builds a bitcast instruction to convert the given value to a value of the 
  /// given type by just copying the bit pattern.
  public func buildBitCast(_ val: IRValue, type: IRType, name: String = "") -> IRValue {
    return LLVMBuildBitCast(llvm, val.asLLVM(), type.asLLVM(), name)
  }

  /// Builds a sign extension instruction to sign extend the given value to
  /// the given type with a wider width.
  public func buildSExt(_ val: IRValue, type: IRType, name: String = "") -> IRValue {
    return LLVMBuildSExt(llvm, val.asLLVM(), type.asLLVM(), name)
  }

  /// Builds a zero extension instruction to zero extend the given value to the
  /// given type with a wider width.
  public func buildZExt(_ val: IRValue, type: IRType, name: String = "") -> IRValue {
    return LLVMBuildZExt(llvm, val.asLLVM(), type.asLLVM(), name)
  }

  /// Builds a truncate instruction to truncate the given value to the given
  /// type with a shorter width.
  public func buildTrunc(_ val: IRValue, type: IRType, name: String = "") -> IRValue {
    return LLVMBuildTrunc(llvm, val.asLLVM(), type.asLLVM(), name)
  }

  /// Builds an integer-to-pointer instruction to convert the given value to the
  /// given pointer type.
  public func buildIntToPtr(_ val: IRValue, type: PointerType, name: String = "") -> IRValue {
    return LLVMBuildIntToPtr(llvm, val.asLLVM(), type.asLLVM(), name)
  }

  /// Builds a pointer-to-integer instruction to convert the given pointer value
  /// to the given integer type.
  public func buildPtrToInt(_ val: IRValue, type: IntType, name: String = "") -> IRValue {
    return LLVMBuildIntToPtr(llvm, val.asLLVM(), type.asLLVM(), name)
  }

  /// Builds an integer-to-floating instruction to convert the given integer 
  /// value to the given floating type.
  public func buildIntToFP(_ val: IRValue, type: FloatType, signed: Bool, name: String = "") -> IRValue {
    if signed {
      return LLVMBuildSIToFP(llvm, val.asLLVM(), type.asLLVM(), name)
    } else {
      return LLVMBuildUIToFP(llvm, val.asLLVM(), type.asLLVM(), name)
    }
  }

  /// Builds a floating-to-integer instruction to convert the given floating
  /// value to the given integer type.
  public func buildFPToInt(_ val: IRValue, type: IntType, signed: Bool, name: String = "") -> IRValue {
    if signed {
      return LLVMBuildFPToSI(llvm, val.asLLVM(), type.asLLVM(), name)
    } else {
      return LLVMBuildFPToUI(llvm, val.asLLVM(), type.asLLVM(), name)
    }
  }

  ///
  public func buildSizeOf(_ val: IRType) -> IRValue {
    return LLVMSizeOf(val.asLLVM())
  }

  // MARK: Vector Instructions

  /// Builds an instruction to insert a value <TODO>
  public func buildInsertValue(aggregate: IRValue, element: IRValue, index: Int, name: String = "") -> IRValue {
    return LLVMBuildInsertValue(llvm, aggregate.asLLVM(), element.asLLVM(), UInt32(index), name)
  }

  /// Builds a vector insert instruction to nondestructively insert the given 
  /// value into the given vector.
  public func buildInsertElement(vector: IRValue, element: IRValue, index: IRValue, name: String = "") -> IRValue {
    return LLVMBuildInsertElement(llvm, vector.asLLVM(), element.asLLVM(), index.asLLVM(), name)
  }

  // MARK: Global Variable Creation Instructions

  /// Builds a named global variable containing the characters of the given 
  /// string value.
  public func buildGlobalString(_ string: String, name: String = "") -> IRValue {
    return LLVMBuildGlobalString(llvm, string, name)
  }

  /// Builds a named global variable containing a pointer to the contents of the
  /// given string value.
  public func buildGlobalStringPtr(_ string: String, name: String = "") -> IRValue {
    return LLVMBuildGlobalStringPtr(llvm, string, name)
  }
}
