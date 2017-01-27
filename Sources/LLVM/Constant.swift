#if !NO_SWIFTPM
import cllvm
#endif

/// A protocol to which the phantom types for a constant's representation conform.
public protocol ConstantRepresentation {}
/// A protocol to which the phantom types for integral constants conform.
public protocol IntegralConstantRepresentation: ConstantRepresentation {}

/// Represents unsigned integral types and operations.
public enum Unsigned: IntegralConstantRepresentation {}
/// Represents signed integral types and operations.
public enum Signed: IntegralConstantRepresentation {}
/// Represents floating types and operations.
public enum Floating: ConstantRepresentation {}

// FIXME: When upgrading to Swift 3.1, move this into `Constant`.
internal enum InternalConstantRepresentation {
  case unsigned
  case signed
  case floating
}

/// A `Constant` represents a value initialized to a constant.  Constant values
/// may be manipulated with standard Swift arithmetic operations and used with
/// standard IR Builder instructions like any other operand.  The difference
/// being any instructions acting solely on constants and any arithmetic
/// performed on constants is evaluated at compile-time only.
///
/// `Constant`s keep track of the values they represent at the type level to
/// disallow mixed-type arithmetic.  Use the `cast` family of operations to
/// safely convert constants to other representations.
public struct Constant<Repr: ConstantRepresentation>: IRValue {
  internal let llvm: LLVMValueRef
  internal let repr: InternalConstantRepresentation
  internal init(llvm: LLVMValueRef!) {
    self.llvm = llvm

    let reprID = ObjectIdentifier(Repr.self)
    if reprID == ObjectIdentifier(Unsigned.self) {
      self.repr = .unsigned
    } else if reprID == ObjectIdentifier(Signed.self) {
      self.repr = .signed
    } else if reprID == ObjectIdentifier(Floating.self) {
      self.repr = .floating
    } else {
      fatalError("Invalid representation \(type(of: Repr.self))")
    }
  }

  /// Retrieves the underlying LLVM constant object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }

  // MARK: Casting

  /// Creates a constant cast to a given integral type.
  ///
  /// - parameter type: The type to cast towards.
  ///
  /// - returns: A const value representing this value cast to the given
  ///   integral type.
  public func cast<T: IntegralConstantRepresentation>(to type: IntType) -> Constant<T> {
    let destID = ObjectIdentifier(T.self)
    let val = self.asLLVM()
    if destID == ObjectIdentifier(Unsigned.self) {
      switch self.repr {
      case .unsigned: fallthrough
      case .signed:
        return Constant<T>(llvm: LLVMConstIntCast(val, type.asLLVM(), /*signed:*/ false.llvm))
      case .floating:
        return Constant<T>(llvm: LLVMConstFPToUI(val, type.asLLVM()))
      }
    } else if destID == ObjectIdentifier(Signed.self) {
      switch self.repr {
      case .unsigned: fallthrough
      case .signed:
        return Constant<T>(llvm: LLVMConstIntCast(val, type.asLLVM(), /*signed:*/ true.llvm))
      case .floating:
        return Constant<T>(llvm: LLVMConstFPToSI(val, type.asLLVM()))
      }
    } else {
      fatalError("Invalid representation \(type(of: T.self))")
    }
  }

  /// Creates a constant cast to a given floating type.
  ///
  /// - parameter type: The type to cast towards.
  ///
  /// - returns: A const value representing this value cast to the given 
  ///   floating type.
  public func cast(to type: FloatType) -> Constant<Floating> {
    let val = self.asLLVM()
    switch self.repr {
    case .unsigned:
      return Constant<Floating>(llvm: LLVMConstUIToFP(val, type.asLLVM()))
    case .signed:
      return Constant<Floating>(llvm: LLVMConstSIToFP(val, type.asLLVM()))
    case .floating:
      return Constant<Floating>(llvm: LLVMConstFPCast(val, type.asLLVM()))
    }
  }

  // MARK: Arithmetic Operations

