#if SWIFT_PACKAGE
import cllvm
#endif

/// An `IRValue` is a type that is capable of lowering itself to an
/// `LLVMValueRef` object for use with LLVM's C API.
public protocol IRValue {
  /// Retrieves the underlying LLVM value object.
  func asLLVM() -> LLVMValueRef
}

public extension IRValue {
  /// Retrieves the type of this value.
  public var type: IRType {
    return convertType(LLVMTypeOf(asLLVM()))
  }

  /// Returns whether this value is a constant.
  public var isConstant: Bool {
    return LLVMIsConstant(asLLVM()) != 0
  }

  /// Returns whether this value has been initialized with the special `undef`
  /// value.
  ///
  /// The `undef` value can be used anywhere a constant is expected, and
  /// indicates that the user of the value may receive an unspecified
  /// bit-pattern.
  public var isUndef: Bool {
    return LLVMIsUndef(asLLVM()) != 0
  }

  /// Gets and sets the name for this value.
  public var name: String {
    get {
      let ptr = LLVMGetValueName(asLLVM())!
      return String(cString: ptr)
    }
    set {
      LLVMSetValueName(asLLVM(), newValue)
    }
  }

  /// Perform a GEP (Get Element Pointer) with this value as the base.
  ///
  /// - parameter indices: A list of indices that indicate which of the elements
  ///   of the aggregate object are indexed.
  ///
  /// - returns: A value representing the address of a subelement of the given
  ///   aggregate data structure value.
  public func constGEP(indices: [IRValue]) -> IRValue {
    var idxs = indices.map { $0.asLLVM() as Optional }
    return idxs.withUnsafeMutableBufferPointer { buf in
      return LLVMConstGEP(asLLVM(), buf.baseAddress, UInt32(buf.count))
    }
  }

  /// Replaces all uses of this value with the specified value.
  ///
  /// - parameter value: The new value to swap in.
  public func replaceAllUses(with value: IRValue) {
    LLVMReplaceAllUsesWith(asLLVM(), value.asLLVM())
  }

  /// Dumps a representation of this value to stderr.
  public func dump() {
    LLVMDumpValue(asLLVM())
  }
}

extension LLVMValueRef: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return self
  }
}

extension Int: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int>.size * 8).constant(self).asLLVM()
  }
}

extension Int8: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int8>.size * 8).constant(self).asLLVM()
  }
}

extension Int16: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int16>.size * 8).constant(self).asLLVM()
  }
}

extension Int32: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int32>.size * 8).constant(self).asLLVM()
  }
}

extension Int64: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<Int64>.size * 8).constant(self).asLLVM()
  }
}

extension UInt: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt>.size * 8).constant(self).asLLVM()
  }
}

extension UInt8: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt8>.size * 8).constant(self).asLLVM()
  }
}

extension UInt16: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt16>.size * 8).constant(self).asLLVM()
  }
}

extension UInt32: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt32>.size * 8).constant(self).asLLVM()
  }
}

extension UInt64: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: MemoryLayout<UInt64>.size * 8).constant(self).asLLVM()
  }
}

extension Bool: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return IntType(width: 1).constant(self ? 1 : 0).asLLVM()
  }
}

extension String: IRValue {
  /// Retrieves the underlying LLVM value object.
  public func asLLVM() -> LLVMValueRef {
    return LLVMConstString(self, UInt32(self.utf8.count), 0)
  }
}
