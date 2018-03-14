#if SWIFT_PACKAGE
import cllvm
#endif

public protocol Metadata {
  func asMetadata() -> LLVMMetadataRef
}

struct AnyMetadata: Metadata {
  let llvm: LLVMMetadataRef

  func asMetadata() -> LLVMMetadataRef {
    return llvm
  }
}

public struct VariableMetadata: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }
}

public struct FileMetadata: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }
}

public struct Scope: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }
}

public struct Macro: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }
}

public struct DIModule: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }
}

public struct DIExpression: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }
}


public struct DebugLocation: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }
}
