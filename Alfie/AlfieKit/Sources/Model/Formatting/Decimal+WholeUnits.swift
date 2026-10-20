import Foundation

extension Decimal {
    /// `nil` when the shift overflows or underflows `Decimal`.
    func wholeUnits(shiftedByPowerOf10 power: Int, rounding mode: RoundingMode) -> Decimal? {
        var value = self
        var shifted = Decimal()
        let error = NSDecimalMultiplyByPowerOf10(&shifted, &value, Int16(power), .plain)
        guard error == .noError || error == .lossOfPrecision else { return nil }
        var rounded = Decimal()
        NSDecimalRound(&rounded, &shifted, 0, mode)
        return rounded
    }
}
