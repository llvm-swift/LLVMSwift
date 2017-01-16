import XCTest

@testable import LLVMTests

#if !os(macOS)
XCTMain([
	IRBuilderSpec.allTests,
])
#endif
