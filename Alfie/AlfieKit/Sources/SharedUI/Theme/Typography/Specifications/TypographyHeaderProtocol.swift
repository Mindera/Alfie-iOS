import Foundation
import class UIKit.UIFont

// MARK: - TypographyHeaderProtocol

public protocol TypographyHeaderProtocol {
    /// 'freightBook'
    var h1: UIFont { get }
    /// 'circularBold'
    var h2: UIFont { get }
    /// 'circularMedium'
    var h3: UIFont { get }

    /// 'freightBook 36'
    func h1(_ str: String) -> AttributedString
    func h1(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularBold 24'
    func h2(_ str: String) -> AttributedString
    func h2(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularMedium 20'
    func h3(_ str: String) -> AttributedString
    func h3(_ res: LocalizedStringResource) -> AttributedString
    /// 'circularMedium 20 Underline'
    func h3Underline(_ str: String) -> AttributedString
    func h3Underline(_ res: LocalizedStringResource) -> AttributedString
}

// MARK: - TypographyHeader

public final class TypographyHeader: TypographyHeaderProtocol {
    public var h1: UIFont { FontNames.sfProMedium.withSize(36) }
    public var h2: UIFont { FontNames.sfProMedium.withSize(24) }
    public var h3: UIFont { FontNames.sfProMedium.withSize(20) }

    public init() {}

    public func h1(_ str: String) -> AttributedString {
        .init(str).build(
            font: h1
        )
    }

    public func h1(_ res: LocalizedStringResource) -> AttributedString {
        h1(String(localized: res))
    }

    public func h2(_ str: String) -> AttributedString {
        .init(str).build(
            font: h2
        )
    }

    public func h2(_ res: LocalizedStringResource) -> AttributedString {
        h2(String(localized: res))
    }

    public func h3(_ str: String) -> AttributedString {
        .init(str).build(
            font: h3
        )
    }

    public func h3(_ res: LocalizedStringResource) -> AttributedString {
        h2(String(localized: res))
    }

    public func h3Underline(_ str: String) -> AttributedString {
        .init(str).build(
            font: h3,
            isUnderlined: true
        )
    }

    public func h3Underline(_ res: LocalizedStringResource) -> AttributedString {
        h3Underline(String(localized: res))
    }
}
