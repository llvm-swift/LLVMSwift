#if SWIFT_PACKAGE
import cllvm
#endif

extension Context {
  /// Searches for and retrieves a metadata kind with the given name in this
  /// context.  If none is found, one with that name is created and its unique
  /// identifier is returned.
  public func metadataKind(named name: String, in context: Context = .global) -> UInt32 {
    return LLVMGetMDKindIDInContext(context.llvm, name, UInt32(name.count))
  }
}

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
  public func addMetadata(_ metadata: IRMetadata, kind: AttachedMetadata.PinnedKind) {
    LLVMGlobalSetMetadata(self.asLLVM(), kind.rawValue, metadata.asMetadata())
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

extension Instruction {
  /// Retrieves all metadata entries attached to this instruction.
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
  public func addMetadata(_ metadata: IRMetadata, kind: AttachedMetadata.PinnedKind) {
    LLVMSetMetadata(self.asLLVM(), kind.rawValue, LLVMMetadataAsValue(self.type.context.llvm, metadata.asMetadata()))
  }

  /// Sets a metadata attachment, erasing the existing metadata attachment if
  /// it already exists for the given kind.
  ///
  /// - Parameters:
  ///   - metadata: The metadata to attach to this global value.
  ///   - kind: The kind of metadata to attach.
  public func addMetadata(_ metadata: IRMetadata, kind: UInt32) {
    LLVMSetMetadata(self.asLLVM(), kind, LLVMMetadataAsValue(self.type.context.llvm, metadata.asMetadata()))
  }
}

/// Represents a sequence of metadata entries attached to a global value that
/// are uniqued by kind.
public class AttachedMetadata {
  /// Metadata kinds that are known to LLVM.
  public enum PinnedKind: UInt32 {
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
