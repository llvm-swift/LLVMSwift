import cllvm

/// The `MetadataType` type represents embedded metadata. No derived types may
/// be created from metadata except for function arguments.
public struct MetadataType: IRType {
  internal let llvm: LLVMTypeRef

  /// Creates an embedded metadata type for the given LLVM type object.
  public init(llvm: LLVMTypeRef) {
    self.llvm = llvm
  }

  /// Retrieves the underlying LLVM type object.
  public func asLLVM() -> LLVMTypeRef {
    return llvm
  }
}

/// Represents the debugInfofferent kinds of metadata available
public protocol IRMetadata: IRValue {}

extension IRMetadata {
  /// Retrieves the operands to which this metadata is attached
  public var operands: [IRValue] {
    let count = Int(LLVMGetMDNodeNumOperands(asLLVM()))
    let ptr = UnsafeMutablePointer<LLVMValueRef?>.allocate(capacity: count)
    LLVMGetMDNodeOperands(asLLVM(), ptr)

    var operands = [IRValue]()
    for i in 0..<count {
      operands.append(ptr[i]!)
    }
    return operands
  }
}

/// A `MetadataNode` is a bit of arbitrary metadata attached to an instruction
/// or value. It can be initialized with `IRValues` and attached to any kind of
/// value.
public struct MetadataNode: IRMetadata {
  let llvm: LLVMValueRef

  /// Creates a `MetadataNode` from an underlying LLVM value
  ///
  /// - parameter llvm: The LLVM value for this `MDNode`
  internal init(llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  /// Creates the appropriate MDNode or MDString from the provided
  /// `LLVMValueRef`.
  /// - parameter llvm: The LLVMValueRef representing the desired metadata.
  /// - returns: Either a `MetadataString` or `MetadataNode` depending on the
  ///            underlying value.
  internal static func fromLLVM(_ llvm: LLVMValueRef) -> IRMetadata {
    if llvm.isAnMDString { return MetadataString(llvm: llvm) }
    return MetadataNode(llvm: llvm)
  }

  /// Creates a `MetadataNode` with the provided values, in the provided
  /// context. If no context is provided, it will be created in the global
  /// context.
  ///
  /// - parameters:
  ///   - values: The values to add to the metadata
  ///   - context: The context in which to create the metadata. Defaults to
  ///              `nil`, which means the global context.
  public init(values: [IRValue], in context: Context? = nil) {
    var vals = values.map { $0.asLLVM() as Optional }
    self.llvm = vals.withUnsafeMutableBufferPointer { buf in
      if let context = context {
        return LLVMMDNodeInContext(context.llvm, buf.baseAddress,
                                   UInt32(buf.count))
      } else {
        return LLVMMDNode(buf.baseAddress, UInt32(buf.count))
      }
    }
  }

  /// Returns the underlying `LLVMValueRef` backing this node.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}

/// A `MetadataString` is an arbitrary string  of metadata attached to an
/// instruction or value.
public struct MetadataString: IRMetadata, ExpressibleByStringLiteral {
  let llvm: LLVMValueRef

  /// Creates a `MetadataString` from an underlying LLVM value
  ///
  /// - parameter llvm: The LLVM value for this `MDString`
  internal init(llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  /// Creates a `MetadataString` with the provided string as a value, in the
  /// provided context. If no context is provided, it will be created in the
  /// global context.
  ///
  /// - parameters:
  ///   - string: The string with which to create this node.
  ///   - context: The context in which to create this node.
  public init(_ string: String, in context: Context? = nil) {
    if let context = context {
      self.llvm = LLVMMDStringInContext(context.llvm, string,
                                        UInt32(string.utf8.count))
    } else {
      self.llvm = LLVMMDString(string, UInt32(string.utf8.count))
    }
  }

  /// Creates a `MetadataString` from a `String` literal.
  ///
  /// - parameter value: The string with which to create this node.
  public init(stringLiteral value: String) {
    self.init(value)
  }

  /// Creates a `MetadataString` from a `UnicodeScalar` literal.
  ///
  /// - parameter value: The string with which to create this node.
  public init(unicodeScalarLiteral value: String) {
    self.init(value)
  }

  /// Creates a `MetadataString` from a `ExtendedGraphemeClusterLiteral`
  /// literal.
  ///
  /// - parameter value: The string with which to create this node.
  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(value)
  }

  /// Returns the underlying `LLVMValueRef` backing this string.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}

/// Enumerates the possible kinds of metadata that LLVM supports.
/// - note: These must match, exactly, the enum in `llvm/Metadata.h`
public enum MetadataKind: UInt32 {
  /// A simple metadata node with a `tuple` of operands.
  case tuple                           =  0

  /// A debug location in source code, used for debug info and otherwise.
  case debugInfoLocation               =  1

  /// An un-specialized DWARF-like metadata node. The first operand is a 
  /// (possibly empty) null-separated `MetadataString` header that contains
  /// arbitrary fields. The remaining operands are references to other metadata.
  case genericDebugInfoNode            =  2

  /// An array subrange.
  case debugInfoSubrange               =  3

  /// A wrapper for an enumerator (e.g. `x` and `y` in `enum { case x, y }`)
  case debugInfoEnumerator             =  4

  /// A basic type, like 'Int' or 'Double'.
  case debugInfoBasicType              =  5

  /// A derived type. This includes qualified types, pointers, references,
  /// friends, typedefs, and class members.
  case debugInfoDerivedType            =  6

  /// A composite type, like a struct or vector.
  case debugInfoCompositeType          =  7

  /// A type corresponding to a function. It has one child node, `types`,
  /// a tuple of type metadata.
  /// The first element is the return type of the function, or `null` if
  /// the function returns void. The rest are the parameter types of the
  /// function, in order.
  case debugInfoSubroutineType         =  8

  /// A file node.
  case debugInfoFile                   =  9
  case debugInfoCompileUnit            = 10
  case debugInfoSubprogram             = 11
  case debugInfoLexicalBlock           = 12
  case debugInfoLexicalBlockFile       = 13
  case debugInfoNamespace              = 14
  case debugInfoModule                 = 15
  case debugInfoTemplateTypeParameter  = 16
  case debugInfoTemplateValueParameter = 17
  case debugInfoGlobalVariable         = 18
  case debugInfoLocalVariable          = 19
  case debugInfoExpression             = 20
  case debugInfoObjCProperty           = 21
  case debugInfoImportedEntity         = 22
  case constantAsMetadata              = 23
  case localAsMetadata                 = 24
  case string                          = 25
  case debugInfoMacro                  = 26
  case debugInfoMacroFile              = 27
}