  /// Creates a constant negate operation to negate a value.
  ///
  /// - parameter lhs: The operand to negate.
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the negation of the given constant.
  public static func negate(_ lhs: Constant<Signed>, overflowBehavior: OverflowBehavior = .default) -> Constant<Signed> {
    precondition(lhs.repr == .signed, "Invalid representation")

    let lhsVal = lhs.asLLVM()
    switch overflowBehavior {
    case .noSignedWrap:
      return Constant<Signed>(llvm: LLVMConstNSWNeg(lhsVal))
    case .noUnsignedWrap:
      return Constant<Signed>(llvm: LLVMConstNUWNeg(lhsVal))
    case .default:
      return Constant<Signed>(llvm: LLVMConstNeg(lhsVal))
    }
  }

  /// Creates a constant add operation to add two homogenous constants together.
  ///
  /// - parameter lhs: The first summand value (the augend).
  /// - parameter rhs: The second summand value (the addend).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the sum of the two operands.
  public static func add(_ lhs: Constant, _ rhs: Constant, overflowBehavior: OverflowBehavior = .default) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    switch lhs.repr {
    case .signed: fallthrough
    case .unsigned:
      switch overflowBehavior {
      case .noSignedWrap:
        return Constant(llvm: LLVMConstNSWAdd(lhsVal, rhsVal))
      case .noUnsignedWrap:
        return Constant(llvm: LLVMConstNUWAdd(lhsVal, rhsVal))
      case .default:
        return lhs + rhs
      }
    case .floating:
      return Constant(llvm: LLVMConstFAdd(lhsVal, rhsVal))
    }
  }

  /// A constant add operation to add two homogenous constants together.
  ///
  /// - parameter lhs: The first summand value (the augend).
  /// - parameter rhs: The second summand value (the addend).
  ///
  /// - returns: A constant value representing the sum of the two operands.
  public static func +(lhs: Constant, rhs: Constant) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    switch lhs.repr {
    case .signed: fallthrough
    case .unsigned:
      return Constant(llvm: LLVMConstAdd(lhs.llvm, rhs.llvm))
    case .floating:
      return Constant(llvm: LLVMConstFAdd(lhs.llvm, rhs.llvm))
    }
  }

  /// Creates a constant sub operation to subtract two homogenous constants.
  ///
  /// - parameter lhs: The first value (the minuend).
  /// - parameter rhs: The second value (the subtrahend).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the difference of the two operands.
  public static func subtract(_ lhs: Constant, _ rhs: Constant, overflowBehavior: OverflowBehavior = .default) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    switch lhs.repr {
    case .signed: fallthrough
    case .unsigned:
      switch overflowBehavior {
      case .noSignedWrap:
        return Constant(llvm: LLVMConstNSWSub(lhsVal, rhsVal))
      case .noUnsignedWrap:
        return Constant(llvm: LLVMConstNUWSub(lhsVal, rhsVal))
      case .default:
        return lhs - rhs
      }
    case .floating:
      return lhs - rhs
    }
  }

  /// Creates a constant sub operation to subtract two homogenous constants.
  ///
  /// - parameter lhs: The first value (the minuend).
  /// - parameter rhs: The second value (the subtrahend).
  ///
  /// - returns: A constant value representing the difference of the two operands.
  public static func -(lhs: Constant, rhs: Constant) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    switch lhs.repr {
    case .signed: fallthrough
    case .unsigned:
      return Constant(llvm: LLVMConstSub(lhs.llvm, rhs.llvm))
    case .floating:
      return Constant(llvm: LLVMConstFSub(lhs.llvm, rhs.llvm))
    }
  }

  /// Creates a constant multiply operation with the given values as operands.
  ///
  /// - parameter lhs: The first factor value (the multiplier).
  /// - parameter rhs: The second factor value (the multiplicand).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the product of the two operands.
  public static func multiply(_ lhs: Constant, _ rhs: Constant, overflowBehavior: OverflowBehavior = .default) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    let lhsVal = lhs.asLLVM()
    let rhsVal = rhs.asLLVM()
    switch lhs.repr {
    case .signed: fallthrough
    case .unsigned:
      switch overflowBehavior {
      case .noSignedWrap:
        return Constant(llvm: LLVMConstNSWMul(lhsVal, rhsVal))
      case .noUnsignedWrap:
        return Constant(llvm: LLVMConstNUWMul(lhsVal, rhsVal))
      case .default:
        return lhs * rhs
      }
    case .floating:
      return lhs * rhs
    }
  }

  /// A constant multiply operation with the given values as operands.
  ///
  /// - parameter lhs: The first factor value (the multiplier).
  /// - parameter rhs: The second factor value (the multiplicand).
  ///
  /// - returns: A constant value representing the product of the two operands.
  public static func *(lhs: Constant, rhs: Constant) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    switch lhs.repr {
    case .signed: fallthrough
    case .unsigned:
      return Constant(llvm: LLVMConstMul(lhs.llvm, rhs.llvm))
    case .floating:
      return Constant(llvm: LLVMConstFMul(lhs.llvm, rhs.llvm))
    }
  }

  /// A constant divide operation that provides the remainder after divison of
  /// the first value by the second value.
  ///
  /// - parameter lhs: The first value (the dividend).
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the quotient of the first and 
  ///   second operands.
  public static func /(lhs: Constant, rhs: Constant) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    switch lhs.repr {
    case .signed:
      return Constant(llvm: LLVMConstSDiv(lhs.llvm, rhs.llvm))
    case .unsigned:
      return Constant(llvm: LLVMConstUDiv(lhs.llvm, rhs.llvm))
    case .floating:
      return Constant(llvm: LLVMConstFDiv(lhs.llvm, rhs.llvm))
    }
  }

  /// A constant remainder operation that provides the remainder after divison 
  /// of the first value by the second value.
  ///
  /// - parameter lhs: The first value (the dividend).
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the remainder of division of the
  ///   first operand by the second operand.
  public static func %(lhs: Constant, rhs: Constant) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    switch lhs.repr {
    case .signed:
      return Constant(llvm: LLVMConstSRem(lhs.llvm, rhs.llvm))
    case .unsigned:
      return Constant(llvm: LLVMConstURem(lhs.llvm, rhs.llvm))
    case .floating:
      return Constant(llvm: LLVMConstFRem(lhs.llvm, rhs.llvm))
    }
  }

  // MARK: Comparison Operations

  /// A constant equality comparison between two values.
  ///
  /// - parameter lhs: The first value to compare.
  /// - parameter rhs: The second value to compare.
  ///
  /// - returns: A constant integral value (i1) representing the result of the 
  ///   comparision of the given operands.
  public static func ==(lhs: Constant, rhs: Constant) -> Constant<Signed> {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    switch lhs.repr {
    case .signed:
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.eq.llvm, lhs.llvm, rhs.llvm))
    case .unsigned:
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.eq.llvm, lhs.llvm, rhs.llvm))
    case .floating:
      return Constant<Signed>(llvm: LLVMConstFCmp(RealPredicate.oeq.llvm, lhs.llvm, rhs.llvm))
    }
  }

  /// A constant less-than comparison between two values.
  ///
  /// - parameter lhs: The first value to compare.
  /// - parameter rhs: The second value to compare.
  ///
  /// - returns: A constant integral value (i1) representing the result of the
  ///   comparision of the given operands.
  public static func <(lhs: Constant, rhs: Constant) -> Constant<Signed> {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    switch lhs.repr {
    case .signed:
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.slt.llvm, lhs.llvm, rhs.llvm))
    case .unsigned:
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.ult.llvm, lhs.llvm, rhs.llvm))
    case .floating:
      return Constant<Signed>(llvm: LLVMConstFCmp(RealPredicate.olt.llvm, lhs.llvm, rhs.llvm))
    }
  }

  /// A constant greater-than comparison between two values.
  ///
  /// - parameter lhs: The first value to compare.
  /// - parameter rhs: The second value to compare.
  ///
  /// - returns: A constant integral value (i1) representing the result of the
  ///   comparision of the given operands.
  public static func >(lhs: Constant, rhs: Constant) -> Constant<Signed> {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    switch lhs.repr {
    case .signed:
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.sgt.llvm, lhs.llvm, rhs.llvm))
    case .unsigned:
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.ugt.llvm, lhs.llvm, rhs.llvm))
    case .floating:
      return Constant<Signed>(llvm: LLVMConstFCmp(RealPredicate.ogt.llvm, lhs.llvm, rhs.llvm))
    }
  }

  /// A constant less-than-or-equal comparison between two values.
  ///
  /// - parameter lhs: The first value to compare.
  /// - parameter rhs: The second value to compare.
  ///
  /// - returns: A constant integral value (i1) representing the result of the
  ///   comparision of the given operands.
  public static func <=(lhs: Constant, rhs: Constant) -> Constant<Signed> {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    switch lhs.repr {
    case .signed:
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.sle.llvm, lhs.llvm, rhs.llvm))
    case .unsigned:
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.ule.llvm, lhs.llvm, rhs.llvm))
    case .floating:
      return Constant<Signed>(llvm: LLVMConstFCmp(RealPredicate.ole.llvm, lhs.llvm, rhs.llvm))
    }
  }

  /// A constant greater-than-or-equal comparison between two values.
  ///
  /// - parameter lhs: The first value to compare.
  /// - parameter rhs: The second value to compare.
  ///
  /// - returns: A constant integral value (i1) representing the result of the
  ///   comparision of the given operands.
  public static func >=(lhs: Constant, rhs: Constant) -> Constant<Signed> {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    switch lhs.repr {
    case .signed:
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.sge.llvm, lhs.llvm, rhs.llvm))
    case .unsigned:
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.uge.llvm, lhs.llvm, rhs.llvm))
    case .floating:
      return Constant<Signed>(llvm: LLVMConstFCmp(RealPredicate.oge.llvm, lhs.llvm, rhs.llvm))
    }
  }
}

