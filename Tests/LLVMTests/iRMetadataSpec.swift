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

  func testFPMathTag() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRFPMATHMETADATA"]) {
      // IRFPMATHMETADATA: ; ModuleID = '[[ModuleName:IRFPMathTest]]'
      // IRFPMATHMETADATA-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRFPMathTest")
      let builder = IRBuilder(module: module)
      let MDB = MDBuilder()
      XCTAssertNil(builder.defaultFloatingPointMathTag)
      builder.defaultFloatingPointMathTag = MDB.buildFPMath(0.1)

      // IRFPMATHMETADATA: define float @test(float, float) {
      let main = builder.addFunction("test",
                                     type: FunctionType(argTypes: [FloatType.float, FloatType.float],
                                                        returnType: FloatType.float))
      // IRFPMATHMETADATA-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRFPMATHMETADATA-NEXT: %2 = fadd float %0, %1, !fpmath !0
      let value = builder.buildAdd(main.parameters[0], main.parameters[1])
      // IRFPMATHMETADATA-NEXT: ret float %2
      builder.buildRet(value)
      // IRFPMATHMETADATA-NEXT: }

      // IRFPMATHMETADATA: !0 = !{float 0x3FB99999A0000000}
      module.dump()
    })
  }

  func testBranchWeights() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRBWMETADATA"]) {
      // IRBWMETADATA: ; ModuleID = '[[ModuleName:IRBWMetadataTest]]'
      // IRBWMETADATA-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBWMetadataTest")
      let builder = IRBuilder(module: module)
      let MDB = MDBuilder()

      // IRBWMETADATA: define float @test(i1, float, float) {
      let main = builder.addFunction("test",
                                     type: FunctionType(argTypes: [IntType.int1, FloatType.float, FloatType.float],
                                                        returnType: FloatType.float))
      // IRBWMETADATA-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      let thenBlock = main.appendBasicBlock(named: "then")
      let elseBlock = main.appendBasicBlock(named: "else")
      let mergeBB = main.appendBasicBlock(named: "merge")
      let bws = MDB.buildBranchWeights([
        1000,
        2000,
      ])
      // IRBWMETADATA-NEXT: br i1 %0, label %then, label %else, !prof !0
      let branch = builder.buildCondBr(condition: main.parameters[0], then: thenBlock, else: elseBlock)
      branch.addMetadata(bws, kind: .prof)

      // IRBWMETADATA: then:
      // IRBWMETADATA-NEXT: %3 = fadd float %1, %2
      builder.positionAtEnd(of: thenBlock)
      let opThen = builder.buildAdd(main.parameters[1], main.parameters[2])
      builder.buildBr(mergeBB)

      // IRBWMETADATA: else:
      // IRBWMETADATA-NEXT: %4 = fsub float %1, %2
      builder.positionAtEnd(of: elseBlock)
      let opElse = builder.buildSub(main.parameters[1], main.parameters[2])
      builder.buildBr(mergeBB)

      // IRBWMETADATA: merge:
      // IRBWMETADATA-NEXT: %5 = phi float [ %3, %then ], [ %4, %else ]
      builder.positionAtEnd(of: mergeBB)
      let phi = builder.buildPhi(FloatType.float)
      phi.addIncoming([
        (opThen, thenBlock),
        (opElse, elseBlock),
      ])

      // IRBWMETADATA-NEXT: ret float %5
      builder.buildRet(phi)
      // IRBWMETADATA-NEXT: }

      // IRBWMETADATA: !0 = !{!"branch_weights", i32 1000, i32 2000}
      module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testGlobalMetadata", testGlobalMetadata),
    ("testFPMathTag", testFPMathTag),
    ("testBranchWeights", testBranchWeights),
  ])
  #endif
}

