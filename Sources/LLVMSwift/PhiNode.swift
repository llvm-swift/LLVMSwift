import cllvm

public struct PhiNode: IRValue {
  internal let llvm: LLVMValueRef
  
  public func addIncoming(_ valueMap: [(IRValue, BasicBlock)]) {
    var values = valueMap.map { $0.0.asLLVM() as Optional }
    var blocks = valueMap.map { $0.1.asLLVM() as Optional }
    
    values.withUnsafeMutableBufferPointer { valueBuf in
      blocks.withUnsafeMutableBufferPointer { blockBuf in
        LLVMAddIncoming(llvm,
                        valueBuf.baseAddress,
                        blockBuf.baseAddress,
                        UInt32(valueMap.count))
      }
    }
  }
  
  public var incoming: [(IRValue, BasicBlock)] {
    let count = Int(LLVMCountIncoming(llvm))
    var values = [(IRValue, BasicBlock)]()
    for i in 0..<count {
      guard let value = incomingValue(at: i),
            let block = incomingBlock(at: i) else { continue }
      values.append((value, block))
    }
    return values
  }
  
  public func incomingValue(at index: Int) -> IRValue? {
    return LLVMGetIncomingValue(llvm, UInt32(index))
  }
  
  public func incomingBlock(at index: Int) -> BasicBlock? {
    guard let blockRef = LLVMGetIncomingBlock(llvm, UInt32(index)) else { return nil }
    return BasicBlock(llvm: blockRef)
  }
  
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}
