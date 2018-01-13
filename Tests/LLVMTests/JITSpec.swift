import LLVM
import XCTest
import FileCheck
import Foundation

class JITSpec : XCTestCase {
  func testFibonacci() {
    XCTAssert(fileCheckOutput(withPrefixes: ["JIT"]) {
      let module = Module(name: "Fibonacci")
      let builder = IRBuilder(module: module)

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

      // Setup the JIT
      let jit = try! JIT(module: module, machine: TargetMachine())
      typealias FnPtr = @convention(c) (Bool) -> Double
      // Retrieve a handle to the function we're going to invoke
      let fnAddr = jit.addressOfFunction(name: "calculateFibs")
      let fn = unsafeBitCast(fnAddr, to: FnPtr.self)
      // JIT: 0.00917431192660551
      print(fn(true))
      // JIT-NEXT: 0.0112359550561798
      print(fn(false))
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testFibonacci", testFibonacci),
  ])
  #endif
}

