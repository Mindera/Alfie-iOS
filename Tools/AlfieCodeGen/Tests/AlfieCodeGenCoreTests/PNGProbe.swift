import CoreImage
import Foundation
import ImageIO
import Testing
@testable import AlfieCodeGenCore

/// Reads back a rendered PNG the way a printer and a phone camera would: its pixel size, the DPI it
/// claims, and what a QR decoder actually gets out of it.
enum PNGProbe {
    struct Attributes {
        let pixelWidth: Int
        let pixelHeight: Int
        let dotsPerInch: Double

        /// What a ruler laid across the printed code would read, at 100% scale.
        var millimetresWide: Double { Double(pixelWidth) / dotsPerInch * 25.4 }
    }

    static func attributes(of data: Data) throws -> Attributes {
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let properties = try #require(
            CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        )
        return Attributes(
            pixelWidth: try #require(properties[kCGImagePropertyPixelWidth] as? Int),
            pixelHeight: try #require(properties[kCGImagePropertyPixelHeight] as? Int),
            dotsPerInch: try #require(properties[kCGImagePropertyDPIWidth] as? Double)
        )
    }

    /// The string a scanner reads out of the image, or `nil` if nothing decodes.
    static func decodedMessage(in data: Data) throws -> String? {
        let image = try #require(CIImage(data: data))
        let detector = try #require(
            CIDetector(
                ofType: CIDetectorTypeQRCode,
                context: nil,
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            )
        )
        let features = detector.features(in: image).compactMap { $0 as? CIQRCodeFeature }
        #expect(features.count <= 1, "more than one code in a single image")
        return features.first?.messageString
    }
}
