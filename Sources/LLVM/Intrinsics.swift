#if !NO_SWIFTPM
import cllvm
#endif

/// The `LLVMIntrinsic` protocol represents types that act as selectors for
/// intrinsic functions.
///
/// LLVM supports the notion of an “intrinsic function”. These functions have
/// well known names and semantics and are required to follow certain
/// restrictions. Overall, these intrinsics represent an extension mechanism for
/// the LLVM language that does not require changing all of the transformations
/// in LLVM when adding to the language.
///
/// Intrinsic function names all start with an "llvm." prefix. This prefix is
/// reserved in LLVM for intrinsic names; thus, function names may not begin
/// with this prefix. Intrinsic functions must always be external functions:
/// you cannot define the body of intrinsic functions. Intrinsic functions may
/// only be used in call or invoke instructions: it is illegal to take the
/// address of an intrinsic function.
public protocol LLVMIntrinsic {
  var signature: FunctionType { get }
  var llvmSelector: String { get }
}

/// The `LLVMOverloadedIntrinsic` protocol represents types that act as
/// selectors for a family of overloaded intrinsic functions.
///
/// Some intrinsic functions can be overloaded, i.e., the intrinsic represents a
/// family of functions that perform the same operation but on different data
/// types. Because LLVM can represent over 8 million different integer types,
/// overloading is used commonly to allow an intrinsic function to operate on
/// any integer type. One or more of the argument types or the result type can
/// be overloaded to accept any integer type. Argument types may also be defined
/// as exactly matching a previous argument’s type or the result type. This
/// allows an intrinsic function which accepts multiple arguments, but needs all
/// of them to be of the same type, to only be overloaded with respect to a
/// single argument or the result.
///
/// Overloaded intrinsics will have the names of its overloaded argument types
/// encoded into its function name, each preceded by a period. Only those types
/// which are overloaded result in a name suffix. Arguments whose type is
/// matched against another type do not. For example, the llvm.ctpop function
/// can take an integer of any width and returns an integer of exactly the same
/// integer width. This leads to a family of functions such as
/// `i8 @llvm.ctpop.i8(i8 %val)` and i29 `@llvm.ctpop.i29(i29 %val)`. Only one
/// type, the return type, is overloaded, and only one type suffix is required.
/// Because the argument’s type is matched against the return type, it does not
/// require its own name suffix.
public protocol LLVMOverloadedIntrinsic: LLVMIntrinsic {
  static var overloadSet: [LLVMIntrinsic] { get }
}

extension IRBuilder {
  /// Builds a call to an intrinsic function.
  ///
  /// - note: In debug builds this function type checks its arguments to ensure
  ///         calls are well-formed.  In release builds no such checking will
  ///         occur and all calls to intrinsics with mismatched arguments will
  ///         result in undefined behavior.
  ///
  /// - Parameters:
  ///   - intr: The selector for the intrinsic to be invoked.
  ///   - returnType: A suggested return type for overloaded intrinsics.  By
  ///     default, the framework will infer a type and attempt to match the
  ///     right intrinsic function.
  ///   - args: The arguments to the intrinsic function.
  /// - Returns: A value representing the result of calling the intrinsic
  ///   function.
  public func buildIntrinsicCall<I: LLVMIntrinsic>(to intr: I, returnType: IRType? = nil, args: IRValue...) -> IRValue {
    assert(typeCheckArguments(to: intr, args: args))

    return self.buildCall(self.buildIntrinsic(self.resolveIntrinsic(intr, args, returnType)), args: args)
  }

  
  /// Builds a call to one of a family of overloaded intrinsic functions.
  ///
  /// - note: The type of the arguments ultimately determines the selector for
  ///         the intrinsic that is called.  Failure of the arguments to
  ///         correspond to any of the overloads is a fatal condition.
  ///
  /// - Parameters:
  ///   - intr: The selector for the overloaded intrinsic to be resolved and
  ///     invoked.
  ///   - returnType: A suggested return type for overloaded intrinsics.  By
  ///     default, the framework will infer a type and attempt to match the
  ///     right intrinsic function.
  ///   - args: The arguments to the intrinsic function.
  /// - Returns: A value representing the result of calling the intrinsic
  ///   function.
  public func buildIntrinsicCall<I: LLVMOverloadedIntrinsic>(to intr: I.Type, returnType: IRType? = nil, args: IRValue...) -> IRValue  {
    guard let intr = resolveOverloadedArguments(to: intr, args: args) else {
      fatalError("Unable to resolve overload among \(I.overloadSet.map{$0.llvmSelector})")
    }
    return self.buildCall(self.buildIntrinsic(self.resolveIntrinsic(intr, args, returnType)), args: args)
  }

