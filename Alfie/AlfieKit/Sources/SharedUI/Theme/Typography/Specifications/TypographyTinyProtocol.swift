import Foundation
import class UIKit.UIFont

// MARK: - TypographyTinyProtocol

public protocol TypographyTinyProtocol {
    var normal: UIFont { get }
    var normalItalic: UIFont { get }
    var bold: UIFont { get }
    var boldItalic: UIFont { get }

    /// 'circularBook 12'
    func normal(_ str: String) -> AttributedString
    func normal(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularBookItalic 12'
    func italic(_ str: String) -> AttributedString
    func italic(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularMedium 12'
    func bold(_ str: String) -> AttributedString
    func bold(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularMediumItalic 12'
    func boldItalic(_ str: String) -> AttributedString
    func boldItalic(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularMedium 12 Underline'
    func boldUnderline(_ str: String) -> AttributedString
    func boldUnderline(_ res: LocalizedStringResource) -> AttributedString
}

// MARK: - TypographyTiny

public class TypographyTiny: TypographyTinyProtocol {
    public var normal: UIFont { FontNames.sfProMedium.withSize(12) }
    public var normalItalic: UIFont { FontNames.sfProMedium.withSize(12) }
    public var bold: UIFont { FontNames.sfProMedium.withSize(12) }
    public var boldItalic: UIFont { FontNames.sfProMedium.withSize(12) }

    public init() {}

    public func normal(_ str: String) -> AttributedString {
        .init(str).build(
            font: normal
        )
    }

    public func normal(_ res: LocalizedStringResource) -> AttributedString {
        normal(String(localized: res))
    }

    public func italic(_ str: String) -> AttributedString {
        .init(str).build(
            font: normalItalic
        )
    }

    public func italic(_ res: LocalizedStringResource) -> AttributedString {
        italic(String(localized: res))
    }

    public func bold(_ str: String) -> AttributedString {
        .init(str).build(
            font: bold
        )
    }

    public func bold(_ res: LocalizedStringResource) -> AttributedString {
        bold(String(localized: res))
    }

    public func boldItalic(_ str: String) -> AttributedString {
        .init(str).build(
            font: boldItalic
        )
    }

    public func boldItalic(_ res: LocalizedStringResource) -> AttributedString {
        boldItalic(String(localized: res))
    }

    public func boldUnderline(_ str: String) -> AttributedString {
        .init(str).build(
            font: bold,
            isUnderlined: true
        )
    }

    public func boldUnderline(_ res: LocalizedStringResource) -> AttributedString {
        boldUnderline(String(localized: res))
    }
}
