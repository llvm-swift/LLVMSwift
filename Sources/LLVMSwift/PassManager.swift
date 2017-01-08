import cllvm

public enum FunctionPass {
    case aggressiveDCE
    case bitTrackingDCE
    case alignmentFromAssumptions
    case cfgSimplification
    case deadStoreElimination
    case scalarizer
    case mergedLoadStoreMotion
    case gvn
    case indVarSimplify
    case instructionCombining
    case jumpThreading
    case licm
    case loopDeletion
    case loopIdiom
    case loopRotate
    case loopReroll
    case loopUnroll
    case loopUnswitch
    case memCpyOpt
    case partiallyInlineLibCalls
    case lowerSwitch
    case promoteMemoryToRegister
    case reassociate
    case sccp
    case scalarReplAggregates
    case scalarReplAggregatesSSA
    case simplifyLibCalls
    case tailCallElimination
    case constantPropagation
    case demoteMemoryToRegister
    case verifier
    case correlatedValuePropagation
    case earlyCSE
    case lowerExpectIntrinsic
    case typeBasedAliasAnalysis
    case scopedNoAliasAA
    case basicAliasAnalysis
}

public class FunctionPassManager {
    internal let llvm: LLVMPassManagerRef
    
    private static let passMapping: [FunctionPass: (LLVMPassManagerRef) -> Void] = [
        .aggressiveDCE: LLVMAddAggressiveDCEPass,
        .bitTrackingDCE: LLVMAddBitTrackingDCEPass,
        .alignmentFromAssumptions: LLVMAddAlignmentFromAssumptionsPass,
        .cfgSimplification: LLVMAddCFGSimplificationPass,
        .deadStoreElimination: LLVMAddDeadStoreEliminationPass,
        .scalarizer: LLVMAddScalarizerPass,
        .mergedLoadStoreMotion: LLVMAddMergedLoadStoreMotionPass,
        .gvn: LLVMAddGVNPass,
        .indVarSimplify: LLVMAddIndVarSimplifyPass,
        .instructionCombining: LLVMAddInstructionCombiningPass,
        .jumpThreading: LLVMAddJumpThreadingPass,
        .licm: LLVMAddLICMPass,
        .loopDeletion: LLVMAddLoopDeletionPass,
        .loopIdiom: LLVMAddLoopIdiomPass,
        .loopRotate: LLVMAddLoopRotatePass,
        .loopReroll: LLVMAddLoopRerollPass,
        .loopUnroll: LLVMAddLoopUnrollPass,
        .loopUnswitch: LLVMAddLoopUnswitchPass,
        .memCpyOpt: LLVMAddMemCpyOptPass,
        .partiallyInlineLibCalls: LLVMAddPartiallyInlineLibCallsPass,
        .lowerSwitch: LLVMAddLowerSwitchPass,
        .promoteMemoryToRegister: LLVMAddPromoteMemoryToRegisterPass,
        .reassociate: LLVMAddReassociatePass,
        .sccp: LLVMAddSCCPPass,
        .scalarReplAggregates: LLVMAddScalarReplAggregatesPass,
        .scalarReplAggregatesSSA: LLVMAddScalarReplAggregatesPassSSA,
        .simplifyLibCalls: LLVMAddSimplifyLibCallsPass,
        .tailCallElimination: LLVMAddTailCallEliminationPass,
        .constantPropagation: LLVMAddConstantPropagationPass,
        .demoteMemoryToRegister: LLVMAddDemoteMemoryToRegisterPass,
        .verifier: LLVMAddVerifierPass,
        .correlatedValuePropagation: LLVMAddCorrelatedValuePropagationPass,
        .earlyCSE: LLVMAddEarlyCSEPass,
        .lowerExpectIntrinsic: LLVMAddLowerExpectIntrinsicPass,
        .typeBasedAliasAnalysis: LLVMAddTypeBasedAliasAnalysisPass,
        .scopedNoAliasAA: LLVMAddScopedNoAliasAAPass,
        .basicAliasAnalysis: LLVMAddBasicAliasAnalysisPass,
    ]
    
    public init(module: Module) {
        llvm = LLVMCreateFunctionPassManagerForModule(module.llvm)!
        LLVMInitializeFunctionPassManager(llvm)
    }
    
    public func add(_ passes: FunctionPass...) {
        for pass in passes {
            FunctionPassManager.passMapping[pass]!(llvm)
        }
    }
    
    public func run(on function: Function) {
        LLVMRunFunctionPassManager(llvm, function.asLLVM())
    }
}
