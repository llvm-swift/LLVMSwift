import cllvm

public struct Switch: IRValue {
    internal let llvm: LLVMValueRef
    
    public func addCase(_ value: IRValue, _ block: BasicBlock) {
        LLVMAddCase(llvm, value.asLLVM(), block.asLLVM())
    }
    
    public func asLLVM() -> LLVMValueRef {
        return llvm
    }
}
