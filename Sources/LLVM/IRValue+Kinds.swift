import cllvm

// Automatically generated from the macros in llvm/Core.h

public extension IRValue {

  /// Whether or not the underlying LLVM value is an `Argument`
  public var isAArgument: Bool {
    return LLVMIsAArgument(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `BasicBlock`
  public var isABasicBlock: Bool {
    return LLVMIsABasicBlock(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is `InlineAsm`
  public var isAInlineAsm: Bool {
    return LLVMIsAInlineAsm(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `User`
  public var isAUser: Bool {
    return LLVMIsAUser(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `Constant`
  public var isAConstant: Bool {
    return LLVMIsAConstant(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `BlockAddress`
  public var isABlockAddress: Bool {
    return LLVMIsABlockAddress(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantAggregateZero`
  public var isAConstantAggregateZero: Bool {
    return LLVMIsAConstantAggregateZero(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantArray`
  public var isAConstantArray: Bool {
    return LLVMIsAConstantArray(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantDataSequential`
  public var isAConstantDataSequential: Bool {
    return LLVMIsAConstantDataSequential(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantDataArray`
  public var isAConstantDataArray: Bool {
    return LLVMIsAConstantDataArray(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantDataVector`
  public var isAConstantDataVector: Bool {
    return LLVMIsAConstantDataVector(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantExpr`
  public var isAConstantExpr: Bool {
    return LLVMIsAConstantExpr(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantFP`
  public var isAConstantFP: Bool {
    return LLVMIsAConstantFP(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantInt`
  public var isAConstantInt: Bool {
    return LLVMIsAConstantInt(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantPointerNull`
  public var isAConstantPointerNull: Bool {
    return LLVMIsAConstantPointerNull(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantStruct`
  public var isAConstantStruct: Bool {
    return LLVMIsAConstantStruct(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantTokenNone`
  public var isAConstantTokenNone: Bool {
    return LLVMIsAConstantTokenNone(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ConstantVector`
  public var isAConstantVector: Bool {
    return LLVMIsAConstantVector(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `GlobalValue`
  public var isAGlobalValue: Bool {
    return LLVMIsAGlobalValue(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `GlobalAlias`
  public var isAGlobalAlias: Bool {
    return LLVMIsAGlobalAlias(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `GlobalObject`
  public var isAGlobalObject: Bool {
    return LLVMIsAGlobalObject(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `Function`
  public var isAFunction: Bool {
    return LLVMIsAFunction(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `GlobalVariable`
  public var isAGlobalVariable: Bool {
    return LLVMIsAGlobalVariable(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `UndefValue`
  public var isAUndefValue: Bool {
    return LLVMIsAUndefValue(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `Instruction`
  public var isAInstruction: Bool {
    return LLVMIsAInstruction(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `BinaryOperator`
  public var isABinaryOperator: Bool {
    return LLVMIsABinaryOperator(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `CallInst`
  public var isACallInst: Bool {
    return LLVMIsACallInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `IntrinsicInst`
  public var isAIntrinsicInst: Bool {
    return LLVMIsAIntrinsicInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `DbgInfoIntrinsic`
  public var isADbgInfoIntrinsic: Bool {
    return LLVMIsADbgInfoIntrinsic(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `DbgDeclareInst`
  public var isADbgDeclareInst: Bool {
    return LLVMIsADbgDeclareInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `MemIntrinsic`
  public var isAMemIntrinsic: Bool {
    return LLVMIsAMemIntrinsic(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `MemCpyInst`
  public var isAMemCpyInst: Bool {
    return LLVMIsAMemCpyInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `MemMoveInst`
  public var isAMemMoveInst: Bool {
    return LLVMIsAMemMoveInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `MemSetInst`
  public var isAMemSetInst: Bool {
    return LLVMIsAMemSetInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `CmpInst`
  public var isACmpInst: Bool {
    return LLVMIsACmpInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `FCmpInst`
  public var isAFCmpInst: Bool {
    return LLVMIsAFCmpInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `ICmpInst`
  public var isAICmpInst: Bool {
    return LLVMIsAICmpInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `ExtractElementInst`
  public var isAExtractElementInst: Bool {
    return LLVMIsAExtractElementInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `GetElementPtrInst`
  public var isAGetElementPtrInst: Bool {
    return LLVMIsAGetElementPtrInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `InsertElementInst`
  public var isAInsertElementInst: Bool {
    return LLVMIsAInsertElementInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `InsertValueInst`
  public var isAInsertValueInst: Bool {
    return LLVMIsAInsertValueInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `LandingPadInst`
  public var isALandingPadInst: Bool {
    return LLVMIsALandingPadInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `PHINode`
  public var isAPHINode: Bool {
    return LLVMIsAPHINode(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `SelectInst`
  public var isASelectInst: Bool {
    return LLVMIsASelectInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ShuffleVectorInst`
  public var isAShuffleVectorInst: Bool {
    return LLVMIsAShuffleVectorInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `StoreInst`
  public var isAStoreInst: Bool {
    return LLVMIsAStoreInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `TerminatorInst`
  public var isATerminatorInst: Bool {
    return LLVMIsATerminatorInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `BranchInst`
  public var isABranchInst: Bool {
    return LLVMIsABranchInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `IndirectBrInst`
  public var isAIndirectBrInst: Bool {
    return LLVMIsAIndirectBrInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `InvokeInst`
  public var isAInvokeInst: Bool {
    return LLVMIsAInvokeInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ReturnInst`
  public var isAReturnInst: Bool {
    return LLVMIsAReturnInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `SwitchInst`
  public var isASwitchInst: Bool {
    return LLVMIsASwitchInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `UnreachableInst`
  public var isAUnreachableInst: Bool {
    return LLVMIsAUnreachableInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ResumeInst`
  public var isAResumeInst: Bool {
    return LLVMIsAResumeInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `CleanupReturnInst`
  public var isACleanupReturnInst: Bool {
    return LLVMIsACleanupReturnInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `CatchReturnInst`
  public var isACatchReturnInst: Bool {
    return LLVMIsACatchReturnInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `FuncletPadInst`
  public var isAFuncletPadInst: Bool {
    return LLVMIsAFuncletPadInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `CatchPadInst`
  public var isACatchPadInst: Bool {
    return LLVMIsACatchPadInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `CleanupPadInst`
  public var isACleanupPadInst: Bool {
    return LLVMIsACleanupPadInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `UnaryInstruction`
  public var isAUnaryInstruction: Bool {
    return LLVMIsAUnaryInstruction(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `AllocaInst`
  public var isAAllocaInst: Bool {
    return LLVMIsAAllocaInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `CastInst`
  public var isACastInst: Bool {
    return LLVMIsACastInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `AddrSpaceCastInst`
  public var isAAddrSpaceCastInst: Bool {
    return LLVMIsAAddrSpaceCastInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `BitCastInst`
  public var isABitCastInst: Bool {
    return LLVMIsABitCastInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `FPExtInst`
  public var isAFPExtInst: Bool {
    return LLVMIsAFPExtInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `FPToSIInst`
  public var isAFPToSIInst: Bool {
    return LLVMIsAFPToSIInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `FPToUIInst`
  public var isAFPToUIInst: Bool {
    return LLVMIsAFPToUIInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `FPTruncInst`
  public var isAFPTruncInst: Bool {
    return LLVMIsAFPTruncInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is an `IntToPtrInst`
  public var isAIntToPtrInst: Bool {
    return LLVMIsAIntToPtrInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `PtrToIntInst`
  public var isAPtrToIntInst: Bool {
    return LLVMIsAPtrToIntInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `SExtInst`
  public var isASExtInst: Bool {
    return LLVMIsASExtInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `SIToFPInst`
  public var isASIToFPInst: Bool {
    return LLVMIsASIToFPInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `TruncInst`
  public var isATruncInst: Bool {
    return LLVMIsATruncInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `UIToFPInst`
  public var isAUIToFPInst: Bool {
    return LLVMIsAUIToFPInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ZExtInst`
  public var isAZExtInst: Bool {
    return LLVMIsAZExtInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `ExtractValueInst`
  public var isAExtractValueInst: Bool {
    return LLVMIsAExtractValueInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `LoadInst`
  public var isALoadInst: Bool {
    return LLVMIsALoadInst(asLLVM()) != nil
  }

  /// Whether or not the underlying LLVM value is a `VAArgInst`
  public var isAVAArgInst: Bool {
    return LLVMIsAVAArgInst(asLLVM()) != nil
  }
}
