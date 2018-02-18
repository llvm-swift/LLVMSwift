import XCTest

@testable import LLVMTests

#if !os(macOS)
XCTMain([
  ConstantSpec.allTests,
  FileCheckSpec.allTests,
  IRBuilderSpec.allTests,
  IRExceptionSpec.allTests,
  IRGlobalSpec.allTests,
  IROperationSpec.allTests,
  JITSpec.allTests,
  ModuleLinkSpec.allTests,
])
#endif
