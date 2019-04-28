import LLVM
import XCTest
import FileCheck
import Foundation

class ConstantSpec : XCTestCase {
  func testConstants() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["SIGNEDCONST"]) {
      // SIGNEDCONST: ; ModuleID = '[[ModuleName:ConstantTest]]'
      // SIGNEDCONST-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "ConstantTest")
      let builder = IRBuilder(module: module)
      // SIGNEDCONST: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], VoidType()))
      let constant = IntType.int64.constant(42)

      // SIGNEDCONST-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // SIGNEDCONST-NOT: %{{[0-9]+}} = add i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val1 = builder.buildAdd(constant.adding(constant), constant.multiplying(constant))
      // SIGNEDCONST-NOT: %{{[0-9]+}} = sub i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val2 = builder.buildSub(constant.subtracting(constant), constant.dividing(by: constant))
      // SIGNEDCONST-NOT: %{{[0-9]+}} = mul i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val3 = builder.buildMul(val1, val2)
      // SIGNEDCONST-NOT: %{{[0-9]+}} = mul i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val4 = builder.buildMul(val3, constant.negate())

      // SIGNEDCONST-NEXT: ret i64 77616
      builder.buildRet(val4)
      // SIGNEDCONST-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["UNSIGNEDCONST"]) {
      // UNSIGNEDCONST: ; ModuleID = '[[ModuleName:ConstantTest]]'
      // UNSIGNEDCONST-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "ConstantTest")
      let builder = IRBuilder(module: module)
      // UNSIGNEDCONST: define i64 @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], IntType.int64))
      let constant = IntType.int64.constant(UInt64(42))

      // UNSIGNEDCONST-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // UNSIGNEDCONST-NOT: %{{[0-9]+}} = add i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val1 = builder.buildAdd(constant.adding(constant), constant.multiplying(constant))
      // UNSIGNEDCONST-NOT: %{{[0-9]+}} = sub i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val2 = builder.buildSub(constant.subtracting(constant), constant.dividing(by: constant))
      // UNSIGNEDCONST-NOT: %{{[0-9]+}} = mul i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val3 = builder.buildMul(val1, val2)

      // UNSIGNEDCONST-NEXT: ret i64 -1848
      builder.buildRet(val3)
      // UNSIGNEDCONST-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["FLOATINGCONST"]) {
      // FLOATINGCONST: ; ModuleID = '[[ModuleName:ConstantTest]]'
      // FLOATINGCONST-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "ConstantTest")
      let builder = IRBuilder(module: module)
      // FLOATINGCONST: define i64 @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], IntType.int64))
      let constant = FloatType.double.constant(42.0)

      // FLOATINGCONST-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // FLOATINGCONST-NOT: %{{[0-9]+}} = add double %%{{[0-9]+}}, %%{{[0-9]+}}
      let val1 = builder.buildAdd(constant.adding(constant), constant.multiplying(constant))
      // FLOATINGCONST-NOT: %{{[0-9]+}} = sub double %%{{[0-9]+}}, %%{{[0-9]+}}
      let val2 = builder.buildSub(constant.subtracting(constant), constant.dividing(by: constant))
      // FLOATINGCONST-NOT: %{{[0-9]+}} = mul double %%{{[0-9]+}}, %%{{[0-9]+}}
      let val3 = builder.buildMul(val1, val2)

      // FLOATINGCONST-NEXT: ret double -1.848000e+03
      builder.buildRet(val3)
      // FLOATINGCONST-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["STRUCTCONST"]) {
      // STRUCTCONST: ; ModuleID = '[[ModuleName:ConstantTest]]'
      // STRUCTCONST-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "ConstantTest")
      let builder = IRBuilder(module: module)
      // STRUCTCONST: define i64 @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], IntType.int64))

      let constant = StructType(elementTypes: [IntType.int64])
        .constant(values: [42])

      // STRUCTCONST-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // STRUCTCONST-NEXT: ret { i64 } { i64 42 }
      builder.buildRet(constant)
      // STRUCTCONST-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["STRUCTCONSTGETELEMENT"]) {
      // STRUCTCONSTGETELEMENT: ; ModuleID = '[[ModuleName:ConstantTest]]'
      // STRUCTCONSTGETELEMENT-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "ConstantTest")
      let builder = IRBuilder(module: module)
      // STRUCTCONSTGETELEMENT: define i64 @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], IntType.int64))

      let constant = StructType(elementTypes: [IntType.int64])
        .constant(values: [42])

      // STRUCTCONSTGETELEMENT-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      let firstElement = constant.getElement(indices: [0])

      // STRUCTCONSTGETELEMENT-NEXT: ret i64 42
      builder.buildRet(firstElement)
      // STRUCTCONSTGETELEMENT-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["VECTORCONSTSHUFFLE-IDENTITY"]) {
      // VECTORCONSTSHUFFLE-IDENTITY: ; ModuleID = '[[ModuleName:ConstantTest]]'
      // VECTORCONSTSHUFFLE-IDENTITY-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "ConstantTest")
      let builder = IRBuilder(module: module)

      let vecTy = VectorType(elementType: IntType.int32, count: 4)
      // VECTORCONSTSHUFFLE-IDENTITY: define <4 x i32> @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], vecTy))

      let vec1 = vecTy.constant([ 1, 2, 3, 4 ] as [Int32])
      let mask = vecTy.constant([ 0, 1, 2, 3 ] as [Int32])

      // VECTORCONSTSHUFFLE-IDENTITY-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      let firstElement = Constant<Vector>.buildShuffleVector(vec1, and: .undef(vecTy), mask: mask)

      // VECTORCONSTSHUFFLE-IDENTITY-NEXT: ret <4 x i32> <i32 1, i32 2, i32 3, i32 4>
      builder.buildRet(firstElement)
      // VECTORCONSTSHUFFLE-IDENTITY-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["VECTORCONSTSHUFFLE"]) {
      // VECTORCONSTSHUFFLE: ; ModuleID = '[[ModuleName:ConstantTest]]'
      // VECTORCONSTSHUFFLE-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "ConstantTest")
      let builder = IRBuilder(module: module)

      let maskTy = VectorType(elementType: IntType.int32, count: 8)
      // VECTORCONSTSHUFFLE: define <8 x i32> @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], maskTy))

      let vecTy = VectorType(elementType: IntType.int32, count: 4)
      let vec1 = vecTy.constant([ 1, 2, 3, 4 ] as [Int32])
      let vec2 = vecTy.constant([ 5, 6, 7, 8 ] as [Int32])
      let mask = maskTy.constant([ 1, 3, 5, 7, 0, 2, 4, 6 ] as [Int32])

      // VECTORCONSTSHUFFLE-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      let firstElement = Constant<Vector>.buildShuffleVector(vec1, and: vec2, mask: mask)

      // VECTORCONSTSHUFFLE-NEXT: ret <8 x i32> <i32 2, i32 4, i32 6, i32 8, i32 1, i32 3, i32 5, i32 7>
      builder.buildRet(firstElement)
      // VECTORCONSTSHUFFLE-NEXT: }
      module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testConstants", testConstants),
  ])
  #endif
}
