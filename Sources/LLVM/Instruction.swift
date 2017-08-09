import cllvm

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

  /// Retrieves the opcode associated with this `Instruction`.
  public var opCode: OpCode {
    return OpCode(rawValue: LLVMGetInstructionOpcode(llvm))
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

  /// Retrieves the parent basic block that contains this instruction, if it
  /// exists.
  public var parentBlock: BasicBlock? {
    guard let parent = LLVMGetInstructionParent(self.llvm) else { return nil }
    return BasicBlock(llvm: parent)
  }

  /// Retrieves the first use of this instruction.
  public var firstUse: Use? {
    guard let use = LLVMGetFirstUse(llvm) else { return nil }
    return Use(llvm: use)
  }

  /// Retrieves the sequence of instructions that use the value from this
  /// instruction.
  public var uses: AnySequence<Use> {
    var current = firstUse
    return AnySequence<Use> {
      return AnyIterator<Use> {
        defer { current = current?.next() }
        return current
      }
    }
  }
}

/// A `TerminatorInstruction` represents an instruction that terminates a 
/// basic block.
public struct TerminatorInstruction {
  internal let llvm: LLVMValueRef

  /// Creates a `TerminatorInstruction` from an `LLVMValueRef` object.
  public init(llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  /// Retrieves the number of successors of this terminator instruction.
  public var successorCount: Int {
    return Int(LLVMGetNumSuccessors(llvm))
  }

  /// Returns the successor block at the specified index, if it exists.
  public func getSuccessor(at idx: Int) -> BasicBlock? {
    guard let succ = LLVMGetSuccessor(llvm, UInt32(idx)) else { return nil }
    return BasicBlock(llvm: succ)
  }

  /// Updates the successor block at the specified index.
  public func setSuccessor(at idx: Int, to bb: BasicBlock) {
    LLVMSetSuccessor(llvm, UInt32(idx), bb.asLLVM())
  }
}
