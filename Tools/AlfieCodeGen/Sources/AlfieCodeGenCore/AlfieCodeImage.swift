import CoreGraphics
import CoreImage
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Renders one printable Alfie code: a QR code carrying the link, with an optional caption
/// underneath so whoever is cutting up the sheet knows which tag is which.
public enum AlfieCodeImage {
    /// Error correction level. `M` (~15%) keeps the modules large enough to print small; the codes
    /// are printed fresh for a demo, not stuck to a crate for a year.
    private static let correctionLevel = "M"
    /// Quiet zone, in modules. Four is the QR spec's minimum for reliable acquisition.
    private static let quietZoneModules = 4

    public static func png(link: URL, caption: String?, size: PrintSize) throws -> Data {
        let modules = try renderModules(for: link)

        // The printed square is the code plus its quiet zone, so that is what the scale is derived
        // from: sizing the code alone leaves each QR version printing at a different width.
        let totalModules = modules.width + quietZoneModules * 2
        let scale = max(1, Int((Double(size.minimumPixels) / Double(totalModules)).rounded(.up)))
        let quietZone = quietZoneModules * scale
        let side = totalModules * scale

        let captionLayout = caption.map { CaptionLayout(text: $0, width: side, scale: scale) }
        let height = side + (captionLayout?.height ?? 0)

        guard let context = CGContext(
            data: nil,
            width: side,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            throw AlfieCodeError.renderFailed(link: link.absoluteString)
        }

        context.setFillColor(gray: 1, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: side, height: height))

        // Origin is bottom-left: the code sits on top, the caption in the strip below it.
        context.interpolationQuality = .none
        context.draw(
            modules.image,
            in: CGRect(
                x: quietZone,
                y: (captionLayout?.height ?? 0) + quietZone,
                width: modules.width * scale,
                height: modules.height * scale
            )
        )
        captionLayout?.draw(in: context)

        guard let image = context.makeImage() else {
            throw AlfieCodeError.renderFailed(link: link.absoluteString)
        }
        // The code square — not the captioned image — is what has to measure `size.millimetres`.
        return try encodePNG(image, dotsPerInch: size.dotsPerInch(forPixels: side), link: link)
    }

    // MARK: - QR

    private struct Modules {
        let image: CGImage
        let width: Int
        let height: Int
    }

    /// One pixel per QR module, unscaled — CoreImage's native output for the generator.
    private static func renderModules(for link: URL) throws -> Modules {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            throw AlfieCodeError.renderFailed(link: link.absoluteString)
        }
        filter.setValue(Data(link.absoluteString.utf8), forKey: "inputMessage")
        filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")

        guard
            let output = filter.outputImage,
            let image = CIContext().createCGImage(output, from: output.extent)
        else {
            throw AlfieCodeError.renderFailed(link: link.absoluteString)
        }
        return Modules(image: image, width: image.width, height: image.height)
    }

    // MARK: - Caption

    private struct CaptionLayout {
        let line: CTLine
        let width: Int
        let height: Int
        let baseline: CGFloat

        init(text: String, width: Int, scale: Int) {
            let fontSize = max(8, CGFloat(scale) * 4)
            var line = Self.makeLine(text, pointSize: fontSize)

            // A Handle can be longer than the code is wide; shrink to fit rather than clip it.
            let available = CGFloat(width) - fontSize
            let typeset = CTLineGetTypographicBounds(line, nil, nil, nil)
            if typeset > available, typeset > 0 {
                line = Self.makeLine(text, pointSize: fontSize * available / typeset)
            }

            self.line = line
            self.width = width
            baseline = fontSize * 0.8
            height = Int((fontSize * 1.8).rounded(.up))
        }

        /// CoreText only — this package has no AppKit, so `NSAttributedString.Key.font` is unavailable.
        private static func makeLine(_ text: String, pointSize: CGFloat) -> CTLine {
            let attributed = NSAttributedString(
                string: text,
                attributes: [
                    NSAttributedString.Key(kCTFontAttributeName as String):
                        CTFontCreateWithName("Menlo" as CFString, pointSize, nil),
                    NSAttributedString.Key(kCTForegroundColorAttributeName as String):
                        CGColor(gray: 0, alpha: 1),
                ]
            )
            return CTLineCreateWithAttributedString(attributed)
        }

        func draw(in context: CGContext) {
            let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
            context.textPosition = CGPoint(
                x: (CGFloat(width) - bounds.width) / 2 - bounds.origin.x,
                y: baseline
            )
            CTLineDraw(line, context)
        }
    }

    // MARK: - Encoding

    private static func encodePNG(_ image: CGImage, dotsPerInch: Double, link: URL) throws -> Data {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw AlfieCodeError.renderFailed(link: link.absoluteString)
        }

        // The DPI is what makes this print-ready: without it, a print dialog guesses the size.
        CGImageDestinationAddImage(destination, image, [
            kCGImagePropertyDPIWidth: dotsPerInch,
            kCGImagePropertyDPIHeight: dotsPerInch,
        ] as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            throw AlfieCodeError.renderFailed(link: link.absoluteString)
        }
        return data as Data
    }
}
