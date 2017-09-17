import LLVM
import XCTest
import Foundation

class ORCJITSpec : XCTestCase {
  func testRunSimpleProgram() {
    typealias TestFunction = @convention(c) () -> Int64
    do {
      let jit = try ORCJIT(machine: TargetMachine())
      let module = Module(name: #function)
      let builder = IRBuilder(module: module)
      let mainType = FunctionType(argTypes: [], returnType: IntType.int64)
      let testName = "\(#function)_llvm"
      let main = builder.addFunction(testName, type: mainType)

      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      builder.buildRet(IntType.int64.constant(100))

      try jit.addModule(module)

      guard let addr = jit.address(of: testName) else {
        XCTFail("Could not find \(testName) in jit")
        return
      }

      let testFunction = unsafeBitCast(addr, to: TestFunction.self)
      XCTAssertEqual(testFunction(), 100)
    } catch {
      XCTFail("Could not initialize JIT: \(error)")
    }
  }

  func testFunctionWithInputs() {
    typealias TestFunction = @convention(c) (Int64, Int64) -> Int64
    do {
      let jit = try ORCJIT(machine: TargetMachine())
      let module = Module(name: #function)
      let builder = IRBuilder(module: module)
      let mainType = FunctionType(argTypes: [IntType.int64, IntType.int64],
                                  returnType: IntType.int64)
      let testName = "\(#function)_llvm"
      let main = builder.addFunction(testName, type: mainType)

      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      let add = builder.buildAdd(main.parameter(at: 0)!,
                                 main.parameter(at: 1)!)

      builder.buildRet(add)

      try jit.addModule(module)

      guard let addr = jit.address(of: testName) else {
        XCTFail("Could not find \(testName) in jit")
        return
      }

      let testFunction = unsafeBitCast(addr, to: TestFunction.self)
      XCTAssertEqual(testFunction(50, 75), 125)
    } catch {
      XCTFail("Could not initialize JIT: \(error)")
    }
  }
}
