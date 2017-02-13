extension IntPredicate {
    /// Yields `true` if the operands are equal, false otherwise without sign
    /// interpretation.
    @available(*, deprecated, renamed: "equal")
    public static let eq = equal
    /// Yields `true` if the operands are unequal, false otherwise without sign
    /// interpretation.
    @available(*, deprecated, renamed: "notEqual")
    public static let ne = notEqual

    /// Interprets the operands as unsigned values and yields true if the first is
    /// greater than the second.
    @available(*, deprecated, renamed: "unsignedGreaterThan")
    public static let ugt = unsignedGreaterThan
    /// Interprets the operands as unsigned values and yields true if the first is
    /// greater than or equal to the second.

    @available(*, deprecated, renamed: "unsignedGreaterThanOrEqual")
    public static let uge = unsignedGreaterThanOrEqual
    /// Interprets the operands as unsigned values and yields true if the first is
    /// less than the second.
    @available(*, deprecated, renamed: "unsignedLessThan")
    public static let ult = unsignedLessThan
    /// Interprets the operands as unsigned values and yields true if the first is
    /// less than or equal to the second.
    @available(*, deprecated, renamed: "unsignedLessThanOrEqual")
    public static let ule = unsignedLessThanOrEqual

    /// Interprets the operands as signed values and yields true if the first is
    /// greater than the second.
    @available(*, deprecated, renamed: "signedGreaterThan")
    public static let sgt = signedGreaterThan
    /// Interprets the operands as signed values and yields true if the first is
    /// greater than or equal to the second.
    @available(*, deprecated, renamed: "signedGreaterThanOrEqual")
    public static let sge = signedGreaterThanOrEqual
    /// Interprets the operands as signed values and yields true if the first is
    /// less than the second.
    @available(*, deprecated, renamed: "signedLessThan")
    public static let slt = signedLessThan
    /// Interprets the operands as signed values and yields true if the first is
    /// less than or equal to the second.
    @available(*, deprecated, renamed: "signedLessThanOrEqual")
    public static let sle = signedLessThanOrEqual
}

extension RealPredicate {
    /// Ordered and equal.
    @available(*, deprecated, renamed: "orderedEqual")
    public static let oeq = orderedEqual
    /// Ordered greater than.
    @available(*, deprecated, renamed: "orderedGreaterThan")
    public static let ogt = orderedGreaterThan
    /// Ordered greater than or equal.
    @available(*, deprecated, renamed: "orderedGreaterThanOrEqual")
    public static let oge = orderedGreaterThanOrEqual
    /// Ordered less than.
    @available(*, deprecated, renamed: "orderedLessThan")
    public static let olt = orderedLessThan
    /// Ordered less than or equal.
    @available(*, deprecated, renamed: "orderedLessThanOrEqual")
    public static let ole = orderedLessThanOrEqual
    /// Ordered and not equal.
    @available(*, deprecated, renamed: "orderedNotEqual")
    public static let one = orderedNotEqual
    /// Oredered (no nans).
    @available(*, deprecated, renamed: "ordered")
    public static let ord = ordered
    /// Unordered (either nans).
    @available(*, deprecated, renamed: "unordered")
    public static let uno = unordered
    /// Unordered or equal.
    @available(*, deprecated, renamed: "unorderedEqual")
    public static let ueq = unorderedEqual
    /// Unordered or greater than.
    @available(*, deprecated, renamed: "unorderedGreaterThan")
    public static let ugt = unorderedGreaterThan
    /// Unordered or greater than or equal.
    @available(*, deprecated, renamed: "unorderedGreaterThanOrEqual")
    public static let uge = unorderedGreaterThanOrEqual
    /// Unordered or less than.
    @available(*, deprecated, renamed: "unorderedLessThan")
    public static let ult = unorderedLessThan
    /// Unordered or less than or equal.
    @available(*, deprecated, renamed: "unorderedLessThanOrEqual")
    public static let ule = unorderedLessThanOrEqual
    /// Unordered or not equal.
    @available(*, deprecated, renamed: "unorderedNotEqual")
    public static let une = unorderedNotEqual
}
