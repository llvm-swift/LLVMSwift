# LLVMSwift

LLVMSwift is a set of Swifty API wrappers for the LLVM C API.
It makes compiler development feel great from Swift!

## Installation

There are a couple, annoying steps you need to get it working before it'll
build. Number one, you'll need a custom `cllvm` pkg-config file, which is
included in the repo. Drop that in `/usr/local/lib/pkgconfig` and make sure
you have LLVM installed through `homebrew`:

```
brew install llvm
```

Once you do that, you can add LLVMSwift as a dependency for your own Swift
compiler projects!

This project is used by [Trill](https://github.com/harlanhaskins/trill) for
all its code generation.

Happy compiling!

## Author

Harlan Haskins ([@harlanhaskins](https://github.com/harlanhaskins))

## License

This project is released under the MIT license, a copy of which is available
in this repo.

