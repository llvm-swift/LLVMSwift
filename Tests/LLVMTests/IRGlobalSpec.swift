import LLVM
import XCTest
import FileCheck
import Foundation

class IRGlobalSpec : XCTestCase {
  func testIRInertGlobal() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRINERTGLOBAL"]) {
      // IRINERTGLOBAL: ; ModuleID = '[[ModuleName:IRInertGlobalTest]]'
      // IRINERTGLOBAL-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRInertGlobalTest")
      let builder = IRBuilder(module: module)
      // IRINERTGLOBAL: @external_global = external constant i32
      let extGlobal = builder.addGlobal("external_global", type: IntType.int32)
      extGlobal.isGlobalConstant = true
      // IRINERTGLOBAL: @got.external_global = private unnamed_addr constant i32* @external_global
      var gotGlobal = builder.addGlobal("got.external_global",
                                        initializer: extGlobal)
      gotGlobal.linkage = .`private`
      gotGlobal.unnamedAddressKind = .global
      gotGlobal.isGlobalConstant = true

      // IRINERTGLOBAL: @external_relative_reference = global i32 trunc (i64 sub (i64 ptrtoint (i32** @got.external_global to i64), i64 ptrtoint (i32* @external_relative_reference to i64)) to i32)
      let ext_relative_reference = builder.addGlobal("external_relative_reference", type: IntType.int32)
      ext_relative_reference.initializer = Constant<Unsigned>.pointerToInt(gotGlobal, .int64)
        .subtracting(Constant<Unsigned>.pointerToInt(ext_relative_reference, .int64)).truncate(to: .int32)
      module.dump()
    })
  }

  func testIRCOMDATGlobal() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRCOMDATGLOBAL"]) {
      // IRCOMDATGLOBAL: ; ModuleID = '[[ModuleName:IRCOMDATGLOBALTest]]'
      // IRCOMDATGLOBAL-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRCOMDATGLOBALTest")
      let builder = IRBuilder(module: module)

      // IRCOMDATGLOBAL: $test_any = comdat any
      let comdatAnySec = module.comdat(named: "test_any")
      comdatAnySec.selectionKind = .any

      // IRCOMDATGLOBAL: $test_largest = comdat largest
      let comdatLargestSec = module.comdat(named: "test_largest")
      comdatLargestSec.selectionKind = .largest

      // IRCOMDATGLOBAL: $test_no_deduplicate = comdat nodeduplicate
      let comdatNoDeduplicateSec = module.comdat(named: "test_no_deduplicate")
      comdatNoDeduplicateSec.selectionKind = .noDeduplicate

      // IRCOMDATGLOBAL: $test_same_size = comdat samesize
      let comdatSameSizeSec = module.comdat(named: "test_same_size")
      comdatSameSizeSec.selectionKind = .sameSize

      // IRCOMDATGLOBAL: $test_exact_match = comdat exactmatch
      let comdatExactSec = module.comdat(named: "test_exact_match")
      comdatExactSec.selectionKind = .exactMatch

      let i = IntType.int8.constant(42)

      // IRCOMDATGLOBAL: @comdat_global_any = global i8 42, comdat($test_any)
      var comdatGlobalAny = builder.addGlobal("comdat_global_any", initializer: i)
      comdatGlobalAny.comdat = comdatAnySec

      // IRCOMDATGLOBAL: @comdat_global_largest = global i8 42, comdat($test_largest)
      var comdatGlobalLargest = builder.addGlobal("comdat_global_largest", initializer: i)
      comdatGlobalLargest.comdat = comdatLargestSec

      // IRCOMDATGLOBAL: @comdat_global_no_deduplicate = global i8 42, comdat($test_no_deduplicate)
      var comdatGlobalNoDuduplicate = builder.addGlobal("comdat_global_no_deduplicate", initializer: i)
      comdatGlobalNoDuduplicate.comdat = comdatNoDeduplicateSec

      // IRCOMDATGLOBAL: @comdat_global_same_size = global i8 42, comdat($test_same_size)
      var comdatGlobalSameSize = builder.addGlobal("comdat_global_same_size", initializer: i)
      comdatGlobalSameSize.comdat = comdatSameSizeSec

      // IRCOMDATGLOBAL: @comdat_global_exact_match = global i8 42, comdat($test_exact_match)
      var comdatGlobalExactMatch = builder.addGlobal("comdat_global_exact_match", initializer: i)
      comdatGlobalExactMatch.comdat = comdatExactSec

      module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testIRInertGlobal", testIRInertGlobal),
    ("testIRCOMDATGlobal", testIRCOMDATGlobal),
  ])
  #endif
}

