import SnapshotTesting
import UIKit

extension Snapshotting where Value == UIView, Format == UIImage {
    /// Default snapshot strategy. `precision` defaults to `1.0` (every pixel must match) so a test
    /// cannot pass with an element missing; `perceptualPrecision` `0.95` still absorbs anti-aliasing
    /// across devices. A view with genuinely non-deterministic content (e.g. a time-driven animation)
    /// may lower `precision` explicitly — see `SplashViewSnapshotTests`.
    public static func defaultImage(
        precision: Float = 1.0,
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
