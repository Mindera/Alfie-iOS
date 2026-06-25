import SwiftUI

/// A diagonal slash used to cross out an unavailable colour / sizing swatch.
/// Not a design token — pure geometry — so it is used directly rather than vended by the theme.
public struct UnavailableCrossedOutShape: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}
