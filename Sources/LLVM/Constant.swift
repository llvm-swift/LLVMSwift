#if !NO_SWIFTPM
import cllvm
#endif

/// A protocol to which the phantom types for a constant's representation conform.
public protocol ConstantRepresentation {}
/// A protocol to which the phantom types for all numerical constants conform.
public protocol NumericalConstantRepresentation: ConstantRepresentation {}
/// A protocol to which the phantom types for integral constants conform.
public protocol IntegralConstantRepresentation: NumericalConstantRepresentation {}

/// Represents unsigned integral types and operations.
public enum Unsigned: IntegralConstantRepresentation {}
/// Represents signed integral types and operations.
public enum Signed: IntegralConstantRepresentation {}
/// Represents floating types and operations.
public enum Floating: NumericalConstantRepresentation {}
/// Represents struct types and operations.
public enum Struct: ConstantRepresentation {}

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

  internal init(llvm: LLVMValueRef!) {
    self.llvm = llvm
  }

  /// Retrieves the underlying LLVM constant object.
  public func asLLVM() -> LLVMValueRef {
    return llvm
  }
}


// MARK: Casting

extension Constant where Repr == Unsigned {

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
      return Constant<T>(llvm: LLVMConstIntCast(val, type.asLLVM(), /*signed:*/ false.llvm))
    } else if destID == ObjectIdentifier(Signed.self) {
      return Constant<T>(llvm: LLVMConstIntCast(val, type.asLLVM(), /*signed:*/ true.llvm))
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
    return Constant<Floating>(llvm: LLVMConstUIToFP(val, type.asLLVM()))
  }
}

extension Constant where Repr == Signed {

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
      return Constant<T>(llvm: LLVMConstIntCast(val, type.asLLVM(), /*signed:*/ false.llvm))
    } else if destID == ObjectIdentifier(Signed.self) {
      return Constant<T>(llvm: LLVMConstIntCast(val, type.asLLVM(), /*signed:*/ true.llvm))
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
    return Constant<Floating>(llvm: LLVMConstSIToFP(val, type.asLLVM()))
  }
}

extension Constant where Repr == Floating {

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
      return Constant<T>(llvm: LLVMConstFPToUI(val, type.asLLVM()))
    } else if destID == ObjectIdentifier(Signed.self) {
      return Constant<T>(llvm: LLVMConstFPToSI(val, type.asLLVM()))
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
    return Constant<Floating>(llvm: LLVMConstFPCast(val, type.asLLVM()))
  }
}


extension Constant where Repr == Struct {

  @available(*, unavailable, message: "You cannot cast an aggregate type. See the LLVM Reference manual's section on `bitcast`")
  public func cast<T: IntegralConstantRepresentation>(to type: IntType) -> Constant<T> {
    fatalError()
  }

  @available(*, unavailable, message: "You cannot cast an aggregate type. See the LLVM Reference manual's section on `bitcast`")
  public func cast(to type: FloatType) -> Constant<Floating> {
    fatalError()
  }
}



// MARK: Arithmetic Operations

// MARK: Negation

extension Constant {

  /// Creates a constant negate operation to negate a value.
  ///
  /// - parameter lhs: The operand to negate.
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the negation of the given constant.
  public static func negate(_ lhs: Constant<Signed>, overflowBehavior: OverflowBehavior = .default) -> Constant<Signed> {

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

  /// Creates a constant negate operation to negate a value.
  ///
  /// - parameter lhs: The operand to negate.
  ///
  /// - returns: A constant value representing the negation of the given constant.
  public static func negate(_ lhs: Constant<Floating>) -> Constant<Floating> {
    return Constant<Floating>(llvm: LLVMConstFNeg(lhs.llvm))
  }
}

extension Constant where Repr == Signed {

  /// Creates a constant negate operation to negate a value.
  ///
  /// - returns: A constant value representing the negation of the given constant.
  public func negate() -> Constant {
    return Constant.negate(self)
  }
}

extension Constant where Repr == Floating {

