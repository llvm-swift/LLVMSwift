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
    .package(url: "https://github.com/trill-lang/FileCheck.git", .branch("master")),
  ],
  targets: [
    .target(
      name: "LLVM"),
    .testTarget(
      name: "LLVMTests",
      dependencies: ["LLVM", "FileCheck"]),
  ]
)
