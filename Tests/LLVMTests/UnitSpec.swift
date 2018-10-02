import LLVM
import XCTest
import Foundation

class UnitSpec : XCTestCase {
  func testAlign() {
    let expectations: [(Size, Alignment, Size)] = [
      (Size(5), Alignment(8), Size(8)),
      (Size(17), Alignment(8), Size(24)),
      (Size(321), Alignment(255), Size(510)),
    ]

    for (argSize, argAlign, expect) in expectations {
      XCTAssertEqual(TargetData.align(argSize, to: argAlign), expect)
    }

    let expectationsWithSkew: [(Size, Alignment, Size, Size)] = [
      (Size(5), Alignment(8), Size(7), Size(7)),
      (Size(17), Alignment(8), Size(1), Size(17)),
      (Size(321), Alignment(255), Size(42), Size(552)),
    ]

    for (argSize, argAlign, argSkew, expect) in expectationsWithSkew {
      XCTAssertEqual(TargetData.align(argSize, to: argAlign, skew: argSkew), expect)
    }
  }

  func testEmptyStructLayout() {
    let mod = Module(name: "StructLayout")

    let emptyPackedStruct = StructType(elementTypes: [], isPacked: true, in: Context.global)
    let emptyUnpackedStruct = StructType(elementTypes: [], isPacked: false, in: Context.global)

    let emptyPackedLayout = mod.dataLayout.layout(of: emptyPackedStruct)
    XCTAssertEqual(emptyPackedLayout.alignment, Alignment.one)
    XCTAssertEqual(emptyPackedLayout.size, Size.zero)
    XCTAssertEqual(emptyPackedLayout.elementCount, 0)
    XCTAssertFalse(emptyPackedLayout.isPadded)
    let emptyUnpackedLayout = mod.dataLayout.layout(of: emptyUnpackedStruct)
    XCTAssertEqual(emptyUnpackedLayout.alignment, Alignment.one)
    XCTAssertEqual(emptyUnpackedLayout.size, Size.zero)
    XCTAssertEqual(emptyUnpackedLayout.elementCount, 0)
    XCTAssertFalse(emptyUnpackedLayout.isPadded)
  }

  func testStructLayout() {
    let mod = Module(name: "StructLayout")

    let packedStruct = StructType(elementTypes: [
      IntType.int1,
      IntType.int8,
      IntType.int1,
      PointerType(pointee: IntType.int8),
    ], isPacked: true, in: Context.global)
    let unpackedStruct = StructType(elementTypes: [
      IntType.int1,
      IntType.int8,
      IntType.int1,
      PointerType(pointee: IntType.int8),
    ], isPacked: false, in: Context.global)

    let packedLayout = mod.dataLayout.layout(of: packedStruct)
    XCTAssertEqual(packedLayout.alignment, Alignment.one)
    XCTAssertEqual(packedLayout.size, Size(11))
    XCTAssertEqual(packedLayout.elementCount, 4)
    XCTAssertFalse(packedLayout.isPadded)
    XCTAssertEqual(packedLayout.memberOffsets, [
      Size(0), Size(1), Size(2), Size(3),
    ])
    let unpackedLayout = mod.dataLayout.layout(of: unpackedStruct)
    XCTAssertEqual(unpackedLayout.alignment, Alignment(8))
    XCTAssertEqual(unpackedLayout.size, Size(16))
    XCTAssertEqual(unpackedLayout.elementCount, 4)
    XCTAssertTrue(unpackedLayout.isPadded)
    XCTAssertEqual(unpackedLayout.memberOffsets, [
      Size(0), Size(1), Size(2), Size(8),
    ])
  }


  #if !os(macOS)
  static var allTests = testCase([
    ("testAlign", testAlign),
    ("testEmptyStructLayout", testEmptyStructLayout),
    ("testStructLayout", testStructLayout),
  ])
  #endif
}

