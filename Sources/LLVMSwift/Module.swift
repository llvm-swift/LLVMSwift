import cllvm

public class Context {
  internal let llvm: LLVMContextRef
  public static let global = Context(llvm: LLVMGetGlobalContext()!)
  public init(llvm: LLVMContextRef) {
    self.llvm = llvm
  }
}

public enum ModuleError: Error, CustomStringConvertible {
  case didNotPassVerification(String)
  case couldNotPrint(path: String, error: String)
  case couldNotEmitBitCode(path: String)
  
  public var description: String {
    switch self {
    case .didNotPassVerification(let message):
      return "module did not pass verification: \(message)"
    case .couldNotPrint(let path, let error):
      return "could not print to file \(path): \(error)"
    case .couldNotEmitBitCode(let path):
      return "could not emit bitcode to file \(path) for an unknown reason"
    }
  }
}

public final class Module {
  internal let llvm: LLVMModuleRef
  public init(name: String, context: Context? = nil) {
    if let context = context {
      llvm = LLVMModuleCreateWithNameInContext(name, context.llvm)
      self.context = context
    } else {
      llvm = LLVMModuleCreateWithName(name)
      self.context = Context(llvm: LLVMGetModuleContext(llvm)!)
    }
  }
  
  public let context: Context
  
  public var dataLayout: TargetData {
    return TargetData(llvm: LLVMGetModuleDataLayout(llvm))
  }
  
  public func print(to path: String) throws {
    var err: UnsafeMutablePointer<Int8>?
    path.withCString { cString in
      let mutable = strdup(cString)
      LLVMPrintModuleToFile(llvm, mutable, &err)
      free(mutable)
    }
    if let err = err {
      defer { LLVMDisposeMessage(err) }
      throw ModuleError.couldNotPrint(path: path, error: String(cString: err))
    }
  }
  
  public func emitBitCode(to path: String) throws {
    let status = path.withCString { cString -> Int32 in
      let mutable = strdup(cString)
      defer { free(mutable) }
      return LLVMWriteBitcodeToFile(llvm, mutable)
    }
    
    if status != 0 {
      throw ModuleError.couldNotEmitBitCode(path: path)
    }
  }
  
  public func type(named name: String) -> IRType? {
    guard let type = LLVMGetTypeByName(llvm, name) else { return nil }
    return convertType(type)
  }
  
  public func function(named name: String) -> Function? {
    guard let fn = LLVMGetNamedFunction(llvm, name) else { return nil }
    return Function(llvm: fn)
  }
  
  public func verify() throws {
    var message: UnsafeMutablePointer<Int8>?
    let status = Int(LLVMVerifyModule(llvm, LLVMReturnStatusAction, &message))
    if let message = message, status == 1 {
      defer { LLVMDisposeMessage(message) }
      throw ModuleError.didNotPassVerification(String(cString: message))
    }
  }
  
  public func dump() {
    LLVMDumpModule(llvm)
  }
}

extension Bool {
  internal var llvm: LLVMBool {
    return self ? 1 : 0
  }
}
