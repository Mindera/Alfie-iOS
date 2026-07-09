import AlicerceLogging
import Foundation
import SwiftUI
import class UIKit.UIFont

// MARK: - FontNames

public enum FontNames: String, CaseIterable {
    case sfProMedium = "SF Pro Display Medium"
    // rawValue is the PostScript name (resolved via UIFont(name:)); fileName is the .dataset name.
    case libreBaskerville = "LibreBaskerville-Regular"

    public var fileName: String {
        switch self {
        case .sfProMedium:
            return "SF-Pro-Display-Medium"
        case .libreBaskerville:
            return "LibreBaskerville-Regular"
        }
    }

    public func withSize(_ size: CGFloat) -> UIFont {
        guard let font = UIFont(name: rawValue, size: size) else {
            assertionFailure("There is no font for this value \(rawValue)")
            return UIFont()
        }
        return font
    }

    /// Maps a design-token font-family name (e.g. `"Libre Baskerville"`) to the PostScript name a
    /// bundled face is registered under (`UIFont(name:)` needs the PostScript name, not the family
    /// name). Returns `nil` for families that aren't bundled — those load by their own name.
    public static func postScriptName(forFamily family: String) -> String? {
        switch family {
        case "Libre Baskerville":
            return FontNames.libreBaskerville.rawValue
        default:
            return nil
        }
    }
}

// MARK: - FontManager

public enum FontManager {
    public static func registerAll() throws {
        try FontNames.allCases.forEach { fontName in
            try FontManager.registerFont(named: fontName.fileName)
        }
    }

    private static func registerFont(named name: String) throws {
        guard
            let asset = NSDataAsset(name: "\(name)", bundle: Bundle.module),
            // swiftlint:disable:next legacy_objc_type
            let provider = CGDataProvider(data: asset.data as NSData),
            let font = CGFont(provider)
        else {
            log.error("FontManager failed to register font \(name)")
            throw FontError.failedToRegisterFont(name)
        }

        CTFontManagerRegisterGraphicsFont(font, nil)
    }
}

// MARK: - FontError

public enum FontError: Swift.Error {
    case failedToRegisterFont(_ fontName: String)
}

extension UIFont {
    // swiftlint:disable:next strict_fileprivate
    fileprivate static func register(from url: URL) {
        guard let fontDataProvider = CGDataProvider(url: url as CFURL) else {
            log.error("could not get reference to font data provider")
            return
        }
        guard let font = CGFont(fontDataProvider) else {
            log.error("could not get font from coregraphics")
            return
        }
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(font, &error) else {
            log.error("error registering font: \(error.debugDescription)")
            return
        }
    }
}
