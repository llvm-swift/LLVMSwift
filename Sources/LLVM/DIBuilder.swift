#if SWIFT_PACKAGE
import cllvm
#endif

/// Source languages known by DWARF.
public enum DWARFSourceLanguage {
  case ada83

  case ada95

  case c

  case c89

  case c99

  case c11

  case cPlusPlus

  case cPlusPlus03

  case cPlusPlus11

  case cPlusPlus14

  case cobol74

  case cobol85

  case fortran77

  case fortran90

  case fortran03

  case fortran08

  case pascal83

  case modula2

  case java

  case fortran95

  case PLI

  case objC

  case objCPlusPlus

  case UPC

  case D

  case python

  case openCL

  case go

  case modula3

  case haskell

  case ocaml

  case rust

  case swift

  case julia

  case dylan
  
  case renderScript
  
  case BLISS
  
  // MARK: Vendor Extensions

  case mipsAssembler
  
  case googleRenderScript
  
  case borlandDelphi


  private static let languageMapping: [DWARFSourceLanguage: LLVMDWARFSourceLanguage] = [
    .c: LLVMDWARFSourceLanguageC, .c89: LLVMDWARFSourceLanguageC89,
    .c99: LLVMDWARFSourceLanguageC99, .c11: LLVMDWARFSourceLanguageC11,
    .ada83: LLVMDWARFSourceLanguageAda83,
    .cPlusPlus: LLVMDWARFSourceLanguageC_plus_plus,
    .cPlusPlus03: LLVMDWARFSourceLanguageC_plus_plus_03,
    .cPlusPlus11: LLVMDWARFSourceLanguageC_plus_plus_11,
    .cPlusPlus14: LLVMDWARFSourceLanguageC_plus_plus_14,
    .cobol74: LLVMDWARFSourceLanguageCobol74,
    .cobol85: LLVMDWARFSourceLanguageCobol85,
    .fortran77: LLVMDWARFSourceLanguageFortran77,
    .fortran90: LLVMDWARFSourceLanguageFortran90,
    .pascal83: LLVMDWARFSourceLanguagePascal83,
    .modula2: LLVMDWARFSourceLanguageModula2,
    .java: LLVMDWARFSourceLanguageJava,
    .ada95: LLVMDWARFSourceLanguageAda95,
    .fortran95: LLVMDWARFSourceLanguageFortran95,
    .PLI: LLVMDWARFSourceLanguagePLI,
    .objC: LLVMDWARFSourceLanguageObjC,
    .objCPlusPlus: LLVMDWARFSourceLanguageObjC_plus_plus,
    .UPC: LLVMDWARFSourceLanguageUPC,
    .D: LLVMDWARFSourceLanguageD,
    .python: LLVMDWARFSourceLanguagePython,
    .openCL: LLVMDWARFSourceLanguageOpenCL,
    .go: LLVMDWARFSourceLanguageGo,
    .modula3: LLVMDWARFSourceLanguageModula3,
    .haskell: LLVMDWARFSourceLanguageHaskell,
    .ocaml: LLVMDWARFSourceLanguageOCaml,
    .rust: LLVMDWARFSourceLanguageRust,
    .swift: LLVMDWARFSourceLanguageSwift,
    .julia: LLVMDWARFSourceLanguageJulia,
    .dylan: LLVMDWARFSourceLanguageDylan,
    .fortran03: LLVMDWARFSourceLanguageFortran03,
    .fortran08: LLVMDWARFSourceLanguageFortran08,
    .renderScript: LLVMDWARFSourceLanguageRenderScript,
    .BLISS: LLVMDWARFSourceLanguageBLISS,
    .mipsAssembler: LLVMDWARFSourceLanguageMips_Assembler,
    .googleRenderScript: LLVMDWARFSourceLanguageGOOGLE_RenderScript,
    .borlandDelphi: LLVMDWARFSourceLanguageBORLAND_Delphi,
  ]

  /// Retrieves the corresponding `LLVMDWARFSourceLanguage`.
  public var llvm: LLVMDWARFSourceLanguage {
    return DWARFSourceLanguage.languageMapping[self]!
  }
}

/// The amount of debug information to emit.
public enum DWARFEmissionKind {
  case none
  case full
  case lineTablesOnly

