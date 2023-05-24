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

      let f = builder.addFunction("foo", type: FunctionType([], VoidType()))
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

  func testDIExpression() {
    XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["DIEXPRESSION"]) {
      // DIEXPRESSION: ; ModuleID = 'DIExpressionTest'
      let module = Module(name: "DIExpressionTest")
      // DIEXPRESSION: source_filename = "DIExpressionTest"
      let builder = IRBuilder(module: module)
      let debugBuilder = DIBuilder(module: module)

      let file = debugBuilder.buildFile(named: "test.trill", in: "/")
      let cu = debugBuilder.buildCompileUnit(for: .swift, in: file, kind: .full, optimized: false, runtimeVersion: 0)

      let global = builder.addGlobal("global", type: IntType.int32)
      global.initializer = IntType.int32.constant(5)
      let globalTy = debugBuilder.buildBasicType(named: "int32_t", encoding: .signed, flags: [], size: Size(bits: 32))

      // DIEXPRESSION: !{{[0-9]+}} = !DIGlobalVariableExpression(var: !{{[0-9]+}}, expr: !DIExpression())
      // DIEXPRESSION: !{{[0-9]+}} = distinct !DIGlobalVariable(name: "global", linkageName: "global", scope: !{{[0-9]+}}, file: !{{[0-9]+}}, line: 42, type: !{{[0-9]+}}, isLocal: true, isDefinition: true)
      // DIEXPRESSION: !{{[0-9]+}} = !DIBasicType(name: "int32_t", size: 32, encoding: DW_ATE_signed)
      // DIEXPRESSION: !{{[0-9]+}} = !DIGlobalVariableExpression(var: !{{[0-9]+}}, expr: !{{[0-9]+}})
      let expr = debugBuilder.buildGlobalExpression(
        named: "global", linkageName: "global", type: globalTy,
        scope: cu, file: file, line: 42, alignment: global.alignment)
      // DIEXPRESSION: !{{[0-9]+}} = distinct !DIGlobalVariable(name: "unattached", linkageName: "unattached", scope: !0, file: !{{[0-9]+}}, line: 42, type: !{{[0-9]+}}, isLocal: true, isDefinition: true)
      _ = debugBuilder.buildGlobalExpression(
        named: "unattached", linkageName: "unattached",
        type: globalTy, scope: cu, file: file, line: 42,
        isLocal: true,
        expression: expr, declaration: nil, alignment: .zero)

      // DIEXPRESSION: !{{[0-9]+}} = !DIGlobalVariableExpression(var: !{{[0-9]+}}, expr: !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 3, DW_OP_constu, 3, DW_OP_plus, DW_OP_deref, DW_OP_constu, 3, DW_OP_constu, 2, DW_OP_swap, DW_OP_xderef, DW_OP_constu, 42, DW_OP_stack_value))
      let addrExpr = debugBuilder.buildExpression([
        .deref,
        .plus_uconst(3),
        .constu(3), .plus,
        .deref, .constu(3),
        .constu(2), .swap, .xderef,
        .constu(42), .stackValue
      ])
      // !10 = distinct !DIGlobalVariable(name: "unattached_addrExpr", linkageName: "unattached_addrExpr", scope: !{{[0-9]+}}, file: !{{[0-9]+}}, line: 42, type: !{{[0-9]+}}, isLocal: true, isDefinition: true)
      _ = debugBuilder.buildGlobalExpression(
        named: "unattached_addrExpr", linkageName: "unattached_addrExpr",
        type: globalTy, scope: cu, file: file, line: 42,
        isLocal: true,
        expression: addrExpr, declaration: nil, alignment: .zero)

      debugBuilder.finalize()
      module.dump()
//      try! module.verify()
    })
  }

  func testDIScopeAccessors() {
    let module = Module(name: "DISCope")
    let debugBuilder = DIBuilder(module: module)

    let directory = "/some/long/directory/name"
    let fileName = "test.trill"
    let file = debugBuilder.buildFile(named: fileName, in: directory)
    let cu = debugBuilder.buildCompileUnit(for: .swift, in: file, kind: .full, optimized: false, runtimeVersion: 0)

    XCTAssertEqual(cu.file?.name, fileName)
    XCTAssertEqual(cu.file?.directory, directory)
    // FIXME: Empty, for now.  Need hashing and DWARF 5 source text bindings.
    XCTAssertEqual(cu.file?.source, "")
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testDIBuilder", testDIBuilder),
    ("testDIExpression", testDIExpression),
    ("testDIScopeAccessors", testDIScopeAccessors),
  ])
  #endif
}
