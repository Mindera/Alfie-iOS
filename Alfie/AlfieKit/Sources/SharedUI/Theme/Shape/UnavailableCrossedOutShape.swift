import SwiftUI

/// A diagonal slash used to cross out an unavailable colour / sizing swatch.
/// Not a design token — pure geometry — so it is used directly rather than vended by the theme.
public struct UnavailableCrossedOutShape: Shape {
    public enum Direction {
        /// Rises left to right. What the colour swatches have always drawn.
        case bottomLeadingToTopTrailing
        /// Falls left to right, as the design draws the size chips.
        case topLeadingToBottomTrailing
    }

    private let direction: Direction

    public init(direction: Direction = .bottomLeadingToTopTrailing) {
        self.direction = direction
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        switch direction {
        case .bottomLeadingToTopTrailing:
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        case .topLeadingToBottomTrailing:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        return path
    }
}
