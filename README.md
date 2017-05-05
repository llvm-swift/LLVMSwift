# LLVMSwift
[![Build Status](https://travis-ci.org/trill-lang/LLVMSwift.svg?branch=master)](https://travis-ci.org/trill-lang/LLVMSwift) [![Documentation](https://cdn.rawgit.com/trill-lang/LLVMSwift/master/docs/badge.svg)](https://trill-lang.github.io/LLVMSwift) [![Slack Invite](https://llvmswift-slack.herokuapp.com/badge.svg)](https://llvmswift-slack.herokuapp.com)

LLVMSwift is a pure Swift interface to the [LLVM](http://llvm.org) API and its associated libraries. It provides native, easy-to-use components to make compiler development fun.

## Introduction

### LLVM IR

The root unit of organization of an LLVM IR program is a `Module`

```swift
let module = Module(name: "main")
```

LLVM IR is construction is done with an `IRBuilder` object.  An `IRBuilder` is a cursor pointed inside a context, and as such has ways of extending that context and moving around inside of it.

Defining a simple function and moving the cursor to a point where we can begin inserting instructions is done like so:

```swift
let builder = IRBuilder(module: module)

let main = builder.addFunction(
             name: "main", 
             type: FunctionType(argTypes: [],
             returnType: VoidType())
           )
let entry = main.appendBasicBlock(named: "entry")
builder.positionAtEnd(of: entry)
```

Inserting instructions creates native `IRValue` placeholder objects that allow us to structure LLVM IR programs just like Swift programs:

```swift
let constant = IntType.int64.constant(21)
let sum = builder.buildAdd(constant, constant)
builder.buildRet(sum)
```

This simple program generates the following IR:

```llvm
// module.dump()

define void @main() {
entry:
  ret i64 42
}
```

### Types

LLVM IR is a strong, statically typed language.  As such, values and functions
are tagged with their types, and conversions between them must be explicit (see
[Conversion Operators](http://llvm.org/docs/LangRef.html#conversion-operations)).
LLVMSwift represents this with values conforming to the `IRType` protocol and defines
the following types:

|**Type** | **Represents** |
|:---:|:---:|
| VoidType | Nothing; Has no size |
| IntType | Integer and Boolean values (`i1`) |
| FloatType | Floating-point values |
| FunctionType | Function values |
| LabelType | Code labels |
| TokenType | Values paired with instructions |
| MetadataType | Embedded metadata |
| X86MMXType | X86 MMX values |
| PointerType | Pointer values |
| VectorType | SIMD data |
| ArrayType | Homogeneous values |
| Structure Type | Heterogeneous values |


### Control Flow

Control flow is changed through the unconditional and conditional `br` instruction.

LLVM is also famous for a control-flow specific IR construct called a [PHI node](http://llvm.org/docs/LangRef.html#phi-instruction).  Because all instructions in LLVM IR are in SSA (Single Static Assignment) form, a PHI node is necessary when the value of a variable assignment depends on the path the flow of control takes through the program.  For example, let's try to build the following Swift program in IR:

```swift
func calculateFibs(_ backward : Bool) -> Double {
  let retVal : Double
  if !backward {
    // the fibonacci series (sort of)
    retVal = 1/89
  } else {
    // the fibonacci series (sort of) backwards
    retVal = 1/109
  }
  return retVal
}
```

Notice that the value of `retVal` depends on the path the flow of control takes through this program, so we must emit a PHI node to properly initialize it:

```swift
let function = builder.addFunction(
                 "calculateFibs", 
                 type: FunctionType(argTypes: [IntType.int1], 
                 returnType: FloatType.double)
               )
let entryBB = function.appendBasicBlock(named: "entry")
builder.positionAtEnd(of: entryBB)

// Compare to the condition
let test = builder.buildICmp(function.parameters[0], IntType.int1.zero(), .notEqual)

// Create basic blocks for "then", "else", and "merge"
let thenBB = function.appendBasicBlock(named: "then")
let elseBB = function.appendBasicBlock(named: "else")
let mergeBB = function.appendBasicBlock(named: "merge")

builder.buildCondBr(condition: test, then: thenBB, else: elseBB)

// MARK: Then Block
builder.positionAtEnd(of: thenBB)
// local = 1/89, the fibonacci series (sort of)
let thenVal = FloatType.double.constant(1/89)
// Branch to the merge block
builder.buildBr(mergeBB)

// MARK: Else Block
builder.positionAtEnd(of: elseBB)
// local = 1/109, the fibonacci series (sort of) backwards
let elseVal = FloatType.double.constant(1/109)
// Branch to the merge block
builder.buildBr(mergeBB)

// MARK: Merge Block
builder.positionAtEnd(of: mergeBB)
let phi = builder.buildPhi(FloatType.double, name: "phi_example")
phi.addIncoming([
  (thenVal, thenBB),
  (elseVal, elseBB),
])
builder.buildRet(phi)
```

This program generates the following IR:

```llvm
define double @calculateFibs(i1) {
entry:
  %1 = icmp ne i1 %0, false
  br i1 %1, label %then, label %else

then:                                             ; preds = %entry
  br label %merge

else:                                             ; preds = %entry
  br label %merge

merge:                                            ; preds = %else, %then
  %phi_example = phi double [ 0x3F8702E05C0B8170, %then ], [ 0x3F82C9FB4D812CA0, %else ]
  ret double %phi_example
}
```

### JIT

LLVMSwift provides a JIT abstraction to make executing code in LLVM modules quick and easy.  Let's execute the PHI node example from before:

```swift
// Setup the JIT
let jit = try! JIT(module: module, machine: TargetMachine())
typealias FnPtr = @convention(c) (Bool) -> Double
// Retrieve a handle to the function we're going to invoke
let fnAddr = jit.addressOfFunction(name: "calculateFibs")
let fn = unsafeBitCast(fnAddr, to: FnPtr.self)
// Call the function!
print(fn(true)) // 0.00917431192660551...
print(fn(false)) // 0.0112359550561798...
```

## Installation

There are a couple, annoying steps you need to get it working before it'll
build.

- Install LLVM 4.0 using your favorite package manager. For example:
  - `brew install llvm`
- Ensure `llvm-config` is in your `PATH`
  - That will reside in the `/bin` folder wherever your package manager
    installed LLVM.
- Create a pkg-config file for your specific LLVM installation.
  - We have a utility for this: `swift utils/make-pkgconfig.swift`

Once you do that, you can add LLVMSwift as a dependency for your own Swift
compiler projects!

### Installation without Swift Package Manager

We really recommend using SwiftPM with LLVMSwift, but if your project is
structured in such a way that makes using SwiftPM impractical or impossible,
you can still use LLVMSwift by passing the `-DNO_SWIFTPM` to swift when
compiling.

- Xcode:
  - Add this repository as a git submodule
  - Add the files in `Sources/` to your Xcode project.
  - Under `Other Swift Flags`, add `-DNO_SWIFTPM`.
  - Under `Library Search Paths` add the output of `llvm-config --libdir`
  - Under `Header Search Paths` add the output of `llvm-config --includedir`
  - Under `Link Target with Libraries` drag in
    `/path/to/your/llvm/lib/libLLVM.dylib`

This project is used by [Trill](https://github.com/harlanhaskins/trill) for
all its code generation.

## Authors

- Harlan Haskins ([@harlanhaskins](https://github.com/harlanhaskins))
- Robert Widmann ([@CodaFi](https://github.com/CodaFi))

## License

This project is released under the MIT license, a copy of which is available
in this repo.
