// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "LLVM",
  products: [
    .library(
      name: "LLVM",
      targets: ["LLVM"]),
  ],
  dependencies: [
    .package(url: "https://github.com/trill-lang/cllvm.git", .branch("master")),
  ]
)
