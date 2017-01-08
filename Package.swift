import PackageDescription

let package = Package(
    name: "LLVMSwift",
    dependencies: [
        .Package(url: "https://github.com/harlanhaskins/cllvm.git", majorVersion: 0),
    ]
)
