import cllvm

public struct Global: IRValue {
    internal let llvm: LLVMValueRef
    
    public var isExternallyInitialized: Bool {
        get { return LLVMIsExternallyInitialized(llvm) != 0 }
        set { LLVMSetExternallyInitialized(llvm, newValue.llvm) }
    }
    
    public var initializer: IRValue {
        get { return LLVMGetInitializer(asLLVM()) }
        set { LLVMSetInitializer(asLLVM(), newValue.asLLVM()) }
    }
    
    public var isGlobalConstant: Bool {
        get { return LLVMIsGlobalConstant(asLLVM()) != 0 }
        set { LLVMSetGlobalConstant(asLLVM(), newValue.llvm) }
    }
    
    public var isThreadLocal: Bool {
        get { return LLVMIsThreadLocal(asLLVM()) != 0 }
        set { LLVMSetThreadLocal(asLLVM(), newValue.llvm) }
    }
    
    public func asLLVM() -> LLVMValueRef {
        return llvm
    }
}
