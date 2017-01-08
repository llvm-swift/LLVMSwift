import cllvm

public struct Switch: LLVMValue {
    internal let llvm: LLVMValueRef
    
    public func addCase(_ value: LLVMValue, _ block: BasicBlock) {
        LLVMAddCase(llvm, value.asLLVM(), block.asLLVM())
    }
    
    public func asLLVM() -> LLVMValueRef {
        return llvm
    }
}
