import cllvm

/// A subset of supported LLVM IR optimizer passes.
public enum FunctionPass {
  ///  This pass uses the SSA based Aggressive DCE algorithm.  This algorithm 
  /// assumes instructions are dead until proven otherwise, which makes
  /// it more successful are removing non-obviously dead instructions.
  case aggressiveDCE
  /// This pass uses a bit-tracking DCE algorithm in order to remove 
  /// computations of dead bits.
  case bitTrackingDCE
  /// Use assume intrinsics to set load/store alignments.
  case alignmentFromAssumptions
  /// Merge basic blocks, eliminate unreachable blocks, simplify terminator 
  /// instructions, etc.
  case cfgSimplification
  /// This pass deletes stores that are post-dominated by must-aliased stores 
  /// and are not loaded used between the stores.
  case deadStoreElimination
  /// Converts vector operations into scalar operations.
  case scalarizer
  /// This pass merges loads and stores in diamonds. Loads are hoisted into the
  /// header, while stores sink into the footer.
  case mergedLoadStoreMotion
  /// This pass performs global value numbering and redundant load elimination
  /// cotemporaneously.
  case gvn
  /// Transform induction variables in a program to all use a single canonical 
  /// induction variable per loop.
  case indVarSimplify
  /// Combine instructions to form fewer, simple instructions. This pass does 
  /// not modify the CFG, and has a tendency to make instructions dead, so a 
  /// subsequent DCE pass is useful.
  ///
  /// This pass combines things like:
  /// ```asm
  /// %Y = add int 1, %X
  /// %Z = add int 1, %Y
  /// ```
  /// into:
  /// ```asm
  /// %Z = add int 2, %X
  /// ```
  case instructionCombining
  /// Thread control through mult-pred/multi-succ blocks where some preds 
  /// always go to some succ. Thresholds other than minus one override the 
  /// internal BB duplication default threshold.
  case jumpThreading
  /// This pass is a loop invariant code motion and memory promotion pass.
  case licm
  /// This pass performs DCE of non-infinite loops that it can prove are dead.
  case loopDeletion
  /// This pass recognizes and replaces idioms in loops.
  case loopIdiom
  /// This pass is a simple loop rotating pass.
  case loopRotate
  /// This pass is a simple loop rerolling pass.
  case loopReroll
  /// This pass is a simple loop unrolling pass.
  case loopUnroll
  /// This pass is a simple loop unswitching pass.
  case loopUnswitch
  /// This pass performs optimizations related to eliminating `memcpy` calls
  /// and/or combining multiple stores into memset's.
  case memCpyOpt
  /// Tries to inline the fast path of library calls such as sqrt.
  case partiallyInlineLibCalls
  /// This pass converts SwitchInst instructions into a sequence of chained
  /// binary branch instructions.
  case lowerSwitch
  ///  This pass is used to promote memory references to
  /// be register references. A simple example of the transformation performed 
  /// by this pass is going from code like this:
  ///
  /// ```asm
  /// %X = alloca i32, i32 1
  /// store i32 42, i32 *%X
  /// %Y = load i32* %X
  /// ret i32 %Y
  /// ```
  ///
  /// To code like this:
  ///
  /// ```asm
  /// ret i32 42
  /// ```
  case promoteMemoryToRegister
  /// This pass reassociates commutative expressions in an order that
  /// is designed to promote better constant propagation, GCSE, LICM, PRE, etc.
  ///
  /// For example:
  /// ```
  /// 4 + (x + 5)  ->  x + (4 + 5)
  /// ```
  case reassociate
  /// Sparse conditional constant propagation.
  case sccp
  /// Replace aggregates or pieces of aggregates with scalar SSA values.
  case scalarReplAggregates
  /// Replace aggregates or pieces of aggregates with scalar SSA values.
  case scalarReplAggregatesSSA
  /// Tries to inline the fast path of library calls such as sqrt.
  case simplifyLibCalls
  /// This pass eliminates call instructions to the current function which occur
  /// immediately before return instructions.
  case tailCallElimination
  /// A worklist driven constant propagation pass.
  case constantPropagation
  /// This pass is used to demote registers to memory references. It basically
  /// undoes the `.promoteMemoryToRegister` pass to make CFG hacking easier.
  case demoteMemoryToRegister
  /// Propagate CFG-derived value information
  case correlatedValuePropagation
  /// This pass performs a simple and fast CSE pass over the dominator tree.
  case earlyCSE
  ///  Removes `llvm.expect` intrinsics and creates "block_weights" metadata.
  case lowerExpectIntrinsic
  /// Adds metadata to LLVM IR types and performs metadata-based TBAA.
  case typeBasedAliasAnalysis
  /// Adds metadata to LLVM IR types and performs metadata-based scoped no-alias
  /// analysis.
  case scopedNoAliasAA
  /// LLVM's primary stateless and local alias analysis.
  case basicAliasAnalysis
  /// Runs the LLVM IR Verifier to sanity check the results of passes.
  case verifier
  /// A pass to inline and remove functions marked as "always_inline".
  case alwaysInliner
  /// This pass promotes "by reference" arguments to be passed by value if the 
  /// number of elements passed is less than or equal to 3.
  case argumentPromotion
  /// This function returns a new pass that merges duplicate global constants 
  /// together into a single constant that is shared. This is useful because 
  /// some passes (ie TraceValues) insert a lot of string constants into the 
  /// program, regardless of whether or not they duplicate an existing string.
  case constantMerge
  /// This pass removes arguments from functions which are not used by the body
  /// of the function.
  case deadArgElimination
  /// This pass walks SCCs of the call graph in RPO to deduce and propagate 
  /// function attributes. Currently it only handles synthesizing `norecurse`
  /// attributes.
  case functionAttrs
  /// Uses a heuristic to inline direct function calls to small functions.
  case functionInlining
  /// This transform is designed to eliminate unreachable internal globals 
  /// (functions or global variables)
  case globalDCE
  /// This function returns a new pass that optimizes non-address taken internal
  /// globals.
  case globalOptimizer
  /// This pass propagates constants from call sites into the bodies of 
  /// functions.
  case ipConstantPropagation
  /// This pass propagates constants from call sites into the bodies of 
  /// functions, and keeps track of whether basic blocks are executable in the 
  /// process.
  case ipscc
  /// Return a new pass object which transforms invoke instructions into calls, 
  /// if the callee can *not* unwind the stack.
  case pruneEH
  /// This pass removes any function declarations (prototypes) that are not used.
  case stripDeadPrototypes
  /// These functions removes symbols from functions and modules without 
  /// touching symbols for debugging information.
  case stripSymbols
}

