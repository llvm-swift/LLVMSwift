import PackageDescription

let package = Package(
    name: "LLVM",
    targets: [
        Target(name: "LLVM", dependencies: ["LLVMWrappers"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/harlanhaskins/cllvm.git", majorVersion: 0),
    ]
)
