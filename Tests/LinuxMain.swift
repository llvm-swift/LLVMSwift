import XCTest

@testable import LLVMTests

#if !os(macOS)
XCTMain([
  ConstantSpec.allTests,
  DIBuilderSpec.allTests,
  FileCheckSpec.allTests,
  IRBuilderSpec.allTests,
  IRExceptionSpec.allTests,
  IRGlobalSpec.allTests,
  IROperationSpec.allTests,
  // FIXME: These tests cannot run on Linux without SEGFAULT'ing.
  // JITSpec.allTests,
  ModuleLinkSpec.allTests,
  ModuleMetadataSpec.allTests,
])
#endif
