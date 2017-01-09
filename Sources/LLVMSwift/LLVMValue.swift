import cllvm

public protocol IRValue {
  func asLLVM() -> LLVMValueRef
}

public extension IRValue {
  public var type: IRType {
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

  public func constGEP(indices: [IRValue]) -> IRValue {
    var idxs = indices.map { $0.asLLVM() as Optional }
    return idxs.withUnsafeMutableBufferPointer { buf in
      return LLVMConstGEP(asLLVM(), buf.baseAddress, UInt32(buf.count))
    }
  }

  public func replaceAllUses(with value: IRValue) {
    LLVMReplaceAllUsesWith(asLLVM(), value.asLLVM())
  }

  public func dump() {
    LLVMDumpValue(asLLVM())
  }
}

extension LLVMValueRef: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return self
  }
}

extension Int: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int>.size * 8).constant(self).asLLVM()
  }
}

extension Int8: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int8>.size * 8).constant(self).asLLVM()
  }
}

extension Int16: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int16>.size * 8).constant(self).asLLVM()
  }
}

extension Int32: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int32>.size * 8).constant(self).asLLVM()
  }
}

extension Int64: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int64>.size * 8).constant(self).asLLVM()
  }
}

extension UInt: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt>.size * 8).constant(self).asLLVM()
  }
}

extension UInt8: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt8>.size * 8).constant(self).asLLVM()
  }
}

extension UInt16: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt16>.size * 8).constant(self).asLLVM()
  }
}

extension UInt32: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt32>.size * 8).constant(self).asLLVM()
  }
}

extension UInt64: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt64>.size * 8).constant(self).asLLVM()
  }
}

extension Bool: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: 1).constant(self ? 1 : 0).asLLVM()
  }
}

extension String: IRValue {
  public func asLLVM() -> LLVMValueRef {
    return LLVMConstString(self, UInt32(self.utf8.count), 0)
  }
}
