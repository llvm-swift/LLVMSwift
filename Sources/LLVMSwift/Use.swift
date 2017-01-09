import cllvm

public struct Use {
    internal let llvm: LLVMUseRef
    
    public func next() -> Use? {
        guard let next = LLVMGetNextUse(llvm) else { return nil }
        return Use(llvm: next)
    }
    
    public func user() -> IRValue? {
        return LLVMGetUser(llvm)
    }
    
    public func usedValue() -> IRValue? {
        return LLVMGetUsedValue(llvm)
    }
}
