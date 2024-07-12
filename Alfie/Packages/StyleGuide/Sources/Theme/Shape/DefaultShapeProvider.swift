import SwiftUI

public class DefaultShapeProvider: ShapeProviderProtocol {
    public init() {}

    public func unavailableCrossedOutShape() -> AnyShape {
        AnyShape(DefaultShapes.SlashLine())
    }
}

private enum DefaultShapes {
    struct SlashLine: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            return path
        }
    }
}
