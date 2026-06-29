import Foundation

// MARK: - TypographyProviderProtocol

public protocol TypographyProviderProtocol {
    var header: TypographyHeaderProtocol { get }
    var paragraph: TypographyParagraphProtocol { get }
    var small: TypographySmallProtocol { get }
    var tiny: TypographyTinyProtocol { get }

    // Token-driven Figma groups (additive; legacy members above removed in a later phase).
    var display: TypographyDisplayProtocol { get }
    var heading: TypographyHeadingProtocol { get }
    var body: TypographyBodyProtocol { get }
    var label: TypographyLabelProtocol { get }
    var link: TypographyLinkProtocol { get }
}

// MARK: - TypographyProvider

public class TypographyProvider: TypographyProviderProtocol {
    public var header: TypographyHeaderProtocol
    public var paragraph: TypographyParagraphProtocol
    public var small: TypographySmallProtocol
    public var tiny: TypographyTinyProtocol

    public let display: TypographyDisplayProtocol = TypographyDisplay()
    public let heading: TypographyHeadingProtocol = TypographyHeading()
    public let body: TypographyBodyProtocol = TypographyBody()
    public let label: TypographyLabelProtocol = TypographyLabel()
    public let link: TypographyLinkProtocol = TypographyLink()

    public init(
        header: TypographyHeaderProtocol = TypographyHeader(),
        paragraph: TypographyParagraphProtocol = TypographyParagraph(),
        small: TypographySmallProtocol = TypographySmall(),
        tiny: TypographyTinyProtocol = TypographyTiny()
    ) {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            try? FontManager.registerAll()
        }
        self.header = header
        self.paragraph = paragraph
        self.small = small
        self.tiny = tiny
    }
}
