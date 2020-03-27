// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "LLVM",
  platforms: [
    .macOS(.v10_14),
  ],
  products: [
    .library(
      name: "LLVM",
      targets: ["LLVM"]),
  ],
  dependencies: [
    .package(url: "https://github.com/llvm-swift/FileCheck.git", from: "0.0.3"),
  ],
  targets: [
    .systemLibrary(
      name: "cllvm",
      pkgConfig: "cllvm",
      providers: [
          .brew(["llvm"]),
      ]),
    .target(
      name: "llvmshims",
      dependencies: ["cllvm"]),
    .target(
      name: "LLVM",
      dependencies: ["cllvm", "llvmshims"]),
    .testTarget(
      name: "LLVMTests",
      dependencies: ["LLVM", "FileCheck"]),
  ],
  cxxLanguageStandard: .cxx14
)
