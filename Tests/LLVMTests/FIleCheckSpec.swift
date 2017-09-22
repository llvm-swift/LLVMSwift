import LLVM
import XCTest
import FileCheck
import Foundation

class FileCheckSpec : XCTestCase {
  func testImplicitCheckNot() {
    XCTAssert(fileCheckOutput(of: .stdout, withPrefixes: ["CHECK-NOTCHECK"]) {
      // CHECK-NOTCHECK: error: NOTCHECK-NOT: string occurred!
      // CHECK-NOTCHECK-NEXT: warning:
      // CHECK-NOTCHECK-NEXT: note: NOTCHECK-NOT: pattern specified here
      // CHECK-NOTCHECK-NEXT: IMPLICIT-CHECK-NOT: warning:
      XCTAssertFalse(fileCheckOutput(of: .stdout, withPrefixes: ["NOTCHECK"], checkNot: ["warning:"], options: [.disableColors]) {
        // NOTCHECK: error:
        print("error:")
        // NOTCHECK: error:
        print("error:")
        // NOTCHECK: error:
        print("error:")
        // NOTCHECK: error:
        print("error:")
        print("warning:")
      })
    })

    XCTAssert(fileCheckOutput(of: .stdout, withPrefixes: ["CHECK-NOTCHECK-MID"]) {
      // CHECK-NOTCHECK-MID: error: NOTCHECK-MID-NOT: string occurred!
      // CHECK-NOTCHECK-MID-NEXT: warning:
      // CHECK-NOTCHECK-MID-NEXT: note: NOTCHECK-MID-NOT: pattern specified here
      // CHECK-NOTCHECK-MID-NEXT: IMPLICIT-CHECK-NOT: warning:
      XCTAssertFalse(fileCheckOutput(of: .stdout, withPrefixes: ["NOTCHECK-MID"], checkNot: ["warning:"], options: [.disableColors]) {
        // NOTCHECK-MID: error:
        print("error:")
        // NOTCHECK-MID: error:
        print("error:")
        print("warning:")
        // NOTCHECK-MID: error:
        print("error:")
        // NOTCHECK-MID: error:
        print("error:")
      })
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testImplicitCheckNot", testImplicitCheckNot),
  ])
  #endif
}
