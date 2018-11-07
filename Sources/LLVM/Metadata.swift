#if SWIFT_PACKAGE
import cllvm
#endif

public protocol _IRMetadataInitializerHack {
  init(llvm: LLVMMetadataRef)
}

/// The `Metadata` protocol captures those types that represent metadata nodes
/// in LLVM IR.
///
/// LLVM IR allows metadata to be attached to instructions in the program that
/// can convey extra information about the code to the optimizers and code
/// generator. One example application of metadata is source-level debug
/// information.
///
/// Metadata does not have a type, and is not a value. If referenced from a call
/// instruction, it uses the metadata type.
///
/// The idea of LLVM debugging information is to capture how the important
/// pieces of the source-language’s Abstract Syntax Tree map onto LLVM code.
/// LLVM takes a number of positions on the impact of the broader compilation
/// process on debug information:
///
/// - Debugging information should have very little impact on the rest of the
///   compiler. No transformations, analyses, or code generators should need to
///   be modified because of debugging information.
/// - LLVM optimizations should interact in well-defined and easily described
///   ways with the debugging information.
/// - Because LLVM is designed to support arbitrary programming languages,
///   LLVM-to-LLVM tools should not need to know anything about the semantics
///   of the source-level-language.
/// - Source-level languages are often widely different from one another. LLVM
///   should not put any restrictions of the flavor of the source-language, and
///   the debugging information should work with any language.
/// - With code generator support, it should be possible to use an LLVM compiler
///   to compile a program to native machine code and standard debugging
///   formats. This allows compatibility with traditional machine-code level
///   debuggers, like GDB, DBX, or CodeView.
public protocol Metadata: _IRMetadataInitializerHack {
  func asMetadata() -> LLVMMetadataRef
}

extension Metadata {
  /// Replaces all uses of the this metadata with the given metadata.
  ///
  /// - parameter metadata: The new value to swap in.
  public func replaceAllUses(with metadata: Metadata) {
    LLVMMetadataReplaceAllUsesWith(self.asMetadata(), metadata.asMetadata())
  }
}

extension Metadata {
  /// Dumps a representation of this metadata to stderr.
  public func dump() {
    LLVMDumpValue(LLVMMetadataAsValue(LLVMGetGlobalContext(), self.asMetadata()))
  }

  public func forceCast<DestTy: Metadata>(to: DestTy.Type) -> DestTy {
    return DestTy(llvm: self.asMetadata())
  }
}

/// Denotes a scope in which child metadata nodes can be inserted.
public protocol DIScope: Metadata {}

/// Denotes metadata for a type.
public protocol DIType: DIScope {}

extension DIType {
  /// Retrieves the name of this type.
  public var name: String {
    var length: Int = 0
    let cstring = LLVMDITypeGetName(self.asMetadata(), &length)
    return String(cString: cstring!)
  }

  /// Retrieves the size of the type represented by this metadata in bits.
  public var sizeInBits: Size {
    return Size(LLVMDITypeGetSizeInBits(self.asMetadata()))
  }

  /// Retrieves the offset of the type represented by this metadata in bits.
  public var offsetInBits: Size {
    return Size(LLVMDITypeGetOffsetInBits(self.asMetadata()))
  }

  /// Retrieves the alignment of the type represented by this metadata in bits.
  public var alignmentInBits: Alignment {
    return Alignment(LLVMDITypeGetAlignInBits(self.asMetadata()))
  }

  /// Retrieves the line the type represented by this metadata is declared on.
  public var line: Int {
    return Int(LLVMDITypeGetLine(self.asMetadata()))
  }

  /// Retrieves the flags the type represented by this metadata is declared
  /// with.
  public var flags: DIFlags {
    return DIFlags(rawValue: LLVMDITypeGetFlags(self.asMetadata()).rawValue)
  }
}

/// A `DebugLocation` represents a location in source.
public struct DebugLocation: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  /// Retrieves the line described by this location.
  public var line: Int {
    return Int(LLVMDILocationGetLine(self.llvm))
  }

  /// Retrieves the column described by this location.
  public var column: Int {
    return Int(LLVMDILocationGetColumn(self.llvm))
  }

  /// Retrieves the enclosing scope containing this location.
  public var scope: DIScope {
    return DIOpaqueType(llvm: LLVMDILocationGetScope(self.llvm))
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

struct AnyMetadata: Metadata {
  let llvm: LLVMMetadataRef

  func asMetadata() -> LLVMMetadataRef {
    return llvm
  }
}

struct DIOpaqueType: DIType {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

/// `CompileUnitMetadata` nodes represent a compile unit, the root of a metadata
/// hierarchy for a translation unit.
///
/// Compile unit descriptors provide the root scope for objects declared in a
/// specific compilation unit. `FileMetadata` descriptors are defined using this
/// scope.
///
/// These descriptors are collected by a named metadata node `!llvm.dbg.cu`.
/// They keep track of global variables, type information, and imported entities
/// (declarations and namespaces).
public struct CompileUnitMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}


/// `FileMetadata` nodes represent files.
///
/// The file name does not necessarily have to be a proper file path.  For
/// example, it can include additional slash-separated path components.
public struct FileMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

/// `DIBasicType` nodes represent primitive types, such as `int`, `bool` and
/// `float`.
///
/// Basic types carry an encoding describing the details of the type to
/// influence how it is presented in debuggers.  LLVM currently supports
/// specific DWARF "Attribute Type Encodings" that are enumerated in
/// `DIAttributeTypeEncoding`.
public struct DIBasicType: DIType {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

/// `DISubroutineType` nodes represent subroutine types.
///
/// Subroutine types are meant to mirror their formal declarations in source:
/// arguments are represented in order.  The return type is optional and meant
/// to represent the concept of `void` in C-like languages.
public struct DISubroutineType: DIType {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

/// `LexicalBlockMetadata` nodes describe nested blocks within a subprogram. The
/// line number and column numbers are used to distinguish two lexical blocks at
/// same depth.
///
/// Usually lexical blocks are distinct to prevent node merging based on
/// operands.
public struct LexicalBlockMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

/// `LexicalBlockFile` nodes are used to discriminate between sections of a
/// lexical block. The file field can be changed to indicate textual inclusion,
/// or the discriminator field can be used to discriminate between control flow
/// within a single block in the source language.
public struct LexicalBlockFileMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

/// `LocalVariableMetadata` nodes represent local variables and function
/// parameters in the source language.
public struct LocalVariableMetadata: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

/// `ObjectiveCPropertyMetadata` nodes represent Objective-C property nodes.
public struct ObjectiveCPropertyMetadata: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

/// `ImportedEntityMetadata` nodes represent entities (such as modules) imported
/// into a compile unit.
public struct ImportedEntityMetadata: DIType {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct FunctionMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct ModuleMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct NameSpaceMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

/// `ExpressionMetadata` nodes represent expressions that are inspired by the
/// DWARF expression language. They are used in debug intrinsics (such as
/// llvm.dbg.declare and llvm.dbg.value) to describe how the referenced LLVM
/// variable relates to the source language variable.
///
/// Debug intrinsics are interpreted left-to-right: start by pushing the
/// value/address operand of the intrinsic onto a stack, then repeatedly push
/// and evaluate opcodes from the `ExpressionMetadata` until the final variable
/// description is produced.
///
/// Though DWARF supports hundreds of expressions, LLVM currently implements
/// a very limited subset.
public struct ExpressionMetadata: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}
