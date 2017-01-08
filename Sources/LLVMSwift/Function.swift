import cllvm

public enum Attribute {
  case zExt, sExt, noReturn, inReg, structRet, noUnwind, noAlias
  case byVal, nest, readOnly, noInline, alwaysInline, optimizeForSize
  case stackProtect, stackProtectReq, alignment, noCapture, noRedZone
  case noImplicitFloat, naked, inlineHint, stackAlignment, returnsTwice
  case uwTable, nonLazyBind
  
  /* FIXME: These attributes are currently not included in the C API as
   a temporary measure until the API/ABI impact to the C API is understood
   and the path forward agreed upon.
   case sanitizeAddress, stackProtectStrong, cold, optimizeNone, inAlloca
   case nonNull, jumpTable, convergent, safeStack, swiftSelf, swiftError
   */
  
  private static let mapping: [Attribute: LLVMAttribute] = [
    .zExt: LLVMZExtAttribute, .sExt: LLVMSExtAttribute, .noReturn: LLVMNoReturnAttribute,
    .inReg: LLVMInRegAttribute, .structRet: LLVMStructRetAttribute, .noUnwind: LLVMNoUnwindAttribute,
    .noAlias: LLVMNoAliasAttribute, .byVal: LLVMByValAttribute, .nest: LLVMNestAttribute,
    .readOnly: LLVMReadOnlyAttribute, .noInline: LLVMNoInlineAttribute, .alwaysInline: LLVMAlwaysInlineAttribute,
    .optimizeForSize: LLVMOptimizeForSizeAttribute, .stackProtect: LLVMStackProtectAttribute,
    .stackProtectReq: LLVMStackProtectReqAttribute, .alignment: LLVMAlignment,
    .noCapture: LLVMNoCaptureAttribute, .noRedZone: LLVMNoRedZoneAttribute,
    .noImplicitFloat: LLVMNoImplicitFloatAttribute, .naked: LLVMNakedAttribute,
    .inlineHint: LLVMInlineHintAttribute, .stackAlignment: LLVMStackAlignment,
    .returnsTwice: LLVMReturnsTwice, .uwTable: LLVMUWTable, .nonLazyBind: LLVMNonLazyBind
  ]
  
  public func asLLVM() -> LLVMAttribute {
    return Attribute.mapping[self]!
  }
}

public class Function: LLVMValue {
  internal let llvm: LLVMValueRef
  internal init(llvm: LLVMValueRef) {
    self.llvm = llvm
  }
  
  public var entryBlock: BasicBlock? {
    guard let blockRef = LLVMGetEntryBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }
  
  public var firstBlock: BasicBlock? {
    guard let blockRef = LLVMGetFirstBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }
  
  public var lastBlock: BasicBlock? {
    guard let blockRef = LLVMGetLastBasicBlock(llvm) else { return nil }
    return BasicBlock(llvm: blockRef)
  }
  
  public var basicBlocks: [BasicBlock] {
    var blocks = [BasicBlock]()
    var current = firstBlock
    while let block = current {
      blocks.append(block)
      current = block.next()
    }
    return blocks
  }
  
  public func parameter(at index: Int) -> Parameter? {
    guard let value = LLVMGetParam(llvm, UInt32(index)) else { return nil }
    return Parameter(llvm: value)
  }
  
  public var firstParameter: Parameter? {
    guard let value = LLVMGetFirstParam(llvm) else { return nil }
    return Parameter(llvm: value)
  }
  
  public var lastParameter: Parameter? {
    guard let value = LLVMGetLastParam(llvm) else { return nil }
    return Parameter(llvm: value)
  }
  
  public var parameters: [LLVMValue] {
    var current = firstParameter
    var params = [Parameter]()
    while let param = current {
      params.append(param)
      current = param.next()
    }
    return params
  }
  
  public func appendBasicBlock(named name: String, in context: Context? = nil) -> BasicBlock {
    let block: LLVMBasicBlockRef
    if let context = context {
      block = LLVMAppendBasicBlockInContext(context.llvm, llvm, name)
    } else {
      block = LLVMAppendBasicBlock(llvm, name)
    }
    return BasicBlock(llvm: block)
  }
  
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}

public struct Parameter: LLVMValue {
  internal let llvm: LLVMValueRef
  
  func addAttribute(_ attr: Attribute) {
    LLVMAddAttribute(asLLVM(), attr.asLLVM())
  }
  
  func removeAttribute(_ attr: Attribute) {
    LLVMRemoveAttribute(asLLVM(), attr.asLLVM())
  }
  
  public func next() -> Parameter? {
    guard let param = LLVMGetNextParam(llvm) else { return nil }
    return Parameter(llvm: param)
  }
  
  public func previous() -> Parameter? {
    guard let param = LLVMGetPreviousParam(llvm) else { return nil }
    return Parameter(llvm: param)
  }
  
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}
