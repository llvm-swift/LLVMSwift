import LLVM
import XCTest
import FileCheck
import Foundation

// NB: Marking this function `public` is the safest way to make sure it gets
// emitted.
public func calculateFibs(_ forward: Bool) -> Double {
  if forward {
    return 1/109
  } else {
    return 1/89
  }
}

typealias FnPtr = @convention(c) (Bool) -> Double
private func getUnderlyingCDecl(_ function: FnPtr) -> JIT.TargetAddress {
  return withoutActuallyEscaping(function) { fn in
    return unsafeBitCast(fn, to: JIT.TargetAddress.self)
  }
}

class JITSpec : XCTestCase {
  typealias MainFnPtr = @convention(c) () -> ()

  func buildTestModule() -> Module {
    let module = Module(name: "Fibonacci")
    let builder = IRBuilder(module: module)

    var llvmSwiftFn = builder.addFunction(
      "calculateSwiftFibs",
      type: FunctionType(argTypes: [IntType.int1],
                         returnType: FloatType.double)
    )
    llvmSwiftFn.linkage = .external

    let function = builder.addFunction(
      "calculateFibs",
      type: FunctionType(argTypes: [IntType.int1],
                         returnType: FloatType.double)
    )
    let entryBB = function.appendBasicBlock(named: "entry")
    builder.positionAtEnd(of: entryBB)

    // allocate space for a local value
    let local = builder.buildAlloca(type: FloatType.double, name: "local")

    // Compare to the condition
    let test = builder.buildICmp(function.parameters[0], IntType.int1.zero(), .equal)

    // Create basic blocks for "then", "else", and "merge"
    let thenBB = function.appendBasicBlock(named: "then")
    let elseBB = function.appendBasicBlock(named: "else")
    let mergeBB = function.appendBasicBlock(named: "merge")

    builder.buildCondBr(condition: test, then: thenBB, else: elseBB)

    // MARK: Then Block

    builder.positionAtEnd(of: thenBB)
    // local = 1/89, the fibonacci series (sort of)
    let thenVal = FloatType.double.constant(1/89)
    // Branch to the merge block
    builder.buildBr(mergeBB)

    // MARK: Else Block
    builder.positionAtEnd(of: elseBB)
    // local = 1/109, the fibonacci series (sort of) backwards
    let elseVal = FloatType.double.constant(1/109)
    // Branch to the merge block
    builder.buildBr(mergeBB)

    // MARK: Merge Block

    builder.positionAtEnd(of: mergeBB)
    let phi = builder.buildPhi(FloatType.double, name: "phi_example")
    phi.addIncoming([
      (thenVal, thenBB),
      (elseVal, elseBB),
    ])
    builder.buildStore(phi, to: local)
    let ret = builder.buildLoad(local, name: "ret")
    builder.buildRet(ret)

    let main = builder.addFunction("main", type: FunctionType(argTypes: [], returnType: VoidType()))
    let mainEntry = main.appendBasicBlock(named: "entry")
    builder.positionAtEnd(of: mainEntry)
    _ = builder.buildCall(llvmSwiftFn, args: [ IntType.int1.constant(1) ])
    _ = builder.buildCall(function, args: [ IntType.int1.constant(1) ])
    builder.buildRetVoid()

    return module
  }

  
  func testEagerIRCompilation() {
    XCTAssert(fileCheckOutput(withPrefixes: ["JIT-EAGER-COMPILE"]) {
      do {
        let jit = try JIT(machine: TargetMachine())
        let module = buildTestModule()

        let testFuncName = jit.mangle(symbol: "calculateSwiftFibs")
        var gotForced = false
        _ = try jit.addEagerlyCompiledIR(module) { (name) -> JIT.TargetAddress in
          gotForced = true
          guard name == testFuncName else {
            return JIT.TargetAddress()
          }
          return getUnderlyingCDecl(calculateFibs)
        }

        XCTAssertFalse(gotForced)
        let fibsAddr = try jit.address(of: "calculateFibs")
        XCTAssertTrue(gotForced)
        let fibFn = unsafeBitCast(fibsAddr, to: FnPtr.self)
        // JIT-EAGER-COMPILE: 0.009174311926605505
        print(fibFn(true))
        // JIT-EAGER-COMPILE: 0.011235955056179775
        print(fibFn(false))
      } catch _ {
        XCTFail()
      }
    })
  }

