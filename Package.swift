import PackageDescription

let package = Package(
  name: "LLVM",
  dependencies: [
    .Package(url: "https://github.com/trill-lang/cllvm.git", majorVersion: 0),
  ]
)
