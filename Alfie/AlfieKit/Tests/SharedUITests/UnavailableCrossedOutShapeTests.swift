import SwiftUI
import XCTest
@testable import SharedUI

/// The two directions differ only in which corners the line joins, and both share a bounding box —
/// so a swapped `case` would look identical to every geometric check except this one.
final class UnavailableCrossedOutShapeTests: XCTestCase {
    private let rect = CGRect(x: 0, y: 0, width: 100, height: 40)

    private func endpoints(of shape: UnavailableCrossedOutShape) -> (start: CGPoint, end: CGPoint)? {
        var points: [CGPoint] = []
        shape.path(in: rect).forEach { element in
            switch element {
            case .move(let point),
                 .line(let point): // swiftlint:disable:this indentation_width
                points.append(point)
            default:
                break
            }
        }
        guard points.count == 2, let start = points.first, let end = points.last else {
            return nil
        }
        return (start, end)
    }

    func test_default_direction_rises_left_to_right() throws {
        // What the colour swatches have always drawn; changing it would restyle them silently.
        let sut = try XCTUnwrap(endpoints(of: UnavailableCrossedOutShape()))
        XCTAssertEqual(sut.start, CGPoint(x: rect.maxX, y: rect.minY))
        XCTAssertEqual(sut.end, CGPoint(x: rect.minX, y: rect.maxY))
    }

    func test_size_chip_direction_falls_left_to_right() throws {
        let sut = try XCTUnwrap(endpoints(of: UnavailableCrossedOutShape(direction: .topLeadingToBottomTrailing)))
        XCTAssertEqual(sut.start, CGPoint(x: rect.minX, y: rect.minY))
        XCTAssertEqual(sut.end, CGPoint(x: rect.maxX, y: rect.maxY))
    }
}
