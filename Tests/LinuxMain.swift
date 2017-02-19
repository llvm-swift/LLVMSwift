import XCTest

@testable import LLVMTests

#if !os(macOS)
XCTMain([
  IRBuilderSpec.allTests,
  ConstantSpec.allTests,
  IRExceptionSpec.allTests,
  IROperationSpec.allTests,
])
#endif
