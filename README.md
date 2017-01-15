

# LLVMSwift [![Build Status](https://travis-ci.org/harlanhaskins/LLVMSwift.svg?branch=master)](https://travis-ci.org/harlanhaskins/LLVMSwift) [![Documentation](https://cdn.rawgit.com/harlanhaskins/LLVMSwift/master/docs/badge.svg)](https://harlanhaskins.github.io/LLVMSwift)

LLVMSwift is a set of Swifty API wrappers for the LLVM C API.
It makes compiler development feel great from Swift!

## Usage

To start emitting IR, you'll want to create a `Module` object, with an optional `Context` parameter,
and an `IRBuilder` that will build instructions for that module. 

```swift
let module = Module(name: "main")
let builder = IRBuilder(module: module)
```

Once you do that, you can start adding functions, global variables, and generating instructions!

```swift
let main = builder.addFunction(name: "main", 
                               type: FunctionType(argTypes: [], 
                                                  returnType: VoidType())
let entry = builder.appendBasicBlock(named: "entry")
builder.positionAtEnd(of: entry)

builder.buildRetVoid()

module.dump()
```

The IRBuilder class has methods for almost all functions from the LLVM C API, like:

- `builder.buildAdd`
- `builder.buildSub`
- `builder.buildMul`
- `builder.buildCondBr`
- `builder.addSwitch`

and so many more.

Plus, it provides common wrappers around oft-used types like `Function`, `Global`, `Switch`, and `PhiNode`.

## Installation

There are a couple, annoying steps you need to get it working before it'll
build.

- Install LLVM 3.9 using your favorite package manager. For example:
  - `brew install llvm`
- Ensure `llvm-config` is in your `PATH`
  - That will reside in the `/bin` folder wherever your package manager
    installed LLVM.
- Create a pkg-config file for your specific LLVM installation.
  - We have a utility for this: `swift utils/make-pkgconfig.swift`

Once you do that, you can add LLVMSwift as a dependency for your own Swift
compiler projects!

This project is used by [Trill](https://github.com/harlanhaskins/trill) for
all its code generation.

## Authors

- Harlan Haskins ([@harlanhaskins](https://github.com/harlanhaskins))
- Robert Widmann ([@CodaFi](https://github.com/CodaFi))

## License

This project is released under the MIT license, a copy of which is available
in this repo.

