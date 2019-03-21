#if SWIFT_PACKAGE
import cllvm
#endif

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

  /// Creates a new basic block without a parent function.
  ///
  /// The basic block should be inserted into a function or destroyed before
  /// the IR builder is finalized.
  public init(context: Context = .global, name: String = "") {
    self.llvm = LLVMCreateBasicBlockInContext(context.llvm, name)
  }

  /// Given that this block and a given block share a parent function, move this
  /// block before the given block in that function's basic block list.
  ///
  /// - Parameter position: The basic block that acts as a position before
  ///   which this block will be moved.
  public func move(before position: BasicBlock) {
    LLVMMoveBasicBlockBefore(self.asLLVM(), position.asLLVM())
  }

  /// Given that this block and a given block share a parent function, move this
  /// block after the given block in that function's basic block list.
  ///
  /// - Parameter position: The basic block that acts as a position after
  ///   which this block will be moved.
  public func move(after position: BasicBlock) {
    LLVMMoveBasicBlockAfter(self.asLLVM(), position.asLLVM())
  }

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }

  /// Retrieves the name of this basic block.
  public var name: String {
    let cstring = LLVMGetBasicBlockName(self.llvm)
    return String(cString: cstring!)
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

extension BasicBlock: Equatable {
  public static func == (lhs: BasicBlock, rhs: BasicBlock) -> Bool {
    return lhs.asLLVM() == rhs.asLLVM()
  }
}
