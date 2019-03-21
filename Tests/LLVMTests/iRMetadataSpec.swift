
import LLVM
import XCTest
import FileCheck
import Foundation

class IRMetadataSpec : XCTestCase {
  func testGlobalMetadata() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRGLOBALMETADATA"]) {
      // IRGLOBALMETADATA: ; ModuleID = '[[ModuleName:IRGLOBALMETADATATest]]'
      // IRGLOBALMETADATA-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRGLOBALMETADATATest")
      let builder = IRBuilder(module: module)
      let dibuilder = DIBuilder(module: module)

      let tag = module.context.metadataKind(named: "custom")

      // IRGLOBALMETADATA: @customAttachment = global i8 42, !custom !0
      let global = builder.addGlobal("customAttachment", initializer: IntType.int8.constant(42))

      // IRGLOBALMETADATA: !0 = !DIBasicType(name: "custom_type", encoding: DW_ATE_address)
      let type = dibuilder.buildBasicType(named: "custom_type", encoding: .address, flags: [], size: .zero)
      global.addMetadata(type, kind: tag)

      module.dump()
    })
  }

  func testInstructionMetadata() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRINSTRMETADATA"]) {
      // IRINSTRMETADATA: ; ModuleID = '[[ModuleName:IRINSTRMETADATATest]]'
      // IRINSTRMETADATA-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRINSTRMETADATATest")
      let builder = IRBuilder(module: module)
      let dibuilder = DIBuilder(module: module)

      let tag = module.context.metadataKind(named: "custom")

      // IRINSTRMETADATA: define i32 @test() {
      let main = builder.addFunction("test",
                                     type: FunctionType(argTypes: [],
                                                        returnType: IntType.int32))
      // IRINSTRMETADATA-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      // IRINSTRMETADATA-NEXT: ret i32 42
      builder.buildRet(IntType.int32.constant(42))

      let type = dibuilder.buildBasicType(named: "custom_type", encoding: .address, flags: [], size: .zero)
      builder.insertBlock?.lastInstruction?.addMetadata(type, kind: tag)
      // IRINSTRMETADATA-NEXT: }

      // IRINSTRMETADATA: !0 = !DIBasicType(name: "custom_type", encoding: DW_ATE_address)
      module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testGlobalMetadata", testGlobalMetadata),
  ])
  #endif
}

