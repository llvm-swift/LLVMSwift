import cllvm

/// `Linkage` enumerates the supported kinds of linkage for global values.  All
/// global variables and functions have a linkage.
public enum Linkage {
  /// Externally visible function.  This is the default linkage.
  ///
  /// If none of the other linkages are specified, the global is externally
  /// visible, meaning that it participates in linkage and can be used to 
  /// resolve external symbol references.
  case external
  /// Available for inspection, not emission.
  ///
  /// Globals with "available_externally" linkage are never emitted into the 
  /// object file corresponding to the LLVM module. From the linker’s 
  /// perspective, an available_externally global is equivalent to an external 
  /// declaration. They exist to allow inlining and other optimizations to take 
  /// place given knowledge of the definition of the global, which is known to 
  /// be somewhere outside the module. Globals with available_externally linkage
  /// are allowed to be discarded at will, and allow inlining and other 
  /// optimizations. This linkage type is only allowed on definitions, not 
  /// declarations.
  case availableExternally
  /// Keep one copy of function when linking.
  /// 
  /// Globals with "linkonce" linkage are merged with other globals of the same 
  /// name when linkage occurs. This can be used to implement some forms of 
  /// inline functions, templates, or other code which must be generated in each
  /// translation unit that uses it, but where the body may be overridden with a
  /// more definitive definition later. Unreferenced linkonce globals are 
  /// allowed to be discarded. Note that linkonce linkage does not actually 
  /// allow the optimizer to inline the body of this function into callers 
  /// because it doesn’t know if this definition of the function is the 
  /// definitive definition within the program or whether it will be overridden 
  /// by a stronger definition.
  case linkOnceAny
  /// Keep one copy of function when linking but enable inlining and
  /// other optimizations.
  ///
  /// Some languages allow differing globals to be merged, such as two functions
  /// with different semantics. Other languages, such as C++, ensure that only
  /// equivalent globals are ever merged (the "one definition rule" — "ODR").
  /// Such languages can use the linkonce_odr and weak_odr linkage types to
  /// indicate that the global will only be merged with equivalent globals.
  /// These linkage types are otherwise the same as their non-odr versions.
  case linkOnceODR
  /// Keep one copy of function when linking (weak).
  ///
  /// "weak" linkage has the same merging semantics as linkonce linkage, except
  /// that unreferenced globals with weak linkage may not be discarded. This is
  /// used for globals that are declared "weak" in C source code.
  case weakAny
  /// Keep one copy of function when linking but apply "One Definition Rule"
  /// semantics.
  ///
  /// Some languages allow differing globals to be merged, such as two functions
  /// with different semantics. Other languages, such as C++, ensure that only 
  /// equivalent globals are ever merged (the "one definition rule" — "ODR"). 
  /// Such languages can use the linkonce_odr and weak_odr linkage types to 
  /// indicate that the global will only be merged with equivalent globals. 
  /// These linkage types are otherwise the same as their non-odr versions.
  case weakODR
  /// Special purpose, only applies to global arrays.
  ///
  /// "appending" linkage may only be applied to global variables of pointer to 
  /// array type. When two global variables with appending linkage are linked 
  /// together, the two global arrays are appended together. This is the LLVM, 
  /// typesafe, equivalent of having the system linker append together 
  /// "sections" with identical names when .o files are linked.
  ///
  /// Unfortunately this doesn’t correspond to any feature in .o files, so it 
  /// can only be used for variables like llvm.global_ctors which llvm 
  /// interprets specially.
  case appending
  /// Rename collisions when linking (static functions).
  ///
  /// Similar to private, but the value shows as a local symbol 
  /// (`STB_LOCAL` in the case of ELF) in the object file. This corresponds to 
  /// the notion of the `static` keyword in C.
  case `internal`
  /// Like `.internal`, but omit from symbol table.
  ///
  /// Global values with "private" linkage are only directly accessible by 
  /// objects in the current module. In particular, linking code into a module
  /// with an private global value may cause the private to be renamed as 
  /// necessary to avoid collisions. Because the symbol is private to the 
  /// module, all references can be updated. This doesn’t show up in any symbol
  /// table in the object file.
  case `private`
  /// Keep one copy of the function when linking, but apply ELF semantics.
  ///
  /// The semantics of this linkage follow the ELF object file model: the symbol
  /// is weak until linked, if not linked, the symbol becomes null instead of 
  /// being an undefined reference.
  case externalWeak
  /// Tentative definitions.
  ///
  /// "common" linkage is most similar to "weak" linkage, but they are used for
  /// tentative definitions in C, such as "int X;" at global scope. Symbols with
  /// "common" linkage are merged in the same way as weak symbols, and they may 
  /// not be deleted if unreferenced. common symbols may not have an explicit 
  /// section, must have a zero initializer, and may not be marked ‘constant‘. 
  /// Functions and aliases may not have common linkage.
  case common

