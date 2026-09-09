import Foundation
import Testing
@testable import AlfieCodeGenCore

@Suite("AlfieCodeImage")
struct AlfieCodeImageTests {
    private let link = URL(string: "https://localhost:4000/product/mens-jeans-slim-indigo?sku=SKU-8842")!
    /// Long enough to need a denser QR version than `link` does.
    private let longLink = URL(
        string: "https://localhost:4000/product/mens/outerwear/coats/wool-blend-double-breasted-camel"
            + "?sku=WOOL-COAT-CAMEL-UK-12-REGULAR"
    )!

    @Test("decoding a generated image returns exactly the encoded link")
    func roundTrips() throws {
        let png = try AlfieCodeImage.png(link: link, caption: nil, size: .swingTag)

        #expect(try PNGProbe.decodedMessage(in: png) == link.absoluteString)
    }

    @Test("a caption under the code does not disturb the payload")
    func roundTripsWithCaption() throws {
        let png = try AlfieCodeImage.png(link: link, caption: "mens-jeans-slim-indigo · SKU-8842", size: .swingTag)

        #expect(try PNGProbe.decodedMessage(in: png) == link.absoluteString)
    }

    @Test("a long link still round-trips")
    func roundTripsLongLink() throws {
        let png = try AlfieCodeImage.png(link: longLink, caption: nil, size: .swingTag)

        #expect(try PNGProbe.decodedMessage(in: png) == longLink.absoluteString)
    }

    @Test("the code prints at exactly the requested width")
    func printsAtRequestedWidth() throws {
        let png = try AlfieCodeImage.png(link: link, caption: nil, size: .swingTag)
        let attributes = try PNGProbe.attributes(of: png)

        #expect(abs(attributes.millimetresWide - PrintSize.swingTag.millimetres) < 0.1)
    }

    @Test("every code prints the same size, whatever its QR version")
    func printsOneSizeForAllCodes() throws {
        let short = try PNGProbe.attributes(of: AlfieCodeImage.png(link: link, caption: nil, size: .swingTag))
        let long = try PNGProbe.attributes(of: AlfieCodeImage.png(link: longLink, caption: nil, size: .swingTag))

        // Different QR versions, so different pixel counts — but the same width on paper.
        #expect(short.pixelWidth != long.pixelWidth)
        #expect(abs(short.millimetresWide - long.millimetresWide) < 0.1)
    }

    @Test("resolution is at least the requested floor, so it stays legible at that size")
    func meetsResolutionFloor() throws {
        let png = try AlfieCodeImage.png(link: longLink, caption: nil, size: .swingTag)
        let attributes = try PNGProbe.attributes(of: png)

        #expect(attributes.dotsPerInch >= PrintSize.swingTag.minimumDotsPerInch - 1)
        #expect(attributes.pixelWidth >= PrintSize.swingTag.minimumPixels)
    }

    @Test("a smaller tag is honoured rather than silently rounded up")
    func honoursASmallerTag() throws {
        let size = PrintSize(millimetres: 20, minimumDotsPerInch: 300)
        let attributes = try PNGProbe.attributes(of: AlfieCodeImage.png(link: link, caption: nil, size: size))

        #expect(abs(attributes.millimetresWide - 20) < 0.1)
    }

    @Test("the caption adds height below the code, not width")
    func captionAddsHeightOnly() throws {
        let bare = try PNGProbe.attributes(of: AlfieCodeImage.png(link: link, caption: nil, size: .swingTag))
        let captioned = try PNGProbe.attributes(
            of: AlfieCodeImage.png(link: link, caption: "mens-jeans", size: .swingTag)
        )

        #expect(captioned.pixelWidth == bare.pixelWidth)
        #expect(captioned.pixelHeight > bare.pixelHeight)
    }

    @Test("an uncaptioned code is square")
    func uncaptionedCodeIsSquare() throws {
        let attributes = try PNGProbe.attributes(of: AlfieCodeImage.png(link: link, caption: nil, size: .swingTag))

        #expect(attributes.pixelWidth == attributes.pixelHeight)
    }
}
