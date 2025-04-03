#if SWIFT_PACKAGE
  import cllvm
#endif

public final class JIT {

  var jit: LLVMOrcLLJITRef? = nil
  let mainDyLib: LLVMOrcJITDylibRef

  public init() {
    LLVMInitializeNativeTarget()
    LLVMInitializeNativeAsmPrinter()

    let jitBuilder = LLVMOrcCreateLLJITBuilder()
    LLVMOrcCreateLLJIT(&self.jit, jitBuilder)
    self.mainDyLib = LLVMOrcLLJITGetMainJITDylib(jit)
  }

  public func compile(module: Module, name: String) -> LLVMOrcExecutorAddress {
    let threadContext = LLVMOrcCreateNewThreadSafeContext()
    let threadModule = LLVMOrcCreateNewThreadSafeModule(module.llvm, threadContext)
    LLVMOrcLLJITAddLLVMIRModule(jit, self.mainDyLib, threadModule)

    var res: LLVMOrcExecutorAddress = 0
    LLVMOrcLLJITLookup(jit, &res, name)

    return res
  }

  deinit {
    LLVMOrcDisposeLLJIT(jit)
    LLVMShutdown()
  }
}
