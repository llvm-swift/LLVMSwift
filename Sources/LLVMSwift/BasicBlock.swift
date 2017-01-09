import cllvm

public struct BasicBlock: IRValue, Sequence {
    internal let llvm: LLVMBasicBlockRef
    public init(llvm: LLVMBasicBlockRef) {
        self.llvm = llvm
    }
    
    public var firstInstruction: Instruction? {
        guard let val = LLVMGetFirstInstruction(llvm) else { return nil }
        return Instruction(llvm: val)
    }
    
    public var lastInstruction: Instruction? {
        guard let val = LLVMGetLastInstruction(llvm) else { return nil }
        return Instruction(llvm: val)
    }
    
    public func parent() -> BasicBlock? {
        guard let blockRef = LLVMGetBasicBlockParent(llvm) else { return nil }
        return BasicBlock(llvm: blockRef)
    }
    
    public func asLLVM() -> LLVMValueRef {
        return llvm
    }
    
    public func next() -> BasicBlock? {
        guard let blockRef = LLVMGetNextBasicBlock(llvm) else { return nil }
        return BasicBlock(llvm: blockRef)
    }
    
    public func delete() {
        LLVMDeleteBasicBlock(llvm)
    }
    
    public func removeFromParent() {
        LLVMRemoveBasicBlockFromParent(llvm)
    }
    
    public func moveBefore(_ block: BasicBlock) {
        LLVMMoveBasicBlockBefore(llvm, block.llvm)
    }
    
    public func moveAfter(_ block: BasicBlock) {
        LLVMMoveBasicBlockAfter(llvm, block.llvm)
    }
    
    public func makeIterator() -> AnyIterator<Instruction> {
        var current = firstInstruction
        return AnyIterator {
            defer { current = current?.next() }
            return current
        }
    }
}

public struct Instruction: IRValue {
    internal let llvm: LLVMValueRef
    
    public init(llvm: LLVMValueRef) {
        self.llvm = llvm
    }
    
    public func asLLVM() -> LLVMValueRef {
        return llvm
    }
    
    public func previous() -> Instruction? {
        guard let val = LLVMGetPreviousInstruction(llvm) else { return nil }
        return Instruction(llvm: val)
    }
    
    public func next() -> Instruction? {
        guard let val = LLVMGetNextInstruction(llvm) else { return nil }
        return Instruction(llvm: val)
    }
}

