import LLVM
import XCTest
import FileCheck
import Foundation

class BFCSpec : XCTestCase {
  func testCompile() {
    // So, this looks weird for a reason.  It has to be edge-aligned because
    // I'm lazy and didn't want to implement column resets correctly.  And it has
    // to be indented on every operation because LLVM de-duplicates source
    // locations by file and line.  So even if you emit two distinct locations
    // for two distinct operations on the same line, you'll step over both of
    // them if they don't have discriminators set.  We need hooks for this.
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["BFC"]) {
      // BFC: ; ModuleID = 'brainfuck'
compile(
"""
+
+
+
+
+
+
+
+
[
>
+
+
+
+
[
>
+
+
>
+
+
+
>
+
+
+
>
+
<
<
<
<
-
]
>
+
>
+
>
-
>
>
+
[
<
]
<
-
]
>
>
.
>
-
-
-
.
+
+
+
+
+
+
+
.
.
+
+
+
.
>
>
.
<
-
.
<
.
+
+
+
.
-
-
-
-
-
-
.
-
-
-
-
-
-
-
-
.
>
>
+
.
>
+
+
.
""")
    })
  }
  #if !os(macOS)
  static var allTests = testCase([
    ("testCompile", testCompile)
  ])
  #endif
}

private let cellType = IntType.int8
private let cellTapeType = ArrayType(elementType: cellType, count: 30000)

struct Loop {
  let entry: BasicBlock
  let body: BasicBlock
  let exit: BasicBlock
  let headerDestination: PhiNode
  let exitDestination: PhiNode
}

private enum Externs {
  case putchar
  case getchar
  case flush

  func resolve(_ builder: IRBuilder) -> Function {
    let lastEntry = builder.insertBlock
    defer { if let pos = lastEntry { builder.positionAtEnd(of: pos) } }
    switch self {
    case .getchar:
      let f = builder.addFunction("readchar",
                                  type: FunctionType([],
                                                     cellType))
      let getCharExtern = builder.addFunction("getchar",
                                              type: FunctionType([],
                                                                 cellType))
      let entry = f.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      let charValue = builder.buildCall(getCharExtern, args: [])
      let cond = builder.buildICmp(charValue, cellType.constant(0), .signedGreaterThanOrEqual)
      let retVal = builder.buildSelect(cond, then: charValue, else: cellType.constant(0))
      builder.buildRet(retVal)
      return f
    case .putchar:
      return builder.addFunction("putchar",
                                 type: FunctionType([
                                   cellType
                                 ], VoidType()))
    case .flush:
      let f = builder.addFunction("flush",
                                  type: FunctionType([], VoidType()))
      let entry = f.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)
      let ptrTy = PointerType(pointee: IntType.int8)
      let fflushExtern = builder.addFunction("fflush",
                                             type: FunctionType([ ptrTy ],
                                                                IntType.int32))
      _ = builder.buildCall(fflushExtern, args: [ ptrTy.constPointerNull() ])
      builder.buildRetVoid()
      return f
    }
  }
}

private func compile(at column: Int = #column, line: Int = #line, _ program: String) {
  let module = Module(name: "brainfuck")
  let builder = IRBuilder(module: module)
  let dibuilder = DIBuilder(module: module)
  let cellTape = module.addGlobal("tape", initializer: cellTapeType.null())

  let main = builder.addFunction("main",
                                 type: FunctionType([],
                                                    IntType.int32))

  let sourceFile = #file.components(separatedBy: "/").last!
  let sourceDir = #file.components(separatedBy: "/").dropLast().joined(separator: "/")
  let mainFile = dibuilder.buildFile(named: sourceFile,
                                     in: sourceDir)
  let compileUnit = dibuilder.buildCompileUnit(for: .c, in: mainFile, kind: .full)
  let mainModule = dibuilder.buildModule(
    named: "bf", scope: compileUnit, macros: [],
    includePath: sourceDir, includeSystemRoot: "")
  _ = dibuilder.buildImportedModule(
    in: mainFile, module: mainModule, file: mainFile, line: 0)

  let diFnTy = dibuilder.buildSubroutineType(in: mainFile, parameterTypes: [])
  main.metadata = dibuilder.buildFunction(
    named: "main", linkageName: "_main", scope: mainFile,
    file: mainFile, line: line, scopeLine: line,
    type: diFnTy, flags: [], isLocal: true)

  let entryBlock = main.appendBasicBlock(named: "entry")
  builder.positionAtEnd(of: entryBlock)

  let mainScope = dibuilder.buildLexicalBlock(
    scope: main.metadata, file: mainFile, line: line, column: column)

  compileProgramBody(program, (line, column), builder, dibuilder, main, mainScope, mainFile, cellTape)

  dibuilder.finalize()

  module.dump()

  /* Uncomment to output an object file.
  let targetMachine = try! TargetMachine(optLevel: .none)
  try! targetMachine.emitToFile(module: module, type: .object, path: sourceDir + "/bf.o")
  */
}

