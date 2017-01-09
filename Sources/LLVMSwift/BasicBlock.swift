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
public struct BasicBlock: IRValue, Sequence {
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

  /// Returns the parent of this basic block, if it exists.
  public func parent() -> BasicBlock? {
    guard let blockRef = LLVMGetBasicBlockParent(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  /// Returns the basic block following this basic block, if it exists.
  public func next() -> BasicBlock? {
    guard let blockRef = LLVMGetNextBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  /// Removes this basic block from a function and deletes it.
  public func delete() {
    LLVMDeleteBasicBlock(llvm)
  }

  /// Removes this basic block from a function but keeps it alive.
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

  /// Returns an iterator over the `Instruction`s that make up this basic block.
  public func makeIterator() -> AnyIterator<Instruction> {
    var current = firstInstruction
    return AnyIterator {
      defer { current = current?.next() }
      return current
    }
  }
}

/// An `Instruction` represents an instruction residing in a basic block.
public struct Instruction: IRValue {
  internal let llvm: LLVMValueRef

  /// Creates an `Intruction` from an `LLVMValueRef` object.
  public init(llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }

  /// Obtain the instruction that occurs before this one, if it exists.
  public func previous() -> Instruction? {
    guard let val = LLVMGetPreviousInstruction(llvm) else { return nil }
    return Instruction(llvm: val)
  }

  /// Obtain the instruction that occurs after this one, if it exists.
  public func next() -> Instruction? {
    guard let val = LLVMGetNextInstruction(llvm) else { return nil }
    return Instruction(llvm: val)
  }
}