  func testLazyIRCompilation() {
    XCTAssert(fileCheckOutput(withPrefixes: ["JIT-LAZY-COMPILE"]) {
      do {
        let jit = try JIT(machine: TargetMachine())
        let module = buildTestModule()

        let testFuncName = jit.mangle(symbol: "calculateSwiftFibs")
        var gotForced = false
        _ = try jit.addLazilyCompiledIR(module) { (name) -> JIT.TargetAddress in
          gotForced = true
          guard name == testFuncName else {
            return JIT.TargetAddress()
          }
          return getUnderlyingCDecl(calculateFibs)
        }

        XCTAssertFalse(gotForced)
        let fibsAddr = try jit.address(of: "calculateFibs")
        let fibFn = unsafeBitCast(fibsAddr, to: FnPtr.self)
        // JIT-LAZY-COMPILE: 0.009174311926605505
        print(fibFn(true))
        XCTAssertFalse(gotForced)
        // JIT-LAZY-COMPILE-NEXT: 0.011235955056179775
        print(fibFn(false))
        XCTAssertFalse(gotForced)

        let mainAddr = try jit.address(of: "main")
        let mainFn = unsafeBitCast(mainAddr, to: MainFnPtr.self)
        mainFn()
        XCTAssertTrue(gotForced)
      } catch _ {
        XCTFail()
      }
    })
  }

  func testAddObjectFile() {
    do {
      let module = buildTestModule()
      let targetMachine = try TargetMachine()
      let objBuffer = try targetMachine.emitToMemoryBuffer(module: module, type: .object)

      let jit = JIT(machine: targetMachine)
      let testFuncName = jit.mangle(symbol: "calculateSwiftFibs")
      _ = try jit.addObjectFile(objBuffer) { (name) -> JIT.TargetAddress in
        guard name == testFuncName else {
          return JIT.TargetAddress()
        }
        return getUnderlyingCDecl(calculateFibs)
      }
      let mainAddr = try jit.address(of: "main")
      XCTAssert(mainAddr != JIT.TargetAddress())
    } catch _ {
      XCTFail()
    }
  }

  func testDirectCallbacks() {
    XCTAssert(fileCheckOutput(withPrefixes: ["JIT-DIRECT-CALLBACK"]) {
      do {
        let jit = try JIT(machine: TargetMachine())

        let testFuncName = jit.mangle(symbol: "calculateSwiftFibs")
        let ccAddr = try jit.registerLazyCompile({ (jit) -> JIT.TargetAddress in
          let sm = self.buildTestModule()
          _ = try! jit.addEagerlyCompiledIR(sm) { (name) -> JIT.TargetAddress in
            guard name == testFuncName else {
              return JIT.TargetAddress()
            }
            return getUnderlyingCDecl(calculateFibs)
          }
          let fibsAddr = try! jit.address(of: "calculateFibs")
          try! jit.setIndirectStubPointer(named: "force", address: fibsAddr)
          return fibsAddr
        })
        try jit.createIndirectStub(named: "force", address: ccAddr)
        let fooAddr = try jit.address(of: "force")
        let fooFn = unsafeBitCast(fooAddr, to: FnPtr.self)
        // JIT-DIRECT-CALLBACK: 0.009174311926605505
        print(fooFn(true))
        // JIT-DIRECT-CALLBACK-NEXT: 0.011235955056179775
        print(fooFn(false))
      } catch _ {
        XCTFail()
      }
    })
  }

  func testDirectCallBackToSwift() {
    XCTAssert(fileCheckOutput(withPrefixes: ["JIT-SWIFT-CALLBACK"]) {
      do {
        let jit = try JIT(machine: TargetMachine())

        let testFuncName = jit.mangle(symbol: "calculateSwiftFibs")
        var gotForced = false
        let ccAddr = try jit.registerLazyCompile { (jit) -> JIT.TargetAddress in
          gotForced = true
          let sm = self.buildTestModule()
          _ = try! jit.addEagerlyCompiledIR(sm) { (name) -> JIT.TargetAddress in
            guard name == testFuncName else {
              return JIT.TargetAddress()
            }
            return getUnderlyingCDecl(calculateFibs)
          }
          let mainAddr = getUnderlyingCDecl(calculateFibs)
          try! jit.setIndirectStubPointer(named: "force", address: mainAddr)
          return mainAddr
        }

        // Ensure the main entry point is compiled, causing calculateSwiftFibs
        // to be lazily compiled.
        try jit.createIndirectStub(named: "force", address: ccAddr)
        let forceAddr = try jit.address(of: "force")
        let forceFn = unsafeBitCast(forceAddr, to: FnPtr.self)

        XCTAssertFalse(gotForced)
        // JIT-SWIFT-CALLBACK: 0.009174311926605505
        print(forceFn(true))
        // JIT-SWIFT-CALLBACK-NEXT: 0.011235955056179775
        print(forceFn(false))
        XCTAssertTrue(gotForced)
      } catch _ {
        XCTFail()
      }
    })
  }

  // FIXME: These tests cannot run on Linux without SEGFAULT'ing.
  #if !os(macOS)
  static var allTests = testCase([
    ("testEagerIRCompilation", testEagerIRCompilation),
    ("testLazyIRCompilation", testLazyIRCompilation),
    ("testAddObjectFile", testAddObjectFile),
    ("testDirectCallbacks", testDirectCallbacks),
    ("testDirectCallBackToSwift", testDirectCallBackToSwift),
  ])
  #endif
}

