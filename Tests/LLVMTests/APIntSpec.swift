import LLVM
import XCTest
import FileCheck
import Foundation

class APIntSpec : XCTestCase {
  func testZeroInit() {
    let zero = APInt()
    XCTAssert(zero == APInt(width: 1, value: 0))
    XCTAssert(zero.zeroExtend(to: 64) == APInt(width: 64, value: 0))
    XCTAssert(zero.signExtend(to: 64) == APInt(width: 64, value: 0))
  }

  func testNegativeCount() {
    let minus1 = APInt(width: 128, value: UInt64(bitPattern: -1), signed: true)
    XCTAssertEqual(0, minus1.leadingZeroBitCount)
    XCTAssertEqual(0, minus1.trailingZeroBitCount)
    XCTAssertEqual(128, minus1.nonzeroBitCount)
  }

  func testi33Count() {
    let i33minus2 = APInt(width: 33, value: UInt64(bitPattern: -2), signed: true)
    XCTAssertEqual(0, i33minus2.leadingZeroBitCount)
    XCTAssertEqual(1, i33minus2.trailingZeroBitCount)
    XCTAssertEqual(32, i33minus2.nonzeroBitCount)
  }

  func testi61Count() {
    let i61 = APInt(width: 61, value: 1 << 15)
    XCTAssertEqual(45, i61.leadingZeroBitCount)
    XCTAssertEqual(15, i61.trailingZeroBitCount)
    XCTAssertEqual(1, i61.nonzeroBitCount)
  }

  func testi65Count() {
    let i65 = APInt(width: 65, value: 0, signed: true)

    XCTAssertEqual(65, i65.leadingZeroBitCount)
    XCTAssertEqual(65, i65.trailingZeroBitCount)
    XCTAssertEqual(0, i65.nonzeroBitCount)
  }

  func testi1() {
    let negTwo = APInt(width: 1, value: UInt64(bitPattern: -2), signed: true)
    let negOne = APInt(width: 1, value: UInt64(bitPattern: -1), signed: true)
    let zero = APInt(width: 1, value: 0)
    let one = APInt(width: 1, value: 1)
    let two = APInt(width: 1, value: 2)

    XCTAssertEqual(0, negTwo.signExtendedValue!)
    XCTAssertEqual(-1, negOne.signExtendedValue!)
    XCTAssertEqual(1, negOne.zeroExtendedValue!)
    XCTAssertEqual(0, zero.zeroExtendedValue!)
    XCTAssertEqual(-1, one.signExtendedValue!)
    XCTAssertEqual(1, one.zeroExtendedValue!)
    XCTAssertEqual(0, two.zeroExtendedValue!)
    XCTAssertEqual(0, two.signExtendedValue!)

    // Basic equalities for 1-bit values.
    XCTAssertEqual(zero, two)
    XCTAssertEqual(zero, negTwo)
    XCTAssertEqual(one, negOne)
    XCTAssertEqual(two, negTwo)

    // Additions.
    XCTAssertEqual(two, one + one)
    XCTAssertEqual(zero, negOne + one)
    XCTAssertEqual(negTwo, negOne + negOne)

    // Subtractions.
    XCTAssertEqual(negTwo, negOne - one)
    XCTAssertEqual(two, one - negOne)
    XCTAssertEqual(zero, one - one)

    // And
    XCTAssertEqual(zero, zero & zero)
    XCTAssertEqual(zero, one & zero)
    XCTAssertEqual(zero, zero & one)
    XCTAssertEqual(one, one & one)
    XCTAssertEqual(zero, zero & zero)
    XCTAssertEqual(zero, negOne & zero)
    XCTAssertEqual(zero, zero & negOne)
    XCTAssertEqual(negOne, negOne & negOne)

    // Or
    XCTAssertEqual(zero, zero | zero)
    XCTAssertEqual(one, one | zero)
    XCTAssertEqual(one, zero | one)
    XCTAssertEqual(one, one | one)
    XCTAssertEqual(zero, zero | zero)
    XCTAssertEqual(negOne, negOne | zero)
    XCTAssertEqual(negOne, zero | negOne)
    XCTAssertEqual(negOne, negOne | negOne)

    // Xor
    XCTAssertEqual(zero, zero ^ zero)
    XCTAssertEqual(one, one ^ zero)
    XCTAssertEqual(one, zero ^ one)
    XCTAssertEqual(zero, one ^ one)
    XCTAssertEqual(zero, zero ^ zero)
    XCTAssertEqual(negOne, negOne ^ zero)
    XCTAssertEqual(negOne, zero ^ negOne)
    XCTAssertEqual(zero, negOne ^ negOne)

    // Shifts.
    XCTAssertEqual(zero, one << 1)
    XCTAssertEqual(one, one << 0)
    XCTAssertEqual(zero, one.logicallyShiftedRight(by: 1))

    // Multiplies.
    XCTAssertEqual(negOne, negOne * one)
    XCTAssertEqual(negOne, one * negOne)
    XCTAssertEqual(one, negOne * negOne)
    XCTAssertEqual(one, one * one)
  }

  func testMultiply() {
    let i64 = APInt(width: 64, value: 1234)

    XCTAssertEqual(7006652, i64 * 5678)
    XCTAssertEqual(7006652, 5678 * i64)

    let i128 = APInt(width: 128, value: 1 << 64)
    var i128_1234 = APInt(width: 128, value: 1234)
    i128_1234 <<= 64
    XCTAssertEqual(i128_1234, i128 * APInt(width: 128, value: 1234))
    XCTAssertEqual(i128_1234, APInt(width: 128, value: 1234) * i128)

    var i96 = APInt(width: 96, value: 1 << 64)
    i96 *= APInt(width: 96, value: UInt64.max)
    XCTAssertEqual(96, i96.leadingZeroBitCount)
    XCTAssertEqual(0, i96.nonzeroBitCount)
    XCTAssertEqual(96, i96.trailingZeroBitCount)
  }

  func testArbitraryIRGen() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["ARBITRARY"]) {
      // ARBITRARY: ; ModuleID = '[[ModuleName:ArbitraryTest]]'
      // ARBITRARY-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "ArbitraryTest")
      let builder = IRBuilder(module: module)
      let intType = IntType(width: 420)
      // ARBITRARY: define i420 @test() {
      let main = builder.addFunction("test",
                                     type: FunctionType(argTypes: [],
                                                        returnType: intType))
      // ARBITRARY-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      // ARBITRARY-NEXT: ret i420 420
      builder.buildRet(APInt(width: 420, value: 0b00000001_10100100))
      // ARBITRARY-NEXT: }
      module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testZeroInit", testZeroInit),
    ("testi33Count", testi33Count),
    ("testi1", testi1),
    ("testMultiply", testMultiply),
    ("testArbitraryIRGen", testArbitraryIRGen),
  ])
  #endif
}
