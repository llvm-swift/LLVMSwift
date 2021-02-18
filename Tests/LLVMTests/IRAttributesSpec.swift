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
                                   type: FunctionType([IntType.int32, IntType.int32],
                                                      IntType.int32))

      // FNATTR: define i32 @fn(i32 %0, i32 %1) #0 {
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
                                   type: FunctionType([IntType.int32, IntType.int32],
                                                      IntType.int32))

      // RVATTR: define signext i32 @fn(i32 %0, i32 %1) {
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
      let i8ptr = PointerType(pointee: IntType.int8)
      let fn = builder.addFunction("fn",
                                   type: FunctionType([IntType.int32, i8ptr],
                                                      IntType.int32))

      // ARGATTR: define i32 @fn(i32 zeroext %0, i8* align 8 %1) {
      fn.addAttribute(.zeroext, to: .argument(0))
      fn.addAttribute(.align, value: 8, to: .argument(1))

      // ARGATTR-NEXT: entry:
      let entry = fn.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      // ARGATTR-NEXT: ret i32 0
      builder.buildRet(IntType.int32.constant(0))
      // ARGATTR-NEXT: }
      module.dump()
    })
  }

  func testSetUnsetFunctionAttributes() {
    let module = Module(name: "FNATTR")
    let builder = IRBuilder(module: module)

    let i8ptr = PointerType(pointee: IntType.int8)
    let fn = builder.addFunction("fn",
                                 type: FunctionType([i8ptr], i8ptr))

    // MARK: Enum attributes

    var enumAttr: EnumAttribute
    let fnAttrs: [AttributeKind: UInt64] = [
      .alignstack: 8,
      .allocsize: 8,
      .alwaysinline: 0,
      .builtin: 0,
      .cold: 0,
      .convergent: 0,
      .inaccessiblememonly: 0,
      .inaccessiblememOrArgmemonly: 0,
      .inlinehint: 0,
      .jumptable: 0,
      .minsize: 0,
      .naked: 0,
      .noJumpTables: 0,
      .nobuiltin: 0,
      .noduplicate: 0,
      .noimplicitfloat: 0,
      .noinline: 0,
      .nonlazybind: 0,
      .noredzone: 0,
      .noreturn: 0,
      .norecurse: 0,
      .nounwind: 0,
      .optnone: 0,
      .optsize: 0,
      .readnone: 0,
      .readonly: 0,
      .writeonly: 0,
      .argmemonly: 0,
      .returnsTwice: 0,
      .safestack: 0,
      .sanitizeAddress: 0,
      .sanitizeMemory: 0,
      .sanitizeThread: 0,
      .sanitizeHWAddress: 0,
      .speculatable: 0,
      .ssp: 0,
      .sspreq: 0,
      .sspstrong: 0,
      .strictfp: 0,
      .uwtable: 0,
    ]

    for (attrKind, value) in fnAttrs {
      enumAttr = fn.addAttribute(attrKind, value: value, to: .function)
      XCTAssertEqual(enumAttr.value, value)
      XCTAssert(fn.attributes(at: .function).contains { $0.asLLVM() == enumAttr.asLLVM() })

      fn.removeAttribute(enumAttr, from: .function)
      XCTAssertFalse(fn.attributes(at: .function).contains { $0.asLLVM() == enumAttr.asLLVM() })

      enumAttr = fn.addAttribute(attrKind, value: value, to: .function)
      fn.removeAttribute(attrKind, from: .function)
      XCTAssertFalse(fn.attributes(at: .function).contains { $0.asLLVM() == enumAttr.asLLVM() })
    }

    // MARK: String attributes

    var stringAttr: StringAttribute
    for (name, value) in [("foo", ""), ("foo", "bar")] {
      stringAttr = fn.addAttribute(name, value: value, to: .function)
      XCTAssertEqual(stringAttr.name, name)
      XCTAssertEqual(stringAttr.value, value)
      XCTAssert(fn.attributes(at: .function).contains { $0.asLLVM() == stringAttr.asLLVM() })

      fn.removeAttribute(stringAttr, from: .function)
      XCTAssertFalse(fn.attributes(at: .function).contains { $0.asLLVM() == stringAttr.asLLVM() })

      stringAttr = fn.addAttribute(name, to: .function)
      fn.removeAttribute(name, from: .function)
      XCTAssertFalse(fn.attributes(at: .function).contains { $0.asLLVM() == stringAttr.asLLVM() })
    }
  }

  func testSetUnsetArgumentAttributes() {
    let module = Module(name: "ARGATTR")
    let builder = IRBuilder(module: module)

    let i8ptr = PointerType(pointee: IntType.int8)
    let fn = builder.addFunction("fn",
                                 type: FunctionType([i8ptr], i8ptr))

    // MARK: Enum attributes

    var enumAttr: EnumAttribute
    let argAttrs: [AttributeKind: UInt64] = [
      .zeroext: 0,
      .signext: 0,
      .inreg: 0,
      .byval: 0,
      .inalloca: 0,
      .sret: 0,
      .align: 8,
      .noalias: 0,
      .nocapture: 0,
      .nest: 0,
      .returned: 0,
      .nonnull: 0,
      .dereferenceable: 8,
      .dereferenceableOrNull: 8,
      .swiftself: 0,
      .swifterror: 0,
    ]

    for (attrKind, value) in argAttrs {
      enumAttr = fn.addAttribute(attrKind, value: value, to: .returnValue)
      XCTAssertEqual(enumAttr.value, value)
      XCTAssert(fn.attributes(at: .returnValue).contains { $0.asLLVM() == enumAttr.asLLVM() })

      fn.removeAttribute(enumAttr, from: .returnValue)
      XCTAssertFalse(fn.attributes(at: .returnValue).contains { $0.asLLVM() == enumAttr.asLLVM() })

      enumAttr = fn.addAttribute(attrKind, value: value, to: .returnValue)
      fn.removeAttribute(attrKind, from: .returnValue)
      XCTAssertFalse(fn.attributes(at: .returnValue).contains { $0.asLLVM() == enumAttr.asLLVM() })
    }

    for (attrKind, value) in argAttrs {
      enumAttr = fn.addAttribute(attrKind, value: value, to: .argument(0))
      XCTAssertEqual(enumAttr.value, value)
      XCTAssert(fn.attributes(at: .argument(0)).contains { $0.asLLVM() == enumAttr.asLLVM() })

      fn.removeAttribute(enumAttr, from: .argument(0))
      XCTAssertFalse(fn.attributes(at: .argument(0)).contains { $0.asLLVM() == enumAttr.asLLVM() })

      enumAttr = fn.addAttribute(attrKind, value: value, to: .argument(0))
      fn.removeAttribute(attrKind, from: .argument(0))
      XCTAssertFalse(fn.attributes(at: .argument(0)).contains { $0.asLLVM() == enumAttr.asLLVM() })
    }

    // MARK: String attributes

    var stringAttr: StringAttribute
    for (name, value) in [("foo", ""), ("foo", "bar")] {
      stringAttr = fn.addAttribute(name, value: value, to: .returnValue)
      XCTAssertEqual(stringAttr.name, name)
      XCTAssertEqual(stringAttr.value, value)
      XCTAssert(fn.attributes(at: .returnValue).contains { $0.asLLVM() == stringAttr.asLLVM() })

      fn.removeAttribute(stringAttr, from: .returnValue)
      XCTAssertFalse(fn.attributes(at: .returnValue).contains { $0.asLLVM() == stringAttr.asLLVM() })

      stringAttr = fn.addAttribute(name, to: .returnValue)
      fn.removeAttribute(name, from: .returnValue)
      XCTAssertFalse(fn.attributes(at: .returnValue).contains { $0.asLLVM() == stringAttr.asLLVM() })
    }

    for (name, value) in [("foo", ""), ("foo", "bar")] {
      stringAttr = fn.addAttribute(name, value: value, to: .argument(0))
      XCTAssertEqual(stringAttr.name, name)
      XCTAssertEqual(stringAttr.value, value)
      XCTAssert(fn.attributes(at: .argument(0)).contains { $0.asLLVM() == stringAttr.asLLVM() })

      fn.removeAttribute(stringAttr, from: .argument(0))
      XCTAssertFalse(fn.attributes(at: .argument(0)).contains { $0.asLLVM() == stringAttr.asLLVM() })

      stringAttr = fn.addAttribute(name, to: .argument(0))
      fn.removeAttribute(name, from: .argument(0))
      XCTAssertFalse(fn.attributes(at: .argument(0)).contains { $0.asLLVM() == stringAttr.asLLVM() })
    }
  }

  #if !os(macOS)
  static var allTests = testCase([
  ("testIRAttributes", testIRAttributes),
  ("testSetUnsetFunctionAttributes", testSetUnsetFunctionAttributes),
  ("testSetUnsetArgumentAttributes", testSetUnsetArgumentAttributes),
  ])
  #endif
}
