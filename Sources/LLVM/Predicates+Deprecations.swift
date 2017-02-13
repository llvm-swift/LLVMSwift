extension IntPredicate {
    /// Yields `true` if the operands are equal, false otherwise without sign
    /// interpretation.
    @available(*, deprecated, renamed: "equal")
    static let eq = equal
    /// Yields `true` if the operands are unequal, false otherwise without sign
    /// interpretation.
    @available(*, deprecated, renamed: "notEqual")
    static let ne = notEqual

    /// Interprets the operands as unsigned values and yields true if the first is
    /// greater than the second.
    @available(*, deprecated, renamed: "unsignedGreaterThan")
    static let ugt = unsignedGreaterThan
    /// Interprets the operands as unsigned values and yields true if the first is
    /// greater than or equal to the second.

    @available(*, deprecated, renamed: "unsignedGreaterThanOrEqual")
    static let uge = unsignedGreaterThanOrEqual
    /// Interprets the operands as unsigned values and yields true if the first is
    /// less than the second.
    @available(*, deprecated, renamed: "unsignedLessThan")
    static let ult = unsignedLessThan
    /// Interprets the operands as unsigned values and yields true if the first is
    /// less than or equal to the second.
    @available(*, deprecated, renamed: "unsignedLessThanOrEqual")
    static let ule = unsignedLessThanOrEqual

    /// Interprets the operands as signed values and yields true if the first is
    /// greater than the second.
    @available(*, deprecated, renamed: "signedGreaterThan")
    static let sgt = signedGreaterThan
    /// Interprets the operands as signed values and yields true if the first is
    /// greater than or equal to the second.
    @available(*, deprecated, renamed: "signedGreaterThanOrEqual")
    static let sge = signedGreaterThanOrEqual
    /// Interprets the operands as signed values and yields true if the first is
    /// less than the second.
    @available(*, deprecated, renamed: "signedLessThan")
    static let slt = signedLessThan
    /// Interprets the operands as signed values and yields true if the first is
    /// less than or equal to the second.
    @available(*, deprecated, renamed: "signedLessThanOrEqual")
    static let sle = signedLessThanOrEqual
}

extension RealPredicate {
    /// Ordered and equal.
    @available(*, deprecated, renamed: "orderedEqual")
    static let oeq = orderedEqual
    /// Ordered greater than.
    @available(*, deprecated, renamed: "orderedGreaterThan")
    static let ogt = orderedGreaterThan
    /// Ordered greater than or equal.
    @available(*, deprecated, renamed: "orderedGreaterThanOrEqual")
    static let oge = orderedGreaterThanOrEqual
    /// Ordered less than.
    @available(*, deprecated, renamed: "orderedLessThan")
    static let olt = orderedLessThan
    /// Ordered less than or equal.
    @available(*, deprecated, renamed: "orderedLessThanOrEqual")
    static let ole = orderedLessThanOrEqual
    /// Ordered and not equal.
    @available(*, deprecated, renamed: "orderedNotEqual")
    static let one = orderedNotEqual
    /// Oredered (no nans).
    @available(*, deprecated, renamed: "ordered")
    static let ord = ordered
    /// Unordered (either nans).
    @available(*, deprecated, renamed: "unordered")
    static let uno = unordered
    /// Unordered or equal.
    @available(*, deprecated, renamed: "unorderedEqual")
    static let ueq = unorderedEqual
    /// Unordered or greater than.
    @available(*, deprecated, renamed: "unorderedGreaterThan")
    static let ugt = unorderedGreaterThan
    /// Unordered or greater than or equal.
    @available(*, deprecated, renamed: "unorderedGreaterThanOrEqual")
    static let uge = unorderedGreaterThanOrEqual
    /// Unordered or less than.
    @available(*, deprecated, renamed: "unorderedLessThan")
    static let ult = unorderedLessThan
    /// Unordered or less than or equal.
    @available(*, deprecated, renamed: "unorderedLessThanOrEqual")
    static let ule = unorderedLessThanOrEqual
    /// Unordered or not equal.
    @available(*, deprecated, renamed: "unorderedNotEqual")
    static let une = unorderedNotEqual
}