/// Creates a constant negate operation to negate an integral value.
///
/// - parameter lhs: The operand to negate.
///
/// - returns: A constant value representing the negation of the given constant.
public prefix func -(lhs: Constant<Signed>) -> Constant<Signed> {
  precondition(lhs.repr == .signed, "Invalid representation")
  return Constant<Signed>(llvm: LLVMConstNeg(lhs.llvm))
}

/// Creates a constant negate operation to negate a floating value.
///
/// - parameter lhs: The operand to negate.
///
/// - returns: A constant value representing the negation of the given constant.
public prefix func -(lhs: Constant<Floating>) -> Constant<Floating> {
  precondition(lhs.repr == .floating, "Invalid representation")
  return Constant<Floating>(llvm: LLVMConstFNeg(lhs.llvm))
}

extension Constant where Repr: IntegralConstantRepresentation {
  // MARK: Logical Operations

  /// A constant bitwise logical not with the given integral value as an operand.
  ///
  /// - parameter val: The value to negate.
  ///
  /// - returns: A constant value representing the logical negation of the given
  ///   operand.
  public static prefix func !(lhs: Constant) -> Constant {
    precondition(lhs.repr == .signed || lhs.repr == .unsigned, "Invalid representation")

    return Constant(llvm: LLVMConstNot(lhs.llvm))
  }

