#if SWIFT_PACKAGE
import cllvm
import llvmshims
#endif

public struct TBAAStructField {
  public let offset: Size
  public let size: Size
  public let type: MDNode
}

public final class MDBuilder {
  let context: Context

  public init(in context: Context = .global) {
    self.context = context
  }
}

extension MDBuilder {
  public func buildFPMath(_ accuracy: Float) -> MDNode? {
    guard accuracy > 0.0 else {
      return nil
    }
    let op = MDNode(constant: FloatType.float.constant(Double(accuracy)))
    return MDNode(in: self.context, operands: [ op ])
  }
}

extension MDBuilder {
  public func buildBranchWeights(_ weights: [Int]) -> MDNode {
    precondition(weights.count >= 1, "Branch weights must have at least one value")
    var ops = [IRMetadata]()
    ops.reserveCapacity(weights.count + 1)
    ops.append(MDString("branch_weights"))
    let int32Ty = IntType.int32
    for weight in weights {
      ops.append(MDNode(constant: int32Ty.constant(weight)))
    }
    return MDNode(in: self.context, operands: ops)
  }
}

extension MDBuilder {
  public func buildUnpredictable() -> MDNode {
    return MDNode(in: self.context, operands: [])
  }
}

extension MDBuilder {
  public func buildFunctionSectionPrefix(_ prefix: String) -> MDNode {
    return MDNode(in: self.context, operands: [
      MDString("function_section_prefix"),
      MDString(prefix),
    ])
  }
}

extension MDBuilder {
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

extension MDBuilder {
  public func buildCallees(_ callees: [Function]) -> MDNode {
    var ops = [IRMetadata]()
    ops.reserveCapacity(callees.count)
    for callee in callees {
      ops.append(MDNode(constant: callee))
    }
    return MDNode(in: self.context, operands: ops)
  }
}

extension MDBuilder {
  public func buildCallbackEncoding(_ calleeArgNo: UInt, _ arguments: [Int], varArgPassed: Bool) -> MDNode {
    var ops = [IRMetadata]()
    let int64 = IntType.int64
    ops.append(MDNode(constant: int64.constant(calleeArgNo)))
    for argNo in arguments {
      ops.append(MDNode(constant: int64.constant(argNo)))
    }
    ops.append(MDNode(constant: IntType.int1.constant(varArgPassed ? 1 : 0)))
    return MDNode(in: self.context, operands: ops)
  }
}

extension MDBuilder {
  public func buildAnonymousAARoot(_ name: String, _ extra: MDNode? = nil) -> MDNode {
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
      let flags = IntType.int64.constant(1)
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
    let int64 = IntType.int64
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
    let int64 = IntType.int64
    ops.append(MDString(name))
    for (type, offset) in fields {
      ops.append(type)
      ops.append(MDNode(constant: int64.constant(offset.rawValue)))
    }
    return MDNode(in: self.context, operands: ops)
  }

  public func buildTBAAScalarTypeNode(_ name: String, _ parent: MDNode, _ offset: Size) -> MDNode {
    let off = IntType.int64.constant(offset.rawValue)
    return MDNode(in: self.context, operands: [
      MDString(name),
      parent,
      MDNode(constant: off)
    ])
  }

  public func buildTBAAStructTagNode(_ baseType: MDNode, _ accessType: MDNode, _ offset: Size, _ isConstant: Bool) -> MDNode {
    let int64 = IntType.int64
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
    let int64 = IntType.int64
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
    let int64 = IntType.int64
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

extension MDBuilder {
  public func buildIrrLoopHeaderWeight(_ weight: UInt64) -> MDNode {
    return MDNode(in: self.context, operands: [
      MDString("loop_header_weight"),
      MDNode(constant: IntType.int64.constant(weight))
    ])
  }
}

extension MDBuilder {
  public func buildFunctionEntryCount(_ count: UInt64, _ synthetic: Bool, _ imports: Set<UInt64>) -> MDNode {
    let int64 = IntType.int64
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

