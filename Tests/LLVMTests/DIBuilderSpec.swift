import LLVM
import XCTest
import FileCheck
import Foundation

class DIBuilderSpec : XCTestCase {
  func testDIBuilder() {
    XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["DIBUILDER"]) {
      // DIBUILDER: ; ModuleID = 'DIBuilderTest'
      let module = Module(name: "DIBuilderTest")
      // DIBUILDER: source_filename = "DIBuilderTest"
      let builder = IRBuilder(module: module)
      let debugBuilder = DIBuilder(module: module)

      let f = builder.addFunction("foo", type: FunctionType(argTypes: [], returnType: VoidType()))
      let bb = f.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: bb)
      _ = builder.buildAlloca(type: IntType.int8)

      // DIBUILDER-DAG: !{{[0-9]+}} = !DIFile(filename: "test.trill", directory: "/")
      let file = debugBuilder.buildFile(named: "test.trill", in: "/")
      // DIBUILDER-DAG: !{{[0-9]+}} = distinct !DICompileUnit(language: DW_LANG_Swift, file: !{{[0-9]+}}, isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !{{[0-9]+}}, splitDebugInlining: false)
      _ = debugBuilder.buildCompileUnit(for: .swift, in: file, kind: .full, optimized: false, runtimeVersion: 0)

      debugBuilder.finalize()
      module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testDIBuilder", testDIBuilder),
  ])
  #endif
}
