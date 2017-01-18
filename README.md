

# LLVMSwift
[![Build Status](https://travis-ci.org/trill-lang/LLVMSwift.svg?branch=master)](https://travis-ci.org/trill-lang/LLVMSwift) [![Documentation](https://cdn.rawgit.com/trill-lang/LLVMSwift/master/docs/badge.svg)](https://trill-lang.github.io/LLVMSwift) [![Slack Invite](https://llvmswift-slack.herokuapp.com/badge.svg)](https://llvmswift-slack.herokuapp.com)

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
                                                  returnType: VoidType()))
let entry = main.appendBasicBlock(named: "entry")
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

