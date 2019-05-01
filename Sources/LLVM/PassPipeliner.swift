#if SWIFT_PACKAGE
import cllvm
#endif

/// Implements a pass manager, pipeliner, and executor for a set of
/// user-provided optimization passes.
///
/// A `PassPipeliner` handles the creation of a related set of optimization
/// passes called a "pipeline".  Grouping passes is done for multiple reasons,
/// chief among them is that optimizer passes are extremely sensitive to their
/// ordering relative to other passses.  In addition, pass groupings allow for
/// the clean segregation of otherwise unrelated passes.  For example, a
/// pipeline might consist of "mandatory" passes such as Jump Threading, LICM,
/// and DCE in one pipeline and "diagnostic" passes in another.
public final class PassPipeliner {
  private enum PipelinePlan {
    case builtinPasses([Pass])
    case functionPassManager(LLVMPassManagerRef)
    case modulePassManager(LLVMPassManagerRef)
  }

  /// The module for this pass pipeline.
  public let module: Module
  /// The pipeline stages registered with this pass pipeliner.
  public private(set) var stages: [String]

  private var stageMapping: [String: PipelinePlan]
  private var frozen: Bool = false

  public final class Builder {
    fileprivate var passes: [Pass] = []

    fileprivate init() {}

    /// Appends a pass to the current pipeline.
    public func add(_ type: Pass) {
      self.passes.append(type)
    }
  }

  /// Initializes a new, empty pipeliner.
  ///
  /// - Parameter module: The module the pipeliner will run over.
  public init(module: Module) {
    self.module = module
    self.stages = []
    self.stageMapping = [:]
  }

  deinit {
    for stage in stageMapping.values {
      switch stage {
      case let .functionPassManager(pm):
        LLVMDisposePassManager(pm)
      case let .modulePassManager(pm):
        LLVMDisposePassManager(pm)
      case .builtinPasses(_):
        continue
      }
    }
  }

  /// Appends a stage to the pipeliner.
  ///
  /// The staging function provides a `Builder` object into which the types
  /// of passes for a given pipeline are inserted.
  ///
  /// - Parameters:
  ///   - name: The name of the pipeline stage.
  ///   - stager: A builder function.
  public func addStage(_ name: String, _ stager: (Builder) -> Void) {
    precondition(!self.frozen, "Cannot add new stages to a frozen pipeline!")

    self.frozen = true
    defer { self.frozen = false }

    self.stages.append(name)
    let builder = Builder()
    stager(builder)
    self.stageMapping[name] = .builtinPasses(builder.passes)
  }

  /// Executes the entirety of the pass pipeline.
  ///
  /// Execution of passes is done in a loop that is divided into two phases.
  /// The first phase aggregates all local passes and stops aggregation when
  /// it encounters a module-level pass.  This group of local passes
  /// is then run one at a time on the same scope.  The second phase is entered
  /// and the module pass is run.  The first phase is then re-entered until all
  /// local passes have run on all local scopes and all intervening module
  /// passes have been run.
  ///
  /// The same pipeline may be repeatedly re-executed, but pipeline execution
  /// is not re-entrancy safe.
  ///
  /// - Parameter pipelineMask: Describes the subset of pipelines that should
  ///   be executed.  If the mask is empty, all pipelines will be executed.
  public func execute(mask pipelineMask: Set<String> = []) {
    precondition(!self.frozen, "Cannot execute a frozen pipeline!")

    self.frozen = true
    defer { self.frozen = false }

    stageLoop: for stage in self.stages {
      guard pipelineMask.isEmpty || pipelineMask.contains(stage) else {
        continue
      }

      guard let pipeline = self.stageMapping[stage] else {
        fatalError("Unregistered pass stage?")
      }

      switch pipeline {
      case let .builtinPasses(passTypes):
        guard !passTypes.isEmpty else {
          continue stageLoop
        }
        self.runPasses(passTypes)
      case let .functionPassManager(pm):
        self.runFunctionPasses([], pm)
      case let .modulePassManager(pm):
        LLVMRunPassManager(pm, self.module.llvm)
      }
    }
  }

