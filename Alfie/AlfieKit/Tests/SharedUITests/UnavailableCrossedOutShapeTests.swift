import SwiftUI
import XCTest
@testable import SharedUI

/// The two directions differ only in which corners the line joins, and both share a bounding box —
/// so a swapped `case` would look identical to every geometric check except this one.
final class UnavailableCrossedOutShapeTests: XCTestCase {
    private let rect = CGRect(x: 0, y: 0, width: 100, height: 40)

    /// The corners the line joins, unordered — which two it joins is the specification; whether the
    /// path moves to one or the other first draws the same line.
    private func corners(of shape: UnavailableCrossedOutShape) -> Set<CGPoint>? {
        var points: Set<CGPoint> = []
        shape.path(in: rect).forEach { element in
            switch element {
            case .move(let point),
                 .line(let point): // swiftlint:disable:this indentation_width
                points.insert(point)
            default:
                break
            }
        }
        return points.count == 2 ? points : nil
    }

    func test_default_direction_rises_left_to_right() throws {
        // What the colour swatches have always drawn; changing it would restyle them silently.
        let sut = try XCTUnwrap(corners(of: UnavailableCrossedOutShape()))
        XCTAssertEqual(sut, [CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.minX, y: rect.maxY)])
    }

    func test_size_chip_direction_falls_left_to_right() throws {
        let sut = try XCTUnwrap(corners(of: UnavailableCrossedOutShape(direction: .topLeadingToBottomTrailing)))
        XCTAssertEqual(sut, [CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY)])
    }
}
