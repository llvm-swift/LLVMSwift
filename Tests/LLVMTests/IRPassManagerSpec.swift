import LLVM
import XCTest
import FileCheck
import Foundation

class IRPassManagerSpec : XCTestCase {
  func testEmptyPassPipeliner() {
    let module = Module(name: "Test")
    let pipeliner = PassPipeliner(module: module)
    XCTAssertTrue(pipeliner.stages.isEmpty)
  }

  func testAppendStages() {
    let module = Module(name: "Test")
    let pipeliner = PassPipeliner(module: module)
    XCTAssertTrue(pipeliner.stages.isEmpty)
    var rng = SystemRandomNumberGenerator()
    let stageCount = (rng.next() % 25)
    for i in 0..<stageCount {
      pipeliner.addStage("stage \(i)") { p in }
    }

    XCTAssertEqual(pipeliner.stages.count, Int(stageCount))
  }

  func testAppendStandardStages() {
    let module = Module(name: "Test")
    let pipeliner = PassPipeliner(module: module)
    XCTAssertTrue(pipeliner.stages.isEmpty)
    for i in 0...3 {
      let optLevel: CodeGenOptLevel
      switch i {
      case 0:
        optLevel = .none
      case 1:
        optLevel = .less
      case 2:
        optLevel = .`default`
      case 3:
        optLevel = .aggressive
      default:
        fatalError()
      }
      for j in 0...3 {
        let sizeLevel: CodeGenOptLevel
        switch i {
        case 0:
          sizeLevel = .none
        case 1:
          sizeLevel = .less
        case 2:
          sizeLevel = .`default`
        case 3:
          sizeLevel = .aggressive
        default:
          fatalError()
        }
        pipeliner.addStandardModulePipeline("Opt \(i) Size \(j)", optimization: optLevel, size: sizeLevel)
      }
    }

    XCTAssertEqual(pipeliner.stages.count, 4 * 4)

    for i in 0...3 {
      let optLevel: CodeGenOptLevel
      switch i {
      case 0:
        optLevel = .none
      case 1:
        optLevel = .less
      case 2:
        optLevel = .`default`
      case 3:
        optLevel = .aggressive
      default:
        fatalError()
      }
      for j in 0...3 {
        let sizeLevel: CodeGenOptLevel
        switch i {
        case 0:
          sizeLevel = .none
        case 1:
          sizeLevel = .less
        case 2:
          sizeLevel = .`default`
        case 3:
          sizeLevel = .aggressive
        default:
          fatalError()
        }
        pipeliner.addStandardFunctionPipeline("Opt \(i) Size \(j)", optimization: optLevel, size: sizeLevel)
      }
    }

    XCTAssertEqual(pipeliner.stages.count, (4 * 4) + (4 * 4))
  }