  private func resolveIntrinsic(_ i: LLVMIntrinsic, _ args: [IRValue], _ returnTy: IRType?) -> LLVMIntrinsic {
    let fnArgTypes = i.signature.argTypes

    func typeNameForType(_ type: IRType) -> String {
      if let iTy = type as? IntType {
        return "i\(iTy.width)"
      } else if let fTy = type as? FloatType {
        switch fTy.kind {
        case .half:
          return "f16"
        case .float:
          return "f32"
        case .double:
          return "f64"
        case .x86FP80:
          return "f80"
        case .fp128:
          return "f128"
        case .ppcFP128:
          return "ppcf128"
        }
      } else if let pTy = type as? PointerType {
        return "p0" + typeNameForType(pTy.pointee)
      } else if let vTy = type as? VectorType {
        return "v\(vTy.count)" + typeNameForType(vTy.elementType)
      }
      fatalError()
    }

    var argTypes = [IRType]()
    var sigName = i.llvmSelector
    for t in zip(fnArgTypes, args) {
      guard t.0 is IntrinsicSubstitutionMarker else {
        argTypes.append(t.0)
        continue
      }
      argTypes.append(t.1.type)
      sigName += "." + typeNameForType(t.1.type)
    }

    let retTy: IRType
    if i.signature.returnType is IntrinsicSubstitutionMarker {
      // HACK: Sometimes the return type is generic.  This is nice for people that
      // are writing textual IR and know their types ahead of time, but we have
      // no such luck.  All of the intrinsics seems to be predicated on the idea
      // that the first substitution we perform matches the desired return type.
      guard let potentialRetTy = returnTy ?? argTypes.first else {
        fatalError("Unable to disambiguate return type for overloaded intrinsic \(i.llvmSelector); provide one explicitly.")
      }
      retTy = potentialRetTy
    } else {
      retTy = i.signature.returnType
    }
    return ResolvedIntrinsic(signature: FunctionType(argTypes: argTypes, returnType: retTy), llvmSelector: sigName)
  }

  private func buildIntrinsic(_ i: LLVMIntrinsic) -> Function  {
    if let f = self.module.function(named: i.llvmSelector) {
      return f
    }
    var f = self.addFunction(i.llvmSelector, type: i.signature)
    f.linkage = .external
    return f
  }

  private func typeCheckArguments<I: LLVMIntrinsic>(to fn: I, args: [IRValue]) -> Bool {
    let fnArgTypes = fn.signature.argTypes
    guard fnArgTypes.count == args.count else { return false }
    for t in zip(fnArgTypes, args) {
      // <SUB> => T
      if t.0 is IntrinsicSubstitutionMarker {
        continue
      } else if let vecTy = t.0 as? VectorType, vecTy.elementType is IntrinsicSubstitutionMarker  {
        // Vector<n, <SUB>> => Vector<n, T>
        guard t.1 is VectorType else {
          return false
        }
        continue
      } else if let vecTy = t.0 as? VectorType, vecTy.count == -1 {
        // Vector<-1, T> => Vector<n, T>
        guard let vecTy2 = t.1 as? VectorType, vecTy.elementType.asLLVM() == vecTy2.elementType.asLLVM() else {
          return false
        }
        continue
      }

      // Fall back to pointer equality
      guard t.0.asLLVM() == t.1.type.asLLVM() else { return false }
    }
    return true
  }

  private func resolveOverloadedArguments<I: LLVMOverloadedIntrinsic>(to fns: I.Type, args: [IRValue]) -> LLVMIntrinsic? {
    return fns.overloadSet.filter({ (fn) -> Bool in
      let fnArgTypes = fn.signature.argTypes
      guard fnArgTypes.count == args.count else { return false }
      for t in zip(fnArgTypes, args) {
        guard t.0.asLLVM() == t.1.type.asLLVM() else { return false }
      }
      return true
    }).first
  }
}

// A marker type generated by the 'intrinsics-gen' tool to indicate that a
// substitution should be performed on an argument.  They cannot be reified into
// an LLVM Type and will trap if an attempt is made to do so.
public struct IntrinsicSubstitutionMarker: IRType {
  public init() {}
  public func asLLVM() -> LLVMTypeRef {
    fatalError("Unhandled substitution marker in type")
  }
}

/// A marker intrinsic for the candidate selected during overload resolution.
private struct ResolvedIntrinsic: LLVMIntrinsic {
  let signature: FunctionType
  let llvmSelector: String
}
