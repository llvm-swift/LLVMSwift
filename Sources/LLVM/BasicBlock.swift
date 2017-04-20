import cllvm

/// A `BasicBlock` represents a basic block in an LLVM IR program.  A basic
/// block contains a sequence of instructions, a pointer to its parent block and
/// its follower block, and an optional label that gives the basic block an
/// entry in the symbol table.
///
/// A basic block can be thought of as a sequence of instructions, and indeed
/// its member instructions may be iterated over with a `for-in` loop.
///
/// The first basic block in a function is special in two ways: it is
/// immediately executed on entrance to the function, and it is not allowed to
/// have predecessor basic blocks (i.e. there can not be any branches to the
/// entry block of a function). Because the block can have no predecessors, it
/// also cannot have any PHI nodes.
public struct BasicBlock: IRValue {
  internal let llvm: LLVMBasicBlockRef

  /// Creates a `BasicBlock` from an `LLVMBasicBlockRef` object.
  public init(llvm: LLVMBasicBlockRef) {
    self.llvm = llvm
  }

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }

  /// Returns the first instruction in the basic block, if it exists.
  public var firstInstruction: Instruction? {
    guard let val = LLVMGetFirstInstruction(llvm) else { return nil }
    return Instruction(llvm: val)
  }

  /// Returns the first instruction in the basic block, if it exists.
  public var lastInstruction: Instruction? {
    guard let val = LLVMGetLastInstruction(llvm) else { return nil }
    return Instruction(llvm: val)
  }

  /// Returns the terminator instruction if this basic block is well formed or 
  /// `nil` if it is not well formed.
  public var terminator: TerminatorInstruction? {
    guard let term = LLVMGetBasicBlockTerminator(llvm) else { return nil }
    return TerminatorInstruction(llvm: term)
  }

  /// Returns the parent function of this basic block, if it exists.
  public var parent: Function? {
    guard let functionRef = LLVMGetBasicBlockParent(llvm) else { return nil }
    return Function(llvm: functionRef)
  }

  /// Returns the basic block following this basic block, if it exists.
  public func next() -> BasicBlock? {
    guard let blockRef = LLVMGetNextBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  /// Returns the basic block before this basic block, if it exists.
  public func previous() -> BasicBlock? {
    guard let blockRef = LLVMGetPreviousBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  /// Returns a sequence of the Instructions that make up this basic block.
  public var instructions: AnySequence<Instruction> {
    var current = firstInstruction
    return AnySequence<Instruction> {
      return AnyIterator<Instruction> {
        defer { current = current?.next() }
        return current
      }
    }
  }

  /// Removes this basic block from a function but keeps it alive.
  ///
  /// - note: To ensure correct removal of the block, you must invalidate any 
  ///         references to it and its child instructions.  The block must also
  ///         have no successor blocks that make reference to it.
  public func removeFromParent() {
    LLVMRemoveBasicBlockFromParent(llvm)
  }

  /// Moves this basic block before the given basic block.
  public func moveBefore(_ block: BasicBlock) {
    LLVMMoveBasicBlockBefore(llvm, block.llvm)
  }

  /// Moves this basic block after the given basic block.
  public func moveAfter(_ block: BasicBlock) {
    LLVMMoveBasicBlockAfter(llvm, block.llvm)
  }
}

extension BasicBlock {
  /// Deletes the basic block from its containing function.
  /// - note: This does not remove breaks to this block from the
  ///         function. Ensure you have removed all instructions that reference
  ///         this basic block before deleting it.
  @available(*, deprecated, message: "it is hard to use correctly and will be removed.  See BasicBlock.removeFromParent() instead")
  public func delete() {
    LLVMDeleteBasicBlock(llvm)
  }

}

extension BasicBlock {
  /// An `Address` represents a function-relative address of a basic block for
  /// use with the `indirectbr` instruction.
  public struct Address: IRValue {
    internal let llvm: LLVMValueRef

    internal init(llvm: LLVMValueRef) {
      self.llvm = llvm
    }

    /// Retrieves the underlying LLVM value object.
    public func asLLVM() -> LLVMValueRef {
      return llvm
    }
  }
}
