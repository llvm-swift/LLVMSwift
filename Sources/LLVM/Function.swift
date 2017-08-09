import cllvm

/// Enumerates the calling conventions supported by LLVM.
///
/// The raw values of this enumeration *must* match those in
/// [llvm-c/Core.h](https://github.com/llvm-mirror/llvm/blob/master/include/llvm-c/Core.h)
public enum CallingConvention: UInt32 {
  /// The default LLVM calling convention, compatible with C.
  case c = 0
  /// This calling convention attempts to make calls as fast as possible
  /// (e.g. by passing things in registers).
  case fast = 8
  /// This calling convention attempts to make code in the caller as efficient 
  /// as possible under the assumption that the call is not commonly executed.  
  /// As such, these calls often preserve all registers so that the call does 
  /// not break any live ranges in the caller side.
  case cold = 9
  /// Calling convention for stack based JavaScript calls.
  case webKitJS = 12
  /// Calling convention for dynamic register based calls 
  /// (e.g. stackmap and patchpoint intrinsics).
  case anyReg = 13
  /// The calling conventions mostly used by the Win32 API.
  ///
  /// It is basically the same as the C convention with the difference in that 
  /// the callee is responsible for popping the arguments from the stack.
  case x86Stdcall = 64
  /// "Fast" analog of `x86Stdcall`.
  ///
  /// Passes first two arguments in ECX:EDX registers, others via the stack. 
  /// The callee is responsible for stack cleaning.
  case x86Fastcall = 65
}

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
    get { return CallingConvention(rawValue: LLVMGetFunctionCallConv(llvm))! }
    set { LLVMSetFunctionCallConv(llvm, newValue.rawValue) }
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
