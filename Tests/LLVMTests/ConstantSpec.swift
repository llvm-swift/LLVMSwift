import LLVM
import XCTest
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
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))
      let constant = IntType.int64.constant(42)

      // SIGNEDCONST-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // SIGNEDCONST-NOT: %{{[0-9]+}} = add i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val1 = builder.buildAdd(constant.adding(constant), constant.multiplying(constant))
      // SIGNEDCONST-NOT: %{{[0-9]+}} = sub i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val2 = builder.buildSub(constant.subtracting(constant), constant.dividing(constant))
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
      // UNSIGNEDCONST: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))
      let constant = IntType.int64.constant(UInt64(42))

      // UNSIGNEDCONST-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // UNSIGNEDCONST-NOT: %{{[0-9]+}} = add i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val1 = builder.buildAdd(constant.adding(constant), constant.multiplying(constant))
      // UNSIGNEDCONST-NOT: %{{[0-9]+}} = sub i64 %%{{[0-9]+}}, %%{{[0-9]+}}
      let val2 = builder.buildSub(constant.subtracting(constant), constant.dividing(constant))
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
      // FLOATINGCONST: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))
      let constant = FloatType.double.constant(42.0)

      // FLOATINGCONST-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // FLOATINGCONST-NOT: %{{[0-9]+}} = add double %%{{[0-9]+}}, %%{{[0-9]+}}
      let val1 = builder.buildAdd(constant.adding(constant), constant.multiplying(constant))
      // FLOATINGCONST-NOT: %{{[0-9]+}} = sub double %%{{[0-9]+}}, %%{{[0-9]+}}
      let val2 = builder.buildSub(constant.subtracting(constant), constant.dividing(constant))
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
      // STRUCTCONST: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))

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
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testConstants", testConstants),
  ])
  #endif
}
