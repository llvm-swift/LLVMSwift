import LLVM
import XCTest
import Foundation

class IROperationSpec : XCTestCase {
  func testBinaryOps() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["BINARYOP"]) {
      // BINARYOP: ; ModuleID = '[[ModuleName:BinaryOpTest]]'
      // BINARYOP-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "BinaryOpTest")
      let builder = IRBuilder(module: module)

      // BINARYOP: @a = global i32 1
      var gi1 = builder.addGlobal("a", type: IntType.int32)
      gi1.initializer = Int32(1)
      // BINARYOP-NEXT: @b = global i32 1
      var gi2 = builder.addGlobal("b", type: IntType.int32)
      gi2.initializer = Int32(1)

      // BINARYOP-NEXT: @c = global float 0.000000e+00
      var gf1 = builder.addGlobal("c", type: FloatType.float)
      gf1.initializer = FloatType.float.constant(0.0)
      // BINARYOP-NEXT: @d = global float 0.000000e+00
      var gf2 = builder.addGlobal("d", type: FloatType.float)
      gf2.initializer = FloatType.float.constant(0.0)

      // BINARYOP: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))
      // BINARYOP-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // BINARYOP-NEXT: %0 = load i32, i32* @a
      let vgi1 = builder.buildLoad(gi1)
      // BINARYOP-NEXT: %1 = load i32, i32* @b
      let vgi2 = builder.buildLoad(gi2)

      // BINARYOP-NEXT: %2 = load float, float* @c
      let vgf1 = builder.buildLoad(gf1)
      // BINARYOP-NEXT: %3 = load float, float* @d
      let vgf2 = builder.buildLoad(gf2)

      // BINARYOP-NEXT: %4 = add i32 %0, %1
      _ = builder.buildBinaryOperation(.add, vgi1, vgi2)
      // BINARYOP-NEXT: %5 = sub i32 %0, %1
      _ = builder.buildBinaryOperation(.sub, vgi1, vgi2)
      // BINARYOP-NEXT: %6 = mul i32 %0, %1
      _ = builder.buildBinaryOperation(.mul, vgi1, vgi2)
      // BINARYOP-NEXT: %7 = udiv i32 %0, %1
      _ = builder.buildBinaryOperation(.udiv, vgi1, vgi2)
      // BINARYOP-NEXT: %8 = sdiv i32 %0, %1
      _ = builder.buildBinaryOperation(.sdiv, vgi1, vgi2)
      // BINARYOP-NEXT: %9 = urem i32 %0, %1
      _ = builder.buildBinaryOperation(.urem, vgi1, vgi2)
      // BINARYOP-NEXT: %10 = srem i32 %0, %1
      _ = builder.buildBinaryOperation(.srem, vgi1, vgi2)
      // BINARYOP-NEXT: %11 = shl i32 %0, %1
      _ = builder.buildBinaryOperation(.shl, vgi1, vgi2)
      // BINARYOP-NEXT: %12 = lshr i32 %0, %1
      _ = builder.buildBinaryOperation(.lshr, vgi1, vgi2)
      // BINARYOP-NEXT: %13 = ashr i32 %0, %1
      _ = builder.buildBinaryOperation(.ashr, vgi1, vgi2)
      // BINARYOP-NEXT: %14 = and i32 %0, %1
      _ = builder.buildBinaryOperation(.and, vgi1, vgi2)
      // BINARYOP-NEXT: %15 = or i32 %0, %1
      _ = builder.buildBinaryOperation(.or, vgi1, vgi2)
      // BINARYOP-NEXT: %16 = xor i32 %0, %1
      _ = builder.buildBinaryOperation(.xor, vgi1, vgi2)

      // BINARYOP-NEXT: %17 = fadd float %2, %3
      _ = builder.buildBinaryOperation(.fadd, vgf1, vgf2)
      // BINARYOP-NEXT: %18 = fsub float %2, %3
      _ = builder.buildBinaryOperation(.fsub, vgf1, vgf2)
      // BINARYOP-NEXT: %19 = fmul float %2, %3
      _ = builder.buildBinaryOperation(.fmul, vgf1, vgf2)
      // BINARYOP-NEXT: %20 = fdiv float %2, %3
      _ = builder.buildBinaryOperation(.fdiv, vgf1, vgf2)
      // BINARYOP-NEXT: %21 = frem float %2, %3
      _ = builder.buildBinaryOperation(.frem, vgf1, vgf2)

      // BINARYOP-NEXT: ret void
      builder.buildRetVoid()
      // BINARYOP-NEXT: }
      module.dump()
    })
  }

  func testCastOps() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["CASTOP"]) {
      // CASTOP: ; ModuleID = '[[ModuleName:CastOpTest]]'
      // CASTOP-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "CastOpTest")
      let builder = IRBuilder(module: module)

      // CASTOP: @a = global i32 1
      var gi = builder.addGlobal("a", type: IntType.int32)
      gi.initializer = Int32(1)

      // CASTOP-NEXT: @f = global float 0.000000e+00
      var gf = builder.addGlobal("f", type: FloatType.float)
      gf.initializer = FloatType.float.constant(0.0)

      // CASTOP: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))
      // CASTOP-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // CASTOP-NEXT: %0 = load i32, i32* @a
      let vgi = builder.buildLoad(gi)
      // CASTOP-NEXT: %1 = load float, float* @f
      let vgf = builder.buildLoad(gf)

      // CASTOP-NEXT: %2 = trunc i32 %0 to i16
      _ = builder.buildCast(.trunc, value: vgi, type: IntType.int16)
      // CASTOP-NEXT: %3 = zext i32 %0 to i64
      _ = builder.buildCast(.zext, value: vgi, type: IntType.int64)
      // CASTOP-NEXT: %4 = sext i32 %0 to i64
      _ = builder.buildCast(.sext, value: vgi, type: IntType.int64)
      // CASTOP-NEXT: %5 = fptoui float %1 to i32
      _ = builder.buildCast(.fpToUI, value: vgf, type: IntType.int32)
      // CASTOP-NEXT: %6 = fptosi float %1 to i32
      _ = builder.buildCast(.fpToSI, value: vgf, type: IntType.int32)
      // CASTOP-NEXT: %7 = uitofp i32 %0 to double
      _ = builder.buildCast(.uiToFP, value: vgi, type: FloatType.double)
      // CASTOP-NEXT: %8 = sitofp i32 %0 to float
      _ = builder.buildCast(.siToFP, value: vgi, type: FloatType.float)
      // CASTOP-NEXT: %9 = fptrunc float %1 to half
      _ = builder.buildCast(.fpTrunc, value: vgf, type: FloatType.half)
      // CASTOP-NEXT: %10 = fpext float %1 to fp128
      _ = builder.buildCast(.fpext, value: vgf, type: FloatType.fp128)
      // CASTOP-NEXT: %11 = inttoptr i32 %0 to i32*
      _ = builder.buildCast(.intToPtr, value: vgi, type: PointerType(pointee: IntType.int32))
      // CASTOP-NEXT: %12 = bitcast i32 %0 to float
      _ = builder.buildCast(.bitCast, value: vgi, type: FloatType.float)

      // FIXME: These are not correct
      // _ = builder.buildCast(.ptrToInt, value: gi, type: IntType.int32)
      // _ = builder.buildCast(.addrSpaceCast, value: gi, type: PointerType(pointee: IntType.int32, addressSpace: 1))

      // CASTOP-NEXT: ret void
      builder.buildRetVoid()
      // CASTOP-NEXT: }
      module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testBinaryOps", testBinaryOps),
    ("testCastOps", testCastOps),
  ])
  #endif
}
