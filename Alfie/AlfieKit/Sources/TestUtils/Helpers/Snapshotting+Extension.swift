import SnapshotTesting
import UIKit

extension Snapshotting where Value == UIView, Format == UIImage {
    /// Default snapshot strategy. `precision`/`perceptualPrecision` default to the
    /// suite-wide policy (0.9 / 0.95); a noisy test may override them explicitly.
    public static func defaultImage(
        precision: Float = 0.9,
        perceptualPrecision: Float = 0.95
    ) -> Snapshotting {
        // Pin displayScale to 3 in the strategy's traits. The renderer would otherwise fall back to
        // UIScreen.main.scale, so pinning here keeps references comparable without mutating global state.
        .image(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            traits: UITraitCollection(traitsFrom: [
                UITraitCollection(displayScale: 3),
                UITraitCollection(displayGamut: .SRGB),
            ])
        )
    }
}
