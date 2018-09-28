#if SWIFT_PACKAGE
import cllvm
#endif

/// A `Function` represents a named function body in LLVM IR source.  Functions
/// in LLVM IR encapsulate a list of parameters and a sequence of basic blocks
/// and provide a way to append to that sequence to build out its body.
public class Function: IRGlobal {
  internal let llvm: LLVMValueRef
  internal init(llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  /// Accesses the calling convention for this function.
  public var callingConvention: CallingConvention {
    get { return CallingConvention(llvm: LLVMCallConv(rawValue: LLVMGetFunctionCallConv(llvm))) }
    set { LLVMSetFunctionCallConv(llvm, newValue.llvm.rawValue) }
  }

  /// Retrieves the entry block of this function.
  ///
  /// The first basic block in a function is special in two ways: it is
  /// immediately executed on entrance to the function, and it is not allowed to
  /// have predecessor basic blocks (i.e. there can not be any branches to the
  /// entry block of a function). Because the block can have no predecessors, it
  /// also cannot have any PHI nodes.
  ///
  /// The entry block is also special in that any static allocas emitted into it
  /// influence the layout of the stack frame of the function at code generation
  /// time.  It is therefore often more efficient to emit static allocas in the
  /// entry block than anywhere else in the function.
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
  public var basicBlocks: AnySequence<BasicBlock> {
    var current = firstBlock
    return AnySequence<BasicBlock> {
      return AnyIterator<BasicBlock> {
        defer { current = current?.next() }
        return current
      }
    }
  }

  /// Computes the address of the specified basic block in this function.
  ///
  /// Taking the address of the entry block is illegal.
  ///
  /// This value only has defined behavior when used as an operand to the 
  /// `indirectbr` instruction, or for comparisons against null. Pointer 
  /// equality tests between labels addresses results in undefined behavior.
  /// Though, again, comparison against null is ok, and no label is equal to
  /// the null pointer. This may be passed around as an opaque pointer sized 
  /// value as long as the bits are not inspected. This allows `ptrtoint` and 
  /// arithmetic to be performed on these values so long as the original value 
  /// is reconstituted before the indirectbr instruction.
  ///
  /// Finally, some targets may provide defined semantics when using the value 
  /// as the operand to an inline assembly, but that is target specific.
  ///
  /// - parameter block: The basic block to compute the address of.
  ///
  /// - returns: An IRValue representing the address of the given basic block
  ///   in this function, else nil if the address cannot be computed or the 
  ///   basic block does not reside in this function. 
  public func address(of block: BasicBlock) -> BasicBlock.Address? {
    guard let addr = LLVMBlockAddress(llvm, block.llvm) else {
      return nil
    }
    return BasicBlock.Address(llvm: addr)
  }

  /// Retrieves the previous function in the module, if there is one.
  public func previous() -> Function? {
    guard let previous = LLVMGetPreviousFunction(llvm) else { return nil }
    return Function(llvm: previous)
  }

  /// Retrieves the next function in the module, if there is one.
  public func next() -> Function? {
    guard let next = LLVMGetNextFunction(llvm) else { return nil }
    return Function(llvm: next)
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
  ///         module. Ensure you have removed all instructions that reference
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
