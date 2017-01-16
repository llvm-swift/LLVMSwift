import LLVM
import XCTest
import Foundation

class IRBuilderSpec : XCTestCase {
  func testIRBuilder() {
    XCTAssert(fileCheckOutput(of: .stderr) {
      // CHECK: ; ModuleID = 'IRBuilderTest'
      // CHECK-NEXT: source_filename = "IRBuilderTest"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)
      // CHECK: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: VoidType()))
      // CHECK-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      // CHECK-NEXT: ret void
      builder.buildRetVoid()
      // CHECK-NEXT: }
      module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testIRBuilder", testIRBuilder),
  ])
  #endif
}
