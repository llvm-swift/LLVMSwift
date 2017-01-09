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

/// Enumerates the opcodes of instructions available in the LLVM IR language.
///
/// The raw values of this enumeration *must* match those in
/// [llvm-c/Core.h](https://github.com/llvm-mirror/llvm/blob/master/include/llvm-c/Core.h).
public enum OpCode: UInt32 {
  // MARK: Terminator Instructions

  // The opcode for the `ret` instruction.
  case ret            = 1
  // The opcode for the `br` instruction.
  case br             = 2
  // The opcode for the `switch` instruction.
  case `switch`       = 3
  // The opcode for the `indirectBr` instruction.
  case indirectBr     = 4
  // The opcode for the `invoke` instruction.
  case invoke         = 5
  // The opcode for the `unreachable` instruction.
  case unreachable    = 7

  // MARK: Standard Binary Operators

  // The opcode for the `add` instruction.
  case add            = 8
  // The opcode for the `fadd` instruction.
  case fadd           = 9
  // The opcode for the `sub` instruction.
  case sub            = 10
  // The opcode for the `fsub` instruction.
  case fsub           = 11
  // The opcode for the `mul` instruction.
  case mul            = 12
  // The opcode for the `fmul` instruction.
  case fmul           = 13
  // The opcode for the `udiv` instruction.
  case udiv           = 14
  // The opcode for the `sdiv` instruction.
  case sdiv           = 15
  // The opcode for the `fdiv` instruction.
  case fdiv           = 16
  // The opcode for the `urem` instruction.
  case urem           = 17
  // The opcode for the `srem` instruction.
  case srem           = 18
  // The opcode for the `frem` instruction.
  case frem           = 19

  // MARK: Logical Operators

  // The opcode for the `shl` instruction.
  case shl            = 20
  // The opcode for the `lshr` instruction.
  case lshr           = 21
  // The opcode for the `ashr` instruction.
  case ashr           = 22
  // The opcode for the `and` instruction.
  case and            = 23
  // The opcode for the `or` instruction.
  case or             = 24
  // The opcode for the `xor` instruction.
  case xor            = 25

  // MARK: Memory Operators

  // The opcode for the `alloca` instruction.
  case alloca         = 26
  // The opcode for the `load` instruction.
  case load           = 27
  // The opcode for the `store` instruction.
  case store          = 28
  // The opcode for the `getElementPtr` instruction.
  case getElementPtr  = 29

  // MARK: Cast Operators

  // The opcode for the `trunc` instruction.
  case trunc          = 30
  // The opcode for the `zext` instruction.
  case zext           = 31
  // The opcode for the `sext` instruction.
  case sext           = 32
  // The opcode for the `fpToUI` instruction.
  case fpToUI         = 33
  // The opcode for the `fpToSI` instruction.
  case fpToSI         = 34
  // The opcode for the `uiToFP` instruction.
  case uiToFP         = 35
  // The opcode for the `siToFP` instruction.
  case siToFP         = 36
  // The opcode for the `fpTrunc` instruction.
  case fpTrunc        = 37
  // The opcode for the `fpExt` instruction.
  case fpExt          = 38
  // The opcode for the `ptrToInt` instruction.
  case ptrToInt       = 39
  // The opcode for the `intToPtr` instruction.
  case intToPtr       = 40
  // The opcode for the `bitCast` instruction.
  case bitCast        = 41
  // The opcode for the `addrSpaceCast` instruction.
  case addrSpaceCast  = 60

  // MARK: Other Operators

  // The opcode for the `icmp` instruction.
  case icmp           = 42
  // The opcode for the `fcmp` instruction.
  case fcmp           = 43
  // The opcode for the `PHI` instruction.
  case PHI            = 44
  // The opcode for the `call` instruction.
  case call           = 45
  // The opcode for the `select` instruction.
  case select         = 46
  // The opcode for the `userOp1` instruction.
  case userOp1        = 47
  // The opcode for the `userOp2` instruction.
  case userOp2        = 48
  // The opcode for the `vaArg` instruction.
  case vaArg          = 49
  // The opcode for the `extractElement` instruction.
  case extractElement = 50
  // The opcode for the `insertElement` instruction.
  case insertElement  = 51
  // The opcode for the `shuffleVector` instruction.
  case shuffleVector  = 52
  // The opcode for the `extractValue` instruction.
  case extractValue   = 53
  // The opcode for the `insertValue` instruction.
  case insertValue    = 54

  // MARK: Atomic operators

  // The opcode for the `fence` instruction.
  case fence          = 55
  // The opcode for the `atomicCmpXchg` instruction.
  case atomicCmpXchg  = 56
  // The opcode for the `atomicRMW` instruction.
  case atomicRMW      = 57

  // MARK: Exception Handling Operators

  // The opcode for the `resume` instruction.
  case resume         = 58
  // The opcode for the `landingPad` instruction.
  case landingPad     = 59
  // The opcode for the `cleanupRet` instruction.
  case cleanupRet     = 61
  // The opcode for the `catchRet` instruction.
  case catchRet       = 62
  // The opcode for the `catchPad` instruction.
  case catchPad       = 63
  // The opcode for the `cleanupPad` instruction.
  case cleanupPad     = 64
  // The opcode for the `catchSwitch` instruction.
  case catchSwitch    = 65
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
}

