import XCTest

@testable import LLVMTests

#if !os(macOS)
XCTMain([
  APIntSpec.allTests,
  BFCSpec.allTests,
  ConstantSpec.allTests,
  DIBuilderSpec.allTests,
  FileCheckSpec.allTests,
  IRBuilderSpec.allTests,
  IRExceptionSpec.allTests,
  IRGlobalSpec.allTests,
  IRMetadataSpec.allTests,
  IROperationSpec.allTests,
  JITSpec.allTests,
  ModuleLinkSpec.allTests,
  ModuleMetadataSpec.allTests,
])
#endif
