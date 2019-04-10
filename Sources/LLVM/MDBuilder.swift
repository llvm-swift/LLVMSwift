#if SWIFT_PACKAGE
import cllvm
import llvmshims
#endif

/// An `MDBuilder` object provides a convenient way to build common metadata
/// nodes.
public final class MDBuilder {
  /// The context used to intialize this metadata builder.
  public let context: Context

  /// Creates a metadata builder with the given context.
  ///
  /// - Parameters:
  ///   - context: The context in which to create metadata.
  public init(in context: Context = .global) {
    self.context = context
  }
}

// MARK: Floating Point Accuracy Metadata

extension MDBuilder {
  /// Builds metadata describing the accuracy of a floating-point computation
  /// using the given accuracy value.
  ///
  /// - Parameters:
  ///   - accuracy: The accuracy value.
  /// - Returns: A metadata node describing the accuracy of a floating-point
  ///   computation.
  public func buildFloatingPointMathTag(_ accuracy: Float) -> MDNode? {
    guard accuracy > 0.0 else {
      return nil
    }
    let op = MDNode(constant: FloatType(kind: .float, in: self.context).constant(Double(accuracy)))
    return MDNode(in: self.context, operands: [ op ])
  }
}

// MARK: Branch Prediction Metadata

extension MDBuilder {
  /// Builds branch weight metadata for a set of branch targets of a `branch`,
  /// `select,` `switch`, or `call` instruction.
  ///
  /// - Parameters:
  ///   - weights: The weights of the branches.
  /// - Returns: A metadata node containing the given branch-weight information.
  public func buildBranchWeights(_ weights: [Int]) -> MDNode {
    precondition(weights.count >= 1, "Branch weights must have at least one value")
    var ops = [IRMetadata]()
    ops.reserveCapacity(weights.count + 1)
    ops.append(MDString("branch_weights"))
    let int32Ty = IntType(width: 32, in: self.context)
    for weight in weights {
      ops.append(MDNode(constant: int32Ty.constant(weight)))
    }
    return MDNode(in: self.context, operands: ops)
  }

  /// Builds branch metadata that expresses that the flow of control is
  /// unpredictable in a given `branch` or `switch` instruction.
  ///
  /// - Returns: A metadata node representing unpredictable branch metadata.
  public func buildUnpredictable() -> MDNode {
    return MDNode(in: self.context, operands: [])
  }
}

// MARK: Section Prefix Metadata

extension MDBuilder {
  /// Builds section prefix metadata.
  ///
  /// LLVM allows an explicit section to be specified for functions. If the
  /// target supports it, it will emit functions to the section specified.
  /// Additionally, the function can be placed in a COMDAT.
  ///
  /// - Parameters:
  ///   - section: The section into which functions annotated with this
  ///     metadata should be emitted.
  /// - Returns: A metadata node representing the section prefix metadata.
  public func buildFunctionSectionPrefix(_ section: String) -> MDNode {
    return MDNode(in: self.context, operands: [
      MDString("function_section_prefix"),
      MDString(section),
    ])
  }
}

// MARK: Range Metadata

extension MDBuilder {
  /// Builds range metadata.
  ///
  /// Range metadata may be attached only to load, call and invoke of integer
  /// types. It expresses the possible ranges the loaded value or the value
  /// returned by the called function at this call site is in. If the loaded
  /// or returned value is not in the specified range, the behavior is
  /// undefined.
  ///
  /// - Parameters:
  ///   - lo: The lower bound on the range.
  ///   - hi: The upper bound on the range.
  /// - Returns: A metadata node representing the newly created range metadata.
  public func buildRange(_ lo: APInt, _ hi: APInt) -> MDNode? {
    precondition(lo.bitWidth == hi.bitWidth, "Bitwidth of range limits must match!")
    guard lo != hi else {
      return nil
    }

    return MDNode(in: self.context, operands: [
      MDNode(llvm: LLVMValueAsMetadata(lo.asLLVM())),
      MDNode(llvm: LLVMValueAsMetadata(hi.asLLVM())),
    ])
  }
}

// MARK: Callee Metadata

extension MDBuilder {
  /// Build callees metadata.
  ///
  /// Callees metadata may be attached to indirect call sites. If callees
  /// metadata is attached to a call site, and any callee is not among the
  /// set of functions provided by the metadata, the behavior is undefined.
  ///
  /// - Parameters:
  ///   - callees: An array of callee function values.
  /// - Returns: A metadata node representing the newly created callees metadata.
  public func buildCallees(_ callees: [Function]) -> MDNode {
    var ops = [IRMetadata]()
    ops.reserveCapacity(callees.count)
    for callee in callees {
      ops.append(MDNode(constant: callee))
    }
    return MDNode(in: self.context, operands: ops)
  }
}

