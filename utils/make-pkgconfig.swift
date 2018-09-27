#!/usr/bin/env swift
import Foundation

#if os(Linux)
  let libCPP = "-L/usr/lib -lc++"
#elseif os(macOS)
  let libCPP = "-lc++"
#endif

/// Runs the specified program at the provided path.
/// - parameter path: The full path of the executable you
///                   wish to run.
/// - parameter args: The arguments you wish to pass to the
///                   process.
/// - returns: The standard output of the process, or nil if it was empty.
func run(_ path: String, args: [String] = []) -> String? {
    print("Running \(path) \(args.joined(separator: " "))...")
    let pipe = Pipe()
    let process = Process()
    process.launchPath = path
    process.arguments = args
    process.standardOutput = pipe
    process.launch()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let result = String(data: data, encoding: .utf8)?
                        .trimmingCharacters(in: .whitespacesAndNewlines),
              !result.isEmpty else { return nil }
    return result
}

/// Finds the location of the provided binary on your system.
func which(_ name: String) -> String? {
    return run("/usr/bin/which", args: [name])
}

extension String: Error {
  /// Replaces all occurrences of characters in the provided set with
  /// the provided string.
  func replacing(charactersIn characterSet: CharacterSet,
                 with separator: String) -> String {
    let components = self.components(separatedBy: characterSet)
    return components.joined(separator: separator)
  }
}

func makeFile() throws {
  let pkgConfigPath = "/usr/local/lib/pkgconfig"
  let pkgConfigDir = URL(fileURLWithPath: pkgConfigPath)

  // Make /usr/local/lib/pkgconfig if it doesn't already exist
  if !FileManager.default.fileExists(atPath: pkgConfigPath) {
    try FileManager.default.createDirectory(at: pkgConfigDir,
                                            withIntermediateDirectories: true)
  }
  let cllvmPath = pkgConfigDir.appendingPathComponent("cllvm.pc")

  let brewLLVMConfig: () -> String? = {
    guard let brew = which("brew") else { return nil }
    guard let brewPrefix = run(brew, args: ["--prefix"]) else { return nil }
    return which(brewPrefix + "/opt/llvm/bin/llvm-config")
  }

  /// Ensure we have llvm-config in the PATH
  guard let llvmConfig = which("llvm-config-7") ?? which("llvm-config") ?? brewLLVMConfig() else {
    throw "Failed to find llvm-config. Ensure llvm-config is installed and " +
          "in your PATH"
  }

  /// Extract the info we need from llvm-config

  print("Found llvm-config at \(llvmConfig)...")

  let versionStr = run(llvmConfig, args: ["--version"])!
                     .replacing(charactersIn: .newlines, with: "")
                     .replacingOccurrences(of: "svn", with: "")
  let components = versionStr.components(separatedBy: ".")
                             .compactMap { Int($0) }

  guard components.count == 3 else {
    throw "Invalid version number \(versionStr)"
  }

  let version = (components[0], components[1], components[2])

  guard version >= (7, 0, 0) else {
    throw "LLVMSwift requires LLVM version >=6.0.0, but you have \(versionStr)"
  }

  print("LLVM version is \(versionStr)")

  let ldFlags = run(llvmConfig, args: ["--ldflags", "--libs", "all",
                                       "--system-libs"])!
                .replacing(charactersIn: .newlines, with: " ")
                .components(separatedBy: " ")
                .filter { !$0.hasPrefix("-W") }
                .joined(separator: " ")

  // SwiftPM has a whitelisted set of cflags that it understands, and
  // unfortunately that includes almost everything but the include dir.

  let cFlags = run(llvmConfig, args: ["--cflags"])!
                .replacing(charactersIn: .newlines, with: "")
                .components(separatedBy: " ")
                .filter { $0.hasPrefix("-I") }
                .joined(separator: " ")

  /// Emit the pkg-config file to the path

  let s = [
    "Name: cllvm",
    "Description: The llvm library",
    "Version: \(versionStr)",
    "Libs: \(ldFlags) \(libCPP)",
    "Requires.private:",
    "Cflags: \(cFlags)",
  ].joined(separator: "\n")

  print("Writing pkg-config file to \(cllvmPath.path)...")

  try s.write(toFile: cllvmPath.path, atomically: true, encoding: .utf8)

  print("\nSuccessfully wrote pkg-config file!")
  print("Make sure to re-run this script when you update LLVM.")
}

do {
  try makeFile()
} catch {
  print("error: \(error)")
  exit(-1)
}