  /// Creates a constant negate operation to negate a value.
  ///
  /// - returns: A constant value representing the negation of the given constant.
  public func negate() -> Constant {
    return Constant.negate(self)
  }
}

// MARK: Addition

extension Constant {

  /// Creates a constant add operation to add two homogenous constants together.
  ///
  /// - parameter lhs: The first summand value (the augend).
  /// - parameter rhs: The second summand value (the addend).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the sum of the two operands.
  public static func add(_ lhs: Constant<Unsigned>, _ rhs: Constant<Unsigned>, overflowBehavior: OverflowBehavior = .default) -> Constant<Unsigned> {

    switch overflowBehavior {
    case .noSignedWrap:
      return Constant<Unsigned>(llvm: LLVMConstNSWAdd(lhs.llvm, rhs.llvm))
    case .noUnsignedWrap:
      return Constant<Unsigned>(llvm: LLVMConstNUWAdd(lhs.llvm, rhs.llvm))
    case .default:
      return Constant<Unsigned>(llvm: LLVMConstAdd(lhs.llvm, rhs.llvm))
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
  public static func add(_ lhs: Constant<Signed>, _ rhs: Constant<Signed>, overflowBehavior: OverflowBehavior = .default) -> Constant<Signed> {

    switch overflowBehavior {
    case .noSignedWrap:
      return Constant<Signed>(llvm: LLVMConstNSWAdd(lhs.llvm, rhs.llvm))
    case .noUnsignedWrap:
      return Constant<Signed>(llvm: LLVMConstNUWAdd(lhs.llvm, rhs.llvm))
    case .default:
      return Constant<Signed>(llvm: LLVMConstAdd(lhs.llvm, rhs.llvm))
    }
  }

  /// Creates a constant add operation to add two homogenous constants together.
  ///
  /// - parameter lhs: The first summand value (the augend).
  /// - parameter rhs: The second summand value (the addend).
  ///
  /// - returns: A constant value representing the sum of the two operands.
  public static func add(_ lhs: Constant<Floating>, _ rhs: Constant<Floating>) -> Constant<Floating> {

    return Constant<Floating>(llvm: LLVMConstFAdd(lhs.llvm, rhs.llvm))
  }
}

extension Constant where Repr == Signed {

  /// Creates a constant add operation to add two homogenous constants together.
  ///
  /// - parameter rhs: The second summand value (the addend).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the sum of the two operands.
  public func adding(_ rhs: Constant, overflowBehavior: OverflowBehavior = .default) -> Constant {
    return Constant.add(self, rhs, overflowBehavior: overflowBehavior)
  }
}

extension Constant where Repr == Unsigned {

  /// Creates a constant add operation to add two homogenous constants together.
  ///
  /// - parameter rhs: The second summand value (the addend).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the sum of the two operands.
  public func adding(_ rhs: Constant, overflowBehavior: OverflowBehavior = .default) -> Constant {
    return Constant.add(self, rhs, overflowBehavior: overflowBehavior)
  }
}

extension Constant where Repr == Floating {

  /// Creates a constant add operation to add two homogenous constants together.
  ///
  /// - parameter rhs: The second summand value (the addend).
  ///
  /// - returns: A constant value representing the sum of the two operands.
  public func adding(_ rhs: Constant) -> Constant {
    return Constant.add(self, rhs)
  }
}

// MARK: Subtraction

extension Constant {

  /// Creates a constant sub operation to subtract two homogenous constants.
  ///
  /// - parameter lhs: The first value (the minuend).
  /// - parameter rhs: The second value (the subtrahend).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the difference of the two operands.
  public static func subtract(_ lhs: Constant<Unsigned>, _ rhs: Constant<Unsigned>, overflowBehavior: OverflowBehavior = .default) -> Constant<Unsigned> {

    switch overflowBehavior {
    case .noSignedWrap:
      return Constant<Unsigned>(llvm: LLVMConstNSWSub(lhs.llvm, rhs.llvm))
    case .noUnsignedWrap:
      return Constant<Unsigned>(llvm: LLVMConstNUWSub(lhs.llvm, rhs.llvm))
    case .default:
      return Constant<Unsigned>(llvm: LLVMConstSub(lhs.llvm, rhs.llvm))
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
  public static func subtract(_ lhs: Constant<Signed>, _ rhs: Constant<Signed>, overflowBehavior: OverflowBehavior = .default) -> Constant<Signed> {

    switch overflowBehavior {
    case .noSignedWrap:
      return Constant<Signed>(llvm: LLVMConstNSWSub(lhs.llvm, rhs.llvm))
    case .noUnsignedWrap:
      return Constant<Signed>(llvm: LLVMConstNUWSub(lhs.llvm, rhs.llvm))
    case .default:
      return Constant<Signed>(llvm: LLVMConstSub(lhs.llvm, rhs.llvm))
    }
  }
  
  /// Creates a constant sub operation to subtract two homogenous constants.
  ///
  /// - parameter lhs: The first value (the minuend).
  /// - parameter rhs: The second value (the subtrahend).
  ///
  /// - returns: A constant value representing the difference of the two operands.
  public static func subtract(_ lhs: Constant<Floating>, _ rhs: Constant<Floating>) -> Constant<Floating> {
    return Constant<Floating>(llvm: LLVMConstFSub(lhs.llvm, rhs.llvm))
  }
}

extension Constant where Repr == Unsigned {

  /// Creates a constant sub operation to subtract two homogenous constants.
  ///
  /// - parameter rhs: The second value (the subtrahend).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the difference of the two operands.
  public func subtracting(_ rhs: Constant, overflowBehavior: OverflowBehavior = .default) -> Constant {
    return Constant.subtract(self, rhs, overflowBehavior: overflowBehavior)
  }
}

extension Constant where Repr == Signed {

  /// Creates a constant sub operation to subtract two homogenous constants.
  ///
  /// - parameter rhs: The second value (the subtrahend).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the difference of the two operands.
  public func subtracting(_ rhs: Constant, overflowBehavior: OverflowBehavior = .default) -> Constant {
    return Constant.subtract(self, rhs, overflowBehavior: overflowBehavior)
  }
}

extension Constant where Repr == Floating {

  /// Creates a constant sub operation to subtract two homogenous constants.
  ///
  /// - parameter rhs: The second value (the subtrahend).
  ///
  /// - returns: A constant value representing the difference of the two operands.
  public func subtracting(_ rhs: Constant) -> Constant {
    return Constant.subtract(self, rhs)
  }
}

// MARK: Multiplication

extension Constant {

  /// Creates a constant multiply operation with the given values as operands.
  ///
  /// - parameter lhs: The first factor value (the multiplier).
  /// - parameter rhs: The second factor value (the multiplicand).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the product of the two operands.
  public static func multiply(_ lhs: Constant<Unsigned>, _ rhs: Constant<Unsigned>, overflowBehavior: OverflowBehavior = .default) -> Constant<Unsigned> {

    switch overflowBehavior {
    case .noSignedWrap:
      return Constant<Unsigned>(llvm: LLVMConstNSWMul(lhs.llvm, rhs.llvm))
    case .noUnsignedWrap:
      return Constant<Unsigned>(llvm: LLVMConstNUWMul(lhs.llvm, rhs.llvm))
    case .default:
      return Constant<Unsigned>(llvm: LLVMConstMul(lhs.llvm, rhs.llvm))
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
  public static func multiply(_ lhs: Constant<Signed>, _ rhs: Constant<Signed>, overflowBehavior: OverflowBehavior = .default) -> Constant<Signed> {

    switch overflowBehavior {
    case .noSignedWrap:
      return Constant<Signed>(llvm: LLVMConstNSWMul(lhs.llvm, rhs.llvm))
    case .noUnsignedWrap:
      return Constant<Signed>(llvm: LLVMConstNUWMul(lhs.llvm, rhs.llvm))
    case .default:
      return Constant<Signed>(llvm: LLVMConstMul(lhs.llvm, rhs.llvm))
    }
  }

  /// Creates a constant multiply operation with the given values as operands.
  ///
  /// - parameter lhs: The first factor value (the multiplier).
  /// - parameter rhs: The second factor value (the multiplicand).
  ///
  /// - returns: A constant value representing the product of the two operands.
  public static func multiply(_ lhs: Constant<Floating>, _ rhs: Constant<Floating>) -> Constant<Floating> {
    return Constant<Floating>(llvm: LLVMConstFMul(lhs.llvm, rhs.llvm))
  }
}

extension Constant where Repr == Unsigned {

  /// Creates a constant multiply operation with the given values as operands.
  ///
  /// - parameter rhs: The second factor value (the multiplicand).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the product of the two operands.
  public func multiplying(_ rhs: Constant, overflowBehavior: OverflowBehavior = .default) -> Constant {
    return Constant.multiply(self, rhs, overflowBehavior: overflowBehavior)
  }
}

extension Constant where Repr == Signed {

  /// Creates a constant multiply operation with the given values as operands.
  ///
  /// - parameter rhs: The second factor value (the multiplicand).
  /// - parameter overflowBehavior: Should overflow occur, specifies the
  ///   behavior of the resulting constant value.
  ///
  /// - returns: A constant value representing the product of the two operands.
  public func multiplying(_ rhs: Constant, overflowBehavior: OverflowBehavior = .default) -> Constant {
    return Constant.multiply(self, rhs, overflowBehavior: overflowBehavior)
  }
}

extension Constant where Repr == Floating {

  /// Creates a constant multiply operation with the given values as operands.
  ///
  /// - parameter lhs: The first factor value (the multiplier).
  /// - parameter rhs: The second factor value (the multiplicand).
  ///
  /// - returns: A constant value representing the product of the two operands.
  public func multiplying(_ rhs: Constant) -> Constant {
    return Constant.multiply(self, rhs)
  }
}

// MARK: Divide

extension Constant {

  /// A constant divide operation that provides the remainder after divison of
  /// the first value by the second value.
  ///
  /// - parameter lhs: The first value (the dividend).
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the quotient of the first and 
  ///   second operands.
  public static func divide(_ lhs: Constant<Unsigned>, _ rhs: Constant<Unsigned>) -> Constant<Unsigned> {
    return Constant<Unsigned>(llvm: LLVMConstUDiv(lhs.llvm, rhs.llvm))
  }

  /// A constant divide operation that provides the remainder after divison of
  /// the first value by the second value.
  ///
  /// - parameter lhs: The first value (the dividend).
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the quotient of the first and 
  ///   second operands.
  public static func divide(_ lhs: Constant<Signed>, _ rhs: Constant<Signed>) -> Constant<Signed> {
    return Constant<Signed>(llvm: LLVMConstSDiv(lhs.llvm, rhs.llvm))
  }

  /// A constant divide operation that provides the remainder after divison of
  /// the first value by the second value.
  ///
  /// - parameter lhs: The first value (the dividend).
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the quotient of the first and 
  ///   second operands.
  public static func divide(_ lhs: Constant<Floating>, _ rhs: Constant<Floating>) -> Constant<Floating> {
    return Constant<Floating>(llvm: LLVMConstFDiv(lhs.llvm, rhs.llvm))
  }
}

extension Constant where Repr == Unsigned {

  /// A constant divide operation that provides the remainder after divison of
  /// the first value by the second value.
  ///
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the quotient of the first and 
  ///   second operands.
  public func dividing(_ rhs: Constant) -> Constant {
    return Constant.divide(self, rhs)
  }
}

extension Constant where Repr == Signed {

  /// A constant divide operation that provides the remainder after divison of
  /// the first value by the second value.
  ///
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the quotient of the first and 
  ///   second operands.
  public func dividing(_ rhs: Constant) -> Constant {
    return Constant.divide(self, rhs)
  }
}

extension Constant where Repr == Floating {

  /// A constant divide operation that provides the remainder after divison of
  /// the first value by the second value.
  ///
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the quotient of the first and 
  ///   second operands.
  public func dividing(_ rhs: Constant) -> Constant {
    return Constant.divide(self, rhs)
  }
}

// MARK: Remainder

extension Constant {

  /// A constant remainder operation that provides the remainder after divison 
  /// of the first value by the second value.
  ///
  /// - parameter lhs: The first value (the dividend).
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the remainder of division of the
  ///   first operand by the second operand.
  public static func remainder(_ lhs: Constant<Unsigned>, _ rhs: Constant<Unsigned>) -> Constant<Unsigned> {
    return Constant<Unsigned>(llvm: LLVMConstURem(lhs.llvm, rhs.llvm))
  }

  /// A constant remainder operation that provides the remainder after divison 
  /// of the first value by the second value.
  ///
  /// - parameter lhs: The first value (the dividend).
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the remainder of division of the
  ///   first operand by the second operand.
  public static func remainder(_ lhs: Constant<Signed>, _ rhs: Constant<Signed>) -> Constant<Signed> {
    return Constant<Signed>(llvm: LLVMConstSRem(lhs.llvm, rhs.llvm))
  }

  /// A constant remainder operation that provides the remainder after divison
  /// of the first value by the second value.
  ///
  /// - parameter lhs: The first value (the dividend).
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the remainder of division of the
  ///   first operand by the second operand.
  public static func remainder(_ lhs: Constant<Floating>, _ rhs: Constant<Floating>) -> Constant<Floating> {
    return Constant<Floating>(llvm: LLVMConstFRem(lhs.llvm, rhs.llvm))
  }
}

extension Constant where Repr == Unsigned {

  /// A constant remainder operation that provides the remainder after divison
  /// of the first value by the second value.
  ///
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the remainder of division of the
  ///   first operand by the second operand.
  public func remainder(_ rhs: Constant) -> Constant {
    return Constant.remainder(self, rhs)
  }
}

extension Constant where Repr == Signed {

  /// A constant remainder operation that provides the remainder after divison
  /// of the first value by the second value.
  ///
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the remainder of division of the
  ///   first operand by the second operand.
  public func remainder(_ rhs: Constant) -> Constant {
    return Constant.remainder(self, rhs)
  }
}

extension Constant where Repr == Floating {

  /// A constant remainder operation that provides the remainder after divison
  /// of the first value by the second value.
  ///
  /// - parameter rhs: The second value (the divisor).
  ///
  /// - returns: A constant value representing the remainder of division of the
  ///   first operand by the second operand.
  public func remainder(_ rhs: Constant) -> Constant {
    return Constant.remainder(self, rhs)
  }
}

// MARK: Comparison Operations

extension Constant {

  /// A constant equality comparison between two values.
  ///
  /// - parameter lhs: The first value to compare.
  /// - parameter rhs: The second value to compare.
  ///
  /// - returns: A constant integral value (i1) representing the result of the 
  ///   comparision of the given operands.
  public static func equals<T: NumericalConstantRepresentation>(_ lhs: Constant<T>, _ rhs: Constant<T>) -> Constant<Signed> {

    switch ObjectIdentifier(T.self) {
    case ObjectIdentifier(Unsigned.self): fallthrough
    case ObjectIdentifier(Signed.self):
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.equal.llvm, lhs.llvm, rhs.llvm))
    case ObjectIdentifier(Floating.self):
      return Constant<Signed>(llvm: LLVMConstFCmp(RealPredicate.orderedEqual.llvm, lhs.llvm, rhs.llvm))
    default:
      fatalError("Invalid representation")
    }
  }

  /// A constant less-than comparison between two values.
  ///
  /// - parameter lhs: The first value to compare.
  /// - parameter rhs: The second value to compare.
  ///
  /// - returns: A constant integral value (i1) representing the result of the
  ///   comparision of the given operands.
  public static func lessThan<T: NumericalConstantRepresentation>(_ lhs: Constant<T>, _ rhs: Constant<T>) -> Constant<Signed> {

    switch ObjectIdentifier(T.self) {
    case ObjectIdentifier(Unsigned.self):
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.unsignedLessThan.llvm, lhs.llvm, rhs.llvm))
    case ObjectIdentifier(Signed.self):
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.signedLessThan.llvm, lhs.llvm, rhs.llvm))
    case ObjectIdentifier(Floating.self):
      return Constant<Signed>(llvm: LLVMConstFCmp(RealPredicate.orderedLessThan.llvm, lhs.llvm, rhs.llvm))
    default:
      fatalError("Invalid representation")
    }
  }

