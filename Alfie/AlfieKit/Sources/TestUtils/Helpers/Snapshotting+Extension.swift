import SnapshotTesting
import UIKit

extension Snapshotting where Value == UIView, Format == UIImage {
    /// Default snapshot strategy. `precision`/`perceptualPrecision` default to the
    /// suite-wide policy (0.9 / 0.95); a noisy test may override them explicitly.
    public static func defaultImage(
        precision: Float = 0.9,
        perceptualPrecision: Float = 0.95
    ) -> Snapshotting {
        .image(precision: precision, perceptualPrecision: perceptualPrecision, traits: .init(displayGamut: .SRGB))
    }
}
