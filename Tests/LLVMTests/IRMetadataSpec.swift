import LLVM
import XCTest
import FileCheck
import Foundation

class IRMetadataSpec : XCTestCase {
  func testGlobalMetadata() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRGLOBALMETADATA"]) {
      // IRGLOBALMETADATA:  ModuleID = '[[ModuleName:IRGLOBALMETADATATest]]'
      // IRGLOBALMETADATA-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRGLOBALMETADATATest")
      let builder = IRBuilder(module: module)
      let dibuilder = DIBuilder(module: module)

      let tag = module.context.metadataKind(named: "custom")

      // IRGLOBALMETADATA: @customAttachment = global i8 42, !custom !0
      let global = builder.addGlobal("customAttachment", initializer: IntType.int8.constant(42))

      // IRGLOBALMETADATA: !0 = !DIBasicType(name: "custom_type", encoding: DW_ATE_address)
      let type = dibuilder.buildBasicType(named: "custom_type", encoding: .address, flags: [], size: .zero)
      global.addMetadata(type, kind: tag)

      module.dump()
    })
  }

  func testInstructionMetadata() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRINSTRMETADATA"]) {
      // IRINSTRMETADATA:  ModuleID = '[[ModuleName:IRINSTRMETADATATest]]'
      // IRINSTRMETADATA-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRINSTRMETADATATest")
      let builder = IRBuilder(module: module)
      let dibuilder = DIBuilder(module: module)

      let tag = module.context.metadataKind(named: "custom")

      // IRINSTRMETADATA: define i32 @test() {
      let main = builder.addFunction("test",
                                     type: FunctionType([], IntType.int32))
      // IRINSTRMETADATA-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      // IRINSTRMETADATA-NEXT: ret i32 42
      builder.buildRet(IntType.int32.constant(42))

      let type = dibuilder.buildBasicType(named: "custom_type", encoding: .address, flags: [], size: .zero)
      builder.insertBlock?.lastInstruction?.addMetadata(type, kind: tag)
      // IRINSTRMETADATA-NEXT: }

      // IRINSTRMETADATA: !0 = !DIBasicType(name: "custom_type", encoding: DW_ATE_address)
      module.dump()
    })
  }

  func testFPMathTag() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRFPMATHMETADATA"]) {
      // IRFPMATHMETADATA:  ModuleID = '[[ModuleName:IRFPMathTest]]'
      // IRFPMATHMETADATA-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRFPMathTest")
      let builder = IRBuilder(module: module)
      let MDB = MDBuilder()
      XCTAssertNil(builder.defaultFloatingPointMathTag)
      builder.defaultFloatingPointMathTag = MDB.buildFloatingPointMathTag(0.1)

      // IRFPMATHMETADATA: define float @test(float, float) {
      let main = builder.addFunction("test",
                                     type: FunctionType([
                                       FloatType.float, FloatType.float
                                     ], FloatType.float))
      // IRFPMATHMETADATA-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRFPMATHMETADATA-NEXT: %2 = fadd float %0, %1, !fpmath !0
      let value = builder.buildAdd(main.parameters[0], main.parameters[1])
      // IRFPMATHMETADATA-NEXT: ret float %2
      builder.buildRet(value)
      // IRFPMATHMETADATA-NEXT: }

      // IRFPMATHMETADATA: !0 = !{float 0x3FB99999A0000000}
      module.dump()
    })
  }

  func testBranchWeights() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRBWMETADATA"]) {
      // IRBWMETADATA:  ModuleID = '[[ModuleName:IRBWMetadataTest]]'
      // IRBWMETADATA-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRBWMetadataTest")
      let builder = IRBuilder(module: module)
      let MDB = MDBuilder()

      // IRBWMETADATA: define float @test(i1, float, float) {
      let main = builder.addFunction("test",
                                     type: FunctionType([
                                       IntType.int1,
                                       FloatType.float, FloatType.float
                                     ], FloatType.float))
      // IRBWMETADATA-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      let thenBlock = main.appendBasicBlock(named: "then")
      let elseBlock = main.appendBasicBlock(named: "else")
      let mergeBB = main.appendBasicBlock(named: "merge")
      let bws = MDB.buildBranchWeights([
        1000,
        2000,
      ])
      // IRBWMETADATA-NEXT: br i1 %0, label %then, label %else, !prof !0
      let branch = builder.buildCondBr(condition: main.parameters[0], then: thenBlock, else: elseBlock)
      branch.addMetadata(bws, kind: .prof)

      // IRBWMETADATA: then:
      // IRBWMETADATA-NEXT: %3 = fadd float %1, %2
      builder.positionAtEnd(of: thenBlock)
      let opThen = builder.buildAdd(main.parameters[1], main.parameters[2])
      builder.buildBr(mergeBB)

      // IRBWMETADATA: else:
      // IRBWMETADATA-NEXT: %4 = fsub float %1, %2
      builder.positionAtEnd(of: elseBlock)
      let opElse = builder.buildSub(main.parameters[1], main.parameters[2])
      builder.buildBr(mergeBB)

      // IRBWMETADATA: merge:
      // IRBWMETADATA-NEXT: %5 = phi float [ %3, %then ], [ %4, %else ]
      builder.positionAtEnd(of: mergeBB)
      let phi = builder.buildPhi(FloatType.float)
      phi.addIncoming([
        (opThen, thenBlock),
        (opElse, elseBlock),
      ])

      // IRBWMETADATA-NEXT: ret float %5
      builder.buildRet(phi)
      // IRBWMETADATA-NEXT: }

      // IRBWMETADATA: !0 = !{!"branch_weights", i32 1000, i32 2000}
      module.dump()
    })
  }

  func testSimpleTBAA() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRSIMPLETBAA"]) {
      // IRSIMPLETBAA:  ModuleID = '[[ModuleName:IRTBAATest]]'
      // IRSIMPLETBAA-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRTBAATest")
      let builder = IRBuilder(module: module)
      let MDB = MDBuilder()

      // IRSIMPLETBAA: define void @main() {
      let F = module.addFunction("main", type: FunctionType([], VoidType()))
      // IRSIMPLETBAA-NEXT: entry:
      let bb = F.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: bb)
      // typedef struct {
      //   int16_t s;
      // } A;
      let structTyA = StructType(elementTypes: [
        IntType.int16
      ])
      // typedef struct {
      //   uint32_t s;
      //   A a;
      // } B;
      let structTyB = StructType(elementTypes: [
        IntType.int32,
        structTyA,
      ])

      // struct B *val = alloca(sizeof(struct B));
      // IRSIMPLETBAA-NEXT:  %0 = alloca { i32, { i16 } }
      let alloca = builder.buildAlloca(type: structTyB)
      // IRSIMPLETBAA-NEXT:  %1 = getelementptr inbounds { i32, { i16 } }, { i32, { i16 } }* %0, i64 0, i32 1, i32 0
      let field = builder.buildInBoundsGEP(alloca, type: structTyB, indices: [
        IntType.int64.constant(0), // (*this)
        IntType.int32.constant(1), // .a
        IntType.int32.constant(0), // .s
      ])
      // B->a.s = 42
      // IRSIMPLETBAA-NEXT:  store i16 42, i16* %1, !tbaa [[AccessTag:![0-9]+]]
      let si = builder.buildStore(IntType.int16.constant(42), to: field)
      // IRSIMPLETBAA-NEXT:  ret void
      builder.buildRetVoid()
      // IRSIMPLETBAA-NEXT:  }

      // IRSIMPLETBAA:      [[AccessTag]] = !{[[BTypeNode:![0-9]+]], [[Int16Node:![0-9]+]], i64 4, i64 4}
      // IRSIMPLETBAA-NEXT: [[BTypeNode]] = !{[[OmnipotentChar:![0-9]+]], i64 8, !"B", [[Int32Node:![0-9]+]], i64 0, i64 4, [[ATypeNode:![0-9]+]], i64 4, i64 2}
      // IRSIMPLETBAA-NEXT: [[OmnipotentChar]] = !{[[RootNode:![0-9]+]], i64 1, !"omnipotent char"}
      // IRSIMPLETBAA-NEXT: [[RootNode]] = !{!"TBAA Test Root"}
      // IRSIMPLETBAA-NEXT: [[Int32Node]] = !{[[OmnipotentChar]], i64 4, !"int32_t"}
      // IRSIMPLETBAA-NEXT: [[ATypeNode]] = !{[[OmnipotentChar]], i64 2, !"A", [[Int16Node]], i64 0, i64 2}
      // IRSIMPLETBAA-NEXT: [[Int16Node]] = !{[[OmnipotentChar]], i64 2, !"int16_t"}
      let rootMD = MDB.buildTBAARoot("TBAA Test Root")
      let charMD = MDB.buildTBAATypeNode(MDString("omnipotent char"), parent: rootMD, size: .one)
      let int16MD = MDB.buildTBAATypeNode(MDString("int16_t"), parent: charMD, size: Size(bits: 16))
      let int32MD = MDB.buildTBAATypeNode(MDString("int32_t"), parent: charMD, size: Size(bits: 32))
      let structAMD = MDB.buildTBAATypeNode(MDString("A"),
                                            parent: charMD,
                                            size: module.dataLayout.storeSize(of: structTyA),
                                            fields: [
        .init(offset: .zero, size: Size(bits: 16), type: int16MD)
      ])
      let structBMD = MDB.buildTBAATypeNode(MDString("B"),
                                            parent: charMD,
                                            size: module.dataLayout.storeSize(of: structTyB),
                                            fields: [
        .init(offset: .zero, size: Size(bits: 32), type: int32MD),
        .init(offset: Size(bits: 32), size: module.dataLayout.storeSize(of: structTyA), type: structAMD),
      ])
      let accessTag = MDB.buildTBAAAccessTag(baseType: structBMD, accessType: int16MD, offset: Size(bits: 32), size: Size(bits: 32))
      si.addMetadata(accessTag, kind: .tbaa)

      module.dump()
      try! module.verify()
    })
  }

  func testMemoryTransferTBAA() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRMEMTRANSFERTBAA"]) {
      // IRMEMTRANSFERTBAA:  ModuleID = '[[ModuleName:IRTBAATest]]'
      // IRMEMTRANSFERTBAA-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRTBAATest")
      let builder = IRBuilder(module: module)
      let MDB = MDBuilder()

      // IRMEMTRANSFERTBAA: define void @main(i8*) {
      let F = module.addFunction("main", type: FunctionType([PointerType.toVoid], VoidType()))
      // IRMEMTRANSFERTBAA-NEXT: entry:
      let bb = F.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: bb)
      // typedef struct {
      //   int16_t s;
      // } A;
      let structTyA = StructType(elementTypes: [
        IntType.int16
      ], isPacked: true)
      // typedef struct {
      //   bool s;
      //   // Invisible padding
      //   unsigned pad:15;
      //   A a;
      // } B;
      let structTyB = StructType(elementTypes: [
        IntType.int1,
        IntType(width: 15),
        structTyA,
      ], isPacked: true)

      // struct B *val = alloca(sizeof(struct B));
      // IRMEMTRANSFERTBAA-NEXT:  %1 = alloca <{ i1, i15, <{ i16 }> }>
      let alloca = builder.buildAlloca(type: structTyB)
      // IRMEMTRANSFERTBAA-NEXT:  %2 = bitcast <{ i1, i15, <{ i16 }> }>* %1 to i8*
      let src = builder.buildPointerCast(of: alloca, to: PointerType(pointee: structTyB))
      // IRMEMTRANSFERTBAA-NEXT: call void @llvm.memcpy.p0i8.p0i8.i32(i8* align 1 %0, i8* align 1 %2, i32 5, i1 false), !tbaa.struct [[StructAccssTag:![0-9]+]]
      let inst = builder.buildMemCpy(to: F.parameters[0], module.dataLayout.abiAlignment(of: structTyB),
                                     from: src, module.dataLayout.abiAlignment(of: structTyB),
                                     length: IntType.int32.constant(module.dataLayout.abiSize(of: structTyB).rawValue))

      // IRMEMTRANSFERTBAA-NEXT:  ret void
      builder.buildRetVoid()
      // IRMEMTRANSFERTBAA-NEXT:  }

      // IRMEMTRANSFERTBAA:      [[StructAccssTag]] = !{i64 0, i64 1, [[Field1AccessTag:![0-9]+]], i64 2, i64 2, [[Field2AccessTag:![0-9]+]]}
      // IRMEMTRANSFERTBAA-NEXT: [[Field1AccessTag]] = !{[[BoolTypeTag:![0-9]+]], [[BoolTypeTag]], i64 0, i64 4}
      // IRMEMTRANSFERTBAA-NEXT: [[BoolTypeTag]] = !{[[OmnipotentCharTypeTag:![0-9]+]], i64 1, !"bool"}
      // IRMEMTRANSFERTBAA-NEXT: [[OmnipotentCharTypeTag]] = !{[[TBAARoot:![0-9]+]], i64 1, !"omnipotent char"}
      // IRMEMTRANSFERTBAA-NEXT: [[TBAARoot]] = !{!"TBAA Test Root"}
      // IRMEMTRANSFERTBAA-NEXT: [[Field2AccessTag]] = !{[[Int16TypeTag:![0-9]+]], [[Int16TypeTag]], i64 4, i64 2}
      // IRMEMTRANSFERTBAA-NEXT: [[Int16TypeTag]] = !{[[OmnipotentCharTypeTag]], i64 2, !"int16_t"}

      // TBAA Types
      let rootMD = MDB.buildTBAARoot("TBAA Test Root")
      let charMD = MDB.buildTBAATypeNode(MDString("omnipotent char"), parent: rootMD, size: .one)
      let int16MD = MDB.buildTBAATypeNode(MDString("int16_t"), parent: charMD, size: Size(bits: 16))
      let boolMD = MDB.buildTBAATypeNode(MDString("bool"), parent: charMD, size: Size(bits: 1))

      // Member accesses
      let field1Access = MDB.buildTBAAAccessTag(baseType: boolMD, accessType: boolMD, offset: .zero, size: Size(bits: 32))
      let field2Access = MDB.buildTBAAAccessTag(baseType: int16MD, accessType: int16MD, offset: Size(bits: 32), size: Size(bits: 16))
      let structMD = MDB.buildTBAAStructNode([
        .init(offset: .zero, size: Size(bits: 8), type: field1Access),
        .init(offset: Size(bits: 16), size: Size(bits: 16), type: field2Access),
      ])
      inst.addMetadata(structMD, kind: .tbaaStruct)

      module.dump()
      try! module.verify()
   })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testGlobalMetadata", testGlobalMetadata),
    ("testFPMathTag", testFPMathTag),
    ("testBranchWeights", testBranchWeights),
    ("testSimpleTBAA", testSimpleTBAA),
  ])
  #endif
}

