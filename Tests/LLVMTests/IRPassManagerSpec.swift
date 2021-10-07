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

      // CHECK-EXECUTE-STDOPT:  define i32 @fun(i32 %0, i32 %1) {
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

      // CHECK-EXECUTE-STDOPT: ; Function Attrs: mustprogress nofree norecurse nosync nounwind readnone willreturn
      // CHECK-EXECUTE-STDOPT: define i32 @fun(i32 %0, i32 %1) local_unnamed_addr #0 {
      // CHECK-EXECUTE-STDOPT:   entry:
      // CHECK-EXECUTE-STDOPT:   %2 = icmp eq i32 %0, 1
      // CHECK-EXECUTE-STDOPT:   %3 = add nsw i32 %1, 4
      // CHECK-EXECUTE-STDOPT:   %.0 = select i1 %2, i32 5, i32 %3
      // CHECK-EXECUTE-STDOPT:   ret i32 %.0
      // CHECK-EXECUTE-STDOPT: }
    })
  }

  func testExecuteWithMask() {
    let module = self.createModule()
    let pipeliner = PassPipeliner(module: module)

    pipeliner.addStage("Empty") { _ in }
    pipeliner.addStage("Identity") { _ in }
    pipeliner.addStage("None") { _ in }
    pipeliner.addStandardFunctionPipeline("AggressiveFunc", optimization: .aggressive)
    pipeliner.addStandardModulePipeline("AggressiveModule", optimization: .aggressive)

    XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: [ "CHECK-EXECUTE-MASK" ]) {
      module.dump()

      // CHECK-EXECUTE-MASK:  ; ModuleID = 'Test'
      // CHECK-EXECUTE-MASK:  source_filename = "Test"

      // CHECK-EXECUTE-MASK:  define i32 @fun(i32 %0, i32 %1) {
      // CHECK-EXECUTE-MASK:    entry:
      // CHECK-EXECUTE-MASK:    %2 = alloca i32, align 4
      // CHECK-EXECUTE-MASK:    %3 = alloca i32, align 4
      // CHECK-EXECUTE-MASK:    %4 = alloca i32, align 4
      // CHECK-EXECUTE-MASK:    store i32 %0, i32* %2
      // CHECK-EXECUTE-MASK:    store i32 %1, i32* %3
      // CHECK-EXECUTE-MASK:    store i32 4, i32* %4
      // CHECK-EXECUTE-MASK:    %5 = load i32, i32* %2, align 4
      // CHECK-EXECUTE-MASK:    %6 = icmp eq i32 %5, 1
      // CHECK-EXECUTE-MASK:    br i1 %6, label %block1, label %block2

      // CHECK-EXECUTE-MASK:    block1:
      // CHECK-EXECUTE-MASK:    %7 = load i32, i32* %2, align 4
      // CHECK-EXECUTE-MASK:    %8 = load i32, i32* %4, align 4
      // CHECK-EXECUTE-MASK:    %9 = add nsw i32 %7, %8
      // CHECK-EXECUTE-MASK:    store i32 %9, i32* %4
      // CHECK-EXECUTE-MASK:    br label %merge

      // CHECK-EXECUTE-MASK:    block2:
      // CHECK-EXECUTE-MASK:    %10 = load i32, i32* %3, align 4
      // CHECK-EXECUTE-MASK:    %11 = load i32, i32* %4, align 4
      // CHECK-EXECUTE-MASK:    %12 = add nsw i32 %10, %11
      // CHECK-EXECUTE-MASK:    store i32 %12, i32* %4
      // CHECK-EXECUTE-MASK:    br label %merge

      // CHECK-EXECUTE-MASK:    merge:
      // CHECK-EXECUTE-MASK:    %13 = load i32, i32* %4, align 4
      // CHECK-EXECUTE-MASK:    ret i32 %13
      // CHECK-EXECUTE-MASK:  }

      pipeliner.execute(mask: [ "Empty", "Identity", "None" ])

      module.dump()

      // CHECK-EXECUTE-MASK:  ; ModuleID = 'Test'
      // CHECK-EXECUTE-MASK:  source_filename = "Test"

      // CHECK-EXECUTE-MASK:  define i32 @fun(i32 %0, i32 %1) {
      // CHECK-EXECUTE-MASK:    entry:
      // CHECK-EXECUTE-MASK:    %2 = alloca i32, align 4
      // CHECK-EXECUTE-MASK:    %3 = alloca i32, align 4
      // CHECK-EXECUTE-MASK:    %4 = alloca i32, align 4
      // CHECK-EXECUTE-MASK:    store i32 %0, i32* %2
      // CHECK-EXECUTE-MASK:    store i32 %1, i32* %3
      // CHECK-EXECUTE-MASK:    store i32 4, i32* %4
      // CHECK-EXECUTE-MASK:    %5 = load i32, i32* %2, align 4
      // CHECK-EXECUTE-MASK:    %6 = icmp eq i32 %5, 1
      // CHECK-EXECUTE-MASK:    br i1 %6, label %block1, label %block2

      // CHECK-EXECUTE-MASK:    block1:
      // CHECK-EXECUTE-MASK:    %7 = load i32, i32* %2, align 4
      // CHECK-EXECUTE-MASK:    %8 = load i32, i32* %4, align 4
      // CHECK-EXECUTE-MASK:    %9 = add nsw i32 %7, %8
      // CHECK-EXECUTE-MASK:    store i32 %9, i32* %4
      // CHECK-EXECUTE-MASK:    br label %merge

      // CHECK-EXECUTE-MASK:    block2:
      // CHECK-EXECUTE-MASK:    %10 = load i32, i32* %3, align 4
      // CHECK-EXECUTE-MASK:    %11 = load i32, i32* %4, align 4
      // CHECK-EXECUTE-MASK:    %12 = add nsw i32 %10, %11
      // CHECK-EXECUTE-MASK:    store i32 %12, i32* %4
      // CHECK-EXECUTE-MASK:    br label %merge

      // CHECK-EXECUTE-MASK:    merge:
      // CHECK-EXECUTE-MASK:    %13 = load i32, i32* %4, align 4
      // CHECK-EXECUTE-MASK:    ret i32 %13
      // CHECK-EXECUTE-MASK:  }
    })
  }

  func testIdempotentInternalize() {
    let module = Module(name: "Internalize")
    let builder = IRBuilder(module: module)
    let addFunction: (String) -> Void = { (name) in
      var fun = module.addFunction(name, type: FunctionType([], VoidType()))
      fun.linkage = .external
      let block = fun.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: block)
      builder.buildRetVoid()
    }
    for name in [ "a", "b", "c", "d", "e", "f", "g" ] {
      addFunction(name)
    }
    let pipeliner = PassPipeliner(module: module)
    pipeliner.addStage("Internalize") { builder in
      builder.add(.internalize { g in
        print("Internalizing: \(g.name)")
        return true
      })
    }

    XCTAssertTrue(fileCheckOutput(of: .stdout, withPrefixes: [ "CHECK-IDEMPOTENT-INTERNALIZE" ]) {
      for function in module.functions {
        XCTAssertTrue(function.linkage == .external)
      }
      // CHECK-IDEMPOTENT-INTERNALIZE: Internalizing: a
      // CHECK-IDEMPOTENT-INTERNALIZE: Internalizing: b
      // CHECK-IDEMPOTENT-INTERNALIZE: Internalizing: c
      // CHECK-IDEMPOTENT-INTERNALIZE: Internalizing: d
      // CHECK-IDEMPOTENT-INTERNALIZE: Internalizing: e
      // CHECK-IDEMPOTENT-INTERNALIZE: Internalizing: f
      // CHECK-IDEMPOTENT-INTERNALIZE: Internalizing: g
      pipeliner.execute()
      for function in module.functions {
        XCTAssertTrue(function.linkage == .external)
      }
    })
  }

  func testInternalizeCallback() {
    let module = Module(name: "Internalize")
    let builder = IRBuilder(module: module)
    let addFunction: (String) -> Void = { (name) in
      var fun = module.addFunction(name, type: FunctionType([], VoidType()))
      fun.linkage = .external
      let block = fun.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: block)
      builder.buildRetVoid()
    }
    for name in [ "a", "b", "c", "d", "e", "f", "g" ] {
      addFunction(name)
    }
    let pipeliner = PassPipeliner(module: module)
    pipeliner.addStage("Internalize") { builder in
      builder.add(.internalize { g in
        print("Internalizing: \(g.name)")
        return false
      })
    }

    XCTAssertTrue(fileCheckOutput(of: .stdout, withPrefixes: [ "CHECK-INTERNALIZE" ]) {
      for function in module.functions {
        XCTAssertTrue(function.linkage == .external)
      }
      // CHECK-INTERNALIZE: Internalizing: a
      // CHECK-INTERNALIZE: Internalizing: b
      // CHECK-INTERNALIZE: Internalizing: c
      // CHECK-INTERNALIZE: Internalizing: d
      // CHECK-INTERNALIZE: Internalizing: e
      // CHECK-INTERNALIZE: Internalizing: f
      // CHECK-INTERNALIZE: Internalizing: g
      pipeliner.execute()
      for function in module.functions {
        XCTAssertTrue(function.linkage == .internal)
      }
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
    let reloadVal1 = builder.buildLoad(val1, type: IntType.int32, alignment: Alignment(4))
    let cmpVal = builder.buildICmp(reloadVal1, IntType.int32.constant(1), .equal)
    builder.buildCondBr(condition: cmpVal, then: block1, else: block2)

    builder.positionAtEnd(of: block1)
    let reloadVal2 = builder.buildLoad(val1, type: IntType.int32, alignment: Alignment(4))
    let reloadVal3 = builder.buildLoad(val3, type: IntType.int32, alignment: Alignment(4))
    let sum1 = builder.buildAdd(reloadVal2, reloadVal3, overflowBehavior: .noSignedWrap)
    builder.buildStore(sum1, to: val3)
    builder.buildBr(merge)

    builder.positionAtEnd(of: block2)
    let reloadVal4 = builder.buildLoad(val2, type: IntType.int32, alignment: Alignment(4))
    let reloadVal5 = builder.buildLoad(val3, type: IntType.int32, alignment: Alignment(4))
    let sum2 = builder.buildAdd(reloadVal4, reloadVal5, overflowBehavior: .noSignedWrap)
    builder.buildStore(sum2, to: val3)
    builder.buildBr(merge)

    builder.positionAtEnd(of: merge)
    let reloadVal6 = builder.buildLoad(val3, type: IntType.int32, alignment: Alignment(4))
    builder.buildRet(reloadVal6)

    return module
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testEmptyPassPipeliner", testEmptyPassPipeliner),
    ("testAppendStages", testAppendStages),
    ("testAppendStandardStages", testAppendStandardStages),
    ("testExecute", testExecute),
    ("testExecuteWithMask", testExecuteWithMask),
    ("testIdempotentInternalize", testIdempotentInternalize),
    ("testInternalizeCallback", testInternalizeCallback),
  ])
  #endif
}
