import LLVM
import XCTest
import FileCheck
import Foundation

class TripleSpec : XCTestCase {
  func testBasicParsing() {
    var T: Triple = Triple("")
    XCTAssertEqual("", T.architectureName)
    XCTAssertEqual("", T.vendorName)
    XCTAssertEqual("", T.osName)
    XCTAssertEqual("", T.environmentName)

    T = Triple("-")
    XCTAssertEqual("", T.architectureName)
    XCTAssertEqual("", T.vendorName)
    XCTAssertEqual("", T.osName)
    XCTAssertEqual("", T.environmentName)

    T = Triple("--")
    XCTAssertEqual("", T.architectureName)
    XCTAssertEqual("", T.vendorName)
    XCTAssertEqual("", T.osName)
    XCTAssertEqual("", T.environmentName)

    T = Triple("---")
    XCTAssertEqual("", T.architectureName)
    XCTAssertEqual("", T.vendorName)
    XCTAssertEqual("", T.osName)
    XCTAssertEqual("", T.environmentName)

    T = Triple("----")
    XCTAssertEqual("", T.architectureName)
    XCTAssertEqual("", T.vendorName)
    XCTAssertEqual("", T.osName)
    XCTAssertEqual("-", T.environmentName)

    T = Triple("a")
    XCTAssertEqual("a", T.architectureName)
    XCTAssertEqual("", T.vendorName)
    XCTAssertEqual("", T.osName)
    XCTAssertEqual("", T.environmentName)

    T = Triple("a-b")
    XCTAssertEqual("a", T.architectureName)
    XCTAssertEqual("b", T.vendorName)
    XCTAssertEqual("", T.osName)
    XCTAssertEqual("", T.environmentName)

    T = Triple("a-b-c")
    XCTAssertEqual("a", T.architectureName)
    XCTAssertEqual("b", T.vendorName)
    XCTAssertEqual("c", T.osName)
    XCTAssertEqual("", T.environmentName)

    T = Triple("a-b-c-d")
    XCTAssertEqual("a", T.architectureName)
    XCTAssertEqual("b", T.vendorName)
    XCTAssertEqual("c", T.osName)
    XCTAssertEqual("d", T.environmentName)
  }

