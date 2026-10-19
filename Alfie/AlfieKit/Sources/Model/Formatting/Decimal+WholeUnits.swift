import Foundation

extension Decimal {
    func wholeUnits(shiftedByPowerOf10 power: Int, rounding mode: RoundingMode) -> Decimal {
        var value = self
        var shifted = Decimal()
        _ = NSDecimalMultiplyByPowerOf10(&shifted, &value, Int16(power), .plain)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &shifted, 0, mode)
        return rounded
    }
}
