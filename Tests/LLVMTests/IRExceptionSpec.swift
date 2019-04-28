import LLVM
import XCTest
import FileCheck
import Foundation

class IRExceptionSpec : XCTestCase {
  private let exceptType = StructType(elementTypes: [
    PointerType(pointee: IntType.int8),
    IntType.int32,
  ])

  func testExceptions() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRRESUME"]) {
      // IRRESUME: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
      // IRRESUME-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)
      // IRRESUME: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], VoidType()))
      // IRRESUME-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRRESUME-NEXT: resume i32 5
      builder.buildResume(IntType.int32.constant(5))

      // IRRESUME-NEXT: ret void
      builder.buildRetVoid()
      // IRRESUME-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRCLEANUP"]) {
      // IRCLEANUP: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
      // IRCLEANUP-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)
      // IRCLEANUP: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], VoidType()))
      // IRCLEANUP-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRCLEANUP-NEXT: %0 = landingpad { i8*, i32 }
      // IRCLEANUP-NEXT:         cleanup
      _ = builder.buildLandingPad(returning: exceptType, clauses: [], cleanup: true)

      // IRCLEANUP-NEXT: ret void
      builder.buildRetVoid()
      // IRCLEANUP-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRCATCH"]) {
      // IRCATCH: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
      // IRCATCH-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)

      let except1 = builder.addGlobal("except1", type: PointerType(pointee: IntType.int8))
      let except2 = builder.addGlobal("except2", type: PointerType(pointee: IntType.int8))

      // IRCATCH: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], VoidType()))
      // IRCATCH-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRCATCH-NEXT: %0 = landingpad { i8*, i32 }
      // IRCATCH-NEXT:         catch i8** @except1
      // IRCATCH-NEXT:         catch i8** @except2
      _ = builder.buildLandingPad(returning: exceptType, clauses: [ .`catch`(except1), .`catch`(except2) ], cleanup: false)

      // IRCATCH-NEXT: ret void
      builder.buildRetVoid()
      // IRCATCH-NEXT: }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRCATCHFILTER"]) {
      // IRCATCHFILTER: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
      // IRCATCHFILTER-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBuilderTest")
      let builder = IRBuilder(module: module)

      let except1 = builder.addGlobal("except1", type: PointerType(pointee: IntType.int8))
      let except2 = builder.addGlobal("except2", type: PointerType(pointee: IntType.int8))
      let except3 = builder.addGlobal("except3", type: PointerType(pointee: IntType.int8))

      // IRCATCHFILTER: define void @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType([], VoidType()))
      // IRCATCHFILTER-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRCATCHFILTER-NEXT: %0 = landingpad { i8*, i32 }
      // IRCATCHFILTER-NEXT:         catch i8** @except1
      // IRCATCHFILTER-NEXT:         filter [2 x i8**] [i8** @except2, i8** @except3]
      _ = builder.buildLandingPad(
        returning: exceptType,
        clauses: [ .`catch`(except1), .filter(except1.type, [ except2, except3 ]) ],
        cleanup: false
      )

      // IRCATCHFILTER-NEXT: ret void
      builder.buildRetVoid()
      // IRCATCHFILTER-NEXT: }
      module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testExceptions", testExceptions),
  ])
  #endif
}
