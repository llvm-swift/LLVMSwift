#if SWIFT_PACKAGE
  import cllvm
#endif

/// An in-memory representation of a format-independent object file.
public class ObjectFile {
  let llvm: LLVMObjectFileRef

  /// Creates an `ObjectFile` with the contents of a provided memory buffer.
  /// - parameter memoryBuffer: A memory buffer containing a valid binary
  ///                           object file.
  public init?(memoryBuffer: MemoryBuffer) {
    guard let file = LLVMCreateObjectFile(memoryBuffer.llvm) else {
      return nil
    }
    self.llvm = file
  }

  /// Creates an `ObjectFile` with the contents of the object file at
  /// the provided path.
  /// - parameter path: The absolute file path on your filesystem.
  public convenience init?(path: String) {

    guard let memoryBuffer = try? MemoryBuffer(contentsOf: path) else {
      return nil
    }
    self.init(memoryBuffer: memoryBuffer)
  }

  /// Returns a sequence of all the sections in this object file.
  public var sections: SectionSequence {
    return SectionSequence(llvm: LLVMGetSections(llvm), object: self)
  }

  /// Returns a sequence of all the symbols in this object file.
  public var symbols: SymbolSequence {
    return SymbolSequence(llvm: LLVMGetSymbols(llvm), object: self)
  }

  /// Deinitialize this value and dispose of its resources.
  deinit {
    LLVMDisposeObjectFile(llvm)
  }
}

/// A Section represents one of the binary sections in an object file.
public struct Section {
  /// The section's declared name.
  public let name: String
  /// The size of the contents of the section.
  public let size: Int
  /// The raw contents of the section.
  public let contents: String
  /// The address of the section in the object file.
  public let address: Int

  /// The parent sequence of this section.
  private let sectionIterator: LLVMSectionIteratorRef

  internal init(fromIterator si: LLVMSectionIteratorRef) {
    self.sectionIterator = si
    self.name = String(cString: LLVMGetSectionName(si))
    self.size = Int(LLVMGetSectionSize(si))
    self.contents = String(cString: LLVMGetSectionContents(si))
    self.address = Int(LLVMGetSectionAddress(si))
  }

  /// Returns a sequence of all the relocations in this object file.
  public var relocations: RelocationSequence {
    return RelocationSequence(
      llvm: LLVMGetRelocations(self.sectionIterator),
      sectionIterator: self.sectionIterator
    )
  }

  /// Returns whether a symbol matching the given `Symbol` can be found in
  /// this section.
  public func contains(symbol: Symbol) -> Bool {
    return LLVMGetSectionContainsSymbol(self.sectionIterator, symbol.symbolIterator) != 0
  }
}

/// A sequence for iterating over the sections in an object file.
public class SectionSequence: Sequence {
  let llvm: LLVMSectionIteratorRef
  let objectFile: ObjectFile

  init(llvm: LLVMSectionIteratorRef, object: ObjectFile) {
    self.llvm = llvm
    self.objectFile = object
  }

  /// Makes an iterator that iterates over the sections in an object file.
  public func makeIterator() -> AnyIterator<Section> {
    return AnyIterator {
      if LLVMIsSectionIteratorAtEnd(self.objectFile.llvm, self.llvm) != 0 {
        return nil
      }
      defer { LLVMMoveToNextSection(self.llvm) }
      return Section(fromIterator: self.llvm)
    }
  }

  /// Deinitialize this value and dispose of its resources.
  deinit {
    LLVMDisposeSectionIterator(llvm)
  }
}

/// A symbol is a top-level addressable entity in an object file.
public struct Symbol {
  /// The symbol name.
  public let name: String
  /// The size of the data in the symbol.
  public let size: Int
  /// The address of the symbol in the object file.
  public let address: Int

  /// The parent sequence of this symbol.
  fileprivate let symbolIterator: LLVMSymbolIteratorRef

  internal init(fromIterator si: LLVMSymbolIteratorRef) {
    self.name = String(cString: LLVMGetSymbolName(si))
    self.size = Int(LLVMGetSymbolSize(si))
    self.address = Int(LLVMGetSymbolAddress(si))
    self.symbolIterator = si
  }
}

/// A Relocation represents the contents of a relocated symbol in the dynamic
/// linker.
public struct Relocation {
  /// Retrieves the type of this relocation.
  ///
  /// The value of this integer is dependent upon the type of object file
  /// it was retrieved from.
  public let type: Int
  /// The offset the relocated symbol resides at.
  public let offset: Int
  /// The symbol that is the subject of the relocation.
  public let symbol: Symbol
  /// Get a string that represents the type of this relocation for display
  /// purposes.
  public let typeName: String

  internal init(fromIterator ri: LLVMRelocationIteratorRef) {
    self.type = Int(LLVMGetRelocationType(ri))
    self.offset = Int(LLVMGetRelocationOffset(ri))
    self.symbol = Symbol(fromIterator: LLVMGetRelocationSymbol(ri))
    self.typeName = String(cString: LLVMGetRelocationTypeName(ri))
  }
}

/// A sequence for iterating over the relocations in an object file.
public class RelocationSequence: Sequence {
  let llvm: LLVMRelocationIteratorRef
  let sectionIterator: LLVMSectionIteratorRef

  init(llvm: LLVMRelocationIteratorRef, sectionIterator: LLVMSectionIteratorRef) {
    self.llvm = llvm
    self.sectionIterator = sectionIterator
  }

  /// Creates an iterator that will iterate over all relocations in an object
  /// file.
  public func makeIterator() -> AnyIterator<Relocation> {
    return AnyIterator {
      if LLVMIsRelocationIteratorAtEnd(self.sectionIterator, self.llvm) != 0 {
        return nil
      }
      defer { LLVMMoveToNextRelocation(self.llvm) }
      return Relocation(fromIterator: self.llvm)
    }
  }

  /// Deinitialize this value and dispose of its resources.
  deinit {
    LLVMDisposeSectionIterator(llvm)
  }
}

/// A sequence for iterating over the symbols in an object file.
public class SymbolSequence: Sequence {
  let llvm: LLVMSymbolIteratorRef
  let object: ObjectFile

  init(llvm: LLVMSymbolIteratorRef, object: ObjectFile) {
    self.llvm = llvm
    self.object = object
  }

  /// Creates an iterator that will iterate over all symbols in an object
  /// file.
  public func makeIterator() -> AnyIterator<Symbol> {
    return AnyIterator {
      if LLVMIsSymbolIteratorAtEnd(self.object.llvm, self.llvm) != 0 {
        return nil
      }
      defer { LLVMMoveToNextSymbol(self.llvm) }
      return Symbol(fromIterator: self.llvm)
    }
  }

  /// Deinitialize this value and dispose of its resources.
  deinit {
    LLVMDisposeSymbolIterator(llvm)
  }
}