  func testExecute() {
    let module = self.createModule()
    let pipeliner = PassPipeliner(module: module)

    pipeliner.addStandardFunctionPipeline("Standard", optimization: .aggressive)
    pipeliner.addStandardModulePipeline("Module", optimization: .aggressive)

    XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: [ "CHECK-EXECUTE-STDOPT" ]) {
      module.dump()

      // CHECK-EXECUTE-STDOPT:  ; ModuleID = 'Test'
      // CHECK-EXECUTE-STDOPT:  source_filename = "Test"

      // CHECK-EXECUTE-STDOPT:  define i32 @fun(i32, i32) {
      // CHECK-EXECUTE-STDOPT:    entry:
      // CHECK-EXECUTE-STDOPT:    %2 = alloca i32, align 4
      // CHECK-EXECUTE-STDOPT:    %3 = alloca i32, align 4
      // CHECK-EXECUTE-STDOPT:    %4 = alloca i32, align 4
      // CHECK-EXECUTE-STDOPT:    store i32 %0, i32* %2
      // CHECK-EXECUTE-STDOPT:    store i32 %1, i32* %3
      // CHECK-EXECUTE-STDOPT:    store i32 4, i32* %4
      // CHECK-EXECUTE-STDOPT:    %5 = load i32, i32* %2, align 4
      // CHECK-EXECUTE-STDOPT:    %6 = icmp eq i32 %5, 1
      // CHECK-EXECUTE-STDOPT:    br i1 %6, label %block1, label %block2

      // CHECK-EXECUTE-STDOPT:    block1:
      // CHECK-EXECUTE-STDOPT:    %7 = load i32, i32* %2, align 4
      // CHECK-EXECUTE-STDOPT:    %8 = load i32, i32* %4, align 4
      // CHECK-EXECUTE-STDOPT:    %9 = add nsw i32 %7, %8
      // CHECK-EXECUTE-STDOPT:    store i32 %9, i32* %4
      // CHECK-EXECUTE-STDOPT:    br label %merge

      // CHECK-EXECUTE-STDOPT:    block2:
      // CHECK-EXECUTE-STDOPT:    %10 = load i32, i32* %3, align 4
      // CHECK-EXECUTE-STDOPT:    %11 = load i32, i32* %4, align 4
      // CHECK-EXECUTE-STDOPT:    %12 = add nsw i32 %10, %11
      // CHECK-EXECUTE-STDOPT:    store i32 %12, i32* %4
      // CHECK-EXECUTE-STDOPT:    br label %merge

      // CHECK-EXECUTE-STDOPT:    merge:
      // CHECK-EXECUTE-STDOPT:    %13 = load i32, i32* %4, align 4
      // CHECK-EXECUTE-STDOPT:    ret i32 %13
      // CHECK-EXECUTE-STDOPT  }

      pipeliner.execute()

      module.dump()

      // CHECK-EXECUTE-STDOPT: ; ModuleID = 'Test'
      // CHECK-EXECUTE-STDOPT: source_filename = "Test"

      // CHECK-EXECUTE-STDOPT: ; Function Attrs: norecurse nounwind readnone
      // CHECK-EXECUTE-STDOPT: define i32 @fun(i32, i32) local_unnamed_addr #0 {
      // CHECK-EXECUTE-STDOPT:   entry:
      // CHECK-EXECUTE-STDOPT:   %2 = icmp eq i32 %0, 1
      // CHECK-EXECUTE-STDOPT:   %3 = add nsw i32 %1, 4
      // CHECK-EXECUTE-STDOPT:   %.0 = select i1 %2, i32 5, i32 %3
      // CHECK-EXECUTE-STDOPT:   ret i32 %.0
      // CHECK-EXECUTE-STDOPT: }
    })
  }

  private func createModule() -> Module {
    let module = Module(name: "Test")

    let builder = IRBuilder(module: module)
    let fun = builder.addFunction("fun",
                                  type: FunctionType([
                                    IntType.int32,
                                    IntType.int32,
                                  ], IntType.int32))
    let entry = fun.appendBasicBlock(named: "entry")
    let block1 = fun.appendBasicBlock(named: "block1")
    let block2 = fun.appendBasicBlock(named: "block2")
    let merge = fun.appendBasicBlock(named: "merge")

    builder.positionAtEnd(of: entry)
    let val1 = builder.buildAlloca(type: IntType.int32, alignment: Alignment(4))
    let val2 = builder.buildAlloca(type: IntType.int32, alignment: Alignment(4))
    let val3 = builder.buildAlloca(type: IntType.int32, alignment: Alignment(4))
    builder.buildStore(fun.parameters[0], to: val1)
    builder.buildStore(fun.parameters[1], to: val2)
    builder.buildStore(IntType.int32.constant(4), to: val3)
    let reloadVal1 = builder.buildLoad(val1, alignment: Alignment(4))
    let cmpVal = builder.buildICmp(reloadVal1, IntType.int32.constant(1), .equal)
    builder.buildCondBr(condition: cmpVal, then: block1, else: block2)

    builder.positionAtEnd(of: block1)
    let reloadVal2 = builder.buildLoad(val1, alignment: Alignment(4))
    let reloadVal3 = builder.buildLoad(val3, alignment: Alignment(4))
    let sum1 = builder.buildAdd(reloadVal2, reloadVal3, overflowBehavior: .noSignedWrap)
    builder.buildStore(sum1, to: val3)
    builder.buildBr(merge)

    builder.positionAtEnd(of: block2)
    let reloadVal4 = builder.buildLoad(val2, alignment: Alignment(4))
    let reloadVal5 = builder.buildLoad(val3, alignment: Alignment(4))
    let sum2 = builder.buildAdd(reloadVal4, reloadVal5, overflowBehavior: .noSignedWrap)
    builder.buildStore(sum2, to: val3)
    builder.buildBr(merge)

    builder.positionAtEnd(of: merge)
    let reloadVal6 = builder.buildLoad(val3, alignment: Alignment(4))
    builder.buildRet(reloadVal6)

    return module
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testEmptyPassPipeliner", testEmptyPassPipeliner),
    ("testAppendStages", testAppendStages),
    ("testAppendStandardStages", testAppendStandardStages),
    ("testExecute", testExecute),
  ])
  #endif
}
