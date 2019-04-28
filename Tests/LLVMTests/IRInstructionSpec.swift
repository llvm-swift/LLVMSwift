import LLVM
import XCTest
import FileCheck
import Foundation
import cllvm

class IRInstructionSpec : XCTestCase {
  func testInstructionOpCodes() {
    // N.B. This module does not have to be well-formed.
    let module = Module(name: "IRInstructionTest")
    let builder = IRBuilder(module: module)

    let structTy = StructType(elementTypes: [
      IntType.int32
    ])
    let global = module.addGlobal("type_info", type: structTy)

    let f = module.addFunction("test",
                               type: FunctionType([
                                  IntType.int1,
                                  FloatType.float,
                                  PointerType.toVoid,
                                  structTy,
                                  VectorType(elementType: IntType.int32, count: 42),
                               ], VoidType()))
    let entry = f.appendBasicBlock(named: "entry")
    let landing = f.appendBasicBlock(named: "landing")
    builder.positionAtEnd(of: landing)
    let land = builder.buildLandingPad(returning: VoidType(), clauses: [
      LandingPadClause.catch(global)
    ])
    builder.buildRet(land)
    
    builder.positionAtEnd(of: entry)

    // Use parameter values to guaranteed constant folding is off.
    let ival = f.parameters[0]
    let fval = f.parameters[1]
    let pval = f.parameters[2]
    let sval = f.parameters[3]
    let vval = f.parameters[4]
    for op in OpCode.Binary.allCases {
      let opVal = builder.buildBinaryOperation(op, ival, ival) as! IRInstruction
      XCTAssertTrue(opVal.isAInstruction)
      XCTAssertEqual(opVal.opCode, opVal.opCode)
    }

    for op in OpCode.Cast.allCases {
      let opVal = builder.buildCast(op, value: fval, type: PointerType.toVoid) as! IRInstruction
      XCTAssertTrue(opVal.isAInstruction)
      XCTAssertEqual(opVal.opCode, opVal.opCode)
    }

    XCTAssertEqual((builder.buildPointerCast(of: pval, to: PointerType(pointee: IntType.int1)) as! IRInstruction).opCode, OpCode.bitCast)
    XCTAssertEqual((builder.buildIntCast(of: ival, to: IntType.int32, signed: false) as! IRInstruction).opCode, OpCode.zext)
    XCTAssertEqual((builder.buildIntCast(of: ival, to: IntType.int32, signed: true) as! IRInstruction).opCode, OpCode.sext)
    XCTAssertEqual((builder.buildNeg(ival) as! IRInstruction).opCode, OpCode.sub)
    XCTAssertEqual((builder.buildAdd(ival, ival) as! IRInstruction).opCode, OpCode.add)
    XCTAssertEqual((builder.buildSub(ival, ival) as! IRInstruction).opCode, OpCode.sub)
    XCTAssertEqual((builder.buildAdd(fval, fval) as! IRInstruction).opCode, OpCode.fadd)
    XCTAssertEqual((builder.buildSub(fval, fval) as! IRInstruction).opCode, OpCode.fsub)
    XCTAssertEqual((builder.buildMul(ival, ival) as! IRInstruction).opCode, OpCode.mul)
    XCTAssertEqual((builder.buildRem(ival, ival, signed: false) as! IRInstruction).opCode, OpCode.urem)
    XCTAssertEqual((builder.buildRem(ival, ival, signed: true) as! IRInstruction).opCode, OpCode.srem)
    XCTAssertEqual((builder.buildDiv(ival, ival, signed: false) as! IRInstruction).opCode, OpCode.udiv)
    XCTAssertEqual((builder.buildDiv(ival, ival, signed: true) as! IRInstruction).opCode, OpCode.sdiv)
    XCTAssertEqual((builder.buildICmp(ival, ival, .equal) as! IRInstruction).opCode, OpCode.icmp)
    XCTAssertEqual((builder.buildFCmp(fval, fval, .orderedEqual) as! IRInstruction).opCode, OpCode.fcmp)
    XCTAssertEqual((builder.buildNot(ival) as! IRInstruction).opCode, OpCode.xor)
    XCTAssertEqual((builder.buildXor(ival, ival) as! IRInstruction).opCode, OpCode.xor)
    XCTAssertEqual((builder.buildOr(ival, ival) as! IRInstruction).opCode, OpCode.or)
    XCTAssertEqual((builder.buildAnd(ival, ival) as! IRInstruction).opCode, OpCode.and)
    XCTAssertEqual((builder.buildShl(ival, ival) as! IRInstruction).opCode, OpCode.shl)
    XCTAssertEqual((builder.buildShr(ival, ival, isArithmetic: false) as! IRInstruction).opCode, OpCode.lshr)
    XCTAssertEqual((builder.buildShr(ival, ival, isArithmetic: true) as! IRInstruction).opCode, OpCode.ashr)
    XCTAssertEqual(builder.buildPhi(IntType.int1).opCode, OpCode.phi)
    XCTAssertEqual(builder.buildSelect(ival, then: ival, else: ival).opCode, OpCode.select)
    XCTAssertEqual(builder.buildSwitch(ival, else: entry, caseCount: 0).opCode, OpCode.switch)
    XCTAssertEqual(builder.buildCondBr(condition: ival, then: entry, else: entry).opCode, OpCode.br)
    XCTAssertEqual(builder.buildBr(entry).opCode, OpCode.br)
    XCTAssertEqual(builder.buildIndirectBr(address: f.address(of: entry)!, destinations: []).opCode, OpCode.indirectBr)
    XCTAssertEqual(builder.buildUnreachable().opCode, OpCode.unreachable)
    XCTAssertEqual(builder.buildCall(f, args: [ival, fval, pval]).opCode, OpCode.call)
    XCTAssertEqual(builder.buildInvoke(f, args: [], next: entry, catch: landing).opCode, OpCode.invoke)
    XCTAssertEqual(builder.buildLandingPad(returning: VoidType(), clauses: [
      LandingPadClause.catch(global)
    ]).opCode, OpCode.landingPad)
    XCTAssertEqual((builder.buildResume(ival) as! IRInstruction).opCode, OpCode.resume)
    XCTAssertEqual((builder.buildVAArg(pval, type: PointerType.toVoid) as! IRInstruction).opCode, OpCode.vaArg)
    XCTAssertEqual(builder.buildAlloca(type: IntType.int1).opCode, OpCode.alloca)
    XCTAssertEqual(builder.buildStore(ival, to: pval).opCode, OpCode.store)
    XCTAssertEqual(builder.buildLoad(pval).opCode, OpCode.load)
    XCTAssertEqual((builder.buildInBoundsGEP(pval, indices: []) as! IRInstruction).opCode, OpCode.getElementPtr)
    XCTAssertEqual((builder.buildGEP(pval, indices: []) as! IRInstruction).opCode, OpCode.getElementPtr)
    XCTAssertEqual((builder.buildExtractValue(sval, index: 0) as! IRInstruction).opCode, OpCode.extractValue)
    XCTAssertEqual((builder.buildTrunc(ival, type: IntType.int32) as! IRInstruction).opCode, OpCode.trunc)
    XCTAssertEqual((builder.buildSExt(ival, type: IntType.int32) as! IRInstruction).opCode, OpCode.sext)
    XCTAssertEqual((builder.buildZExt(ival, type: IntType.int32) as! IRInstruction).opCode, OpCode.zext)
    XCTAssertEqual((builder.buildIntToPtr(ival, type: PointerType.toVoid) as! IRInstruction).opCode, OpCode.intToPtr)
    XCTAssertEqual((builder.buildPtrToInt(pval, type: IntType.int32) as! IRInstruction).opCode, OpCode.ptrToInt)
    XCTAssertEqual(builder.buildFence(ordering: .acquire).opCode, OpCode.fence)
    XCTAssertEqual((builder.buildAtomicCmpXchg(ptr: pval, of: ival, to: ival, successOrdering: .acquire, failureOrdering: .acquire) as! IRInstruction).opCode, OpCode.atomicCmpXchg)
    XCTAssertEqual((builder.buildAtomicRMW(atomicOp: .add, ptr: pval, value: ival, ordering: .acquire) as! IRInstruction).opCode, OpCode.atomicRMW)
    XCTAssertEqual(builder.buildMalloc(IntType.int64).opCode, OpCode.bitCast) // malloc-bitcast pair
    XCTAssertEqual(builder.buildFree(pval).opCode, OpCode.call)
    XCTAssertEqual(builder.buildMemset(to: pval, of: ival, length: 1, alignment: .one).opCode, OpCode.call)
    XCTAssertEqual(builder.buildMemCpy(to: pval, .one, from: pval, .one, length: 1).opCode, OpCode.call)
    XCTAssertEqual(builder.buildMemMove(to: pval, .one, from: pval, .one, length: 1).opCode, OpCode.call)
    XCTAssertEqual((builder.buildInsertValue(aggregate: sval, element: ival, index: 0) as! IRInstruction).opCode, OpCode.insertValue)
    XCTAssertEqual((builder.buildExtractValue(sval, index: 0) as! IRInstruction).opCode, OpCode.extractValue)
    XCTAssertEqual((builder.buildInsertElement(vector: vval, element: 0, index: 0) as! IRInstruction).opCode, OpCode.insertElement)
    XCTAssertEqual((builder.buildExtractElement(vector: vval, index: 0) as! IRInstruction).opCode, OpCode.extractElement)
    let mask = VectorType(elementType: IntType.int32, count: 1).undef()
    XCTAssertEqual((builder.buildShuffleVector(vval, and: ival, mask: mask) as! IRInstruction).opCode, OpCode.shuffleVector)
    XCTAssertEqual(builder.buildRetVoid().opCode, OpCode.ret)
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testInstructionOpCodes", testInstructionOpCodes),
  ])
  #endif
}