  private static let linkageMapping: [Linkage: LLVMLinkage] = [
    .external: LLVMExternalLinkage,
    .availableExternally: LLVMAvailableExternallyLinkage,
    .linkOnceAny: LLVMLinkOnceAnyLinkage, .linkOnceODR: LLVMLinkOnceODRLinkage,
    .weakAny: LLVMWeakAnyLinkage, .weakODR: LLVMWeakODRLinkage,
    .appending: LLVMAppendingLinkage, .`internal`: LLVMInternalLinkage,
    .`private`: LLVMPrivateLinkage, .externalWeak: LLVMExternalWeakLinkage,
    .common: LLVMCommonLinkage,
  ]

  internal init(llvm: LLVMLinkage) {
    switch llvm {
    case LLVMExternalLinkage: self = .external
    case LLVMAvailableExternallyLinkage: self = .availableExternally
    case LLVMLinkOnceAnyLinkage: self = .linkOnceAny
    case LLVMLinkOnceODRLinkage: self = .linkOnceODR
    case LLVMWeakAnyLinkage: self = .weakAny
    case LLVMWeakODRLinkage: self = .weakODR
    case LLVMAppendingLinkage: self = .appending   
    case LLVMInternalLinkage: self = .internal
    case LLVMPrivateLinkage: self = .private
    case LLVMExternalWeakLinkage: self = .externalWeak
    case LLVMCommonLinkage: self = .common
    default: fatalError("unknown linkage type \(llvm)")
    }
  }

  /// Retrieves the corresponding `LLVMLinkage`.
  public var llvm: LLVMLinkage {
    return Linkage.linkageMapping[self]!
  }
}

/// A `Global` represents a region of memory allocated at compile time instead
/// of at runtime.  A global variable must either have an initializer, or make
/// reference to an external definition that has an initializer.
public struct Global: IRValue {
  internal let llvm: LLVMValueRef

  /// Returns whether this global variable has no initializer because it makes
  /// reference to an initialized value in another translation unit.
  public var isExternallyInitialized: Bool {
    get { return LLVMIsExternallyInitialized(llvm) != 0 }
    set { LLVMSetExternallyInitialized(llvm, newValue.llvm) }
  }

  /// Retrieves the initializer for this global variable, if it exists.
  public var initializer: IRValue? {
    get { return LLVMGetInitializer(asLLVM()) }
    set { LLVMSetInitializer(asLLVM(), newValue!.asLLVM()) }
  }

  /// Returns whether this global variable is a constant, whether or not the
  /// final definition of the global is not.
  public var isGlobalConstant: Bool {
    get { return LLVMIsGlobalConstant(asLLVM()) != 0 }
    set { LLVMSetGlobalConstant(asLLVM(), newValue.llvm) }
  }

  /// Returns whether this global variable is thread-local.  That is, returns
  /// if this variable is not shared by multiple threads.
  public var isThreadLocal: Bool {
    get { return LLVMIsThreadLocal(asLLVM()) != 0 }
    set { LLVMSetThreadLocal(asLLVM(), newValue.llvm) }
  }

  /// Retrieves the linkage information for this global value.
  public var linkage: Linkage {
    get { return Linkage(llvm: LLVMGetLinkage(asLLVM())) }
    set { LLVMSetLinkage(asLLVM(), newValue.llvm) }
  }

  /// Deletes the global variable from its containing module.
  /// - note: This does not remove references to this global from the
  ///         module. Ensure you have removed all insructions that reference
  ///         this global before deleting it.
  public func delete() {
    LLVMDeleteGlobal(llvm)
  }

  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}
