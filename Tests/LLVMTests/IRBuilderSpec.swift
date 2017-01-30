import LLVM
import XCTest
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
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))
      // IRBUILDER-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      // IRBUILDER-NEXT: ret void
      builder.buildRetVoid()
      // IRBUILDER-NEXT: }
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
      var g1 = builder.addGlobal("a", type: IntType.int32)
      g1.initializer = Int32(1)
      var g2 = builder.addGlobal("b", type: IntType.int32)
      g2.initializer = Int32(1)

      // IRBUILDERARITH: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))
      // IRBUILDERARITH-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRBUILDERARITH-NEXT: %0 = load i32, i32* @a
      let vg1 = builder.buildLoad(g1)
      // IRBUILDERARITH-NEXT: %1 = load i32, i32* @b
      let vg2 = builder.buildLoad(g2)

      // IRBUILDERARITH-NEXT: %2 = add i32 %0, %1
      _ = builder.buildAdd(vg1, vg2)
      // IRBUILDERARITH-NEXT: %3 = sub i32 %0, %1
      _ = builder.buildSub(vg1, vg2)
      // IRBUILDERARITH-NEXT: %4 = mul i32 %0, %1
      _ = builder.buildMul(vg1, vg2)
      // IRBUILDERARITH-NEXT: %5 = sdiv i32 %0, %1
      _ = builder.buildDiv(vg1, vg2, signed: true)
      // IRBUILDERARITH-NEXT: %6 = udiv i32 %0, %1
      _ = builder.buildDiv(vg1, vg2, signed: false)

      // IRBUILDERARITH-NEXT: %7 = add nsw i32 %0, %1
      _ = builder.buildAdd(vg1, vg2, overflowBehavior: .noSignedWrap)
      // IRBUILDERARITH-NEXT: %8 = sub nsw i32 %0, %1
      _ = builder.buildSub(vg1, vg2, overflowBehavior: .noSignedWrap)
      // IRBUILDERARITH-NEXT: %9 = mul nsw i32 %0, %1
      _ = builder.buildMul(vg1, vg2, overflowBehavior: .noSignedWrap)

      // IRBUILDERARITH-NEXT: %10 = add nuw i32 %0, %1
      _ = builder.buildAdd(vg1, vg2, overflowBehavior: .noUnsignedWrap)
      // IRBUILDERARITH-NEXT: %11 = sub nuw i32 %0, %1
      _ = builder.buildSub(vg1, vg2, overflowBehavior: .noUnsignedWrap)
      // IRBUILDERARITH-NEXT: %12 = mul nuw i32 %0, %1
      _ = builder.buildMul(vg1, vg2, overflowBehavior: .noUnsignedWrap)

      // IRBUILDERARITH-NEXT: %13 = sub i32 0, %0
      _ = builder.buildNeg(vg1, overflowBehavior: .default)
      // IRBUILDERARITH-NEXT: %14 = sub nuw i32 0, %0
      _ = builder.buildNeg(vg1, overflowBehavior: .noUnsignedWrap)
      // IRBUILDERARITH-NEXT: %15 = sub nsw i32 0, %0
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
      var g1 = builder.addGlobal("a", type: IntType.int32)
      g1.initializer = Int32(1)
      var g2 = builder.addGlobal("b", type: IntType.int32)
      g2.initializer = Int32(1)

      // IRBUILDERCMP: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))
      // IRBUILDERCMP-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRBUILDERCMP-NEXT: %0 = load i32, i32* @a
      let vg1 = builder.buildLoad(g1)
      // IRBUILDERCMP-NEXT: %1 = load i32, i32* @b
      let vg2 = builder.buildLoad(g2)

      // IRBUILDERCMP-NEXT: %2 = icmp eq i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .eq)
      // IRBUILDERCMP-NEXT: %3 = icmp ne i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .ne)
      // IRBUILDERCMP-NEXT: %4 = icmp ugt i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .ugt)
      // IRBUILDERCMP-NEXT: %5 = icmp uge i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .uge)
      // IRBUILDERCMP-NEXT: %6 = icmp ult i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .ult)
      // IRBUILDERCMP-NEXT: %7 = icmp ule i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .ule)
      // IRBUILDERCMP-NEXT: %8 = icmp sgt i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .sgt)
      // IRBUILDERCMP-NEXT: %9 = icmp sge i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .sge)
      // IRBUILDERCMP-NEXT: %10 = icmp slt i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .slt)
      // IRBUILDERCMP-NEXT: %11 = icmp sle i32 %0, %1
      _ = builder.buildICmp(vg1, vg2, .sle)

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
      var g1 = builder.addGlobal("a", type: FloatType.double)
      g1.initializer = FloatType.double.constant(1)
      var g2 = builder.addGlobal("b", type: FloatType.double)
      g2.initializer = FloatType.double.constant(1)

      // IRBUILDERFCMP: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))
      // IRBUILDERFCMP-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRBUILDERFCMP-NEXT: %0 = load double, double* @a
      let vg1 = builder.buildLoad(g1)
      // IRBUILDERFCMP-NEXT: %1 = load double, double* @b
      let vg2 = builder.buildLoad(g2)

      // IRBUILDERFCMP-NEXT: %2 = fcmp oeq double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .oeq)
      // IRBUILDERFCMP-NEXT: %3 = fcmp one double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .one)
      // IRBUILDERFCMP-NEXT: %4 = fcmp ugt double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .ugt)
      // IRBUILDERFCMP-NEXT: %5 = fcmp uge double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .uge)
      // IRBUILDERFCMP-NEXT: %6 = fcmp ult double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .ult)
      // IRBUILDERFCMP-NEXT: %7 = fcmp ule double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .ule)
      // IRBUILDERFCMP-NEXT: %8 = fcmp ogt double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .ogt)
      // IRBUILDERFCMP-NEXT: %9 = fcmp oge double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .oge)
      // IRBUILDERFCMP-NEXT: %10 = fcmp olt double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .olt)
      // IRBUILDERFCMP-NEXT: %11 = fcmp ole double %0, %1
      _ = builder.buildFCmp(vg1, vg2, .ole)
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
                                     type: FunctionType(argTypes: [],
                                                        returnType: IntType.int32))

      // CONTROLFLOW-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // CONTROLFLOW-NEXT: %var = alloca i64
      let variable = builder.buildAlloca(type: IntType.int64, name: "var")

      // CONTROLFLOW-NEXT: store i64 1, i64* %var
      builder.buildStore(IntType.int64.constant(1), to: variable)

      // CONTROLFLOW-NEXT: %0 = load i64, i64* %var
      let load = builder.buildLoad(variable)

      // CONTROLFLOW-NEXT: %1 = icmp eq i64 %0, 0
      let res = builder.buildICmp(load, IntType.int64.zero(), .eq)

      let thenBB = main.appendBasicBlock(named: "then")
      let elseBB = main.appendBasicBlock(named: "else")

      // CONTROLFLOW-NEXT: br i1 %1, label %then, label %else
      builder.buildCondBr(condition: res, then: thenBB, else: elseBB)

      // CONTROLFLOW-NEXT:
      // CONTROLFLOW-NEXT: then:
      builder.positionAtEnd(of: thenBB)

      // CONTROLFLOW-NEXT: ret i32 1
      builder.buildRet(IntType.int32.constant(1))

      // CONTROLFLOW-NEXT:
      // CONTROLFLOW-NEXT: else:
      builder.positionAtEnd(of: elseBB)

      // CONTROLFLOW-NEXT: ret i32 0
      builder.buildRet(IntType.int32.constant(0))

      // CONTROLFLOW-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["CAST"]) {
        // CAST: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
        // CAST-NEXT: source_filename = "[[ModuleName]]"
        let module = Module(name: "IRBuilderTest")
        let builder = IRBuilder(module: module)


        // CAST: define i32 @main() {
        let main = builder.addFunction("main",
                                       type: FunctionType(argTypes: [],
                                                          returnType: IntType.int32))

        // CAST-NEXT: entry:
        let entry = main.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)

        // CAST-NEXT: %0 = alloca i64
        let alloca = builder.buildAlloca(type: IntType.int64)

        // CAST-NEXT: %1 = ptrtoint i64* %0 to i64
        _ = builder.buildPtrToInt(alloca, type: IntType.int64)

        // CAST-NEXT: %2 = load i64, i64* %0
        let val = builder.buildLoad(alloca)

        // CAST-NEXT: %3 = inttoptr i64 %2 to i64*
        _ = builder.buildIntToPtr(val,
                                  type: PointerType(pointee: IntType.int64))

        // CAST-NEXT: %4 = bitcast i64* %0 to i8*
        _ = builder.buildBitCast(alloca, type: PointerType.toVoid)

        // CAST-NEXT: ret i32 0
        builder.buildRet(IntType.int32.constant(0))

        // CAST-NEXT: }
        module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testIRBuilder", testIRBuilder),
  ])
  #endif
}
