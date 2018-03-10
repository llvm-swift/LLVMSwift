import LLVM
import XCTest
import FileCheck
import Foundation

class IRAttributesSpec : XCTestCase {
    func testIRAttributes() {
        XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["FNATTR"]) {
            // FNATTR: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
            // FNATTR-NEXT: source_filename = "[[ModuleName]]"
            let module = Module(name: "IRBuilderTest")
            let builder = IRBuilder(module: module)
            let fn = builder.addFunction("fn",
                                         type: FunctionType(argTypes: [IntType.int32, IntType.int32],
                                                            returnType: IntType.int32))

            // FNATTR: define i32 @fn(i32, i32) #0 {
            fn.addAttribute(.nounwind, to: .function)

            // FNATTR-NEXT: entry:
            let entry = fn.appendBasicBlock(named: "entry")
            builder.positionAtEnd(of: entry)
            // FNATTR-NEXT: ret i32 0
            builder.buildRet(IntType.int32.constant(0))
            // FNATTR-NEXT: }
            // FNATTR: attributes #0 = { nounwind }
            module.dump()
        })

        XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["RVATTR"]) {
            // RVATTR: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
            // RVATTR-NEXT: source_filename = "[[ModuleName]]"
            let module = Module(name: "IRBuilderTest")
            let builder = IRBuilder(module: module)
            let fn = builder.addFunction("fn",
                                         type: FunctionType(argTypes: [IntType.int32, IntType.int32],
                                                            returnType: IntType.int32))

            // RVATTR: define signext i32 @fn(i32, i32) {
            fn.addAttribute(.signext, to: .returnValue)

            // RVATTR-NEXT: entry:
            let entry = fn.appendBasicBlock(named: "entry")
            builder.positionAtEnd(of: entry)
            // RVATTR-NEXT: ret i32 0
            builder.buildRet(IntType.int32.constant(0))
            // RVATTR-NEXT: }
            module.dump()
        })

        XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["ARGATTR"]) {
            // ARGATTR: ; ModuleID = '[[ModuleName:IRBuilderTest]]'
            // ARGATTR-NEXT: source_filename = "[[ModuleName]]"
            let module = Module(name: "IRBuilderTest")
            let builder = IRBuilder(module: module)
            let fn = builder.addFunction("fn",
                                         type: FunctionType(argTypes: [IntType.int32, IntType.int32],
                                                            returnType: IntType.int32))

            // ARGATTR: define i32 @fn(i32 zeroext, i32 signext) {
            fn.addAttribute(.zeroext, to: .argument(0))
            fn.addAttribute(.signext, to: .argument(1))

            // ARGATTR-NEXT: entry:
            let entry = fn.appendBasicBlock(named: "entry")
            builder.positionAtEnd(of: entry)
            // ARGATTR-NEXT: ret i32 0
            builder.buildRet(IntType.int32.constant(0))
            // ARGATTR-NEXT: }
            module.dump()
        })
    }

    #if !os(macOS)
    static var allTests = testCase([
    ("testIRAttributes", testIRAttributes),
    ])
    #endif
}

