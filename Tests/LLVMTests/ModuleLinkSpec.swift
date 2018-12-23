import LLVM
import XCTest
import FileCheck
import Foundation

class ModuleLinkSpec : XCTestCase {
  func testModuleLink() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["MODULE-LINK"]) {
      // MODULE-LINK: ; ModuleID = '[[ModuleName1:ModuleLinkModuleOne]]'
      // MODULE-LINK-NEXT: source_filename = "[[ModuleName1]]"
      let module1 = Module(name: "ModuleLinkModuleOne")
      XCTAssertEqual(module1.name, "ModuleLinkModuleOne")
      let builder1 = IRBuilder(module: module1)
      // MODULE-LINK: define void @moduleOne() {
      let mod1f = builder1.addFunction("moduleOne",
                                       type: FunctionType(argTypes: [],
                                                          returnType: VoidType()))
      // MODULE-LINK-NEXT: entry:
      let entry1 = mod1f.appendBasicBlock(named: "entry")
      builder1.positionAtEnd(of: entry1)
      // MODULE-LINK-NEXT: ret void
      builder1.buildRetVoid()
      // MODULE-LINK-NEXT: }
      module1.dump()

      // MODULE-LINK: ; ModuleID = '[[ModuleName2:ModuleLinkModuleTwo]]'
      // MODULE-LINK-NEXT: source_filename = "[[ModuleName2]]"
      let module2 = Module(name: "ModuleLinkModuleTwo")
      XCTAssertEqual(module2.name, "ModuleLinkModuleTwo")
      let builder2 = IRBuilder(module: module2)
      // MODULE-LINK: define void @moduleTwo() {
      let mod2f = builder2.addFunction("moduleTwo",
                                       type: FunctionType(argTypes: [],
                                                          returnType: VoidType()))
      // MODULE-LINK-NEXT: entry:
      let entry2 = mod2f.appendBasicBlock(named: "entry")
      builder2.positionAtEnd(of: entry2)
      // MODULE-LINK-NEXT: ret void
      builder2.buildRetVoid()
      // MODULE-LINK-NEXT: }
      module2.dump()

      XCTAssert(module1.link(module2))

      // MODULE-LINK: ; ModuleID = '[[ModuleName1]]'
      // MODULE-LINK-NEXT: source_filename = "[[ModuleName1]]"
      // MODULE-LINK: define void @moduleOne() {
      // MODULE-LINK-NEXT: entry:
      // MODULE-LINK-NEXT: ret void
      // MODULE-LINK-NEXT: }
      // MODULE-LINK: define void @moduleTwo() {
      // MODULE-LINK-NEXT: entry:
      // MODULE-LINK-NEXT: ret void
      // MODULE-LINK-NEXT: }
      module1.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testModuleLink", testModuleLink),
  ])
  #endif
}