// MARK: Callback Metadata

extension MDBuilder {
  /// Build Callback metadata.
  ///
  /// Callback metadata may be attached to a function declaration, or
  /// definition. The metadata describes how the arguments of a call to a
  /// function are in turn passed to the callback function specified by the
  /// metadata. Thus, the callback metadata provides a partial description of
  /// a call site inside the function with regards to the arguments of a call
  /// to the function. The only semantic restriction on the function itself is
  /// that it is not allowed to inspect or modify arguments referenced in the
  /// callback metadata as pass-through to the callback function.
  ///
  /// - Parameters:
  ///   - callbackIndex: The argument index of the callback.
  ///   - argumentIndices: An array of argument indices in the caller that
  ///     are passed to the callback function.
  ///   - passVariadicArguments: If true, denotes that all variadic arguments
  ///     of the function are passed to the callback.
  /// - Returns: A metadata node representing the newly created callees metadata.
  public func buildCallbackEncoding(
    _ callbackIndex: UInt, _ argumentIndices: [Int],
    passVariadicArguments: Bool = false
  ) -> MDNode {
    var ops = [IRMetadata]()
    let int64 = IntType(width: 64, in: self.context)
    ops.append(MDNode(constant: int64.constant(callbackIndex)))
    for argNo in argumentIndices {
      ops.append(MDNode(constant: int64.constant(argNo)))
    }
    ops.append(MDNode(constant: IntType(width: 1, in: self.context).constant(passVariadicArguments ? 1 : 0)))
    return MDNode(in: self.context, operands: ops)
  }
}

// MARK: Function Entry Count Metadata

extension MDBuilder {
  /// Build function entry count metadata.
  ///
  /// Function entry count metadata can be attached to function definitions to
  /// record the number of times the function is called. Used with
  /// block frequency information, it is also used to derive the basic block
  /// profile count.
  ///
  /// - Parameters:
  ///   - count: The number of times a function is called.
  ///   - imports: The GUID of global values that should be imported along with
  ///     this function when running PGO.
  ///   - synthetic: Whether the entry count is synthetic.  User-created
  ///     metadata should not be synthetic outside of PGO passes.
  /// - Returns: A metadata node representing the newly created entry count metadata.
  public func buildFunctionEntryCount(
    _ count: UInt, imports: Set<UInt64> = [], synthetic: Bool = false
  ) -> MDNode {
    let int64 = IntType(width: 64, in: self.context)
    var ops = [IRMetadata]()
    if synthetic {
      ops.append(MDString("synthetic_function_entry_count"))
    } else {
      ops.append(MDString("function_entry_count"))
    }
    ops.append(MDNode(constant: int64.constant(count)))
    for id in imports.sorted() {
      ops.append(MDNode(constant: int64.constant(id)))
    }
    return MDNode(in: self.context, operands: ops)
  }
}

// MARK: TBAA Metadata

/// Represents a single field in a (C or C++) struct.
public struct TBAAStructField {
  /// The offset of this struct field in bytes.
  public let offset: Size
  /// This size of this struct field in bytes.
  public let size: Size
  /// The type metadata node for this struct field.
  public let type: MDNode
}

extension MDBuilder {
  public func buildAARoot(_ name: String, _ extra: MDNode? = nil) -> MDNode {
    // To ensure uniqueness the root node is self-referential.
    let dummy = TemporaryMDNode(in: self.context, operands: [])
    var ops = [IRMetadata]()
    if let extra = extra {
      ops.append(extra)
    }
    if !name.isEmpty {
      ops.append(MDString(name))
    }
    let root = MDNode(in: self.context, operands: ops)
    // At this point we have
    //   !0 = metadata !{}            <- dummy
    //   !1 = metadata !{metadata !0} <- root
    // Replace the dummy operand with the root node itself and delete the dummy.
    dummy.replaceAllUses(with: root)
    // We now have
    //   !1 = metadata !{metadata !1} <- self-referential root
    return root
  }

  public func buildTBAARoot(_ name: String) -> MDNode {
    return MDNode(in: self.context, operands: [ MDString(name) ])
  }

