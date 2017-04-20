import cllvm

/// Represents a simple function call.
public struct Call: IRValue {
  let llvm: LLVMValueRef

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return self.llvm
  }

  /// Retrieves the number of argument operands passed by this call.
  public var argumentCount: Int {
    return Int(LLVMGetNumArgOperands(self.llvm))
  }

  /// Accesses the calling convention for this function call.
  public var callingConvention: CallingConvention {
    get { return CallingConvention(rawValue: LLVMGetInstructionCallConv(self.llvm))! }
    set { LLVMSetInstructionCallConv(self.llvm, newValue.rawValue) }
  }

  /// Returns whether this function call is a tail call.  That is, if the callee
  /// may reuse the stack memory of the caller.
  ///
  /// This attribute requires support from the target architecture.
  public var isTailCall: Bool {
    get { return LLVMIsTailCall(self.llvm) != 0 }
    set { LLVMSetTailCall(self.llvm, newValue.llvm) }
  }

  /// Retrieves the alignment of the parameter at the given index.
  ///
  /// This property is currently set-only due to limitations of the LLVM C API.
  ///
  /// - parameter i: The index of the parameter to retrieve.
  /// - parameter alignment: The alignment to apply to the parameter.
  public func setParameterAlignment(at i : Int, to alignment: Int) {
    LLVMSetInstrParamAlignment(self.llvm, UInt32(i), UInt32(alignment))
  }
}

/// Represents a function call that may transfer control to an exception handler.
public struct Invoke: IRValue {
  let llvm: LLVMValueRef

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return self.llvm
  }

  /// Accesses the destination block the flow of control will transfer to if an
  /// exception does not occur.
  public var normalDestination: BasicBlock {
    get { return BasicBlock(llvm: LLVMGetNormalDest(self.llvm)) }
    set { LLVMSetNormalDest(self.llvm, newValue.asLLVM()) }
  }

  /// Accesses the destination block that exception unwinding will jump to.
  public var unwindDestination: BasicBlock {
    get { return BasicBlock(llvm: LLVMGetUnwindDest(self.llvm)) }
    set { LLVMSetUnwindDest(self.llvm, newValue.asLLVM()) }
  }
}
