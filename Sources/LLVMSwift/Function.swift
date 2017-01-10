import cllvm

public class Function: IRValue {
  internal let llvm: LLVMValueRef
  internal init(llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  public var entryBlock: BasicBlock? {
    guard let blockRef = LLVMGetEntryBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  public var firstBlock: BasicBlock? {
    guard let blockRef = LLVMGetFirstBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  public var lastBlock: BasicBlock? {
    guard let blockRef = LLVMGetLastBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }

  public var basicBlocks: [BasicBlock] {
    var blocks = [BasicBlock]()
    var current = firstBlock
    while let block = current {
      blocks.append(block)
      current = block.next()
    }
    return blocks
  }

  public func parameter(at index: Int) -> Parameter? {
    guard let value = LLVMGetParam(llvm, UInt32(index)) else { return nil }
    return Parameter(llvm: value)
  }

  public var firstParameter: Parameter? {
    guard let value = LLVMGetFirstParam(llvm) else { return nil }
    return Parameter(llvm: value)
  }

  public var lastParameter: Parameter? {
    guard let value = LLVMGetLastParam(llvm) else { return nil }
    return Parameter(llvm: value)
  }

  public var parameters: [IRValue] {
    var current = firstParameter
    var params = [Parameter]()
    while let param = current {
      params.append(param)
      current = param.next()
    }
    return params
  }

  public func appendBasicBlock(named name: String, in context: Context? = nil) -> BasicBlock {
    let block: LLVMBasicBlockRef
    if let context = context {
      block = LLVMAppendBasicBlockInContext(context.llvm, llvm, name)
    } else {
      block = LLVMAppendBasicBlock(llvm, name)
    }
    return BasicBlock(llvm: block)
  }

  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}

public struct Parameter: IRValue {
  internal let llvm: LLVMValueRef

  public func next() -> Parameter? {
    guard let param = LLVMGetNextParam(llvm) else { return nil }
    return Parameter(llvm: param)
  }

  public func previous() -> Parameter? {
    guard let param = LLVMGetPreviousParam(llvm) else { return nil }
    return Parameter(llvm: param)
  }

  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}
