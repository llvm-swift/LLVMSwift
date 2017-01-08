import cllvm

// Automatically generated from the macros in llvm/Core.h

public extension LLVMValue {
  public var isAArgument: Bool {
    return LLVMIsAArgument(asLLVM()) != nil
  }
  public var isABasicBlock: Bool {
    return LLVMIsABasicBlock(asLLVM()) != nil
  }
  public var isAInlineAsm: Bool {
    return LLVMIsAInlineAsm(asLLVM()) != nil
  }
  public var isAUser: Bool {
    return LLVMIsAUser(asLLVM()) != nil
  }
  public var isAConstant: Bool {
    return LLVMIsAConstant(asLLVM()) != nil
  }
  public var isABlockAddress: Bool {
    return LLVMIsABlockAddress(asLLVM()) != nil
  }
  public var isAConstantAggregateZero: Bool {
    return LLVMIsAConstantAggregateZero(asLLVM()) != nil
  }
  public var isAConstantArray: Bool {
    return LLVMIsAConstantArray(asLLVM()) != nil
  }
  public var isAConstantDataSequential: Bool {
    return LLVMIsAConstantDataSequential(asLLVM()) != nil
  }
  public var isAConstantDataArray: Bool {
    return LLVMIsAConstantDataArray(asLLVM()) != nil
  }
  public var isAConstantDataVector: Bool {
    return LLVMIsAConstantDataVector(asLLVM()) != nil
  }
  public var isAConstantExpr: Bool {
    return LLVMIsAConstantExpr(asLLVM()) != nil
  }
  public var isAConstantFP: Bool {
    return LLVMIsAConstantFP(asLLVM()) != nil
  }
  public var isAConstantInt: Bool {
    return LLVMIsAConstantInt(asLLVM()) != nil
  }
  public var isAConstantPointerNull: Bool {
    return LLVMIsAConstantPointerNull(asLLVM()) != nil
  }
  public var isAConstantStruct: Bool {
    return LLVMIsAConstantStruct(asLLVM()) != nil
  }
  public var isAConstantTokenNone: Bool {
    return LLVMIsAConstantTokenNone(asLLVM()) != nil
  }
  public var isAConstantVector: Bool {
    return LLVMIsAConstantVector(asLLVM()) != nil
  }
  public var isAGlobalValue: Bool {
    return LLVMIsAGlobalValue(asLLVM()) != nil
  }
  public var isAGlobalAlias: Bool {
    return LLVMIsAGlobalAlias(asLLVM()) != nil
  }
  public var isAGlobalObject: Bool {
    return LLVMIsAGlobalObject(asLLVM()) != nil
  }
  public var isAFunction: Bool {
    return LLVMIsAFunction(asLLVM()) != nil
  }
  public var isAGlobalVariable: Bool {
    return LLVMIsAGlobalVariable(asLLVM()) != nil
  }
  public var isAUndefValue: Bool {
    return LLVMIsAUndefValue(asLLVM()) != nil
  }
  public var isAInstruction: Bool {
    return LLVMIsAInstruction(asLLVM()) != nil
  }
  public var isABinaryOperator: Bool {
    return LLVMIsABinaryOperator(asLLVM()) != nil
  }
  public var isACallInst: Bool {
    return LLVMIsACallInst(asLLVM()) != nil
  }
  public var isAIntrinsicInst: Bool {
    return LLVMIsAIntrinsicInst(asLLVM()) != nil
  }
  public var isADbgInfoIntrinsic: Bool {
    return LLVMIsADbgInfoIntrinsic(asLLVM()) != nil
  }
  public var isADbgDeclareInst: Bool {
    return LLVMIsADbgDeclareInst(asLLVM()) != nil
  }
  public var isAMemIntrinsic: Bool {
    return LLVMIsAMemIntrinsic(asLLVM()) != nil
  }
  public var isAMemCpyInst: Bool {
    return LLVMIsAMemCpyInst(asLLVM()) != nil
  }
  public var isAMemMoveInst: Bool {
    return LLVMIsAMemMoveInst(asLLVM()) != nil
  }
  public var isAMemSetInst: Bool {
    return LLVMIsAMemSetInst(asLLVM()) != nil
  }
  public var isACmpInst: Bool {
    return LLVMIsACmpInst(asLLVM()) != nil
  }
  public var isAFCmpInst: Bool {
    return LLVMIsAFCmpInst(asLLVM()) != nil
  }
  public var isAICmpInst: Bool {
    return LLVMIsAICmpInst(asLLVM()) != nil
  }
  public var isAExtractElementInst: Bool {
    return LLVMIsAExtractElementInst(asLLVM()) != nil
  }
  public var isAGetElementPtrInst: Bool {
    return LLVMIsAGetElementPtrInst(asLLVM()) != nil
  }
  public var isAInsertElementInst: Bool {
    return LLVMIsAInsertElementInst(asLLVM()) != nil
  }
  public var isAInsertValueInst: Bool {
    return LLVMIsAInsertValueInst(asLLVM()) != nil
  }
  public var isALandingPadInst: Bool {
    return LLVMIsALandingPadInst(asLLVM()) != nil
  }
  public var isAPHINode: Bool {
    return LLVMIsAPHINode(asLLVM()) != nil
  }
  public var isASelectInst: Bool {
    return LLVMIsASelectInst(asLLVM()) != nil
  }
  public var isAShuffleVectorInst: Bool {
    return LLVMIsAShuffleVectorInst(asLLVM()) != nil
  }
  public var isAStoreInst: Bool {
    return LLVMIsAStoreInst(asLLVM()) != nil
  }
  public var isATerminatorInst: Bool {
    return LLVMIsATerminatorInst(asLLVM()) != nil
  }
  public var isABranchInst: Bool {
    return LLVMIsABranchInst(asLLVM()) != nil
  }
  public var isAIndirectBrInst: Bool {
    return LLVMIsAIndirectBrInst(asLLVM()) != nil
  }
  public var isAInvokeInst: Bool {
    return LLVMIsAInvokeInst(asLLVM()) != nil
  }
  public var isAReturnInst: Bool {
    return LLVMIsAReturnInst(asLLVM()) != nil
  }
  public var isASwitchInst: Bool {
    return LLVMIsASwitchInst(asLLVM()) != nil
  }
  public var isAUnreachableInst: Bool {
    return LLVMIsAUnreachableInst(asLLVM()) != nil
  }
  public var isAResumeInst: Bool {
    return LLVMIsAResumeInst(asLLVM()) != nil
  }
  public var isACleanupReturnInst: Bool {
    return LLVMIsACleanupReturnInst(asLLVM()) != nil
  }
  public var isACatchReturnInst: Bool {
    return LLVMIsACatchReturnInst(asLLVM()) != nil
  }
  public var isAFuncletPadInst: Bool {
    return LLVMIsAFuncletPadInst(asLLVM()) != nil
  }
  public var isACatchPadInst: Bool {
    return LLVMIsACatchPadInst(asLLVM()) != nil
  }
  public var isACleanupPadInst: Bool {
    return LLVMIsACleanupPadInst(asLLVM()) != nil
  }
  public var isAUnaryInstruction: Bool {
    return LLVMIsAUnaryInstruction(asLLVM()) != nil
  }
  public var isAAllocaInst: Bool {
    return LLVMIsAAllocaInst(asLLVM()) != nil
  }
  public var isACastInst: Bool {
    return LLVMIsACastInst(asLLVM()) != nil
  }
  public var isAAddrSpaceCastInst: Bool {
    return LLVMIsAAddrSpaceCastInst(asLLVM()) != nil
  }
  public var isABitCastInst: Bool {
    return LLVMIsABitCastInst(asLLVM()) != nil
  }
  public var isAFPExtInst: Bool {
    return LLVMIsAFPExtInst(asLLVM()) != nil
  }
  public var isAFPToSIInst: Bool {
    return LLVMIsAFPToSIInst(asLLVM()) != nil
  }
  public var isAFPToUIInst: Bool {
    return LLVMIsAFPToUIInst(asLLVM()) != nil
  }
  public var isAFPTruncInst: Bool {
    return LLVMIsAFPTruncInst(asLLVM()) != nil
  }
  public var isAIntToPtrInst: Bool {
    return LLVMIsAIntToPtrInst(asLLVM()) != nil
  }
  public var isAPtrToIntInst: Bool {
    return LLVMIsAPtrToIntInst(asLLVM()) != nil
  }
  public var isASExtInst: Bool {
    return LLVMIsASExtInst(asLLVM()) != nil
  }
  public var isASIToFPInst: Bool {
    return LLVMIsASIToFPInst(asLLVM()) != nil
  }
  public var isATruncInst: Bool {
    return LLVMIsATruncInst(asLLVM()) != nil
  }
  public var isAUIToFPInst: Bool {
    return LLVMIsAUIToFPInst(asLLVM()) != nil
  }
  public var isAZExtInst: Bool {
    return LLVMIsAZExtInst(asLLVM()) != nil
  }
  public var isAExtractValueInst: Bool {
    return LLVMIsAExtractValueInst(asLLVM()) != nil
  }
  public var isALoadInst: Bool {
    return LLVMIsALoadInst(asLLVM()) != nil
  }
  public var isAVAArgInst: Bool {
    return LLVMIsAVAArgInst(asLLVM()) != nil
  }
}
