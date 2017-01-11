import PackageDescription

let package = Package(
    name: "LLVM",
    dependencies: [
        .Package(url: "https://github.com/harlanhaskins/cllvm.git", majorVersion: 0),
    ]
)
