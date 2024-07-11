import SnapshotTesting
import UIKit

extension Snapshotting where Value == UIView, Format == UIImage {
    public static func defaultImage() -> Snapshotting {
        .image(precision: 0.9, perceptualPrecision: 0.95, traits: .init(displayGamut: .SRGB))
    }
}
