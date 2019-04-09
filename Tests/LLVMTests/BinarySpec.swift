import LLVM
import XCTest
import FileCheck
import Foundation

class BinarySpec : XCTestCase {
  private func readThisObjectFile() -> ObjectFile {
    let result = Result<MachOUniversalBinaryFile, Error>(catching: {
      try MachOUniversalBinaryFile(path: Bundle.main.executablePath!)
    })
    switch result {
    case .failure(_):
      guard let objectFile = try? ObjectFile(path: Bundle.main.executablePath!) else {
        fatalError("Missing object file for host architecture?")
      }
      return objectFile
    case let .success(binary):
      guard let objectFile = try? binary.objectFile(for: Triple.default.architecture) else {
        fatalError("Missing object file for host architecture?")
      }
      return objectFile
    }
  }

  func testBinaryLifetimes() {
    let objectFile = self.readThisObjectFile()

    #if !os(Linux) // Linux has some trouble reading ELF sections.
    var hasSections = false
    for _ in objectFile.sections {
      hasSections = true
      break
    }
    XCTAssertTrue(hasSections)
    #endif

    var hasSymbols = false
    for _ in objectFile.symbols {
      hasSymbols = true
      break
    }
    XCTAssertTrue(hasSymbols)
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testBinaryLifetimes", testBinaryLifetimes),
  ])
  #endif
}

