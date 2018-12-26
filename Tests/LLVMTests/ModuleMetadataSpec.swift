import LLVM
import XCTest
import FileCheck
import Foundation

class ModuleMetadataSpec : XCTestCase {
  func testAddModuleFlags() {
    XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["MODULE-FLAGS"]) {
      // MODULE-FLAGS: ; ModuleID = 'ModuleFlagsTest'
      let module = Module(name: "ModuleFlagsTest")
      // MODULE-FLAGS: !llvm.module.flags = !{!0, !1, !2, !3, !4, !5}

      // MODULE-FLAGS:      !0 = !{i32 [[ERRVAL:\d+]], !"error", i32 [[ERRVAL]]}
      module.addFlag(named: "error", constant: IntType.int32.constant(1), behavior: .error)
      // MODULE-FLAGS-NEXT: !1 = !{i32 [[WARNVAL:\d+]], !"warning", i32 [[WARNVAL]]}
      module.addFlag(named: "warning", constant: IntType.int32.constant(2), behavior: .warning)
      // MODULE-FLAGS-NEXT: !2 = !{i32 [[REQUIREVAL:\d+]], !"require", i32 [[REQUIREVAL]]}
      module.addFlag(named: "require", constant: IntType.int32.constant(3), behavior: .require)
      // MODULE-FLAGS-NEXT: !3 = !{i32 [[OVERRIDEVAL:\d+]], !"override", i32 [[OVERRIDEVAL]]}
      module.addFlag(named: "override", constant: IntType.int32.constant(4), behavior: .override)
      // MODULE-FLAGS-NEXT: !4 = !{i32 [[APPVAL:\d+]], !"append", i32 [[APPVAL]]}
      module.addFlag(named: "append", constant: IntType.int32.constant(5), behavior: .append)
      // MODULE-FLAGS-NEXT: !5 = !{i32 [[APPUNIQVAL:\d+]], !"appendUnique", i32 [[APPUNIQVAL]]}
      module.addFlag(named: "appendUnique", constant: IntType.int32.constant(6), behavior: .appendUnique)

      module.dump()
    })
  }

  func testModuleRetrieveFlags() {
    let module = Module(name: "ModuleFlagsTest")
    module.addFlag(named: "error", constant: IntType.int32.constant(1), behavior: .error)
    module.addFlag(named: "warning", constant: IntType.int32.constant(2), behavior: .warning)
    module.addFlag(named: "require", constant: IntType.int32.constant(3), behavior: .require)
    module.addFlag(named: "override", constant: IntType.int32.constant(4), behavior: .override)
    module.addFlag(named: "append", constant: IntType.int32.constant(5), behavior: .append)
    module.addFlag(named: "appendUnique", constant: IntType.int32.constant(6), behavior: .appendUnique)

    guard let flags = module.flags else {
      XCTFail()
      return
    }

    XCTAssertEqual(flags.count, 6)

    XCTAssertEqual(flags[0].behavior, .error)
    XCTAssertEqual(flags[1].behavior, .warning)
    XCTAssertEqual(flags[2].behavior, .require)
    XCTAssertEqual(flags[3].behavior, .override)
    XCTAssertEqual(flags[4].behavior, .append)
    XCTAssertEqual(flags[5].behavior, .appendUnique)

    XCTAssertEqual(flags[0].key, "error")
    XCTAssertEqual(flags[1].key, "warning")
    XCTAssertEqual(flags[2].key, "require")
    XCTAssertEqual(flags[3].key, "override")
    XCTAssertEqual(flags[4].key, "append")
    XCTAssertEqual(flags[5].key, "appendUnique")
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testAddModuleFlags", testAddModuleFlags),
    ("testModuleRetrieveFlags", testModuleRetrieveFlags),
  ])
  #endif
}
