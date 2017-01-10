import cllvm

/// Lazy static initializer that calls LLVM initialization functions only once.
let llvmInitializer: Void = {
    initializeLLVM()
}()

/// Calls all the LLVM functions to initialize:
///
/// - Targets
/// - Target Infos
/// - ASM Printers
/// - ASM Parsers
/// - Target MCs
/// - Disassemblers
private func initializeLLVM() {
    LLVMInitializeAllTargets()
    LLVMInitializeAllTargetInfos()

    LLVMInitializeAllAsmPrinters()
    LLVMInitializeAllAsmParsers()

    LLVMInitializeAllTargetMCs()
    
    LLVMInitializeAllDisassemblers()
}
