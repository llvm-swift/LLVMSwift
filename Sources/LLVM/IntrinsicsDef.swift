public enum GlobalIntrinsics: String, LLVMIntrinsic {
  case llvm_va_start = "llvm.va_start"
  case llvm_va_copy = "llvm.va_copy"
  case llvm_va_end = "llvm.va_end"
  case llvm_gcroot = "llvm.gcroot"
  case llvm_gcread = "llvm.gcread"
  case llvm_gcwrite = "llvm.gcwrite"
  case llvm_returnaddress = "llvm.returnaddress"
  case llvm_addressofreturnaddress = "llvm.addressofreturnaddress"
  case llvm_frameaddress = "llvm.frameaddress"
  case llvm_localaddress = "llvm.localaddress"
  case llvm_localescape = "llvm.localescape"
  case llvm_localrecover = "llvm.localrecover"
  case llvm_stacksave = "llvm.stacksave"
  case llvm_stackrestore = "llvm.stackrestore"
  case llvm_thread_pointer = "llvm.thread.pointer"
  case llvm_prefetch = "llvm.prefetch"
  case llvm_pcmarker = "llvm.pcmarker"
  case llvm_readcyclecounter = "llvm.readcyclecounter"
  case llvm_assume = "llvm.assume"
  case llvm_stackprotector = "llvm.stackprotector"
  case llvm_stackguard = "llvm.stackguard"
  case llvm_instrprof_increment = "llvm.instrprof.increment"
  case llvm_instrprof_increment_step = "llvm.instrprof.increment.step"
  case llvm_instrprof_value_profile = "llvm.instrprof.value.profile"
  case llvm_setjmp = "llvm.setjmp"
  case llvm_longjmp = "llvm.longjmp"
  case llvm_sigsetjmp = "llvm.sigsetjmp"
  case llvm_siglongjmp = "llvm.siglongjmp"
  case llvm_dbg_declare = "llvm.dbg.declare"
  case llvm_dbg_value = "llvm.dbg.value"
  case llvm_eh_typeid_for = "llvm.eh.typeid.for"
  case llvm_eh_return_i32 = "llvm.eh.return.i32"
  case llvm_eh_return_i64 = "llvm.eh.return.i64"
  case llvm_eh_exceptionpointer = "llvm.eh.exceptionpointer"
  case llvm_eh_exceptioncode = "llvm.eh.exceptioncode"
  case llvm_eh_unwind_init = "llvm.eh.unwind.init"
  case llvm_eh_dwarf_cfa = "llvm.eh.dwarf.cfa"
  case llvm_eh_sjlj_lsda = "llvm.eh.sjlj.lsda"
  case llvm_eh_sjlj_callsite = "llvm.eh.sjlj.callsite"
  case llvm_eh_sjlj_functioncontext = "llvm.eh.sjlj.functioncontext"
  case llvm_eh_sjlj_setjmp = "llvm.eh.sjlj.setjmp"
  case llvm_eh_sjlj_longjmp = "llvm.eh.sjlj.longjmp"
  case llvm_eh_sjlj_setup_dispatch = "llvm.eh.sjlj.setup.dispatch"
  case llvm_var_annotation = "llvm.var.annotation"
  case llvm_init_trampoline = "llvm.init.trampoline"
  case llvm_adjust_trampoline = "llvm.adjust.trampoline"
  case llvm_lifetime_start = "llvm.lifetime.start"
  case llvm_lifetime_end = "llvm.lifetime.end"
  case llvm_invariant_start = "llvm.invariant.start"
  case llvm_invariant_end = "llvm.invariant.end"
  case llvm_invariant_group_barrier = "llvm.invariant.group.barrier"
  case llvm_experimental_stackmap = "llvm.experimental.stackmap"
  case llvm_experimental_patchpoint_void = "llvm.experimental.patchpoint.void"
  case llvm_experimental_patchpoint_i64 = "llvm.experimental.patchpoint.i64"
  case llvm_experimental_gc_statepoint = "llvm.experimental.gc.statepoint"
  case llvm_experimental_gc_result = "llvm.experimental.gc.result"
  case llvm_experimental_gc_relocate = "llvm.experimental.gc.relocate"
  case llvm_coro_id = "llvm.coro.id"
  case llvm_coro_alloc = "llvm.coro.alloc"
  case llvm_coro_begin = "llvm.coro.begin"
  case llvm_coro_free = "llvm.coro.free"
  case llvm_coro_end = "llvm.coro.end"
  case llvm_coro_frame = "llvm.coro.frame"
  case llvm_coro_save = "llvm.coro.save"
  case llvm_coro_suspend = "llvm.coro.suspend"
  case llvm_coro_param = "llvm.coro.param"
  case llvm_coro_resume = "llvm.coro.resume"
  case llvm_coro_destroy = "llvm.coro.destroy"
  case llvm_coro_done = "llvm.coro.done"
  case llvm_coro_promise = "llvm.coro.promise"
  case llvm_coro_subfn_addr = "llvm.coro.subfn.addr"
  case llvm_flt_rounds = "llvm.flt.rounds"
  case llvm_trap = "llvm.trap"
  case llvm_debugtrap = "llvm.debugtrap"
  case llvm_experimental_deoptimize = "llvm.experimental.deoptimize"
  case llvm_experimental_guard = "llvm.experimental.guard"
  case llvm_donothing = "llvm.donothing"
  case llvm_clear_cache = "llvm.clear_cache"
  case llvm_masked_store = "llvm.masked.store"
  case llvm_masked_load = "llvm.masked.load"
  case llvm_masked_gather = "llvm.masked.gather"
  case llvm_masked_scatter = "llvm.masked.scatter"
  case llvm_masked_expandload = "llvm.masked.expandload"
  case llvm_masked_compressstore = "llvm.masked.compressstore"
  case llvm_type_test = "llvm.type.test"
  case llvm_type_checked_load = "llvm.type.checked.load"
  case llvm_memcpy_element_atomic = "llvm.memcpy.element.atomic"
  case llvm_ssa_copy = "llvm.ssa_copy"

  public var llvmSelector: String { return self.rawValue }

  public var signature: FunctionType {
    switch self {
    case .llvm_va_start: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_va_copy: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_va_end: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_gcroot: return FunctionType(argTypes: [PointerType(pointee: PointerType(pointee: IntType(width: 8))), PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_gcread: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: PointerType(pointee: IntType(width: 8)))], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_gcwrite: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), PointerType(pointee: PointerType(pointee: IntType(width: 8)))], returnType: VoidType(), isVarArg: false)
    case .llvm_returnaddress: return FunctionType(argTypes: [IntType(width: 32)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_addressofreturnaddress: return FunctionType(argTypes: [], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_frameaddress: return FunctionType(argTypes: [IntType(width: 32)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_localaddress: return FunctionType(argTypes: [], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_localescape: return FunctionType(argTypes: [], returnType: VoidType(), isVarArg: true)
    case .llvm_localrecover: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_stacksave: return FunctionType(argTypes: [], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_stackrestore: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_thread_pointer: return FunctionType(argTypes: [], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_prefetch: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 32), IntType(width: 32), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
    case .llvm_pcmarker: return FunctionType(argTypes: [IntType(width: 32)], returnType: VoidType(), isVarArg: false)
    case .llvm_readcyclecounter: return FunctionType(argTypes: [], returnType: IntType(width: 64), isVarArg: false)
    case .llvm_assume: return FunctionType(argTypes: [IntType(width: 1)], returnType: VoidType(), isVarArg: false)
    case .llvm_stackprotector: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: PointerType(pointee: IntType(width: 8)))], returnType: VoidType(), isVarArg: false)
    case .llvm_stackguard: return FunctionType(argTypes: [], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_instrprof_increment: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 64), IntType(width: 32), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
    case .llvm_instrprof_increment_step: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 64), IntType(width: 32), IntType(width: 32), IntType(width: 64)], returnType: VoidType(), isVarArg: false)
    case .llvm_instrprof_value_profile: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 64), IntType(width: 64), IntType(width: 32), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
    case .llvm_setjmp: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: IntType(width: 32), isVarArg: false)
    case .llvm_longjmp: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
    case .llvm_sigsetjmp: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
    case .llvm_siglongjmp: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
    case .llvm_dbg_declare: return FunctionType(argTypes: [MetadataType(), MetadataType(), MetadataType()], returnType: VoidType(), isVarArg: false)
    case .llvm_dbg_value: return FunctionType(argTypes: [MetadataType(), IntType(width: 64), MetadataType(), MetadataType()], returnType: VoidType(), isVarArg: false)
    case .llvm_eh_typeid_for: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: IntType(width: 32), isVarArg: false)
    case .llvm_eh_return_i32: return FunctionType(argTypes: [IntType(width: 32), PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_eh_return_i64: return FunctionType(argTypes: [IntType(width: 64), PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_eh_exceptionpointer: return FunctionType(argTypes: [TokenType()], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_eh_exceptioncode: return FunctionType(argTypes: [TokenType()], returnType: IntType(width: 32), isVarArg: false)
    case .llvm_eh_unwind_init: return FunctionType(argTypes: [], returnType: VoidType(), isVarArg: false)
    case .llvm_eh_dwarf_cfa: return FunctionType(argTypes: [IntType(width: 32)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_eh_sjlj_lsda: return FunctionType(argTypes: [], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_eh_sjlj_callsite: return FunctionType(argTypes: [IntType(width: 32)], returnType: VoidType(), isVarArg: false)
    case .llvm_eh_sjlj_functioncontext: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_eh_sjlj_setjmp: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: IntType(width: 32), isVarArg: false)
    case .llvm_eh_sjlj_longjmp: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_eh_sjlj_setup_dispatch: return FunctionType(argTypes: [], returnType: VoidType(), isVarArg: false)
    case .llvm_var_annotation: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
    case .llvm_init_trampoline: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_adjust_trampoline: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_lifetime_start: return FunctionType(argTypes: [IntType(width: 64), PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_lifetime_end: return FunctionType(argTypes: [IntType(width: 64), PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_invariant_start: return FunctionType(argTypes: [IntType(width: 64), PointerType(pointee: IntType(width: 8))], returnType: PointerType(pointee: StructType(elementTypes: [])), isVarArg: false)
    case .llvm_invariant_end: return FunctionType(argTypes: [PointerType(pointee: StructType(elementTypes: [])), IntType(width: 64), PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_invariant_group_barrier: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_experimental_stackmap: return FunctionType(argTypes: [IntType(width: 64), IntType(width: 32)], returnType: VoidType(), isVarArg: true)
    case .llvm_experimental_patchpoint_void: return FunctionType(argTypes: [IntType(width: 64), IntType(width: 32), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: VoidType(), isVarArg: true)
    case .llvm_experimental_patchpoint_i64: return FunctionType(argTypes: [IntType(width: 64), IntType(width: 32), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: IntType(width: 64), isVarArg: true)
    case .llvm_experimental_gc_statepoint: return FunctionType(argTypes: [IntType(width: 64), IntType(width: 32), PointerType(pointee: IntType(width: 8)), IntType(width: 32), IntType(width: 32)], returnType: TokenType(), isVarArg: true)
    case .llvm_experimental_gc_result: return FunctionType(argTypes: [TokenType()], returnType: IntrinsicSubstitutionMarker(), isVarArg: false)
    case .llvm_experimental_gc_relocate: return FunctionType(argTypes: [TokenType(), IntType(width: 32), IntType(width: 32)], returnType: IntrinsicSubstitutionMarker(), isVarArg: false)
    case .llvm_coro_id: return FunctionType(argTypes: [IntType(width: 32), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8))], returnType: TokenType(), isVarArg: false)
    case .llvm_coro_alloc: return FunctionType(argTypes: [TokenType()], returnType: IntType(width: 1), isVarArg: false)
    case .llvm_coro_begin: return FunctionType(argTypes: [TokenType(), PointerType(pointee: IntType(width: 8))], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_coro_free: return FunctionType(argTypes: [TokenType(), PointerType(pointee: IntType(width: 8))], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_coro_end: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 1)], returnType: IntType(width: 1), isVarArg: false)
    case .llvm_coro_frame: return FunctionType(argTypes: [], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_coro_save: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: TokenType(), isVarArg: false)
    case .llvm_coro_suspend: return FunctionType(argTypes: [TokenType(), IntType(width: 1)], returnType: IntType(width: 8), isVarArg: false)
    case .llvm_coro_param: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8))], returnType: IntType(width: 1), isVarArg: false)
    case .llvm_coro_resume: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_coro_destroy: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_coro_done: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8))], returnType: IntType(width: 1), isVarArg: false)
    case .llvm_coro_promise: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 32), IntType(width: 1)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_coro_subfn_addr: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 8)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_flt_rounds: return FunctionType(argTypes: [], returnType: IntType(width: 32), isVarArg: false)
    case .llvm_trap: return FunctionType(argTypes: [], returnType: VoidType(), isVarArg: false)
    case .llvm_debugtrap: return FunctionType(argTypes: [], returnType: VoidType(), isVarArg: false)
    case .llvm_experimental_deoptimize: return FunctionType(argTypes: [], returnType: IntrinsicSubstitutionMarker(), isVarArg: true)
    case .llvm_experimental_guard: return FunctionType(argTypes: [IntType(width: 1)], returnType: VoidType(), isVarArg: true)
    case .llvm_donothing: return FunctionType(argTypes: [], returnType: VoidType(), isVarArg: false)
    case .llvm_clear_cache: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8))], returnType: VoidType(), isVarArg: false)
    case .llvm_masked_store: return FunctionType(argTypes: [VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1), PointerType(pointee: VoidType()), IntType(width: 32), VectorType(elementType: IntType(width: 1), count: -1)], returnType: VoidType(), isVarArg: false)
    case .llvm_masked_load: return FunctionType(argTypes: [PointerType(pointee: VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1)), IntType(width: 32), VectorType(elementType: IntType(width: 1), count: -1), VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1)], returnType: VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1), isVarArg: false)
    case .llvm_masked_gather: return FunctionType(argTypes: [VectorType(elementType: PointerType(pointee: VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1)), count: -1), IntType(width: 32), VectorType(elementType: IntType(width: 1), count: -1), VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1)], returnType: VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1), isVarArg: false)
    case .llvm_masked_scatter: return FunctionType(argTypes: [VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1), VectorType(elementType: PointerType(pointee: VoidType()), count: -1), IntType(width: 32), VectorType(elementType: IntType(width: 1), count: -1)], returnType: VoidType(), isVarArg: false)
    case .llvm_masked_expandload: return FunctionType(argTypes: [PointerType(pointee: VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1)), VectorType(elementType: IntType(width: 1), count: -1), VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1)], returnType: VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1), isVarArg: false)
    case .llvm_masked_compressstore: return FunctionType(argTypes: [VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1), PointerType(pointee: VoidType()), VectorType(elementType: IntType(width: 1), count: -1)], returnType: VoidType(), isVarArg: false)
    case .llvm_type_test: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), MetadataType()], returnType: IntType(width: 1), isVarArg: false)
    case .llvm_type_checked_load: return FunctionType(argTypes: [IntType(width: 1), PointerType(pointee: IntType(width: 8)), IntType(width: 32), MetadataType()], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
    case .llvm_memcpy_element_atomic: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 64), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
    case .llvm_ssa_copy: return FunctionType(argTypes: [IntrinsicSubstitutionMarker()], returnType: IntrinsicSubstitutionMarker(), isVarArg: false)
    }
  }

  public enum int_read_register: String, LLVMOverloadedIntrinsic {
    case llvm_read_register_i8 = "llvm.read_register.i8"
    case llvm_read_register_i16 = "llvm.read_register.i16"
    case llvm_read_register_i32 = "llvm.read_register.i32"
    case llvm_read_register_i64 = "llvm.read_register.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_read_register_i8: return FunctionType(argTypes: [MetadataType()], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_read_register_i16: return FunctionType(argTypes: [MetadataType()], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_read_register_i32: return FunctionType(argTypes: [MetadataType()], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_read_register_i64: return FunctionType(argTypes: [MetadataType()], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_read_register.llvm_read_register_i8,
        int_read_register.llvm_read_register_i16,
        int_read_register.llvm_read_register_i32,
        int_read_register.llvm_read_register_i64,
      ]
    }
  }
  public enum int_write_register: String, LLVMOverloadedIntrinsic {
    case llvm_write_register_i8 = "llvm.write_register.i8"
    case llvm_write_register_i16 = "llvm.write_register.i16"
    case llvm_write_register_i32 = "llvm.write_register.i32"
    case llvm_write_register_i64 = "llvm.write_register.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_write_register_i8: return FunctionType(argTypes: [MetadataType(), IntType(width: 8)], returnType: VoidType(), isVarArg: false)
      case .llvm_write_register_i16: return FunctionType(argTypes: [MetadataType(), IntType(width: 16)], returnType: VoidType(), isVarArg: false)
      case .llvm_write_register_i32: return FunctionType(argTypes: [MetadataType(), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
      case .llvm_write_register_i64: return FunctionType(argTypes: [MetadataType(), IntType(width: 64)], returnType: VoidType(), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_write_register.llvm_write_register_i8,
        int_write_register.llvm_write_register_i16,
        int_write_register.llvm_write_register_i32,
        int_write_register.llvm_write_register_i64,
      ]
    }
  }
  public enum int_get_dynamic_area_offset: String, LLVMOverloadedIntrinsic {
    case llvm_get_dynamic_area_offset_i8 = "llvm.get.dynamic.area.offset.i8"
    case llvm_get_dynamic_area_offset_i16 = "llvm.get.dynamic.area.offset.i16"
    case llvm_get_dynamic_area_offset_i32 = "llvm.get.dynamic.area.offset.i32"
    case llvm_get_dynamic_area_offset_i64 = "llvm.get.dynamic.area.offset.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_get_dynamic_area_offset_i8: return FunctionType(argTypes: [], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_get_dynamic_area_offset_i16: return FunctionType(argTypes: [], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_get_dynamic_area_offset_i32: return FunctionType(argTypes: [], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_get_dynamic_area_offset_i64: return FunctionType(argTypes: [], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_get_dynamic_area_offset.llvm_get_dynamic_area_offset_i8,
        int_get_dynamic_area_offset.llvm_get_dynamic_area_offset_i16,
        int_get_dynamic_area_offset.llvm_get_dynamic_area_offset_i32,
        int_get_dynamic_area_offset.llvm_get_dynamic_area_offset_i64,
      ]
    }
  }
  public enum int_memcpy: String, LLVMOverloadedIntrinsic {
    case llvm_memcpy_p0i8_p0i8_i8 = "llvm.memcpy.p0i8.p0i8.i8"
    case llvm_memcpy_p0i8_p0i8_i16 = "llvm.memcpy.p0i8.p0i8.i16"
    case llvm_memcpy_p0i8_p0i8_i32 = "llvm.memcpy.p0i8.p0i8.i32"
    case llvm_memcpy_p0i8_p0i8_i64 = "llvm.memcpy.p0i8.p0i8.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_memcpy_p0i8_p0i8_i8: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 8)], returnType: VoidType(), isVarArg: false)
      case .llvm_memcpy_p0i8_p0i8_i16: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 16)], returnType: VoidType(), isVarArg: false)
      case .llvm_memcpy_p0i8_p0i8_i32: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
      case .llvm_memcpy_p0i8_p0i8_i64: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 64)], returnType: VoidType(), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_memcpy.llvm_memcpy_p0i8_p0i8_i8,
        int_memcpy.llvm_memcpy_p0i8_p0i8_i16,
        int_memcpy.llvm_memcpy_p0i8_p0i8_i32,
        int_memcpy.llvm_memcpy_p0i8_p0i8_i64,
      ]
    }
  }
  public enum int_memmove: String, LLVMOverloadedIntrinsic {
    case llvm_memmove_p0i8_p0i8_i8 = "llvm.memmove.p0i8.p0i8.i8"
    case llvm_memmove_p0i8_p0i8_i16 = "llvm.memmove.p0i8.p0i8.i16"
    case llvm_memmove_p0i8_p0i8_i32 = "llvm.memmove.p0i8.p0i8.i32"
    case llvm_memmove_p0i8_p0i8_i64 = "llvm.memmove.p0i8.p0i8.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_memmove_p0i8_p0i8_i8: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 8)], returnType: VoidType(), isVarArg: false)
      case .llvm_memmove_p0i8_p0i8_i16: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 16)], returnType: VoidType(), isVarArg: false)
      case .llvm_memmove_p0i8_p0i8_i32: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
      case .llvm_memmove_p0i8_p0i8_i64: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 64)], returnType: VoidType(), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_memmove.llvm_memmove_p0i8_p0i8_i8,
        int_memmove.llvm_memmove_p0i8_p0i8_i16,
        int_memmove.llvm_memmove_p0i8_p0i8_i32,
        int_memmove.llvm_memmove_p0i8_p0i8_i64,
      ]
    }
  }
  public enum int_memset: String, LLVMOverloadedIntrinsic {
    case llvm_memset_p0i8_i8_i8 = "llvm.memset.p0i8.i8.i8"
    case llvm_memset_p0i8_i8_i16 = "llvm.memset.p0i8.i8.i16"
    case llvm_memset_p0i8_i8_i32 = "llvm.memset.p0i8.i8.i32"
    case llvm_memset_p0i8_i8_i64 = "llvm.memset.p0i8.i8.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_memset_p0i8_i8_i8: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 8), IntType(width: 8)], returnType: VoidType(), isVarArg: false)
      case .llvm_memset_p0i8_i8_i16: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 8), IntType(width: 16)], returnType: VoidType(), isVarArg: false)
      case .llvm_memset_p0i8_i8_i32: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 8), IntType(width: 32)], returnType: VoidType(), isVarArg: false)
      case .llvm_memset_p0i8_i8_i64: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 8), IntType(width: 64)], returnType: VoidType(), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_memset.llvm_memset_p0i8_i8_i8,
        int_memset.llvm_memset_p0i8_i8_i16,
        int_memset.llvm_memset_p0i8_i8_i32,
        int_memset.llvm_memset_p0i8_i8_i64,
      ]
    }
  }
  public enum int_fma: String, LLVMOverloadedIntrinsic {
    case llvm_fma_f16 = "llvm.fma.f16"
    case llvm_fma_f32 = "llvm.fma.f32"
    case llvm_fma_f64 = "llvm.fma.f64"
    case llvm_fma_f80 = "llvm.fma.f80"
    case llvm_fma_f128 = "llvm.fma.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_fma_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half, FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_fma_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float, FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_fma_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double, FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_fma_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80, FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_fma_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128, FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_fma.llvm_fma_f16,
        int_fma.llvm_fma_f32,
        int_fma.llvm_fma_f64,
        int_fma.llvm_fma_f80,
        int_fma.llvm_fma_f128,
      ]
    }
  }
  public enum int_fmuladd: String, LLVMOverloadedIntrinsic {
    case llvm_fmuladd_f16 = "llvm.fmuladd.f16"
    case llvm_fmuladd_f32 = "llvm.fmuladd.f32"
    case llvm_fmuladd_f64 = "llvm.fmuladd.f64"
    case llvm_fmuladd_f80 = "llvm.fmuladd.f80"
    case llvm_fmuladd_f128 = "llvm.fmuladd.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_fmuladd_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half, FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_fmuladd_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float, FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_fmuladd_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double, FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_fmuladd_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80, FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_fmuladd_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128, FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_fmuladd.llvm_fmuladd_f16,
        int_fmuladd.llvm_fmuladd_f32,
        int_fmuladd.llvm_fmuladd_f64,
        int_fmuladd.llvm_fmuladd_f80,
        int_fmuladd.llvm_fmuladd_f128,
      ]
    }
  }
  public enum int_sqrt: String, LLVMOverloadedIntrinsic {
    case llvm_sqrt_f16 = "llvm.sqrt.f16"
    case llvm_sqrt_f32 = "llvm.sqrt.f32"
    case llvm_sqrt_f64 = "llvm.sqrt.f64"
    case llvm_sqrt_f80 = "llvm.sqrt.f80"
    case llvm_sqrt_f128 = "llvm.sqrt.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_sqrt_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_sqrt_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_sqrt_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_sqrt_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_sqrt_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_sqrt.llvm_sqrt_f16,
        int_sqrt.llvm_sqrt_f32,
        int_sqrt.llvm_sqrt_f64,
        int_sqrt.llvm_sqrt_f80,
        int_sqrt.llvm_sqrt_f128,
      ]
    }
  }
  public enum int_powi: String, LLVMOverloadedIntrinsic {
    case llvm_powi_f16_i32 = "llvm.powi.f16.i32"
    case llvm_powi_f32_i32 = "llvm.powi.f32.i32"
    case llvm_powi_f64_i32 = "llvm.powi.f64.i32"
    case llvm_powi_f80_i32 = "llvm.powi.f80.i32"
    case llvm_powi_f128_i32 = "llvm.powi.f128.i32"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_powi_f16_i32: return FunctionType(argTypes: [FloatType.half, IntType(width: 32)], returnType: FloatType.half, isVarArg: false)
      case .llvm_powi_f32_i32: return FunctionType(argTypes: [FloatType.float, IntType(width: 32)], returnType: FloatType.float, isVarArg: false)
      case .llvm_powi_f64_i32: return FunctionType(argTypes: [FloatType.double, IntType(width: 32)], returnType: FloatType.double, isVarArg: false)
      case .llvm_powi_f80_i32: return FunctionType(argTypes: [FloatType.x86FP80, IntType(width: 32)], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_powi_f128_i32: return FunctionType(argTypes: [FloatType.ppcFP128, IntType(width: 32)], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_powi.llvm_powi_f16_i32,
        int_powi.llvm_powi_f32_i32,
        int_powi.llvm_powi_f64_i32,
        int_powi.llvm_powi_f80_i32,
        int_powi.llvm_powi_f128_i32,
      ]
    }
  }
  public enum int_sin: String, LLVMOverloadedIntrinsic {
    case llvm_sin_f16 = "llvm.sin.f16"
    case llvm_sin_f32 = "llvm.sin.f32"
    case llvm_sin_f64 = "llvm.sin.f64"
    case llvm_sin_f80 = "llvm.sin.f80"
    case llvm_sin_f128 = "llvm.sin.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_sin_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_sin_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_sin_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_sin_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_sin_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_sin.llvm_sin_f16,
        int_sin.llvm_sin_f32,
        int_sin.llvm_sin_f64,
        int_sin.llvm_sin_f80,
        int_sin.llvm_sin_f128,
      ]
    }
  }
  public enum int_cos: String, LLVMOverloadedIntrinsic {
    case llvm_cos_f16 = "llvm.cos.f16"
    case llvm_cos_f32 = "llvm.cos.f32"
    case llvm_cos_f64 = "llvm.cos.f64"
    case llvm_cos_f80 = "llvm.cos.f80"
    case llvm_cos_f128 = "llvm.cos.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_cos_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_cos_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_cos_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_cos_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_cos_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_cos.llvm_cos_f16,
        int_cos.llvm_cos_f32,
        int_cos.llvm_cos_f64,
        int_cos.llvm_cos_f80,
        int_cos.llvm_cos_f128,
      ]
    }
  }
  public enum int_pow: String, LLVMOverloadedIntrinsic {
    case llvm_pow_f16 = "llvm.pow.f16"
    case llvm_pow_f32 = "llvm.pow.f32"
    case llvm_pow_f64 = "llvm.pow.f64"
    case llvm_pow_f80 = "llvm.pow.f80"
    case llvm_pow_f128 = "llvm.pow.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_pow_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_pow_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_pow_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_pow_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_pow_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_pow.llvm_pow_f16,
        int_pow.llvm_pow_f32,
        int_pow.llvm_pow_f64,
        int_pow.llvm_pow_f80,
        int_pow.llvm_pow_f128,
      ]
    }
  }
  public enum int_log: String, LLVMOverloadedIntrinsic {
    case llvm_log_f16 = "llvm.log.f16"
    case llvm_log_f32 = "llvm.log.f32"
    case llvm_log_f64 = "llvm.log.f64"
    case llvm_log_f80 = "llvm.log.f80"
    case llvm_log_f128 = "llvm.log.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_log_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_log_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_log_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_log_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_log_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_log.llvm_log_f16,
        int_log.llvm_log_f32,
        int_log.llvm_log_f64,
        int_log.llvm_log_f80,
        int_log.llvm_log_f128,
      ]
    }
  }
  public enum int_log10: String, LLVMOverloadedIntrinsic {
    case llvm_log10_f16 = "llvm.log10.f16"
    case llvm_log10_f32 = "llvm.log10.f32"
    case llvm_log10_f64 = "llvm.log10.f64"
    case llvm_log10_f80 = "llvm.log10.f80"
    case llvm_log10_f128 = "llvm.log10.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_log10_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_log10_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_log10_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_log10_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_log10_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_log10.llvm_log10_f16,
        int_log10.llvm_log10_f32,
        int_log10.llvm_log10_f64,
        int_log10.llvm_log10_f80,
        int_log10.llvm_log10_f128,
      ]
    }
  }
  public enum int_log2: String, LLVMOverloadedIntrinsic {
    case llvm_log2_f16 = "llvm.log2.f16"
    case llvm_log2_f32 = "llvm.log2.f32"
    case llvm_log2_f64 = "llvm.log2.f64"
    case llvm_log2_f80 = "llvm.log2.f80"
    case llvm_log2_f128 = "llvm.log2.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_log2_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_log2_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_log2_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_log2_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_log2_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_log2.llvm_log2_f16,
        int_log2.llvm_log2_f32,
        int_log2.llvm_log2_f64,
        int_log2.llvm_log2_f80,
        int_log2.llvm_log2_f128,
      ]
    }
  }
  public enum int_exp: String, LLVMOverloadedIntrinsic {
    case llvm_exp_f16 = "llvm.exp.f16"
    case llvm_exp_f32 = "llvm.exp.f32"
    case llvm_exp_f64 = "llvm.exp.f64"
    case llvm_exp_f80 = "llvm.exp.f80"
    case llvm_exp_f128 = "llvm.exp.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_exp_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_exp_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_exp_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_exp_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_exp_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_exp.llvm_exp_f16,
        int_exp.llvm_exp_f32,
        int_exp.llvm_exp_f64,
        int_exp.llvm_exp_f80,
        int_exp.llvm_exp_f128,
      ]
    }
  }
  public enum int_exp2: String, LLVMOverloadedIntrinsic {
    case llvm_exp2_f16 = "llvm.exp2.f16"
    case llvm_exp2_f32 = "llvm.exp2.f32"
    case llvm_exp2_f64 = "llvm.exp2.f64"
    case llvm_exp2_f80 = "llvm.exp2.f80"
    case llvm_exp2_f128 = "llvm.exp2.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_exp2_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_exp2_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_exp2_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_exp2_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_exp2_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_exp2.llvm_exp2_f16,
        int_exp2.llvm_exp2_f32,
        int_exp2.llvm_exp2_f64,
        int_exp2.llvm_exp2_f80,
        int_exp2.llvm_exp2_f128,
      ]
    }
  }
  public enum int_fabs: String, LLVMOverloadedIntrinsic {
    case llvm_fabs_f16 = "llvm.fabs.f16"
    case llvm_fabs_f32 = "llvm.fabs.f32"
    case llvm_fabs_f64 = "llvm.fabs.f64"
    case llvm_fabs_f80 = "llvm.fabs.f80"
    case llvm_fabs_f128 = "llvm.fabs.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_fabs_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_fabs_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_fabs_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_fabs_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_fabs_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_fabs.llvm_fabs_f16,
        int_fabs.llvm_fabs_f32,
        int_fabs.llvm_fabs_f64,
        int_fabs.llvm_fabs_f80,
        int_fabs.llvm_fabs_f128,
      ]
    }
  }
  public enum int_copysign: String, LLVMOverloadedIntrinsic {
    case llvm_copysign_f16 = "llvm.copysign.f16"
    case llvm_copysign_f32 = "llvm.copysign.f32"
    case llvm_copysign_f64 = "llvm.copysign.f64"
    case llvm_copysign_f80 = "llvm.copysign.f80"
    case llvm_copysign_f128 = "llvm.copysign.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_copysign_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_copysign_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_copysign_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_copysign_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_copysign_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_copysign.llvm_copysign_f16,
        int_copysign.llvm_copysign_f32,
        int_copysign.llvm_copysign_f64,
        int_copysign.llvm_copysign_f80,
        int_copysign.llvm_copysign_f128,
      ]
    }
  }
  public enum int_floor: String, LLVMOverloadedIntrinsic {
    case llvm_floor_f16 = "llvm.floor.f16"
    case llvm_floor_f32 = "llvm.floor.f32"
    case llvm_floor_f64 = "llvm.floor.f64"
    case llvm_floor_f80 = "llvm.floor.f80"
    case llvm_floor_f128 = "llvm.floor.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_floor_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_floor_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_floor_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_floor_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_floor_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_floor.llvm_floor_f16,
        int_floor.llvm_floor_f32,
        int_floor.llvm_floor_f64,
        int_floor.llvm_floor_f80,
        int_floor.llvm_floor_f128,
      ]
    }
  }
  public enum int_ceil: String, LLVMOverloadedIntrinsic {
    case llvm_ceil_f16 = "llvm.ceil.f16"
    case llvm_ceil_f32 = "llvm.ceil.f32"
    case llvm_ceil_f64 = "llvm.ceil.f64"
    case llvm_ceil_f80 = "llvm.ceil.f80"
    case llvm_ceil_f128 = "llvm.ceil.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_ceil_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_ceil_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_ceil_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_ceil_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_ceil_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_ceil.llvm_ceil_f16,
        int_ceil.llvm_ceil_f32,
        int_ceil.llvm_ceil_f64,
        int_ceil.llvm_ceil_f80,
        int_ceil.llvm_ceil_f128,
      ]
    }
  }
  public enum int_trunc: String, LLVMOverloadedIntrinsic {
    case llvm_trunc_f16 = "llvm.trunc.f16"
    case llvm_trunc_f32 = "llvm.trunc.f32"
    case llvm_trunc_f64 = "llvm.trunc.f64"
    case llvm_trunc_f80 = "llvm.trunc.f80"
    case llvm_trunc_f128 = "llvm.trunc.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_trunc_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_trunc_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_trunc_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_trunc_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_trunc_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_trunc.llvm_trunc_f16,
        int_trunc.llvm_trunc_f32,
        int_trunc.llvm_trunc_f64,
        int_trunc.llvm_trunc_f80,
        int_trunc.llvm_trunc_f128,
      ]
    }
  }
  public enum int_rint: String, LLVMOverloadedIntrinsic {
    case llvm_rint_f16 = "llvm.rint.f16"
    case llvm_rint_f32 = "llvm.rint.f32"
    case llvm_rint_f64 = "llvm.rint.f64"
    case llvm_rint_f80 = "llvm.rint.f80"
    case llvm_rint_f128 = "llvm.rint.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_rint_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_rint_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_rint_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_rint_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_rint_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_rint.llvm_rint_f16,
        int_rint.llvm_rint_f32,
        int_rint.llvm_rint_f64,
        int_rint.llvm_rint_f80,
        int_rint.llvm_rint_f128,
      ]
    }
  }
  public enum int_nearbyint: String, LLVMOverloadedIntrinsic {
    case llvm_nearbyint_f16 = "llvm.nearbyint.f16"
    case llvm_nearbyint_f32 = "llvm.nearbyint.f32"
    case llvm_nearbyint_f64 = "llvm.nearbyint.f64"
    case llvm_nearbyint_f80 = "llvm.nearbyint.f80"
    case llvm_nearbyint_f128 = "llvm.nearbyint.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_nearbyint_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_nearbyint_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_nearbyint_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_nearbyint_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_nearbyint_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_nearbyint.llvm_nearbyint_f16,
        int_nearbyint.llvm_nearbyint_f32,
        int_nearbyint.llvm_nearbyint_f64,
        int_nearbyint.llvm_nearbyint_f80,
        int_nearbyint.llvm_nearbyint_f128,
      ]
    }
  }
  public enum int_round: String, LLVMOverloadedIntrinsic {
    case llvm_round_f16 = "llvm.round.f16"
    case llvm_round_f32 = "llvm.round.f32"
    case llvm_round_f64 = "llvm.round.f64"
    case llvm_round_f80 = "llvm.round.f80"
    case llvm_round_f128 = "llvm.round.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_round_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_round_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_round_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_round_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_round_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_round.llvm_round_f16,
        int_round.llvm_round_f32,
        int_round.llvm_round_f64,
        int_round.llvm_round_f80,
        int_round.llvm_round_f128,
      ]
    }
  }
  public enum int_canonicalize: String, LLVMOverloadedIntrinsic {
    case llvm_canonicalize_f16 = "llvm.canonicalize.f16"
    case llvm_canonicalize_f32 = "llvm.canonicalize.f32"
    case llvm_canonicalize_f64 = "llvm.canonicalize.f64"
    case llvm_canonicalize_f80 = "llvm.canonicalize.f80"
    case llvm_canonicalize_f128 = "llvm.canonicalize.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_canonicalize_f16: return FunctionType(argTypes: [FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_canonicalize_f32: return FunctionType(argTypes: [FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_canonicalize_f64: return FunctionType(argTypes: [FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_canonicalize_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_canonicalize_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_canonicalize.llvm_canonicalize_f16,
        int_canonicalize.llvm_canonicalize_f32,
        int_canonicalize.llvm_canonicalize_f64,
        int_canonicalize.llvm_canonicalize_f80,
        int_canonicalize.llvm_canonicalize_f128,
      ]
    }
  }
  public enum int_minnum: String, LLVMOverloadedIntrinsic {
    case llvm_minnum_f16 = "llvm.minnum.f16"
    case llvm_minnum_f32 = "llvm.minnum.f32"
    case llvm_minnum_f64 = "llvm.minnum.f64"
    case llvm_minnum_f80 = "llvm.minnum.f80"
    case llvm_minnum_f128 = "llvm.minnum.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_minnum_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_minnum_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_minnum_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_minnum_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_minnum_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_minnum.llvm_minnum_f16,
        int_minnum.llvm_minnum_f32,
        int_minnum.llvm_minnum_f64,
        int_minnum.llvm_minnum_f80,
        int_minnum.llvm_minnum_f128,
      ]
    }
  }
  public enum int_maxnum: String, LLVMOverloadedIntrinsic {
    case llvm_maxnum_f16 = "llvm.maxnum.f16"
    case llvm_maxnum_f32 = "llvm.maxnum.f32"
    case llvm_maxnum_f64 = "llvm.maxnum.f64"
    case llvm_maxnum_f80 = "llvm.maxnum.f80"
    case llvm_maxnum_f128 = "llvm.maxnum.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_maxnum_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half], returnType: FloatType.half, isVarArg: false)
      case .llvm_maxnum_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float], returnType: FloatType.float, isVarArg: false)
      case .llvm_maxnum_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double], returnType: FloatType.double, isVarArg: false)
      case .llvm_maxnum_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_maxnum_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_maxnum.llvm_maxnum_f16,
        int_maxnum.llvm_maxnum_f32,
        int_maxnum.llvm_maxnum_f64,
        int_maxnum.llvm_maxnum_f80,
        int_maxnum.llvm_maxnum_f128,
      ]
    }
  }
  public enum int_objectsize: String, LLVMOverloadedIntrinsic {
    case llvm_objectsize_i8_p0i8_i1_i1 = "llvm.objectsize.i8.p0i8.i1.i1"
    case llvm_objectsize_i16_p0i8_i1_i1 = "llvm.objectsize.i16.p0i8.i1.i1"
    case llvm_objectsize_i32_p0i8_i1_i1 = "llvm.objectsize.i32.p0i8.i1.i1"
    case llvm_objectsize_i64_p0i8_i1_i1 = "llvm.objectsize.i64.p0i8.i1.i1"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_objectsize_i8_p0i8_i1_i1: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 1), IntType(width: 1)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_objectsize_i16_p0i8_i1_i1: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 1), IntType(width: 1)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_objectsize_i32_p0i8_i1_i1: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 1), IntType(width: 1)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_objectsize_i64_p0i8_i1_i1: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 1), IntType(width: 1)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_objectsize.llvm_objectsize_i8_p0i8_i1_i1,
        int_objectsize.llvm_objectsize_i16_p0i8_i1_i1,
        int_objectsize.llvm_objectsize_i32_p0i8_i1_i1,
        int_objectsize.llvm_objectsize_i64_p0i8_i1_i1,
      ]
    }
  }
  public enum int_experimental_constrained_fadd: String, LLVMOverloadedIntrinsic {
    case llvm_experimental_constrained_fadd_f16 = "llvm.experimental.constrained.fadd.f16"
    case llvm_experimental_constrained_fadd_f32 = "llvm.experimental.constrained.fadd.f32"
    case llvm_experimental_constrained_fadd_f64 = "llvm.experimental.constrained.fadd.f64"
    case llvm_experimental_constrained_fadd_f80 = "llvm.experimental.constrained.fadd.f80"
    case llvm_experimental_constrained_fadd_f128 = "llvm.experimental.constrained.fadd.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_experimental_constrained_fadd_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half, MetadataType(), MetadataType()], returnType: FloatType.half, isVarArg: false)
      case .llvm_experimental_constrained_fadd_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float, MetadataType(), MetadataType()], returnType: FloatType.float, isVarArg: false)
      case .llvm_experimental_constrained_fadd_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double, MetadataType(), MetadataType()], returnType: FloatType.double, isVarArg: false)
      case .llvm_experimental_constrained_fadd_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80, MetadataType(), MetadataType()], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_experimental_constrained_fadd_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128, MetadataType(), MetadataType()], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_experimental_constrained_fadd.llvm_experimental_constrained_fadd_f16,
        int_experimental_constrained_fadd.llvm_experimental_constrained_fadd_f32,
        int_experimental_constrained_fadd.llvm_experimental_constrained_fadd_f64,
        int_experimental_constrained_fadd.llvm_experimental_constrained_fadd_f80,
        int_experimental_constrained_fadd.llvm_experimental_constrained_fadd_f128,
      ]
    }
  }
  public enum int_experimental_constrained_fsub: String, LLVMOverloadedIntrinsic {
    case llvm_experimental_constrained_fsub_f16 = "llvm.experimental.constrained.fsub.f16"
    case llvm_experimental_constrained_fsub_f32 = "llvm.experimental.constrained.fsub.f32"
    case llvm_experimental_constrained_fsub_f64 = "llvm.experimental.constrained.fsub.f64"
    case llvm_experimental_constrained_fsub_f80 = "llvm.experimental.constrained.fsub.f80"
    case llvm_experimental_constrained_fsub_f128 = "llvm.experimental.constrained.fsub.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_experimental_constrained_fsub_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half, MetadataType(), MetadataType()], returnType: FloatType.half, isVarArg: false)
      case .llvm_experimental_constrained_fsub_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float, MetadataType(), MetadataType()], returnType: FloatType.float, isVarArg: false)
      case .llvm_experimental_constrained_fsub_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double, MetadataType(), MetadataType()], returnType: FloatType.double, isVarArg: false)
      case .llvm_experimental_constrained_fsub_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80, MetadataType(), MetadataType()], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_experimental_constrained_fsub_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128, MetadataType(), MetadataType()], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_experimental_constrained_fsub.llvm_experimental_constrained_fsub_f16,
        int_experimental_constrained_fsub.llvm_experimental_constrained_fsub_f32,
        int_experimental_constrained_fsub.llvm_experimental_constrained_fsub_f64,
        int_experimental_constrained_fsub.llvm_experimental_constrained_fsub_f80,
        int_experimental_constrained_fsub.llvm_experimental_constrained_fsub_f128,
      ]
    }
  }
  public enum int_experimental_constrained_fmul: String, LLVMOverloadedIntrinsic {
    case llvm_experimental_constrained_fmul_f16 = "llvm.experimental.constrained.fmul.f16"
    case llvm_experimental_constrained_fmul_f32 = "llvm.experimental.constrained.fmul.f32"
    case llvm_experimental_constrained_fmul_f64 = "llvm.experimental.constrained.fmul.f64"
    case llvm_experimental_constrained_fmul_f80 = "llvm.experimental.constrained.fmul.f80"
    case llvm_experimental_constrained_fmul_f128 = "llvm.experimental.constrained.fmul.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_experimental_constrained_fmul_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half, MetadataType(), MetadataType()], returnType: FloatType.half, isVarArg: false)
      case .llvm_experimental_constrained_fmul_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float, MetadataType(), MetadataType()], returnType: FloatType.float, isVarArg: false)
      case .llvm_experimental_constrained_fmul_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double, MetadataType(), MetadataType()], returnType: FloatType.double, isVarArg: false)
      case .llvm_experimental_constrained_fmul_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80, MetadataType(), MetadataType()], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_experimental_constrained_fmul_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128, MetadataType(), MetadataType()], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_experimental_constrained_fmul.llvm_experimental_constrained_fmul_f16,
        int_experimental_constrained_fmul.llvm_experimental_constrained_fmul_f32,
        int_experimental_constrained_fmul.llvm_experimental_constrained_fmul_f64,
        int_experimental_constrained_fmul.llvm_experimental_constrained_fmul_f80,
        int_experimental_constrained_fmul.llvm_experimental_constrained_fmul_f128,
      ]
    }
  }
  public enum int_experimental_constrained_fdiv: String, LLVMOverloadedIntrinsic {
    case llvm_experimental_constrained_fdiv_f16 = "llvm.experimental.constrained.fdiv.f16"
    case llvm_experimental_constrained_fdiv_f32 = "llvm.experimental.constrained.fdiv.f32"
    case llvm_experimental_constrained_fdiv_f64 = "llvm.experimental.constrained.fdiv.f64"
    case llvm_experimental_constrained_fdiv_f80 = "llvm.experimental.constrained.fdiv.f80"
    case llvm_experimental_constrained_fdiv_f128 = "llvm.experimental.constrained.fdiv.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_experimental_constrained_fdiv_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half, MetadataType(), MetadataType()], returnType: FloatType.half, isVarArg: false)
      case .llvm_experimental_constrained_fdiv_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float, MetadataType(), MetadataType()], returnType: FloatType.float, isVarArg: false)
      case .llvm_experimental_constrained_fdiv_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double, MetadataType(), MetadataType()], returnType: FloatType.double, isVarArg: false)
      case .llvm_experimental_constrained_fdiv_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80, MetadataType(), MetadataType()], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_experimental_constrained_fdiv_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128, MetadataType(), MetadataType()], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_experimental_constrained_fdiv.llvm_experimental_constrained_fdiv_f16,
        int_experimental_constrained_fdiv.llvm_experimental_constrained_fdiv_f32,
        int_experimental_constrained_fdiv.llvm_experimental_constrained_fdiv_f64,
        int_experimental_constrained_fdiv.llvm_experimental_constrained_fdiv_f80,
        int_experimental_constrained_fdiv.llvm_experimental_constrained_fdiv_f128,
      ]
    }
  }
  public enum int_experimental_constrained_frem: String, LLVMOverloadedIntrinsic {
    case llvm_experimental_constrained_frem_f16 = "llvm.experimental.constrained.frem.f16"
    case llvm_experimental_constrained_frem_f32 = "llvm.experimental.constrained.frem.f32"
    case llvm_experimental_constrained_frem_f64 = "llvm.experimental.constrained.frem.f64"
    case llvm_experimental_constrained_frem_f80 = "llvm.experimental.constrained.frem.f80"
    case llvm_experimental_constrained_frem_f128 = "llvm.experimental.constrained.frem.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_experimental_constrained_frem_f16: return FunctionType(argTypes: [FloatType.half, FloatType.half, MetadataType(), MetadataType()], returnType: FloatType.half, isVarArg: false)
      case .llvm_experimental_constrained_frem_f32: return FunctionType(argTypes: [FloatType.float, FloatType.float, MetadataType(), MetadataType()], returnType: FloatType.float, isVarArg: false)
      case .llvm_experimental_constrained_frem_f64: return FunctionType(argTypes: [FloatType.double, FloatType.double, MetadataType(), MetadataType()], returnType: FloatType.double, isVarArg: false)
      case .llvm_experimental_constrained_frem_f80: return FunctionType(argTypes: [FloatType.x86FP80, FloatType.x86FP80, MetadataType(), MetadataType()], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_experimental_constrained_frem_f128: return FunctionType(argTypes: [FloatType.ppcFP128, FloatType.ppcFP128, MetadataType(), MetadataType()], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_experimental_constrained_frem.llvm_experimental_constrained_frem_f16,
        int_experimental_constrained_frem.llvm_experimental_constrained_frem_f32,
        int_experimental_constrained_frem.llvm_experimental_constrained_frem_f64,
        int_experimental_constrained_frem.llvm_experimental_constrained_frem_f80,
        int_experimental_constrained_frem.llvm_experimental_constrained_frem_f128,
      ]
    }
  }
  public enum int_expect: String, LLVMOverloadedIntrinsic {
    case llvm_expect_i8 = "llvm.expect.i8"
    case llvm_expect_i16 = "llvm.expect.i16"
    case llvm_expect_i32 = "llvm.expect.i32"
    case llvm_expect_i64 = "llvm.expect.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_expect_i8: return FunctionType(argTypes: [IntType(width: 8), IntType(width: 8)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_expect_i16: return FunctionType(argTypes: [IntType(width: 16), IntType(width: 16)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_expect_i32: return FunctionType(argTypes: [IntType(width: 32), IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_expect_i64: return FunctionType(argTypes: [IntType(width: 64), IntType(width: 64)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_expect.llvm_expect_i8,
        int_expect.llvm_expect_i16,
        int_expect.llvm_expect_i32,
        int_expect.llvm_expect_i64,
      ]
    }
  }
  public enum int_bswap: String, LLVMOverloadedIntrinsic {
    case llvm_bswap_i8 = "llvm.bswap.i8"
    case llvm_bswap_i16 = "llvm.bswap.i16"
    case llvm_bswap_i32 = "llvm.bswap.i32"
    case llvm_bswap_i64 = "llvm.bswap.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_bswap_i8: return FunctionType(argTypes: [IntType(width: 8)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_bswap_i16: return FunctionType(argTypes: [IntType(width: 16)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_bswap_i32: return FunctionType(argTypes: [IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_bswap_i64: return FunctionType(argTypes: [IntType(width: 64)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_bswap.llvm_bswap_i8,
        int_bswap.llvm_bswap_i16,
        int_bswap.llvm_bswap_i32,
        int_bswap.llvm_bswap_i64,
      ]
    }
  }
  public enum int_ctpop: String, LLVMOverloadedIntrinsic {
    case llvm_ctpop_i8 = "llvm.ctpop.i8"
    case llvm_ctpop_i16 = "llvm.ctpop.i16"
    case llvm_ctpop_i32 = "llvm.ctpop.i32"
    case llvm_ctpop_i64 = "llvm.ctpop.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_ctpop_i8: return FunctionType(argTypes: [IntType(width: 8)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_ctpop_i16: return FunctionType(argTypes: [IntType(width: 16)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_ctpop_i32: return FunctionType(argTypes: [IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_ctpop_i64: return FunctionType(argTypes: [IntType(width: 64)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_ctpop.llvm_ctpop_i8,
        int_ctpop.llvm_ctpop_i16,
        int_ctpop.llvm_ctpop_i32,
        int_ctpop.llvm_ctpop_i64,
      ]
    }
  }
  public enum int_ctlz: String, LLVMOverloadedIntrinsic {
    case llvm_ctlz_i8_i1 = "llvm.ctlz.i8.i1"
    case llvm_ctlz_i16_i1 = "llvm.ctlz.i16.i1"
    case llvm_ctlz_i32_i1 = "llvm.ctlz.i32.i1"
    case llvm_ctlz_i64_i1 = "llvm.ctlz.i64.i1"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_ctlz_i8_i1: return FunctionType(argTypes: [IntType(width: 8), IntType(width: 1)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_ctlz_i16_i1: return FunctionType(argTypes: [IntType(width: 16), IntType(width: 1)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_ctlz_i32_i1: return FunctionType(argTypes: [IntType(width: 32), IntType(width: 1)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_ctlz_i64_i1: return FunctionType(argTypes: [IntType(width: 64), IntType(width: 1)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_ctlz.llvm_ctlz_i8_i1,
        int_ctlz.llvm_ctlz_i16_i1,
        int_ctlz.llvm_ctlz_i32_i1,
        int_ctlz.llvm_ctlz_i64_i1,
      ]
    }
  }
  public enum int_cttz: String, LLVMOverloadedIntrinsic {
    case llvm_cttz_i8_i1 = "llvm.cttz.i8.i1"
    case llvm_cttz_i16_i1 = "llvm.cttz.i16.i1"
    case llvm_cttz_i32_i1 = "llvm.cttz.i32.i1"
    case llvm_cttz_i64_i1 = "llvm.cttz.i64.i1"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_cttz_i8_i1: return FunctionType(argTypes: [IntType(width: 8), IntType(width: 1)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_cttz_i16_i1: return FunctionType(argTypes: [IntType(width: 16), IntType(width: 1)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_cttz_i32_i1: return FunctionType(argTypes: [IntType(width: 32), IntType(width: 1)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_cttz_i64_i1: return FunctionType(argTypes: [IntType(width: 64), IntType(width: 1)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_cttz.llvm_cttz_i8_i1,
        int_cttz.llvm_cttz_i16_i1,
        int_cttz.llvm_cttz_i32_i1,
        int_cttz.llvm_cttz_i64_i1,
      ]
    }
  }
  public enum int_bitreverse: String, LLVMOverloadedIntrinsic {
    case llvm_bitreverse_i8 = "llvm.bitreverse.i8"
    case llvm_bitreverse_i16 = "llvm.bitreverse.i16"
    case llvm_bitreverse_i32 = "llvm.bitreverse.i32"
    case llvm_bitreverse_i64 = "llvm.bitreverse.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_bitreverse_i8: return FunctionType(argTypes: [IntType(width: 8)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_bitreverse_i16: return FunctionType(argTypes: [IntType(width: 16)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_bitreverse_i32: return FunctionType(argTypes: [IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_bitreverse_i64: return FunctionType(argTypes: [IntType(width: 64)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_bitreverse.llvm_bitreverse_i8,
        int_bitreverse.llvm_bitreverse_i16,
        int_bitreverse.llvm_bitreverse_i32,
        int_bitreverse.llvm_bitreverse_i64,
      ]
    }
  }
  public enum int_ptr_annotation: String, LLVMOverloadedIntrinsic {
    case llvm_ptr_annotation_p0i8_p0i8_p0i8_i32 = "llvm.ptr.annotation.p0i8.p0i8.p0i8.i32"
    case llvm_ptr_annotation_p0i16_p0i8_p0i8_i32 = "llvm.ptr.annotation.p0i16.p0i8.p0i8.i32"
    case llvm_ptr_annotation_p0i32_p0i8_p0i8_i32 = "llvm.ptr.annotation.p0i32.p0i8.p0i8.i32"
    case llvm_ptr_annotation_p0i64_p0i8_p0i8_i32 = "llvm.ptr.annotation.p0i64.p0i8.p0i8.i32"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_ptr_annotation_p0i8_p0i8_p0i8_i32: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
      case .llvm_ptr_annotation_p0i16_p0i8_p0i8_i32: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 16)), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: PointerType(pointee: IntType(width: 16)), isVarArg: false)
      case .llvm_ptr_annotation_p0i32_p0i8_p0i8_i32: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 32)), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: PointerType(pointee: IntType(width: 32)), isVarArg: false)
      case .llvm_ptr_annotation_p0i64_p0i8_p0i8_i32: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 64)), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: PointerType(pointee: IntType(width: 64)), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_ptr_annotation.llvm_ptr_annotation_p0i8_p0i8_p0i8_i32,
        int_ptr_annotation.llvm_ptr_annotation_p0i16_p0i8_p0i8_i32,
        int_ptr_annotation.llvm_ptr_annotation_p0i32_p0i8_p0i8_i32,
        int_ptr_annotation.llvm_ptr_annotation_p0i64_p0i8_p0i8_i32,
      ]
    }
  }
  public enum int_annotation: String, LLVMOverloadedIntrinsic {
    case llvm_annotation_i8_p0i8_p0i8_i32 = "llvm.annotation.i8.p0i8.p0i8.i32"
    case llvm_annotation_i16_p0i8_p0i8_i32 = "llvm.annotation.i16.p0i8.p0i8.i32"
    case llvm_annotation_i32_p0i8_p0i8_i32 = "llvm.annotation.i32.p0i8.p0i8.i32"
    case llvm_annotation_i64_p0i8_p0i8_i32 = "llvm.annotation.i64.p0i8.p0i8.i32"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_annotation_i8_p0i8_p0i8_i32: return FunctionType(argTypes: [IntType(width: 8), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_annotation_i16_p0i8_p0i8_i32: return FunctionType(argTypes: [IntType(width: 16), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_annotation_i32_p0i8_p0i8_i32: return FunctionType(argTypes: [IntType(width: 32), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_annotation_i64_p0i8_p0i8_i32: return FunctionType(argTypes: [IntType(width: 64), PointerType(pointee: IntType(width: 8)), PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_annotation.llvm_annotation_i8_p0i8_p0i8_i32,
        int_annotation.llvm_annotation_i16_p0i8_p0i8_i32,
        int_annotation.llvm_annotation_i32_p0i8_p0i8_i32,
        int_annotation.llvm_annotation_i64_p0i8_p0i8_i32,
      ]
    }
  }
  public enum int_sadd_with_overflow: String, LLVMOverloadedIntrinsic {
    case llvm_sadd_with_overflow_i8_i1 = "llvm.sadd.with.overflow.i8.i1"
    case llvm_sadd_with_overflow_i16_i1 = "llvm.sadd.with.overflow.i16.i1"
    case llvm_sadd_with_overflow_i32_i1 = "llvm.sadd.with.overflow.i32.i1"
    case llvm_sadd_with_overflow_i64_i1 = "llvm.sadd.with.overflow.i64.i1"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_sadd_with_overflow_i8_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 8), IntType(width: 8)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_sadd_with_overflow_i16_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 16), IntType(width: 16)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_sadd_with_overflow_i32_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 32), IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_sadd_with_overflow_i64_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 64), IntType(width: 64)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_sadd_with_overflow.llvm_sadd_with_overflow_i8_i1,
        int_sadd_with_overflow.llvm_sadd_with_overflow_i16_i1,
        int_sadd_with_overflow.llvm_sadd_with_overflow_i32_i1,
        int_sadd_with_overflow.llvm_sadd_with_overflow_i64_i1,
      ]
    }
  }
  public enum int_uadd_with_overflow: String, LLVMOverloadedIntrinsic {
    case llvm_uadd_with_overflow_i8_i1 = "llvm.uadd.with.overflow.i8.i1"
    case llvm_uadd_with_overflow_i16_i1 = "llvm.uadd.with.overflow.i16.i1"
    case llvm_uadd_with_overflow_i32_i1 = "llvm.uadd.with.overflow.i32.i1"
    case llvm_uadd_with_overflow_i64_i1 = "llvm.uadd.with.overflow.i64.i1"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_uadd_with_overflow_i8_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 8), IntType(width: 8)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_uadd_with_overflow_i16_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 16), IntType(width: 16)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_uadd_with_overflow_i32_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 32), IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_uadd_with_overflow_i64_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 64), IntType(width: 64)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_uadd_with_overflow.llvm_uadd_with_overflow_i8_i1,
        int_uadd_with_overflow.llvm_uadd_with_overflow_i16_i1,
        int_uadd_with_overflow.llvm_uadd_with_overflow_i32_i1,
        int_uadd_with_overflow.llvm_uadd_with_overflow_i64_i1,
      ]
    }
  }
  public enum int_ssub_with_overflow: String, LLVMOverloadedIntrinsic {
    case llvm_ssub_with_overflow_i8_i1 = "llvm.ssub.with.overflow.i8.i1"
    case llvm_ssub_with_overflow_i16_i1 = "llvm.ssub.with.overflow.i16.i1"
    case llvm_ssub_with_overflow_i32_i1 = "llvm.ssub.with.overflow.i32.i1"
    case llvm_ssub_with_overflow_i64_i1 = "llvm.ssub.with.overflow.i64.i1"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_ssub_with_overflow_i8_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 8), IntType(width: 8)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_ssub_with_overflow_i16_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 16), IntType(width: 16)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_ssub_with_overflow_i32_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 32), IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_ssub_with_overflow_i64_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 64), IntType(width: 64)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_ssub_with_overflow.llvm_ssub_with_overflow_i8_i1,
        int_ssub_with_overflow.llvm_ssub_with_overflow_i16_i1,
        int_ssub_with_overflow.llvm_ssub_with_overflow_i32_i1,
        int_ssub_with_overflow.llvm_ssub_with_overflow_i64_i1,
      ]
    }
  }
  public enum int_usub_with_overflow: String, LLVMOverloadedIntrinsic {
    case llvm_usub_with_overflow_i8_i1 = "llvm.usub.with.overflow.i8.i1"
    case llvm_usub_with_overflow_i16_i1 = "llvm.usub.with.overflow.i16.i1"
    case llvm_usub_with_overflow_i32_i1 = "llvm.usub.with.overflow.i32.i1"
    case llvm_usub_with_overflow_i64_i1 = "llvm.usub.with.overflow.i64.i1"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_usub_with_overflow_i8_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 8), IntType(width: 8)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_usub_with_overflow_i16_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 16), IntType(width: 16)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_usub_with_overflow_i32_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 32), IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_usub_with_overflow_i64_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 64), IntType(width: 64)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_usub_with_overflow.llvm_usub_with_overflow_i8_i1,
        int_usub_with_overflow.llvm_usub_with_overflow_i16_i1,
        int_usub_with_overflow.llvm_usub_with_overflow_i32_i1,
        int_usub_with_overflow.llvm_usub_with_overflow_i64_i1,
      ]
    }
  }
  public enum int_smul_with_overflow: String, LLVMOverloadedIntrinsic {
    case llvm_smul_with_overflow_i8_i1 = "llvm.smul.with.overflow.i8.i1"
    case llvm_smul_with_overflow_i16_i1 = "llvm.smul.with.overflow.i16.i1"
    case llvm_smul_with_overflow_i32_i1 = "llvm.smul.with.overflow.i32.i1"
    case llvm_smul_with_overflow_i64_i1 = "llvm.smul.with.overflow.i64.i1"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_smul_with_overflow_i8_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 8), IntType(width: 8)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_smul_with_overflow_i16_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 16), IntType(width: 16)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_smul_with_overflow_i32_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 32), IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_smul_with_overflow_i64_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 64), IntType(width: 64)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_smul_with_overflow.llvm_smul_with_overflow_i8_i1,
        int_smul_with_overflow.llvm_smul_with_overflow_i16_i1,
        int_smul_with_overflow.llvm_smul_with_overflow_i32_i1,
        int_smul_with_overflow.llvm_smul_with_overflow_i64_i1,
      ]
    }
  }
  public enum int_umul_with_overflow: String, LLVMOverloadedIntrinsic {
    case llvm_umul_with_overflow_i8_i1 = "llvm.umul.with.overflow.i8.i1"
    case llvm_umul_with_overflow_i16_i1 = "llvm.umul.with.overflow.i16.i1"
    case llvm_umul_with_overflow_i32_i1 = "llvm.umul.with.overflow.i32.i1"
    case llvm_umul_with_overflow_i64_i1 = "llvm.umul.with.overflow.i64.i1"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_umul_with_overflow_i8_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 8), IntType(width: 8)], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_umul_with_overflow_i16_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 16), IntType(width: 16)], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_umul_with_overflow_i32_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 32), IntType(width: 32)], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_umul_with_overflow_i64_i1: return FunctionType(argTypes: [IntType(width: 1), IntType(width: 64), IntType(width: 64)], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_umul_with_overflow.llvm_umul_with_overflow_i8_i1,
        int_umul_with_overflow.llvm_umul_with_overflow_i16_i1,
        int_umul_with_overflow.llvm_umul_with_overflow_i32_i1,
        int_umul_with_overflow.llvm_umul_with_overflow_i64_i1,
      ]
    }
  }
  public enum int_coro_size: String, LLVMOverloadedIntrinsic {
    case llvm_coro_size_i8 = "llvm.coro.size.i8"
    case llvm_coro_size_i16 = "llvm.coro.size.i16"
    case llvm_coro_size_i32 = "llvm.coro.size.i32"
    case llvm_coro_size_i64 = "llvm.coro.size.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_coro_size_i8: return FunctionType(argTypes: [], returnType: IntType(width: 8), isVarArg: false)
      case .llvm_coro_size_i16: return FunctionType(argTypes: [], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_coro_size_i32: return FunctionType(argTypes: [], returnType: IntType(width: 32), isVarArg: false)
      case .llvm_coro_size_i64: return FunctionType(argTypes: [], returnType: IntType(width: 64), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_coro_size.llvm_coro_size_i8,
        int_coro_size.llvm_coro_size_i16,
        int_coro_size.llvm_coro_size_i32,
        int_coro_size.llvm_coro_size_i64,
      ]
    }
  }
  public enum int_convert_to_fp16: String, LLVMOverloadedIntrinsic {
    case llvm_convert_to_fp16_i16_f16 = "llvm.convert.to.fp16.i16.f16"
    case llvm_convert_to_fp16_i16_f32 = "llvm.convert.to.fp16.i16.f32"
    case llvm_convert_to_fp16_i16_f64 = "llvm.convert.to.fp16.i16.f64"
    case llvm_convert_to_fp16_i16_f80 = "llvm.convert.to.fp16.i16.f80"
    case llvm_convert_to_fp16_i16_f128 = "llvm.convert.to.fp16.i16.f128"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_convert_to_fp16_i16_f16: return FunctionType(argTypes: [FloatType.half], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_convert_to_fp16_i16_f32: return FunctionType(argTypes: [FloatType.float], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_convert_to_fp16_i16_f64: return FunctionType(argTypes: [FloatType.double], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_convert_to_fp16_i16_f80: return FunctionType(argTypes: [FloatType.x86FP80], returnType: IntType(width: 16), isVarArg: false)
      case .llvm_convert_to_fp16_i16_f128: return FunctionType(argTypes: [FloatType.ppcFP128], returnType: IntType(width: 16), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_convert_to_fp16.llvm_convert_to_fp16_i16_f16,
        int_convert_to_fp16.llvm_convert_to_fp16_i16_f32,
        int_convert_to_fp16.llvm_convert_to_fp16_i16_f64,
        int_convert_to_fp16.llvm_convert_to_fp16_i16_f80,
        int_convert_to_fp16.llvm_convert_to_fp16_i16_f128,
      ]
    }
  }
  public enum int_convert_from_fp16: String, LLVMOverloadedIntrinsic {
    case llvm_convert_from_fp16_f16_i16 = "llvm.convert.from.fp16.f16.i16"
    case llvm_convert_from_fp16_f32_i16 = "llvm.convert.from.fp16.f32.i16"
    case llvm_convert_from_fp16_f64_i16 = "llvm.convert.from.fp16.f64.i16"
    case llvm_convert_from_fp16_f80_i16 = "llvm.convert.from.fp16.f80.i16"
    case llvm_convert_from_fp16_f128_i16 = "llvm.convert.from.fp16.f128.i16"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_convert_from_fp16_f16_i16: return FunctionType(argTypes: [IntType(width: 16)], returnType: FloatType.half, isVarArg: false)
      case .llvm_convert_from_fp16_f32_i16: return FunctionType(argTypes: [IntType(width: 16)], returnType: FloatType.float, isVarArg: false)
      case .llvm_convert_from_fp16_f64_i16: return FunctionType(argTypes: [IntType(width: 16)], returnType: FloatType.double, isVarArg: false)
      case .llvm_convert_from_fp16_f80_i16: return FunctionType(argTypes: [IntType(width: 16)], returnType: FloatType.x86FP80, isVarArg: false)
      case .llvm_convert_from_fp16_f128_i16: return FunctionType(argTypes: [IntType(width: 16)], returnType: FloatType.ppcFP128, isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_convert_from_fp16.llvm_convert_from_fp16_f16_i16,
        int_convert_from_fp16.llvm_convert_from_fp16_f32_i16,
        int_convert_from_fp16.llvm_convert_from_fp16_f64_i16,
        int_convert_from_fp16.llvm_convert_from_fp16_f80_i16,
        int_convert_from_fp16.llvm_convert_from_fp16_f128_i16,
      ]
    }
  }
  public enum int_load_relative: String, LLVMOverloadedIntrinsic {
    case llvm_load_relative_p0i8_p0i8_i8 = "llvm.load.relative.p0i8.p0i8.i8"
    case llvm_load_relative_p0i8_p0i8_i16 = "llvm.load.relative.p0i8.p0i8.i16"
    case llvm_load_relative_p0i8_p0i8_i32 = "llvm.load.relative.p0i8.p0i8.i32"
    case llvm_load_relative_p0i8_p0i8_i64 = "llvm.load.relative.p0i8.p0i8.i64"

    public var llvmSelector: String { return self.rawValue }

    public var signature: FunctionType {
      switch self {
      case .llvm_load_relative_p0i8_p0i8_i8: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 8)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
      case .llvm_load_relative_p0i8_p0i8_i16: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 16)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
      case .llvm_load_relative_p0i8_p0i8_i32: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 32)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
      case .llvm_load_relative_p0i8_p0i8_i64: return FunctionType(argTypes: [PointerType(pointee: IntType(width: 8)), IntType(width: 64)], returnType: PointerType(pointee: IntType(width: 8)), isVarArg: false)
      }
    }

    public static var overloadSet: [LLVMIntrinsic] {
      return [
        int_load_relative.llvm_load_relative_p0i8_p0i8_i8,
        int_load_relative.llvm_load_relative_p0i8_p0i8_i16,
        int_load_relative.llvm_load_relative_p0i8_p0i8_i32,
        int_load_relative.llvm_load_relative_p0i8_p0i8_i64,
      ]
    }
  }

}

