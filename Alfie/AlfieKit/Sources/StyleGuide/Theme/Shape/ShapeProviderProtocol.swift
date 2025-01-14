import SwiftUI

/// Defines a provider of shapes used for clipping or overlaying visual elements
public protocol ShapeProviderProtocol {
    /// Returns a shape used for cross over color and sizing swatch elements
    func unavailableCrossedOutShape() -> AnyShape
}
