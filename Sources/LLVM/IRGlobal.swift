#if SWIFT_PACKAGE
import cllvm
#endif

/// An `IRGlobal` is a value, alias, or function that exists at the top level of
/// an LLVM module.
public protocol IRGlobal: IRConstant {}

extension IRGlobal {
  /// Retrieves the "value type" of this global value.
  ///
  /// The formal type of a global value is always a pointer type.  The value
  /// type, in contrast, is the type of the value the global points to.
  public var valueType: IRType {
    return convertType(LLVMGlobalGetValueType(asLLVM()))
  }

  /// Retrieves the alignment of this value.
  public var alignment: Alignment {
    get { return Alignment(LLVMGetAlignment(asLLVM())) }
    set { LLVMSetAlignment(asLLVM(), newValue.rawValue) }
  }
  
  /// Retrieves the linkage information for this global.
  public var linkage: Linkage {
    get { return Linkage(llvm: LLVMGetLinkage(asLLVM())) }
    set { LLVMSetLinkage(asLLVM(), newValue.llvm) }
  }

  /// Retrieves the visibility style for this global.
  public var visibility: Visibility {
    get { return Visibility(llvm: LLVMGetVisibility(asLLVM())) }
    set { LLVMSetVisibility(asLLVM(), newValue.llvm) }
  }

  /// Retrieves the storage class for this global declaration.  For use with
  /// Portable Executable files.
  public var storageClass: StorageClass {
    get { return StorageClass(llvm: LLVMGetDLLStorageClass(asLLVM())) }
    set { LLVMSetDLLStorageClass(asLLVM(), newValue.llvm) }
  }

  /// Retrieves an indicator for the significance of a global value's address.
  public var unnamedAddressKind: UnnamedAddressKind {
    get { return UnnamedAddressKind(llvm: LLVMGetUnnamedAddress(asLLVM()))  }
    set { LLVMSetUnnamedAddress(asLLVM(), newValue.llvm) }
  }

  /// Retrieves the COMDAT section for this global, if it exists.
  public var comdat: Comdat? {
    get { return LLVMGetComdat(asLLVM()).map(Comdat.init(llvm:))  }
    set { LLVMSetComdat(asLLVM(), newValue?.llvm) }
  }

  /// Retrieves the section associated with the symbol that will eventually be
  /// emitted for this global value.
  ///
  /// - Note: Global `Alias` values may or may not be resolvable to any
  ///   particular section given the state of the IR in an arbitrary module. A
  ///   return value of the empty string indicates a failed section lookup.
  public var section: String {
    get {
      guard let sname = LLVMGetSection(asLLVM()) else { return "" }
      return String(cString: sname)
    }
    set { LLVMSetSection(asLLVM(), newValue) }
  }

  /// Removes this global value from the module and deallocates it.
  ///
  /// - note: To ensure correct removal of the global value, you must invalidate
  ///         any references to it - usually by performing an
  ///         "Replace All Uses With" (RAUW) operation.
  ///
  /// - warning: The native Swift object wrapping this global becomes a dangling
  ///            reference once this function has been invoked.  It is
  ///            recommended that all references to it be dropped immediately.
  public func eraseFromParent() {
    LLVMDeleteGlobal(self.asLLVM())
  }
}

// MARK: Global Metadata

extension IRGlobal {
  /// Retrieves all metadata entries attached to this global value.
  public var metadata: AttachedMetadata {
    var count = 0
    let ptr = LLVMGlobalCopyAllMetadata(self.asLLVM(), &count)
    return AttachedMetadata(llvm: ptr, bounds: count)
  }

  /// Sets a metadata attachment, erasing the existing metadata attachment if
  /// it already exists for the given kind.
  ///
  /// - Parameters:
  ///   - metadata: The metadata to attach to this global value.
  ///   - kind: The kind of metadata to attach.
  public func addMetadata(_ metadata: IRMetadata, kind: UInt32) {
    LLVMGlobalSetMetadata(self.asLLVM(), kind, metadata.asMetadata())
  }

  /// Removes all metadata attachments from this value.
  public func removeAllMetadata() {
    LLVMGlobalClearMetadata(self.asLLVM())
  }

  /// Erases a metadata attachment of the given kind if it exists.
  ///
  /// - Parameter kind: The kind of the metadata to remove.
  public func eraseAllMetadata(of kind: UInt32) {
    LLVMGlobalEraseMetadata(self.asLLVM(), kind)
  }
}

/// Represents a sequence of metadata entries attached to a global value that
/// are uniqued by kind.
public class AttachedMetadata {
  /// Metadata kinds that are known to LLVM.
  public enum PinnedMetadataKind: UInt32 {
    /// "dbg"
    case dbg = 0
    /// "tbaa"
    case tbaa = 1
    /// "prof"
    case prof = 2
    /// "fpmath"
    case fpmath = 3
    /// "range"
    case range = 4
    /// "tbaa.struct"
    case tbaaStruct = 5
    /// "invariant.load"
    case invariantLoad = 6
    /// "alias.scope"
    case alias_scope = 7
    /// "noalias",
    case noalias = 8
    /// "nontemporal"
    case nontemporal = 9
    /// "llvm.mem.parallel_loop_access"
    case memParallelLoopAccess = 10
    /// "nonnull"
    case nonnull = 11
    /// "dereferenceable"
    case dereferenceable = 12
    /// "dereferenceable_or_null"
    case dereferenceable_or_null = 13
    /// "make.implicit"
    case makeImplicit = 14
    /// "unpredictable"
    case unpredictable = 15
    /// "invariant.group"
    case invariantGroup = 16
    /// "align"
    case align = 17
    /// "llvm.loop"
    case loop = 18
    /// "type"
    case type = 19
    /// "section_prefix"
    case sectionPrefix = 20
    /// "absolute_symbol"
    case absoluteSymbol = 21
    /// "associated"
    case associated = 22
    /// "callees"
    case callees = 23
    /// "irr_loop"
    case irrLoop = 24
    /// "llvm.access.group"
    case accessGroup = 25
    // "callback"
    case callback = 26
  }

  /// Represents an entry in the module flags structure.
  public struct Entry {
    fileprivate let base: AttachedMetadata
    fileprivate let index: UInt32

    /// The metadata kind associated with this global metadata.
    public var kind: UInt32 {
      return LLVMValueMetadataEntriesGetKind(self.base.llvm, self.index)
    }

    /// The metadata value associated with this entry.
    public var metadata: IRMetadata {
      return AnyMetadata(llvm: LLVMValueMetadataEntriesGetMetadata(self.base.llvm, self.index))
    }
  }

  private let llvm: OpaquePointer?
  private let bounds: Int
  fileprivate init(llvm: OpaquePointer?, bounds: Int) {
    self.llvm = llvm
    self.bounds = bounds
  }

  deinit {
    guard let ptr = llvm else { return }
    LLVMDisposeValueMetadataEntries(ptr)
  }

  /// Retrieves a flag at the given index.
  ///
  /// - Parameter index: The index to retrieve.
  ///
  /// - Returns: An entry describing the flag at the given index.
  public subscript(_ index: Int) -> Entry {
    precondition(index >= 0 && index < self.bounds, "Index out of bounds")
    return Entry(base: self, index: UInt32(index))
  }

  public var count: Int {
    return self.bounds
  }
}
