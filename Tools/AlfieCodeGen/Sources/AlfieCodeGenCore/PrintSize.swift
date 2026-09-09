import Foundation

/// How big the code has to come out on paper. Pixels are a consequence of these two numbers, not
/// something a caller picks: a code sized in pixels is a code nobody can predict the print size of.
///
/// `millimetres` is exact — every code comes out the same physical size, whatever its QR version —
/// and the resolution is the floor. The renderer scales by whole modules for crispness and then
/// writes back whatever DPI makes that pixel count land on `millimetres`, which is always at least
/// `minimumDotsPerInch`.
public struct PrintSize: Equatable {
    public let millimetres: Double
    public let minimumDotsPerInch: Double

    public init(millimetres: Double, minimumDotsPerInch: Double) {
        self.millimetres = millimetres
        self.minimumDotsPerInch = minimumDotsPerInch
    }

    /// The fewest pixels that still print at `minimumDotsPerInch`.
    public var minimumPixels: Int {
        Int((millimetres / 25.4 * minimumDotsPerInch).rounded(.up))
    }

    /// The DPI that makes `pixels` come out at exactly `millimetres`.
    public func dotsPerInch(forPixels pixels: Int) -> Double {
        Double(pixels) / (millimetres / 25.4)
    }

    /// 30mm at 300dpi or better. Large enough that a phone camera reads it off a creased swing tag,
    /// small enough that eight of them fit on one sheet of paper.
    public static let swingTag = PrintSize(millimetres: 30, minimumDotsPerInch: 300)
}