  /// A constant bitwise logical AND with the given values as operands.
  ///
  /// - parameter lhs: The first operand.
  /// - parameter rhs: The second operand.
  /// - parameter name: The name for the newly inserted instruction.
  ///
  /// - returns: A constant value representing the logical OR of the values of
  ///   the two given operands.
  public static func &(lhs: Constant, rhs: Constant) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    return Constant(llvm: LLVMConstAnd(lhs.llvm, rhs.llvm))
  }

  /// A constant bitwise logical OR with the given values as operands.
  ///
  /// - parameter lhs: The first operand.
  /// - parameter rhs: The second operand.
  /// - parameter name: The name for the newly inserted instruction.
  ///
  /// - returns: A constant value representing the logical OR of the values of 
  ///   the two given operands.
  public static func |(lhs: Constant, rhs: Constant) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    return Constant(llvm: LLVMConstOr(lhs.llvm, rhs.llvm))
  }

  /// A constant bitwise logical exclusive OR with the given values as operands.
  ///
  /// - parameter lhs: The first operand.
  /// - parameter rhs: The second operand.
  ///
  /// - returns: A constant value representing the exclusive OR of the values of
  ///   the two given operands.
  public static func ^(lhs: Constant, rhs: Constant) -> Constant {
    precondition(lhs.repr == rhs.repr, "Mixed-representation constant operations are disallowed")

    return Constant(llvm: LLVMConstXor(lhs.llvm, rhs.llvm))
  }
}