  public func buildTBAANode(_ name: String, parent: MDNode, isConstant: Bool) -> MDNode {
    if isConstant {
      let flags = IntType(width: 64, in: self.context).constant(1)
      return MDNode(in: self.context, operands: [
        MDString(name),
        parent,
        MDNode(constant: flags)
      ])
    }
    return MDNode(in: self.context, operands: [
      MDString(name),
      parent
    ])
  }

  public func buildAliasScopeDomain(_ name: String, _ domain: MDNode? = nil) -> MDNode {
    if let domain = domain {
      return MDNode(in: self.context, operands: [ MDString(name), domain ])
    }
    return MDNode(in: self.context, operands: [ MDString(name) ])
  }

  public func buildTBAAStructNode(_ fields: [TBAAStructField]) -> MDNode {
    var ops = [IRMetadata]()
    ops.reserveCapacity(fields.count * 3)
    let int64 = IntType(width: 64, in: self.context)
    for field in fields {
      ops.append(MDNode(constant: int64.constant(field.offset.rawValue)))
      ops.append(MDNode(constant: int64.constant(field.size.rawValue)))
      ops.append(field.type)
    }
    return MDNode(in: self.context, operands: ops)
  }

  public func buildTBAAStructTypeName(_ name: String, fields: [(MDNode, Size)]) -> MDNode {
    var ops = [IRMetadata]()
    ops.reserveCapacity(fields.count * 2 + 1)
    let int64 = IntType(width: 64, in: self.context)
    ops.append(MDString(name))
    for (type, offset) in fields {
      ops.append(type)
      ops.append(MDNode(constant: int64.constant(offset.rawValue)))
    }
    return MDNode(in: self.context, operands: ops)
  }

  public func buildTBAAScalarTypeNode(_ name: String, _ parent: MDNode, _ offset: Size) -> MDNode {
    let off = IntType(width: 64, in: self.context).constant(offset.rawValue)
    return MDNode(in: self.context, operands: [
      MDString(name),
      parent,
      MDNode(constant: off)
    ])
  }

  public func buildTBAAStructTagNode(_ baseType: MDNode, _ accessType: MDNode, _ offset: Size, _ isConstant: Bool) -> MDNode {
    let int64 = IntType(width: 64, in: self.context)
    let off = int64.constant(offset.rawValue)
    if isConstant {
      return MDNode(in: self.context, operands: [
        baseType,
        accessType,
        MDNode(constant: off),
        MDNode(constant: int64.constant(1))
      ])
    }
    return MDNode(in: self.context, operands: [
      baseType,
      accessType,
      MDNode(constant: off),
    ])
  }

  public func buildTBAATypeNode(_ parent: MDNode, _ size: Size, _ id: IRMetadata, _ fields: [TBAAStructField]) -> MDNode {
    var ops = [IRMetadata]()
    ops.reserveCapacity(3 + fields.count * 3)
    let int64 = IntType(width: 64, in: self.context)
    ops.append(parent)
    ops.append(MDNode(constant: int64.constant(size.rawValue)))
    ops.append(id)
    for field in fields {
      ops.append(field.type)
      ops.append(MDNode(constant: int64.constant(field.offset.rawValue)))
      ops.append(MDNode(constant: int64.constant(field.size.rawValue)))
    }
    return MDNode(in: self.context, operands: ops)
  }

  public func buildTBAAAccessTag(_ baseType: MDNode, _ accessType: MDNode, _ offset: Size, _ size: Size, _ isImmutable: Bool) -> MDNode {
    let int64 = IntType(width: 64, in: self.context)
    let off = MDNode(constant: int64.constant(offset.rawValue))
    let siz = MDNode(constant: int64.constant(size.rawValue))
    if isImmutable {
      return MDNode(in: self.context, operands: [
        baseType,
        accessType,
        off,
        siz,
        MDNode(constant: int64.constant(1)),
      ])
    }
    return MDNode(in: self.context, operands: [
      baseType,
      accessType,
      off,
      siz,
    ])
  }
}

// MARK: Irreducible Loop Metadata

extension MDBuilder {
  /// Builds irreducible loop metadata.
  ///
  /// - Parameters:
  ///   - weight: The weight of a loop header.
  /// - Returns: A metadata node representing the newly created
  ///   irreducible loop metadata.
  public func buildIrreducibleLoopHeaderWeight(_ weight: UInt) -> MDNode {
    return MDNode(in: self.context, operands: [
      MDString("loop_header_weight"),
      MDNode(constant: IntType(width: 64, in: self.context).constant(weight))
    ])
  }
}
