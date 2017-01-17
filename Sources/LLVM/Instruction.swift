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
    return OpCode(rawValue: LLVMGetInstructionOpcode(llvm).rawValue)!
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