private func compileProgramBody(
  _ program: String,
  _ startPoint: (Int, Int),
  _ builder: IRBuilder,
  _ dibuilder: DIBuilder,
  _ function: Function,
  _ entryScope: DIScope,
  _ file: FileMetadata,
  _ cellTape: Global
) {

  let putCharExtern = Externs.putchar.resolve(builder)
  let getCharExtern = Externs.getchar.resolve(builder)
  let flushExtern = Externs.flush.resolve(builder)

  var addressPointer: IRValue = cellTape.constGEP(indices: [
    IntType.int32.zero(),
    IntType.int32.zero()
  ])

  /// Create an artificial typedef and variable for the current
  /// pointer into the tape.
  ///
  /// typedef long value_t;
  ///
  /// value_t this = 0;
  let diDataTy = dibuilder.buildBasicType(named: "value_t",
                                          encoding: .signed, flags: [],
                                          size: builder.module.dataLayout.abiSize(of: cellType))
  let diPtrTy = dibuilder.buildPointerType(pointee: diDataTy,
                                           size: builder.module.dataLayout.pointerSize())
  let diVariable = dibuilder.buildLocalVariable(named: "this",
                                                scope: entryScope,
                                                file: file, line: startPoint.0,
                                                type: diPtrTy, flags: .artificial)

  var sourceLine = startPoint.0 + 1
  var sourceColumn = startPoint.1 + 1

  // Declare the variable at the start of the function and give it a value of 0.
  let loc = dibuilder.buildDebugLocation(at: (sourceLine, sourceColumn), in: entryScope)
  dibuilder.buildDeclare(of: addressPointer, atEndOf: builder.insertBlock!,
                         metadata: diVariable,
                         expr: dibuilder.buildExpression([]),
                         location: loc)
  dibuilder.buildDbgValue(of: cellType.zero(), to: diVariable,
                          atEndOf: builder.insertBlock!,
                          expr: dibuilder.buildExpression([]),
                          location: loc)

  var loopNest = [Loop]()
  var scopeStack = [DIScope]()
  scopeStack.append(entryScope)

  for c in program {
    sourceColumn += 1
    let scope = scopeStack.last!
    switch c {
    case ">":
      // Move right
      addressPointer = builder.buildGEP(addressPointer, indices: [ IntType.int32.constant(1) ])
      builder.currentDebugLocation = dibuilder.buildDebugLocation(at: (sourceLine, sourceColumn), in: scope)
      dibuilder.buildDbgValue(of: addressPointer, to: diVariable,
                              atEndOf: builder.insertBlock!,
                              expr: dibuilder.buildExpression([.deref]),
                              location: builder.currentDebugLocation!)
    case "<":
      // Move left
      addressPointer = builder.buildGEP(addressPointer, indices: [ IntType.int32.constant(-1) ])
      builder.currentDebugLocation = dibuilder.buildDebugLocation(at: (sourceLine, sourceColumn), in: scope)
      dibuilder.buildDbgValue(of: addressPointer, to: diVariable,
                              atEndOf: builder.insertBlock!,
                              expr: dibuilder.buildExpression([.deref]),
                              location: builder.currentDebugLocation!)
    case "+":
      // Increment
      let value = builder.buildLoad(addressPointer)
      let ptrUp = builder.buildAdd(value, cellType.constant(1))
      builder.buildStore(ptrUp, to: addressPointer)
      builder.currentDebugLocation = dibuilder.buildDebugLocation(at: (sourceLine, sourceColumn), in: scope)
      dibuilder.buildDbgValue(of: value, to: diVariable,
                              atEndOf: builder.insertBlock!,
                              expr: dibuilder.buildExpression([.plus_uconst(1)]),
                              location: builder.currentDebugLocation!)
    case "-":
      // Decrement
      let value = builder.buildLoad(addressPointer)
      let ptrDown = builder.buildSub(value, cellType.constant(1))
      builder.buildStore(ptrDown, to: addressPointer)
      builder.currentDebugLocation = dibuilder.buildDebugLocation(at: (sourceLine, sourceColumn), in: scope)
      dibuilder.buildDbgValue(of: value, to: diVariable,
                              atEndOf: builder.insertBlock!,
                              expr: dibuilder.buildExpression([.constu(1), .minus]),
                              location: builder.currentDebugLocation!)
    case ".":
      // Write
      let dataValue = builder.buildLoad(addressPointer)
      _ = builder.buildCall(putCharExtern, args: [dataValue])
      builder.currentDebugLocation = dibuilder.buildDebugLocation(at: (sourceLine, sourceColumn), in: scope)
    case ",":
      // Read
      let readValue = builder.buildCall(getCharExtern, args: [])
      builder.buildStore(readValue, to: addressPointer)
      builder.currentDebugLocation = dibuilder.buildDebugLocation(at: (sourceLine, sourceColumn), in: scope)

    case "[":
      // Jump If Zero
      let loopEntry = builder.insertBlock!
      let loopBody = function.appendBasicBlock(named: "loop")
      let loopExit = function.appendBasicBlock(named: "exit")

      // If zero
      let cond = builder.buildIsNotNull(builder.buildLoad(addressPointer))
      builder.buildCondBr(condition: cond, then: loopBody, else: loopExit)

      // Build a PHI for any address pointer changes in the exit block.
      builder.positionAtEnd(of: loopExit)
      let exitDestPHI = builder.buildPhi(addressPointer.type)
      exitDestPHI.addIncoming([ (addressPointer, loopEntry) ])

      // Build a PHI for any address pointer changes in the loop body.
      builder.positionAtEnd(of: loopBody)
      let headerDestPHI = builder.buildPhi(addressPointer.type)
      headerDestPHI.addIncoming([ (addressPointer, loopEntry) ])

      // Build a lexical scope and enter it.
      let loopScope = dibuilder.buildLexicalBlock(
        scope: scope, file: file,
        line: sourceLine, column: sourceColumn)
      scopeStack.append(loopScope)

      // Move to the loop header.
      addressPointer = headerDestPHI

      // Push the loop onto the nest.
      loopNest.append(Loop(entry: loopEntry,
                           body: loopBody,
                           exit: loopExit,
                           headerDestination: headerDestPHI,
                           exitDestination: exitDestPHI))
    case "]":
      // Jump If Not Zero

      // Pop the innermost loop off the nest.
      guard let loop = loopNest.popLast() else {
        fatalError("] requires matching [")
      }

      // Exit the loop's scope
      _ = scopeStack.popLast()

      // Finish off the phi nodes.
      loop.headerDestination.addIncoming([ (addressPointer, builder.insertBlock!) ])
      loop.exitDestination.addIncoming([ (addressPointer, builder.insertBlock!) ])

      // If not zero.
      let cond = builder.buildIsNotNull(builder.buildLoad(addressPointer))
      builder.buildCondBr(condition: cond, then: loop.body, else: loop.exit)

      // Move the exit block after the loop body.
      loop.exit.moveAfter(builder.insertBlock!)

      // Move to the exit.
      addressPointer = loop.exitDestination

      builder.positionAtEnd(of: loop.exit)
    case "\n":
      sourceLine += 1
      sourceColumn = 1
    default:
      continue
    }
  }

  // Ensure all loops have been closed.
  guard loopNest.isEmpty && scopeStack.count == 1 else {
    fatalError("[ requires matching ]")
  }

  // Flush everything
  _ = builder.buildCall(flushExtern, args: [])

  builder.buildRet(IntType.int32.zero())
}