  func testParsedIDs() {
    var T = Triple("i386-apple-darwin")
    XCTAssertEqual(.x86, T.architecture)
    XCTAssertEqual(.apple, T.vendor)
    XCTAssertEqual(.darwin, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("i386-pc-elfiamcu")
    XCTAssertEqual(.x86, T.architecture)
    XCTAssertEqual(.pc, T.vendor)
    XCTAssertEqual(.elfIAMCU, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("i386-pc-contiki-unknown")
    XCTAssertEqual(.x86, T.architecture)
    XCTAssertEqual(.pc, T.vendor)
    XCTAssertEqual(.contiki, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("i386-pc-hurd-gnu")
    XCTAssertEqual(.x86, T.architecture)
    XCTAssertEqual(.pc, T.vendor)
    XCTAssertEqual(.hurd, T.os)
    XCTAssertEqual(.gnu, T.environment)

    T = Triple("x86_64-pc-linux-gnu")
    XCTAssertEqual(.x86_64, T.architecture)
    XCTAssertEqual(.pc, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnu, T.environment)

    T = Triple("x86_64-pc-linux-musl")
    XCTAssertEqual(.x86_64, T.architecture)
    XCTAssertEqual(.pc, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.musl, T.environment)

    T = Triple("powerpc-bgp-linux")
    XCTAssertEqual(.ppc, T.architecture)
    XCTAssertEqual(.bgp, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("powerpc-bgp-cnk")
    XCTAssertEqual(.ppc, T.architecture)
    XCTAssertEqual(.bgp, T.vendor)
    XCTAssertEqual(.cnk, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("ppc-bgp-linux")
    XCTAssertEqual(.ppc, T.architecture)
    XCTAssertEqual(.bgp, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("ppc32-bgp-linux")
    XCTAssertEqual(.ppc, T.architecture)
    XCTAssertEqual(.bgp, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("powerpc64-bgq-linux")
    XCTAssertEqual(.ppc64, T.architecture)
    XCTAssertEqual(.bgq, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("ppc64-bgq-linux")
    XCTAssertEqual(.ppc64, T.architecture)
    XCTAssertEqual(.bgq, T.vendor)
    XCTAssertEqual(.linux, T.os)

    T = Triple("powerpc-ibm-aix")
    XCTAssertEqual(.ppc, T.architecture)
    XCTAssertEqual(.ibm, T.vendor)
    XCTAssertEqual(.aix, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("powerpc64-ibm-aix")
    XCTAssertEqual(.ppc64, T.architecture)
    XCTAssertEqual(.ibm, T.vendor)
    XCTAssertEqual(.aix, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("powerpc-dunno-notsure")
    XCTAssertEqual(.ppc, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("arm-none-none-eabi")
    XCTAssertEqual(.arm, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)
    XCTAssertEqual(.eabi, T.environment)

    T = Triple("arm-none-linux-musleabi")
    XCTAssertEqual(.arm, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.muslEABI, T.environment)

    T = Triple("armv6hl-none-linux-gnueabi")
    XCTAssertEqual(.arm, T.architecture)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuEABI, T.environment)

    T = Triple("armv7hl-none-linux-gnueabi")
    XCTAssertEqual(.arm, T.architecture)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuEABI, T.environment)

    T = Triple("amdil-unknown-unknown")
    XCTAssertEqual(.amdil, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)

    T = Triple("amdil64-unknown-unknown")
    XCTAssertEqual(.amdil64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)

    T = Triple("hsail-unknown-unknown")
    XCTAssertEqual(.hsail, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)

    T = Triple("hsail64-unknown-unknown")
    XCTAssertEqual(.hsail64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)

    T = Triple("sparcel-unknown-unknown")
    XCTAssertEqual(.sparcel, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)

    T = Triple("spir-unknown-unknown")
    XCTAssertEqual(.spir, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)

    T = Triple("spir64-unknown-unknown")
    XCTAssertEqual(.spir64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)

    T = Triple("x86_64-unknown-ananas")
    XCTAssertEqual(.x86_64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.ananas, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("x86_64-unknown-cloudabi")
    XCTAssertEqual(.x86_64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.cloudABI, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("x86_64-unknown-fuchsia")
    XCTAssertEqual(.x86_64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.fuchsia, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("x86_64-unknown-hermit")
    XCTAssertEqual(.x86_64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.hermitCore, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("wasm32-unknown-unknown")
    XCTAssertEqual(.wasm32, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("wasm32-unknown-wasi-musl")
    XCTAssertEqual(.wasm32, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.wasi, T.os)
    XCTAssertEqual(.musl, T.environment)

    T = Triple("wasm64-unknown-unknown")
    XCTAssertEqual(.wasm64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("wasm64-unknown-wasi-musl")
    XCTAssertEqual(.wasm64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.wasi, T.os)
    XCTAssertEqual(.musl, T.environment)

    T = Triple("avr-unknown-unknown")
    XCTAssertEqual(.avr, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("avr")
    XCTAssertEqual(.avr, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("lanai-unknown-unknown")
    XCTAssertEqual(.lanai, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("lanai")
    XCTAssertEqual(.lanai, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("amdgcn-mesa-mesa3d")
    XCTAssertEqual(.amdgcn, T.architecture)
    XCTAssertEqual(.mesa, T.vendor)
    XCTAssertEqual(.mesa3D, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("amdgcn-amd-amdhsa")
    XCTAssertEqual(.amdgcn, T.architecture)
    XCTAssertEqual(.amd, T.vendor)
    XCTAssertEqual(.amdHSA, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("amdgcn-amd-amdpal")
    XCTAssertEqual(.amdgcn, T.architecture)
    XCTAssertEqual(.amd, T.vendor)
    XCTAssertEqual(.amdPAL, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("riscv32-unknown-unknown")
    XCTAssertEqual(.riscv32, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.unknown, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("riscv64-unknown-linux")
    XCTAssertEqual(.riscv64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("riscv64-unknown-freebsd")
    XCTAssertEqual(.riscv64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.freeBSD, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("armv7hl-suse-linux-gnueabi")
    XCTAssertEqual(.arm, T.architecture)
    XCTAssertEqual(.suse, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuEABI, T.environment)

    T = Triple("i586-pc-haiku")
    XCTAssertEqual(.x86, T.architecture)
    XCTAssertEqual(.pc, T.vendor)
    XCTAssertEqual(.haiku, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("x86_64-unknown-haiku")
    XCTAssertEqual(.x86_64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.haiku, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("mips-mti-linux-gnu")
    XCTAssertEqual(.mips, T.architecture)
    XCTAssertEqual(.mipsTechnologies, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnu, T.environment)

    T = Triple("mipsel-img-linux-gnu")
    XCTAssertEqual(.mipsel, T.architecture)
    XCTAssertEqual(.imaginationTechnologies, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnu, T.environment)

    T = Triple("mips64-mti-linux-gnu")
    XCTAssertEqual(.mips64, T.architecture)
    XCTAssertEqual(.mipsTechnologies, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnu, T.environment)

    T = Triple("mips64el-img-linux-gnu")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.imaginationTechnologies, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnu, T.environment)

    T = Triple("mips64el-img-linux-gnuabin32")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.imaginationTechnologies, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuABIN32, T.environment)

    T = Triple("mips64el-unknown-linux-gnuabi64")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuABI64, T.environment)
    T = Triple("mips64el")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuABI64, T.environment)

    T = Triple("mips64-unknown-linux-gnuabi64")
    XCTAssertEqual(.mips64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuABI64, T.environment)
    T = Triple("mips64")
    XCTAssertEqual(.mips64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuABI64, T.environment)

    T = Triple("mipsisa64r6el-unknown-linux-gnuabi64")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuABI64, T.environment)
    T = Triple("mips64r6el")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuABI64, T.environment)
    T = Triple("mipsisa64r6el")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuABI64, T.environment)

    T = Triple("mipsisa64r6-unknown-linux-gnuabi64")
    XCTAssertEqual(.mips64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuABI64, T.environment)
    T = Triple("mips64r6")
    XCTAssertEqual(.mips64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuABI64, T.environment)
    T = Triple("mipsisa64r6")
    XCTAssertEqual(.mips64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuABI64, T.environment)

    T = Triple("mips64el-unknown-linux-gnuabin32")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuABIN32, T.environment)
    T = Triple("mipsn32el")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuABIN32, T.environment)

    T = Triple("mips64-unknown-linux-gnuabin32")
    XCTAssertEqual(.mips64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuABIN32, T.environment)

    T = Triple("mipsn32")
    XCTAssertEqual(.mips64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuABIN32, T.environment)


    T = Triple("mipsisa64r6el-unknown-linux-gnuabin32")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuABIN32, T.environment)
    T = Triple("mipsn32r6el")
    XCTAssertEqual(.mips64el, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuABIN32, T.environment)

    T = Triple("mipsisa64r6-unknown-linux-gnuabin32")
    XCTAssertEqual(.mips64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuABIN32, T.environment)
    T = Triple("mipsn32r6")
    XCTAssertEqual(.mips64, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnuABIN32, T.environment)

    T = Triple("mipsel-unknown-linux-gnu")
    XCTAssertEqual(.mipsel, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnu, T.environment)

    T = Triple("mipsel")
    XCTAssertEqual(.mipsel, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnu, T.environment)


    T = Triple("mips-unknown-linux-gnu")
    XCTAssertEqual(.mips, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnu, T.environment)

    T = Triple("mips")
    XCTAssertEqual(.mips, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnu, T.environment)


    T = Triple("mipsisa32r6el-unknown-linux-gnu")
    XCTAssertEqual(.mipsel, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnu, T.environment)
    T = Triple("mipsr6el")
    XCTAssertEqual(.mipsel, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    T = Triple("mipsisa32r6el")
    XCTAssertEqual(.mipsel, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnu, T.environment)

    T = Triple("mipsisa32r6-unknown-linux-gnu")
    XCTAssertEqual(.mips, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnu, T.environment)
    T = Triple("mipsr6")
    XCTAssertEqual(.mips, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnu, T.environment)
    T = Triple("mipsisa32r6")
    XCTAssertEqual(.mips, T.architecture)
    XCTAssertEqual(.unknown, T.vendor)
    XCTAssertEqual(.gnu, T.environment)

    T = Triple("arm-oe-linux-gnueabi")
    XCTAssertEqual(.arm, T.architecture)
    XCTAssertEqual(.openEmbedded, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.gnuEABI, T.environment)

    T = Triple("aarch64-oe-linux")
    XCTAssertEqual(.aarch64, T.architecture)
    XCTAssertEqual(.openEmbedded, T.vendor)
    XCTAssertEqual(.linux, T.os)
    XCTAssertEqual(.unknown, T.environment)

    T = Triple("huh")
    XCTAssertEqual(.unknown, T.architecture)
  }


  func testNormalization() {
    XCTAssertEqual("unknown", Triple.normalize(""))
    XCTAssertEqual("unknown-unknown", Triple.normalize("-"))
    XCTAssertEqual("unknown-unknown-unknown", Triple.normalize("--"))
    XCTAssertEqual("unknown-unknown-unknown-unknown", Triple.normalize("---"))
    XCTAssertEqual("unknown-unknown-unknown-unknown-unknown", Triple.normalize("----"))

    XCTAssertEqual("a", Triple.normalize("a"))
    XCTAssertEqual("a-b", Triple.normalize("a-b"))
    XCTAssertEqual("a-b-c", Triple.normalize("a-b-c"))
    XCTAssertEqual("a-b-c-d", Triple.normalize("a-b-c-d"))

    XCTAssertEqual("i386-b-c", Triple.normalize("i386-b-c"))
    XCTAssertEqual("i386-a-c", Triple.normalize("a-i386-c"))
    XCTAssertEqual("i386-a-b", Triple.normalize("a-b-i386"))
    XCTAssertEqual("i386-a-b-c", Triple.normalize("a-b-c-i386"))

    XCTAssertEqual("a-pc-c", Triple.normalize("a-pc-c"))
    XCTAssertEqual("unknown-pc-b-c", Triple.normalize("pc-b-c"))
    XCTAssertEqual("a-pc-b", Triple.normalize("a-b-pc"))
    XCTAssertEqual("a-pc-b-c", Triple.normalize("a-b-c-pc"))

    XCTAssertEqual("a-b-linux", Triple.normalize("a-b-linux"))
    XCTAssertEqual("unknown-unknown-linux-b-c", Triple.normalize("linux-b-c"))
    XCTAssertEqual("a-unknown-linux-c", Triple.normalize("a-linux-c"))

    XCTAssertEqual("i386-pc-a", Triple.normalize("a-pc-i386"))
    XCTAssertEqual("i386-pc-unknown", Triple.normalize("-pc-i386"))
    XCTAssertEqual("unknown-pc-linux-c", Triple.normalize("linux-pc-c"))
    XCTAssertEqual("unknown-pc-linux", Triple.normalize("linux-pc-"))

    XCTAssertEqual("i386", Triple.normalize("i386"))
    XCTAssertEqual("unknown-pc", Triple.normalize("pc"))
    XCTAssertEqual("unknown-unknown-linux", Triple.normalize("linux"))

    XCTAssertEqual("x86_64-unknown-linux-gnu", Triple.normalize("x86_64-gnu-linux"))

    // Check that normalizing a permutated set of valid components returns a
    // triple with the unpermuted components.
    //
    // We don't check every possible combination. For the set of architectures A,
    // vendors V, operating systems O, and environments E, that would require |A|
    // * |V| * |O| * |E| * 4! tests. Instead we check every option for any given
    // slot and make sure it gets normalized to the correct position from every
    // permutation. This should cover the core logic while being a tractable
    // number of tests at (|A| + |V| + |O| + |E|) * 4!.
    /*
    let FirstArchType = ArchType.aarch64
    let FirstVendorType = VendorType.AMD
    let FirstOSType = OSType.AIX
    let FirstEnvType = EnvironmentType.Android
    let InitialC: [String] = [
      FirstArchType.rawValue,
      FirstVendorType.rawValue,
      FirstOSType.rawValue,
      FirstEnvType.rawValue,
    ]
    for Arch in ArchType.allCases.dropFirst() {
      var C = InitialC
      C[0] = Arch.rawValue
      let E = [C[0], C[1], C[2]].joined(separator: "-")
      var I = [0, 1, 2]
      repeat {
        XCTAssertEqual(E, Triple.normalize([C[I[0]], C[I[1]], C[I[2]]].joined(separator: "-")))
      } while nextPermutation(&I)
      let F = [C[0], C[1], C[2], C[3]].joined(separator: "-")
      var J = [0, 1, 2, 3]
      repeat {
        XCTAssertEqual(F, Triple.normalize([C[J[0]], C[J[1]], C[J[2]], C[J[3]]].joined(separator: "-")))
      } while nextPermutation(&J)
    }
    for Vendor in VendorType.allCases.dropFirst() {
      var C = InitialC
      C[1] = Vendor.rawValue
      let E = [C[0], C[1], C[2]].joined(separator: "-")
      var I = [0, 1, 2]
      repeat {
        XCTAssertEqual(E, Triple.normalize([C[I[0]], C[I[1]], C[I[2]]].joined(separator: "-")))
      } while nextPermutation(&I)
      let F = [C[0], C[1], C[2], C[3]].joined(separator: "-")
      var J = [0, 1, 2, 3]
      repeat {
        XCTAssertEqual(F, Triple.normalize([C[J[0]], C[J[1]], C[J[2]], C[J[3]]].joined(separator: "-")))
      } while nextPermutation(&J)
    }
    for OS in LLVM.OSType.allCases.dropFirst() {
      if (OS == .Win32) {
        continue
      }
      var C = InitialC
      C[2] = OS.rawValue
      let E = [C[0], C[1], C[2]].joined(separator: "-")
      var I = [0, 1, 2]
      repeat {
        XCTAssertEqual(E, Triple.normalize([C[I[0]], C[I[1]], C[I[2]]].joined(separator: "-")))
      } while nextPermutation(&I)
      let F = [C[0], C[1], C[2], C[3]].joined(separator: "-")
      var J = [0, 1, 2, 3]
      repeat {
        XCTAssertEqual(F, Triple.normalize([C[J[0]], C[J[1]], C[J[2]], C[J[3]]].joined(separator: "-")))
      } while nextPermutation(&J)
    }
    for Env in EnvironmentType.allCases.dropFirst() {
      var C = InitialC
      C[3] = Env.rawValue
      let F = [C[0], C[1], C[2], C[3]].joined(separator: "-")
      var J = [0, 1, 2, 3]
      repeat {
        XCTAssertEqual(F, Triple.normalize([C[J[0]], C[J[1]], C[J[2]], C[J[3]]].joined(separator: "-")))
      } while nextPermutation(&J)
    }
 */

    // Various real-world funky triples.  The value returned by GCC's config.sub
    // is given in the comment.
    XCTAssertEqual("i386-unknown-windows-gnu",
                   Triple.normalize("i386-mingw32")) // i386-pc-mingw32
    XCTAssertEqual("x86_64-unknown-linux-gnu",
                   Triple.normalize("x86_64-linux-gnu")) // x86_64-pc-linux-gnu
    XCTAssertEqual("i486-unknown-linux-gnu",
                   Triple.normalize("i486-linux-gnu")) // i486-pc-linux-gnu
    XCTAssertEqual("i386-redhat-linux",
                   Triple.normalize("i386-redhat-linux")) // i386-redhat-linux-gnu
    XCTAssertEqual("i686-unknown-linux",
                   Triple.normalize("i686-linux")) // i686-pc-linux-gnu
    XCTAssertEqual("arm-none-unknown-eabi",
                   Triple.normalize("arm-none-eabi")) // arm-none-eabi
  }

  func testFileFormat() {
    XCTAssertEqual(.elf, Triple("i686-unknown-linux-gnu").objectFormat)
    XCTAssertEqual(.elf, Triple("i686-unknown-freebsd").objectFormat)
    XCTAssertEqual(.elf, Triple("i686-unknown-netbsd").objectFormat)
    XCTAssertEqual(.elf, Triple("i686--win32-elf").objectFormat)
    XCTAssertEqual(.elf, Triple("i686---elf").objectFormat)

    XCTAssertEqual(.machO, Triple("i686-apple-macosx").objectFormat)
    XCTAssertEqual(.machO, Triple("i686-apple-ios").objectFormat)
    XCTAssertEqual(.machO, Triple("i686---macho").objectFormat)

    XCTAssertEqual(.coff, Triple("i686--win32").objectFormat)

    XCTAssertEqual(.elf, Triple("i686-pc-windows-msvc-elf").objectFormat)
    XCTAssertEqual(.elf, Triple("i686-pc-cygwin-elf").objectFormat)

    XCTAssertEqual(.wasm, Triple("wasm32-unknown-unknown").objectFormat)
    XCTAssertEqual(.wasm, Triple("wasm64-unknown-unknown").objectFormat)
    XCTAssertEqual(.wasm, Triple("wasm32-unknown-wasi-musl").objectFormat)
    XCTAssertEqual(.wasm, Triple("wasm64-unknown-wasi-musl").objectFormat)

    XCTAssertEqual(.wasm,
                   Triple("wasm32-unknown-unknown-wasm").objectFormat)
    XCTAssertEqual(.wasm,
                   Triple("wasm64-unknown-unknown-wasm").objectFormat)
    XCTAssertEqual(.wasm,
                   Triple("wasm32-unknown-wasi-musl-wasm").objectFormat)
    XCTAssertEqual(.wasm,
                   Triple("wasm64-unknown-wasi-musl-wasm").objectFormat)

    XCTAssertEqual(.xcoff, Triple("powerpc-ibm-aix").objectFormat)
    XCTAssertEqual(.xcoff, Triple("powerpc64-ibm-aix").objectFormat)
    XCTAssertEqual(.xcoff, Triple("powerpc---xcoff").objectFormat)
    XCTAssertEqual(.xcoff, Triple("powerpc64---xcoff").objectFormat)

    let MSVCNormalized = Triple(Triple.normalize("i686-pc-windows-msvc-elf"))
    XCTAssertEqual(.elf, MSVCNormalized.objectFormat)

    let GNUWindowsNormalized = Triple(Triple.normalize("i686-pc-windows-gnu-elf"))
    XCTAssertEqual(.elf, GNUWindowsNormalized.objectFormat)

    let CygnusNormalised = Triple(Triple.normalize("i686-pc-windows-cygnus-elf"))
    XCTAssertEqual(.elf, CygnusNormalised.objectFormat)

    let CygwinNormalized = Triple(Triple.normalize("i686-pc-cygwin-elf"))
    XCTAssertEqual(.elf, CygwinNormalized.objectFormat)
  }


  func testNormalizeWindows() {
    XCTAssertEqual("i686-pc-windows-msvc", Triple.normalize("i686-pc-win32"))
    XCTAssertEqual("i686-unknown-windows-msvc", Triple.normalize("i686-win32"))
    XCTAssertEqual("i686-pc-windows-gnu", Triple.normalize("i686-pc-mingw32"))
    XCTAssertEqual("i686-unknown-windows-gnu", Triple.normalize("i686-mingw32"))
    XCTAssertEqual("i686-pc-windows-gnu", Triple.normalize("i686-pc-mingw32-w64"))
    XCTAssertEqual("i686-unknown-windows-gnu", Triple.normalize("i686-mingw32-w64"))
    XCTAssertEqual("i686-pc-windows-cygnus", Triple.normalize("i686-pc-cygwin"))
    XCTAssertEqual("i686-unknown-windows-cygnus", Triple.normalize("i686-cygwin"))

    XCTAssertEqual("x86_64-pc-windows-msvc", Triple.normalize("x86_64-pc-win32"))
    XCTAssertEqual("x86_64-unknown-windows-msvc", Triple.normalize("x86_64-win32"))
    XCTAssertEqual("x86_64-pc-windows-gnu", Triple.normalize("x86_64-pc-mingw32"))
    XCTAssertEqual("x86_64-unknown-windows-gnu", Triple.normalize("x86_64-mingw32"))
    XCTAssertEqual("x86_64-pc-windows-gnu",
                   Triple.normalize("x86_64-pc-mingw32-w64"))
    XCTAssertEqual("x86_64-unknown-windows-gnu",
                   Triple.normalize("x86_64-mingw32-w64"))

    XCTAssertEqual("i686-pc-windows-elf", Triple.normalize("i686-pc-win32-elf"))
    XCTAssertEqual("i686-unknown-windows-elf", Triple.normalize("i686-win32-elf"))
    XCTAssertEqual("i686-pc-windows-macho", Triple.normalize("i686-pc-win32-macho"))
    XCTAssertEqual("i686-unknown-windows-macho",
                   Triple.normalize("i686-win32-macho"))

    XCTAssertEqual("x86_64-pc-windows-elf", Triple.normalize("x86_64-pc-win32-elf"))
    XCTAssertEqual("x86_64-unknown-windows-elf",
                   Triple.normalize("x86_64-win32-elf"))
    XCTAssertEqual("x86_64-pc-windows-macho",
                   Triple.normalize("x86_64-pc-win32-macho"))
    XCTAssertEqual("x86_64-unknown-windows-macho",
                   Triple.normalize("x86_64-win32-macho"))

    XCTAssertEqual("i686-pc-windows-cygnus",
                   Triple.normalize("i686-pc-windows-cygnus"))
    XCTAssertEqual("i686-pc-windows-gnu", Triple.normalize("i686-pc-windows-gnu"))
    XCTAssertEqual("i686-pc-windows-itanium",
                   Triple.normalize("i686-pc-windows-itanium"))
    XCTAssertEqual("i686-pc-windows-msvc", Triple.normalize("i686-pc-windows-msvc"))

    XCTAssertEqual("i686-pc-windows-elf",
                   Triple.normalize("i686-pc-windows-elf-elf"))
  }

  func testNormalizeARM() {
    XCTAssertEqual("armv6-unknown-netbsd-eabi",
                   Triple.normalize("armv6-netbsd-eabi"))
    XCTAssertEqual("armv7-unknown-netbsd-eabi",
                   Triple.normalize("armv7-netbsd-eabi"))
    XCTAssertEqual("armv6eb-unknown-netbsd-eabi",
                   Triple.normalize("armv6eb-netbsd-eabi"))
    XCTAssertEqual("armv7eb-unknown-netbsd-eabi",
                   Triple.normalize("armv7eb-netbsd-eabi"))
    XCTAssertEqual("armv6-unknown-netbsd-eabihf",
                   Triple.normalize("armv6-netbsd-eabihf"))
    XCTAssertEqual("armv7-unknown-netbsd-eabihf",
                   Triple.normalize("armv7-netbsd-eabihf"))
    XCTAssertEqual("armv6eb-unknown-netbsd-eabihf",
                   Triple.normalize("armv6eb-netbsd-eabihf"))
    XCTAssertEqual("armv7eb-unknown-netbsd-eabihf",
                   Triple.normalize("armv7eb-netbsd-eabihf"))

    XCTAssertEqual("armv7-suse-linux-gnueabihf",
                   Triple.normalize("armv7-suse-linux-gnueabi"))

    var T = Triple("armv6--netbsd-eabi")
    XCTAssertEqual(.arm, T.architecture)
    T = Triple("armv6eb--netbsd-eabi")
    XCTAssertEqual(.armeb, T.architecture)
    T = Triple("armv7-suse-linux-gnueabihf")
    XCTAssertEqual(.gnuEABIHF, T.environment)
  }

  func testParseARMArch() {
    // ARM
    XCTAssertEqual(.arm, Triple("arm").architecture)
    XCTAssertEqual(.armeb, Triple("armeb").architecture)

    // THUMB
    XCTAssertEqual(.thumb, Triple("thumb").architecture)
    XCTAssertEqual(.thumbeb, Triple("thumbeb").architecture)

    // AARCH64
    XCTAssertEqual(.aarch64, Triple("arm64").architecture)
    XCTAssertEqual(.aarch64, Triple("aarch64").architecture)
    XCTAssertEqual(.aarch64_be, Triple("aarch64_be").architecture)
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testBasicParsing", testBasicParsing),
    ("testParsedIDs", testParsedIDs),
    ("testNormalization", testNormalization),
    ("testFileFormat", testFileFormat),
    ("testNormalizeWindows", testNormalizeWindows),
    ("testNormalizeARM", testNormalizeARM),
    ("testParseARMArch", testParseARMArch),
  ])
  #endif
}

func nextPermutation(_ arr: inout [Int]) -> Bool {
  guard !arr.isEmpty else {
    return false
  }

  var i = arr.startIndex
  i += 1;
  if (i == arr.endIndex) {
    return false;
  }

  i = arr.endIndex;
  i -= 1;

  while (true) {
    let j = i;
    i -= 1;

    if (arr[i] < arr[j]) {
      var k = arr.endIndex

      repeat {
        k -= 1
      } while !(arr[i] < arr[k])


      arr.swapAt(i, k)

      reverse(&arr, j, arr.endIndex);
      return true;
    }

    if (i == arr.startIndex) {
      reverse(&arr, arr.startIndex, arr.endIndex);
      return false;
    }
  }
}

func reverse(_ arr: inout [Int], _ start: Int, _ end: Int) {
  guard !arr.isEmpty && start < end else {
    return
  }

  var first = start
  var last = end
  repeat {
    last -= 1
    arr.swapAt(first, last)
    first += 1
  } while (first != end) && (first != last - 1)
}
