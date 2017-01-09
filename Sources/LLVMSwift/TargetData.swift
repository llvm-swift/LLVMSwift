import cllvm

public enum CodegenFileType {
    case object, assembly, bitCode
    
    public func asLLVM() -> LLVMCodeGenFileType {
        switch self {
        case .object: return LLVMObjectFile
        case .assembly: return LLVMAssemblyFile
        case .bitCode: fatalError("not handled here")
        }
    }
}

public enum TargetMachineError: Error, CustomStringConvertible {
    case couldNotEmit(String)
    case couldNotEmitBitCode
    case invalidTriple(String)
    case couldNotCreateTarget(String, String)
    
    public var description: String {
        switch self {
        case .couldNotCreateTarget(let triple, let message):
            return "could not create target for '\(triple)': \(message)"
        case .invalidTriple(let target):
            return "invalid target triple '\(target)'"
        case .couldNotEmit(let message):
            return "could not emit object file: \(message)"
        case .couldNotEmitBitCode:
            return "could not emit bitcode for an unknown reason"
        }
    }
}

public class Target {
    internal let llvm: LLVMTargetRef
    public init(llvm: LLVMTargetRef) {
        self.llvm = llvm
    }
}

public class TargetMachine {
    internal let llvm: LLVMTargetMachineRef
    public  let target: Target
    public let dataLayout: TargetData
    public let triple: String
    public init(triple: String? = nil, cpu: String = "", features: String = "",
         optLevel: CodeGenOptLevel = .default, relocMode: RelocMode = .default,
         codeModel: CodeModel = .default) throws {
        self.triple = triple ?? String(cString: LLVMGetDefaultTargetTriple()!)
        var target: LLVMTargetRef?
        var error: UnsafeMutablePointer<Int8>? = nil
        LLVMGetTargetFromTriple(self.triple, &target, &error)
        if let error = error {
            defer { LLVMDisposeMessage(error) }
            throw TargetMachineError.couldNotCreateTarget(self.triple,
                                                          String(cString: error))
        }
        self.target = Target(llvm: target!)
        self.llvm = LLVMCreateTargetMachine(target!, self.triple, cpu, features,
                                            optLevel.asLLVM(),
                                            relocMode.asLLVM(),
                                            codeModel.asLLVM())
        self.dataLayout = TargetData(llvm: LLVMCreateTargetDataLayout(self.llvm))
    }
    
    public func emitToFile(module: Module, type: CodegenFileType, path: String) throws {
        if case .bitCode = type {
            if LLVMWriteBitcodeToFile(module.llvm, path) != 0 {
                throw TargetMachineError.couldNotEmitBitCode
            }
            return
        }
        var err: UnsafeMutablePointer<Int8>?
        let status = path.withCString { cStr -> LLVMBool in
            var mutable = strdup(cStr)
            defer { free(mutable) }
            return LLVMTargetMachineEmitToFile(llvm, module.llvm, mutable, type.asLLVM(), &err)
        }
        if let err = err, status != 0 {
            defer { LLVMDisposeMessage(err) }
            throw TargetMachineError.couldNotEmit(String(cString: err))
        }
    }
}

public struct TargetData {
    internal let llvm: LLVMTargetDataRef
    public init(llvm: LLVMTargetDataRef) {
        self.llvm = llvm
    }
    public func offsetOfElement(_ element: Int, type: StructType) -> Int {
        return Int(LLVMOffsetOfElement(llvm, type.asLLVM(), UInt32(element)))
    }
    public func sizeOfTypeInBits(_ type: IRType) -> Int {
        return Int(LLVMSizeOfTypeInBits(llvm, type.asLLVM()))
    }
}

public enum CodeGenOptLevel {
    case none, less, `default`, aggressive
    
    public func asLLVM() -> LLVMCodeGenOptLevel {
        switch self {
        case .none: return LLVMCodeGenLevelNone
        case .less: return LLVMCodeGenLevelLess
        case .default: return LLVMCodeGenLevelDefault
        case .aggressive: return LLVMCodeGenLevelAggressive
        }
    }
}

public enum RelocMode {
    case `default`, `static`, pic, dynamicNoPIC
    
    public func asLLVM() -> LLVMRelocMode {
        switch self {
        case .default: return LLVMRelocDefault
        case .static: return LLVMRelocStatic
        case .pic: return LLVMRelocPIC
        case .dynamicNoPIC: return LLVMRelocDynamicNoPic
        }
    }
}

public enum CodeModel {
    case `default`, jitDefault, small, kernel, medium, large
    
    public func asLLVM() -> LLVMCodeModel {
        switch self {
        case .default: return LLVMCodeModelDefault
        case .jitDefault: return LLVMCodeModelJITDefault
        case .small: return LLVMCodeModelSmall
        case .kernel: return LLVMCodeModelKernel
        case .medium: return LLVMCodeModelMedium
        case .large: return LLVMCodeModelLarge
        }
    }
}
