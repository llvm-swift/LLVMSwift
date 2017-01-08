import cllvm

public protocol LLVMValue {
  func asLLVM() -> LLVMValueRef
}

public extension LLVMValue {
  public var type: LLVMType {
    return convertType(LLVMTypeOf(asLLVM()))
  }
  
  public var alignment: Int {
    get { return Int(LLVMGetAlignment(asLLVM())) }
    set { LLVMSetAlignment(asLLVM(), UInt32(newValue)) }
  }
  
  public var isConstant: Bool {
    return LLVMIsConstant(asLLVM()) != 0
  }
  
  public var isUndef: Bool {
    return LLVMIsUndef(asLLVM()) != 0
  }
  
  public var name: String {
    get {
      let ptr = LLVMGetValueName(asLLVM())!
      return String(cString: ptr)
    }
    set {
      LLVMSetValueName(asLLVM(), newValue)
    }
  }
  
  public func constGEP(indices: [LLVMValue]) -> LLVMValue {
    var idxs = indices.map { $0.asLLVM() as Optional }
    return idxs.withUnsafeMutableBufferPointer { buf in
      return LLVMConstGEP(asLLVM(), buf.baseAddress, UInt32(buf.count))
    }
  }
  
  public func replaceAllUses(with value: LLVMValue) {
    LLVMReplaceAllUsesWith(asLLVM(), value.asLLVM())
  }
  
  public func dump() {
    LLVMDumpValue(asLLVM())
  }
}

extension LLVMValueRef: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return self
  }
}

extension Int: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int>.size * 8).constant(self)
  }
}

extension Int8: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int8>.size * 8).constant(self)
  }
}

extension Int16: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int16>.size * 8).constant(self)
  }
}

extension Int32: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int32>.size * 8).constant(self)
  }
}

extension Int64: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int64>.size * 8).constant(self)
  }
}

extension UInt: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt>.size * 8).constant(self)
  }
}

extension UInt8: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt8>.size * 8).constant(self)
  }
}

extension UInt16: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt16>.size * 8).constant(self)
  }
}

extension UInt32: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt32>.size * 8).constant(self)
  }
}

extension UInt64: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt64>.size * 8).constant(self)
  }
}

extension Bool: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: 1).constant(self ? 1 : 0)
  }
}

extension String: LLVMValue {
  public func asLLVM() -> LLVMValueRef {
    return LLVMConstString(self, UInt32(self.utf8.count), 0)
  }
}
