import LLVM
import XCTest
import FileCheck
import Foundation

class IRBuilderSpec : XCTestCase {
  func testIRBuilder() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRBUILDER"]) {
      // IRBUILDER: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
      // IRBUILDER-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)
      // IRBUILDER: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([],
                                                        VoidType()))
      // IRBUILDER-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      // IRBUILDER-NEXT: ret void
      builder.buildRetVoid()
      // IRBUILDER-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRBUILDER-INLINE-ASM"]) {
      // IRBUILDER-INLINE-ASM: ; ModuleID = '[[ModuleName:IRBuilderInlineAsmTest]]'
      // IRBUILDER-INLINE-ASM-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderInlineAsmTest")
      let builder = IRBuilder(module: module)

      // IRBUILDER-INLINE-ASM: module asm "i32 (i32) asm \22bswap $0\22, \22=r,r\22"
      module.appendInlineAssembly("""
      i32 (i32) asm "bswap $0", "=r,r"
      """)
      // IRBUILDER-INLINE-ASM-NEXT: %X = call i32 asm \22bswap $0\22, \22=r,r\22(i32 %Y)
      module.appendInlineAssembly("""
      %X = call i32 asm "bswap $0", "=r,r"(i32 %Y)
      """)

      // IRBUILDER-INLINE-ASM: @a = global i32 1
      let g1 = builder.addGlobal("a", type: IntType.int32)
      g1.initializer = Int32(1)

      // IRBUILDER-INLINE-ASM: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], VoidType()))
      // IRBUILDER-INLINE-ASM-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      let ty = FunctionType([ PointerType(pointee: IntType.int32) ], VoidType())
      let emptyASM = builder.buildInlineAssembly("", dialect: .att, type: ty, constraints: "=r,0", hasSideEffects: true, needsAlignedStack: true)
      // IRBUILDER-INLINE-ASM-NEXT: call void asm sideeffect alignstack "\00", "=r,0\00"(i32* @a)
      _ = builder.buildCall(emptyASM, args: [ g1 ])
      // IRBUILDER-INLINE-ASM-NEXT: ret void
      builder.buildRetVoid()
      // IRBUILDER-INLINE-ASM-NEXT: }
      module.dump()
    })

    // MARK: Arithmetic Instructions

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRBUILDERARITH"]) {
      // IRBUILDERARITH: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
      // IRBUILDERARITH-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)

      // IRBUILDERARITH: @a = global i32 1
      // IRBUILDERARITH-NEXT: @b = global i32 1
      let g1 = builder.addGlobal("a", type: IntType.int32)
      g1.initializer = Int32(1)
      let g2 = builder.addGlobal("b", type: IntType.int32)
      g2.initializer = Int32(1)

      // IRBUILDERARITH-NEXT: @vec1 = global <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
      // IRBUILDERARITH-NEXT: @vec2 = global <8 x i32> <i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2>
      let vecTy = VectorType(elementType: IntType.int32, count: 8)
      let gVec1 = builder.addGlobal("vec1", initializer: vecTy.constant([ 1, 1, 1, 1, 1, 1, 1, 1 ] as [Int32]))
      let gVec2 = builder.addGlobal("vec2", initializer: vecTy.constant([ 2, 2, 2, 2, 2, 2, 2, 2 ] as [Int32]))

      // IRBUILDERARITH: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], VoidType()))
      // IRBUILDERARITH-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRBUILDERARITH-NEXT: [[A_LOAD:%[0-9]+]] = load i32, i32* @a
      let vg1 = builder.buildLoad(g1, type: IntType.int32)
      // IRBUILDERARITH-NEXT: [[B_LOAD:%[0-9]+]] = load i32, i32* @b
      let vg2 = builder.buildLoad(g2, type: IntType.int32)

      // IRBUILDERARITH-NEXT: [[VEC1_LOAD:%[0-9]+]] = load <8 x i32>, <8 x i32>* @vec1
      let vgVec1 = builder.buildLoad(gVec1, type: vecTy)

      // IRBUILDERARITH-NEXT: [[VEC2_LOAD:%[0-9]+]] = load <8 x i32>, <8 x i32>* @vec2
      let vgVec2 = builder.buildLoad(gVec2, type: vecTy)

      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = add i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildAdd(vg1, vg2)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = sub i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildSub(vg1, vg2)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = mul i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildMul(vg1, vg2)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = sdiv i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildDiv(vg1, vg2, signed: true)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = udiv i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildDiv(vg1, vg2, signed: false)

      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = add nsw i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildAdd(vg1, vg2, overflowBehavior: .noSignedWrap)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = sub nsw i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildSub(vg1, vg2, overflowBehavior: .noSignedWrap)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = mul nsw i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildMul(vg1, vg2, overflowBehavior: .noSignedWrap)

      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = add nuw i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildAdd(vg1, vg2, overflowBehavior: .noUnsignedWrap)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = sub nuw i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildSub(vg1, vg2, overflowBehavior: .noUnsignedWrap)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = mul nuw i32 [[A_LOAD]], [[B_LOAD]]
      _ = builder.buildMul(vg1, vg2, overflowBehavior: .noUnsignedWrap)

      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = add <8 x i32> [[VEC1_LOAD]], [[VEC2_LOAD]]
      _ = builder.buildAdd(vgVec1, vgVec2)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = sub <8 x i32> [[VEC1_LOAD]], [[VEC2_LOAD]]
      _ = builder.buildSub(vgVec1, vgVec2)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = mul <8 x i32> [[VEC1_LOAD]], [[VEC2_LOAD]]
      _ = builder.buildMul(vgVec1, vgVec2)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = sdiv <8 x i32> [[VEC1_LOAD]], [[VEC2_LOAD]]
      _ = builder.buildDiv(vgVec1, vgVec2, signed: true)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = udiv <8 x i32> [[VEC1_LOAD]], [[VEC2_LOAD]]
      _ = builder.buildDiv(vgVec1, vgVec2, signed: false)

      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = sub i32 0, [[A_LOAD]]
      _ = builder.buildNeg(vg1, overflowBehavior: .default)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = sub nuw i32 0, [[A_LOAD]]
      _ = builder.buildNeg(vg1, overflowBehavior: .noUnsignedWrap)
      // IRBUILDERARITH-NEXT: {{%[0-9]+}} = sub nsw i32 0, [[A_LOAD]]
      _ = builder.buildNeg(vg1, overflowBehavior: .noSignedWrap)

      // IRBUILDERARITH-NEXT: ret void
      builder.buildRetVoid()
      // IRBUILDERARITH-NEXT: }
      module.dump()
    })

    // MARK: Integer comparisons
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRBUILDERCMP"]) {
      // IRBUILDERCMP: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
      // IRBUILDERCMP-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)

      // IRBUILDERCMP: @a = global i32 1
      // IRBUILDERCMP-NEXT: @b = global i32 1
      let g1 = builder.addGlobal("a", type: IntType.int32)
      g1.initializer = Int32(1)
      let g2 = builder.addGlobal("b", type: IntType.int32)
      g2.initializer = Int32(1)

      // IRBUILDERCMP: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], VoidType()))
      // IRBUILDERCMP-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRBUILDERCMP-NEXT: %0 = load i32, i32* @a
      let vg1 = builder.buildLoad(g1, type: IntType.int32)
      // IRBUILDERCMP-NEXT: %1 = load i32, i32* @b
      let vg2 = builder.buildLoad(g2, type: IntType.int32)

      // IRBUILDERCMP-NEXT: %2 = icmp eq i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .equal)
      // IRBUILDERCMP-NEXT: %3 = icmp ne i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .notEqual)
      // IRBUILDERCMP-NEXT: %4 = icmp ugt i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .unsignedGreaterThan)
      // IRBUILDERCMP-NEXT: %5 = icmp uge i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .unsignedGreaterThanOrEqual)
      // IRBUILDERCMP-NEXT: %6 = icmp ult i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .unsignedLessThan)
      // IRBUILDERCMP-NEXT: %7 = icmp ule i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .unsignedLessThanOrEqual)
      // IRBUILDERCMP-NEXT: %8 = icmp sgt i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .signedGreaterThan)
      // IRBUILDERCMP-NEXT: %9 = icmp sge i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .signedGreaterThanOrEqual)
      // IRBUILDERCMP-NEXT: %10 = icmp slt i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .signedLessThan)
      // IRBUILDERCMP-NEXT: %11 = icmp sle i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .signedLessThanOrEqual)

      // IRBUILDERCMP-NEXT: ret void
      builder.buildRetVoid()
      // IRBUILDERCMP-NEXT: }
      module.dump()
    })

    // MARK: Float comparisons
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRBUILDERFCMP"]) {
      // IRBUILDERFCMP: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
      // IRBUILDERFCMP-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)

      // IRBUILDERFCMP: @a = global double 1
      // IRBUILDERFCMP-NEXT: @b = global double 1
      let g1 = builder.addGlobal("a", type: FloatType.double)
      g1.initializer = FloatType.double.constant(1)
      let g2 = builder.addGlobal("b", type: FloatType.double)
      g2.initializer = FloatType.double.constant(1)

      // IRBUILDERFCMP: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], VoidType()))
      // IRBUILDERFCMP-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRBUILDERFCMP-NEXT: %0 = load double, double* @a
      let vg1 = builder.buildLoad(g1, type: FloatType.double)
      // IRBUILDERFCMP-NEXT: %1 = load double, double* @b
      let vg2 = builder.buildLoad(g2, type: FloatType.double)

      // IRBUILDERFCMP-NEXT: %2 = fcmp oeq double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .orderedEqual)
      // IRBUILDERFCMP-NEXT: %3 = fcmp one double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .orderedNotEqual)
      // IRBUILDERFCMP-NEXT: %4 = fcmp ugt double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .unorderedGreaterThan)
      // IRBUILDERFCMP-NEXT: %5 = fcmp uge double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .unorderedGreaterThanOrEqual)
      // IRBUILDERFCMP-NEXT: %6 = fcmp ult double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .unorderedLessThan)
      // IRBUILDERFCMP-NEXT: %7 = fcmp ule double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .unorderedLessThanOrEqual)
      // IRBUILDERFCMP-NEXT: %8 = fcmp ogt double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .orderedGreaterThan)
      // IRBUILDERFCMP-NEXT: %9 = fcmp oge double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .orderedGreaterThanOrEqual)
      // IRBUILDERFCMP-NEXT: %10 = fcmp olt double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .orderedLessThan)
      // IRBUILDERFCMP-NEXT: %11 = fcmp ole double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .orderedLessThanOrEqual)
      // IRBUILDERFCMP-NEXT: %12 = fcmp true double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .true)
      // IRBUILDERFCMP-NEXT: %13 = fcmp false double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .false)

      // IRBUILDERFCMP-NEXT: ret void
      builder.buildRetVoid()

      // IRBUILDERFCMP-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["CONTROLFLOW"]) {
      // CONTROLFLOW: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
      // CONTROLFLOW-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)

      // CONTROLFLOW: define i32 @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], IntType.int32))

      // CONTROLFLOW-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // CONTROLFLOW-NEXT: %var = alloca i64
      let variable = builder.buildAlloca(type: IntType.int64, name: "var")

      // CONTROLFLOW-NEXT: store i64 1, i64* %var
      builder.buildStore(IntType.int64.constant(1), to: variable)

      // CONTROLFLOW-NEXT: store volatile i64 1, i64* %var
      builder.buildStore(IntType.int64.constant(1), to: variable, volatile: true)

      // CONTROLFLOW-NEXT: store atomic i64 1, i64* %var
      builder.buildStore(IntType.int64.constant(1), to: variable, ordering: .sequentiallyConsistent)

      // CONTROLFLOW-NEXT: %0 = load i64, i64* %var
      let load = builder.buildLoad(variable, type: IntType.int64)

      // CONTROLFLOW-NEXT: %1 = icmp eq i64 %0, 0
      let res = builder.buildICmp(load, IntType.int64.zero(), .equal)

      let thenBB = main.appendBasicBlock(named: "then")
      let elseBB = main.appendBasicBlock(named: "else")

      // CONTROLFLOW-NEXT: br i1 %1, label %then, label %else
      builder.buildCondBr(condition: res, then: thenBB, else: elseBB)

      // CONTROLFLOW: then:
      builder.positionAtEnd(of: thenBB)

      // CONTROLFLOW-NEXT: ret i32 1
      builder.buildRet(IntType.int32.constant(1))

      // CONTROLFLOW: else:
      builder.positionAtEnd(of: elseBB)

      // CONTROLFLOW-NEXT: ret i32 0
      builder.buildRet(IntType.int32.constant(0))

      // CONTROLFLOW-NEXT: }
      module.dump()
    })

    // MARK: Cast Instructions

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["CAST"]) {
      // CAST: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
      // CAST-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)


      // CAST: define i32 @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([],
                                                        IntType.int32))

      // CAST-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // CAST-NEXT: %0 = alloca i64
      let alloca = builder.buildAlloca(type: IntType.int64)

      // CAST-NEXT: %1 = ptrtoint i64* %0 to i64
      _ = builder.buildPtrToInt(alloca, type: IntType.int64)

      // CAST-NEXT: %2 = load i64, i64* %0
      let val = builder.buildLoad(alloca, type: IntType.int64)

      // CAST-NEXT: %3 = inttoptr i64 %2 to i64*
      _ = builder.buildIntToPtr(val,
                                type: PointerType(pointee: IntType.int64))

      // CAST-NEXT: %4 = bitcast i64* %0 to i8*
      _ = builder.buildBitCast(alloca, type: PointerType.toVoid)

      // CAST-NEXT: %5 = alloca double
      let dblAlloca = builder.buildAlloca(type: FloatType.double)

      // CAST-NEXT: %6 = load double, double* %5
      let dblVal = builder.buildLoad(dblAlloca, type: FloatType.double)

      // CAST-NEXT: %7 = fptrunc double %6 to float
      let fltVal = builder.buildFPCast(dblVal, type: FloatType.float)

      // CAST-NEXT: %8 = fpext float %7 to double
      _ = builder.buildFPCast(fltVal, type: FloatType.double)

      // CAST-NEXT: ret i32 0
      builder.buildRet(IntType.int32.constant(0))

      // CAST-NEXT: }
      module.dump()
    })

    // MARK: C Standard Library Instructions
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testIRBuilder", testIRBuilder),
  ])
  #endif
}