  private static let emissionMapping: [DWARFEmissionKind: LLVMDWARFEmissionKind] = [
    .none: LLVMDWARFEmissionNone, .full: LLVMDWARFEmissionFull,
    .lineTablesOnly: LLVMDWARFEmissionLineTablesOnly,
  ]

  /// Retrieves the corresponding `LLVMDWARFEmissionKind`.
  public var llvm: LLVMDWARFEmissionKind {
    return DWARFEmissionKind.emissionMapping[self]!
  }
}

public final class DIBuilder {
  internal let llvm: LLVMDIBuilderRef

  /// The module this `IRBuilder` is associated with.
  public let module: Module

  public init(module: Module, allowUnresolved: Bool = false) {
    self.module = module
    if allowUnresolved {
      self.llvm = LLVMCreateDIBuilder(module.llvm)
    } else {
      self.llvm = LLVMCreateDIBuilderDisallowUnresolved(module.llvm)
    }
  }

  /// A CompileUnit provides an anchor for all debugging information generated
  /// during this instance of compilation.
  ///
  /// - Parameters:
  ///   - language: The source programming language.
  ///   - file: The file descriptor for the source file.
  ///   - kind: The kind of debug info to generate.
  ///   - optimized: A flag that indicates whether optimization is enabled or
  ///                not when compiling the source file.  Defaults to `false`.
  ///   - splitDebugInlining: A flag that indicates whether to emit inline debug
  ///                         information.  Defaults to `false`.
  ///   - debugInfoForProfiling: A flag that indicates whether to emit extra
  ///                            debug information for profile collection.
  ///   - flags: Command line options that are embedded in debug info for use
  ///            by third-party tools.
  ///   - identity: The identity of the tool that is compiling this source file.
  /// - Returns: A value representing a compilation-unit level scope.
  public func createCompileUnit(
    for language: DWARFSourceLanguage,
    in file: FileMetadata,
    kind: DWARFEmissionKind,
    optimized: Bool = false,
    splitDebugInlining: Bool = false,
    debugInfoForProfiling: Bool = false,
    flags: [String] = [],
    identity: String = "",
    splitName: String = ""
  ) -> Scope {
    let allFlags = flags.joined(separator: " ")
    guard let cu = LLVMDIBuilderCreateCompileUnit(
      self.llvm, language.llvm, file.llvm, identity, identity.count,
      optimized.llvm,
      allFlags, allFlags.count,
      /*Runtime Version*/0,
      splitName, splitName.count,
      kind.llvm,
      /*DWOId*/0,
      splitDebugInlining.llvm,
      debugInfoForProfiling.llvm
    ) else {
      fatalError()
    }
    return Scope(llvm: cu)
  }

  /// Create a file descriptor to hold debugging information for a file.
  ///
  /// - Parameters:
  ///   - name: The name of the file.
  ///   - directory: The directory the file resides in.
  /// - Returns: A value represending metadata about a given file.
  public func createFile(named name: String, in directory: String) -> FileMetadata {
    guard let file = LLVMDIBuilderCreateFile(self.llvm, name, name.count, directory, directory.count) else {
      fatalError("Failed to allocate metadata for a file")
    }
    return FileMetadata(llvm: file)
  }

  /// Creates a new debug location that describes a source location.
  ///
  /// - Parameters:
  ///   - location: The location of the line and column for this information.
  ///               If the location of the value is unknown, pass
  ///               `(line: 0, column: 0)`.
  ///   - scope: The scope this debug location resides in.
  ///   - inlinedAt: If this location has been inlined somewhere, the scope in
  ///                which it was inlined.  Defaults to `nil`.
  /// - Returns: A value representing a debug location.
  public func createDebugLocation(
    at location : (line: Int, column: Int),
    in scope: Scope,
    inlinedAt: Scope? = nil
  ) -> DebugLocation {
    guard let loc = LLVMDIBuilderCreateDebugLocation(
      self.module.context.llvm, UInt32(location.line), UInt32(location.column),
      scope.llvm, inlinedAt?.llvm
    ) else {
      fatalError("Failed to allocate metadata for a debug location")
    }
    return DebugLocation(llvm: loc)
  }

  /// Construct any deferred debug info descriptors.
  public func finalize() {
    LLVMDIBuilderFinalize(self.llvm)
  }

  deinit {
    LLVMDisposeDIBuilder(self.llvm)
  }
}
