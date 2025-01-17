import Foundation
import class UIKit.UIFont

// MARK: - TypographyParagraphProtocol

public protocol TypographyParagraphProtocol {
    /// 'circularBook'
    var normal: UIFont { get }
    /// 'circularBookItalic'
    var normalItalic: UIFont { get }
    /// 'circularMedium'
    var bold: UIFont { get }
    /// 'circularMediumItalic'
    var boldItalic: UIFont { get }

    /// 'circularBook 16'
    func normal(_ str: String) -> AttributedString
    func normal(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularBookItalic 16'
    func italic(_ str: String) -> AttributedString
    func italic(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularMedium 16'
    func bold(_ str: String) -> AttributedString
    func bold(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularMediumItalic 16'
    func boldItalic(_ str: String) -> AttributedString
    func boldItalic(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularBook 16 Underline'
    func normalUnderline(_ str: String) -> AttributedString
    func normalUnderline(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularMedium 16 Underline'
    func boldUnderline(_ str: String) -> AttributedString
    func boldUnderline(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularBook 16 Strikethrough'
    func normalStrike(_ str: String) -> AttributedString
    func normalStrike(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularMedium 16 Strikethrough'
    func boldStrike(_ str: String) -> AttributedString
    func boldStrike(_ res: LocalizedStringResource) -> AttributedString
}

// MARK: - TypographyParagraph

public final class TypographyParagraph: TypographyParagraphProtocol {
    public var normal: UIFont { FontNames.sfProMedium.withSize(16) }
    public var normalItalic: UIFont { FontNames.sfProMedium.withSize(16) }
    public var bold: UIFont { FontNames.sfProMedium.withSize(16) }
    public var boldItalic: UIFont { FontNames.sfProMedium.withSize(16) }

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

    public func normalUnderline(_ str: String) -> AttributedString {
        .init(str).build(
            font: normal,
            isUnderlined: true
        )
    }

    public func normalUnderline(_ res: LocalizedStringResource) -> AttributedString {
        normalUnderline(String(localized: res))
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

    public func normalStrike(_ str: String) -> AttributedString {
        .init(str).build(
            font: normal,
            strike: true
        )
    }

    public func normalStrike(_ res: LocalizedStringResource) -> AttributedString {
        normalStrike(String(localized: res))
    }

    public func boldStrike(_ str: String) -> AttributedString {
        .init(str).build(
            font: bold,
            strike: true
        )
    }

    public func boldStrike(_ res: LocalizedStringResource) -> AttributedString {
        boldStrike(String(localized: res))
    }
}
