extension IntPredicate {
    /// Yields `true` if the operands are equal, false otherwise without sign
    /// interpretation.
    static let equal = eq
    /// Yields `true` if the operands are unequal, false otherwise without sign
    /// interpretation.
    static let notEqual = ne

    /// Interprets the operands as unsigned values and yields true if the first is
    /// greater than the second.
    static let unsignedGreaterThan = ugt
    /// Interprets the operands as unsigned values and yields true if the first is
    /// greater than or equal to the second.

    static let unsignedGreaterThanOrEqual = uge
    /// Interprets the operands as unsigned values and yields true if the first is
    /// less than the second.
    static let unsignedLessThan = ult
    /// Interprets the operands as unsigned values and yields true if the first is
    /// less than or equal to the second.
    static let unsignedLessThanOrEqual = ule

    /// Interprets the operands as signed values and yields true if the first is
    /// greater than the second.
    static let signedGreaterThan = sgt
    /// Interprets the operands as signed values and yields true if the first is
    /// greater than or equal to the second.
    static let signedGreaterThanOrEqual = sge
    /// Interprets the operands as signed values and yields true if the first is
    /// less than the second.
    static let signedLessThan = slt
    /// Interprets the operands as signed values and yields true if the first is
    /// less than or equal to the second.
    static let signedLessThanOrEqual = sle
}

extension RealPredicate {
    /// Ordered and equal.
    static let orderedEqual = oeq
    /// Ordered greater than.
    static let orderedGreaterThan = ogt
    /// Ordered greater than or equal.
    static let orderedGreaterThanOrEqual = oge
    /// Ordered less than.
    static let orderedLessThan = olt
    /// Ordered less than or equal.
    static let orderedLessThanOrEqual = ole
    /// Ordered and not equal.
    static let orderedNotEqual = one
    /// Oredered (no nans).
    static let ordered = ord
    /// Unordered (either nans).
    static let unordered = uno
    /// Unordered or equal.
    static let unorderedEqual = ueq
    /// Unordered or greater than.
    static let unorderedGreaterThan = ugt
    /// Unordered or greater than or equal.
    static let unorderedGreaterThanOrEqual = uge
    /// Unordered or less than.
    static let unorderedLessThan = ult
    /// Unordered or less than or equal.
    static let unorderedLessThanOrEqual = ule
    /// Unordered or not equal.
    static let unorderedNotEqual = une
}