/// A `FunctionPassManager` is an object that collects a sequence of passes
/// which run over a particular IR construct, and runs each of them in sequence
/// over each such construct.
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
    .alwaysInliner: LLVMAddAlwaysInlinerPass,
    .argumentPromotion: LLVMAddArgumentPromotionPass,
    .constantMerge: LLVMAddConstantMergePass,
    .deadArgElimination: LLVMAddDeadArgEliminationPass,
    .functionAttrs: LLVMAddFunctionAttrsPass,
    .functionInlining: LLVMAddFunctionInliningPass,
    .globalDCE: LLVMAddGlobalDCEPass,
    .globalOptimizer: LLVMAddGlobalOptimizerPass,
    .ipConstantPropagation: LLVMAddIPConstantPropagationPass,
    .ipscc: LLVMAddIPSCCPPass,
    .pruneEH: LLVMAddPruneEHPass,
    .stripDeadPrototypes: LLVMAddStripDeadPrototypesPass,
    .stripSymbols: LLVMAddStripSymbolsPass,

//    .internalize: LLVMAddInternalizePass,
//    .sroaWithThreshhold: LLVMAddScalarReplAggregatesPassWithThreshold,
  ]

  /// Creates a `FunctionPassManager` bound to the given module's IR.
  public init(module: Module) {
    llvm = LLVMCreateFunctionPassManagerForModule(module.llvm)!
    LLVMInitializeFunctionPassManager(llvm)
  }

  /// Adds the given passes to the pass manager.
  ///
  /// - parameter passes: A list of function passes to add to the pass manager's
  ///   list of passes to run.
  public func add(_ passes: FunctionPass...) {
    for pass in passes {
      FunctionPassManager.passMapping[pass]!(llvm)
    }
  }

  /// Runs all listed functions in the pass manager on the given function.
  ///
  /// - parameter function: The function to run listed passes on.
  public func run(on function: Function) {
    LLVMRunFunctionPassManager(llvm, function.asLLVM())
  }
}
