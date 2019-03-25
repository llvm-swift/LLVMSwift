// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "LLVM",
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
      dependencies: ["cllvm"],
      linkerSettings: [
        .unsafeFlags([ "-w" ], .when(platforms: [.macOS]))
      ]),
    .target(
      name: "LLVM",
      dependencies: ["cllvm", "llvmshims"],
      linkerSettings: [
        .unsafeFlags([ "-w" ], .when(platforms: [.macOS]))
      ]),
    .testTarget(
      name: "LLVMTests",
      dependencies: ["LLVM", "FileCheck"]),
  ],
  cxxLanguageStandard: .cxx14
)