  /// A constant greater-than comparison between two values.
  ///
  /// - parameter lhs: The first value to compare.
  /// - parameter rhs: The second value to compare.
  ///
  /// - returns: A constant integral value (i1) representing the result of the
  ///   comparision of the given operands.
  public static func greaterThan<T: NumericalConstantRepresentation>(_ lhs: Constant<T>, _ rhs: Constant<T>) -> Constant<Signed> {

    switch ObjectIdentifier(T.self) {
    case ObjectIdentifier(Unsigned.self):
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.unsignedGreaterThan.llvm, lhs.llvm, rhs.llvm))
    case ObjectIdentifier(Signed.self):
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.signedGreaterThan.llvm, lhs.llvm, rhs.llvm))
    case ObjectIdentifier(Floating.self):
      return Constant<Signed>(llvm: LLVMConstFCmp(RealPredicate.orderedGreaterThan.llvm, lhs.llvm, rhs.llvm))
    default:
      fatalError("Invalid representation")
    }
  }

  /// A constant less-than-or-equal comparison between two values.
  ///
  /// - parameter lhs: The first value to compare.
  /// - parameter rhs: The second value to compare.
  ///
  /// - returns: A constant integral value (i1) representing the result of the
  ///   comparision of the given operands.
  public static func lessThanOrEqual <T: NumericalConstantRepresentation>(_ lhs: Constant<T>, _ rhs: Constant<T>) -> Constant<Signed> {

    switch ObjectIdentifier(T.self) {
    case ObjectIdentifier(Unsigned.self):
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.unsignedLessThanOrEqual.llvm, lhs.llvm, rhs.llvm))
    case ObjectIdentifier(Signed.self):
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.signedLessThanOrEqual.llvm, lhs.llvm, rhs.llvm))
    case ObjectIdentifier(Floating.self):
      return Constant<Signed>(llvm: LLVMConstFCmp(RealPredicate.orderedLessThanOrEqual.llvm, lhs.llvm, rhs.llvm))
    default:
      fatalError("Invalid representation")
    }
  }

  /// A constant greater-than-or-equal comparison between two values.
  ///
  /// - parameter lhs: The first value to compare.
  /// - parameter rhs: The second value to compare.
  ///
  /// - returns: A constant integral value (i1) representing the result of the
  ///   comparision of the given operands.
  public static func greaterThanOrEqual <T: NumericalConstantRepresentation>(_ lhs: Constant<T>, _ rhs: Constant<T>) -> Constant<Signed> {

    switch ObjectIdentifier(T.self) {
    case ObjectIdentifier(Unsigned.self):
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.unsignedGreaterThanOrEqual.llvm, lhs.llvm, rhs.llvm))
    case ObjectIdentifier(Signed.self):
      return Constant<Signed>(llvm: LLVMConstICmp(IntPredicate.signedGreaterThanOrEqual.llvm, lhs.llvm, rhs.llvm))
    case ObjectIdentifier(Floating.self):
      return Constant<Signed>(llvm: LLVMConstFCmp(RealPredicate.orderedGreaterThanOrEqual.llvm, lhs.llvm, rhs.llvm))
    default:
      fatalError("Invalid representation")
    }
  }


  // MARK: Logical Operations

  /// A constant bitwise logical not with the given integral value as an operand.
  ///
  /// - parameter val: The value to negate.
  ///
  /// - returns: A constant value representing the logical negation of the given
  ///   operand.
  public static func not<T: IntegralConstantRepresentation>(_ lhs: Constant<T>) -> Constant<T> {
    return Constant<T>(llvm: LLVMConstNot(lhs.llvm))
  }

  /// A constant bitwise logical AND with the given values as operands.
  ///
  /// - parameter lhs: The first operand.
  /// - parameter rhs: The second operand.
  /// - parameter name: The name for the newly inserted instruction.
  ///
  /// - returns: A constant value representing the logical OR of the values of
  ///   the two given operands.
  public static func and<T: IntegralConstantRepresentation>(_ lhs: Constant<T>, _ rhs: Constant<T>) -> Constant<T> {
    return Constant<T>(llvm: LLVMConstAnd(lhs.llvm, rhs.llvm))
  }

  /// A constant bitwise logical OR with the given values as operands.
  ///
  /// - parameter lhs: The first operand.
  /// - parameter rhs: The second operand.
  /// - parameter name: The name for the newly inserted instruction.
  ///
  /// - returns: A constant value representing the logical OR of the values of 
  ///   the two given operands.
  public static func or<T: IntegralConstantRepresentation>(_ lhs: Constant<T>, _ rhs: Constant<T>) -> Constant<T> {
    return Constant<T>(llvm: LLVMConstOr(lhs.llvm, rhs.llvm))
  }

  /// A constant bitwise logical exclusive OR with the given values as operands.
  ///
  /// - parameter lhs: The first operand.
  /// - parameter rhs: The second operand.
  ///
  /// - returns: A constant value representing the exclusive OR of the values of
  ///   the two given operands.
  public static func xor<T: IntegralConstantRepresentation>(_ lhs: Constant<T>, _ rhs: Constant<T>) -> Constant<T> {
    return Constant<T>(llvm: LLVMConstXor(lhs.llvm, rhs.llvm))
  }

  // MARK: Bitshifting Operations

  /// A constant left-shift of the first value by the second amount.
  ///
  /// - parameter lhs: The first operand.
  /// - parameter rhs: The second operand.
  ///
  /// - returns: A constant value representing the value of the first operand
  ///   shifted left by the number of bits specified in the second operand.
  public static func leftShift<T: IntegralConstantRepresentation>(_ lhs: Constant<T>, _ rhs: Constant<T>) -> Constant<T> {
    return Constant<T>(llvm: LLVMConstShl(lhs.llvm, rhs.llvm))
  }


  // MARK: Conditional Operations

  /// A constant select using the given condition to select among two values.
  ///
  /// - parameter cond: The condition to evaluate.  It must have type `i1` or
  ///   be a vector of `i1`.
  /// - parameter then: The value to select if the given condition is true.
  /// - parameter else: The value to select if the given condition is false.
  ///
  /// - returns: A constant value representing the constant value selected for
  ///   by the condition.
  public static func select<T>(_ cond: Constant, then: Constant<T>, else: Constant<T>) -> Constant<T> {
    return Constant<T>(llvm: LLVMConstSelect(cond.llvm, then.llvm, `else`.llvm))
  }
}

// MARK: Struct Operations

extension Constant where Repr == Struct {

  public func getElement(indices: [Int]) -> IRValue {
    var indices = indices.map({ UInt32($0) })
    return indices.withUnsafeMutableBufferPointer { buf in
      return LLVMConstExtractValue(asLLVM(), buf.baseAddress, UInt32(buf.count))
    }
  }
}
