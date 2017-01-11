import cllvm

/// A `Function` represents a named function body in LLVM IR source.  Functions
/// in LLVM IR encapsulate a list of parameters and a sequence of basic blocks 
/// and provide a way to append to that sequence to build out its body.
public class Function: IRValue {
  internal let llvm: LLVMValueRef
  internal init(llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  /// Retrieves the entry block of this function.
  ///
  /// The first basic block in a function is special in two ways: it is 
  /// immediately executed on entrance to the function, and it is not allowed to
  /// have predecessor basic blocks (i.e. there can not be any branches to the 
  /// entry block of a function). Because the block can have no predecessors, it
  /// also cannot have any PHI nodes.
  public var entryBlock: BasicBlock? {
    guard let blockRef = LLVMGetEntryBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  /// Retrieves the first basic block in this function's body.
  ///
  /// The first basic block in a function is special in two ways: it is
  /// immediately executed on entrance to the function, and it is not allowed to
  /// have predecessor basic blocks (i.e. there can not be any branches to the
  /// entry block of a function). Because the block can have no predecessors, it
  /// also cannot have any PHI nodes.
  public var firstBlock: BasicBlock? {
    guard let blockRef = LLVMGetFirstBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  /// Retrieves the last basic block in this function's body.
  public var lastBlock: BasicBlock? {
    guard let blockRef = LLVMGetLastBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  /// Retrieves the sequence of basic blocks that make up this function's body.
  public var basicBlocks: [BasicBlock] {
    var blocks = [BasicBlock]()
    var current = firstBlock
    while let block = current {
      blocks.append(block)
      current = block.next()
    }
    return blocks
  }

  /// Retrieves a parameter at the given index, if it exists.
  ///
  /// - parameter index: The index of the parameter to retrieve.
  ///
  /// - returns: The parameter at the specified index if it exists, else nil.
  public func parameter(at index: Int) -> Parameter? {
    guard let value = LLVMGetParam(llvm, UInt32(index)) else { return nil }
    return Parameter(llvm: value)
  }

  /// Retrieves a parameter at the first index, if it exists.
  public var firstParameter: Parameter? {
    guard let value = LLVMGetFirstParam(llvm) else { return nil }
    return Parameter(llvm: value)
  }

  /// Retrieves a parameter at the last index, if it exists.
  public var lastParameter: Parameter? {
    guard let value = LLVMGetLastParam(llvm) else { return nil }
    return Parameter(llvm: value)
  }

  /// Retrieves the list of all parameters for this function, in order.
  public var parameters: [IRValue] {
    var current = firstParameter
    var params = [Parameter]()
    while let param = current {
      params.append(param)
      current = param.next()
    }
    return params
  }

  /// Appends the named basic block to the body of this function.
  ///
  /// - parameter name: The name associated with this basic block.
  /// - parameter context: An optional context into which the basic block can be
  ///   inserted into.  If no context is provided, the block is inserted into
  ///   the global context.
  public func appendBasicBlock(named name: String, in context: Context? = nil) -> BasicBlock {
    let block: LLVMBasicBlockRef
    if let context = context {
      block = LLVMAppendBasicBlockInContext(context.llvm, llvm, name)
    } else {
      block = LLVMAppendBasicBlock(llvm, name)
    }
    return BasicBlock(llvm: block)
  }

  /// Deletes the function from its containing module.
  /// - note: This does not remove calls to this function from the
  ///         module. Ensure you have removed all insructions that reference
  ///         this function before deleting it.
  public func delete() {
    LLVMDeleteFunction(llvm)
  }

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}

/// A `Parameter` represents an index into the parameters of a `Function`.
public struct Parameter: IRValue {
  internal let llvm: LLVMValueRef

  /// Retrieves the next parameter, if it exists.
  public func next() -> Parameter? {
    guard let param = LLVMGetNextParam(llvm) else { return nil }
    return Parameter(llvm: param)
  }

  /// Retrieves the previous parameter, if it exists.
  public func previous() -> Parameter? {
    guard let param = LLVMGetPreviousParam(llvm) else { return nil }
    return Parameter(llvm: param)
  }

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}