  private func runFunctionPasses(_ passes: [Pass], _ pm: LLVMPassManagerRef) {
    LLVMInitializeFunctionPassManager(pm)

    for pass in passes {
      PassPipeliner.passMapping[pass]!(pm)
    }

    for function in self.module.functions {
      LLVMRunFunctionPassManager(pm, function.asLLVM())
    }
  }

  private func runPasses(_ passes: [Pass]) {
    let pm = LLVMCreatePassManager()!
    for pass in passes {
      PassPipeliner.passMapping[pass]!(pm)
    }
    LLVMRunPassManager(pm, self.module.llvm)
    LLVMDisposePassManager(pm)
  }
}

// MARK: Standard Pass Pipelines

extension PassPipeliner {
  public func addStandardFunctionPipeline(
    _ name: String,
    optimization: CodeGenOptLevel = .`default`,
    size: CodeGenOptLevel = .none
  ) {
    let passBuilder = self.configurePassBuilder(optimization, size)
    let functionPasses =
      LLVMCreateFunctionPassManagerForModule(self.module.llvm)!
    LLVMPassManagerBuilderPopulateFunctionPassManager(passBuilder,
                                                      functionPasses)
    LLVMPassManagerBuilderDispose(passBuilder)
    self.stages.append(name)
    self.stageMapping[name] = .functionPassManager(functionPasses)
  }

  public func addStandardModulePipeline(
    _ name: String,
    optimization: CodeGenOptLevel = .`default`,
    size: CodeGenOptLevel = .none
  ) {
    let passBuilder = self.configurePassBuilder(optimization, size)
    let modulePasses = LLVMCreatePassManager()!
    LLVMPassManagerBuilderPopulateModulePassManager(passBuilder, modulePasses)
    LLVMPassManagerBuilderDispose(passBuilder)
    self.stages.append(name)
    self.stageMapping[name] = .modulePassManager(modulePasses)
  }

  private func configurePassBuilder(
    _ opt: CodeGenOptLevel,
    _ size: CodeGenOptLevel
  ) -> LLVMPassManagerBuilderRef {
    let passBuilder = LLVMPassManagerBuilderCreate()!
    switch opt {
    case .none:
      LLVMPassManagerBuilderSetOptLevel(passBuilder, 0)
    case .less:
      LLVMPassManagerBuilderSetOptLevel(passBuilder, 1)
    case .default:
      LLVMPassManagerBuilderSetOptLevel(passBuilder, 2)
    case .aggressive:
      LLVMPassManagerBuilderSetOptLevel(passBuilder, 3)
    }

    switch size {
    case .none:
      LLVMPassManagerBuilderSetSizeLevel(passBuilder, 0)
    case .less:
      LLVMPassManagerBuilderSetSizeLevel(passBuilder, 1)
    case .default:
      LLVMPassManagerBuilderSetSizeLevel(passBuilder, 2)
    case .aggressive:
      LLVMPassManagerBuilderSetSizeLevel(passBuilder, 3)
    }

    return passBuilder
  }
}


extension PassPipeliner {
  static let passMapping: [Pass: (LLVMPassManagerRef) -> Void] = [
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
    .loopUnrollAndJam: LLVMAddLoopUnrollAndJamPass,
    .loopUnswitch: LLVMAddLoopUnswitchPass,
    .lowerAtomic: LLVMAddLowerAtomicPass,
    .memCpyOpt: LLVMAddMemCpyOptPass,
    .partiallyInlineLibCalls: LLVMAddPartiallyInlineLibCallsPass,
    .lowerSwitch: LLVMAddLowerSwitchPass,
    .promoteMemoryToRegister: LLVMAddPromoteMemoryToRegisterPass,
    .reassociate: LLVMAddReassociatePass,
    .sccp: LLVMAddSCCPPass,
    .scalarReplAggregates: LLVMAddScalarReplAggregatesPass,
    .scalarReplAggregatesSSA: LLVMAddScalarReplAggregatesPassSSA,
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
    .unifyFunctionExitNodes: LLVMAddUnifyFunctionExitNodesPass,
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
    .loopVectorize: LLVMAddLoopVectorizePass,
    .slpVectorize: LLVMAddSLPVectorizePass,
    //    .internalize: LLVMAddInternalizePass,
    //    .sroaWithThreshhold: LLVMAddScalarReplAggregatesPassWithThreshold,
  ]
}
