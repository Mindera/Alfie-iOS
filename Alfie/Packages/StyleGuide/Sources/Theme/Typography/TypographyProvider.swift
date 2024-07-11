import Foundation

// MARK: - TypographyProviderProtocol

public protocol TypographyProviderProtocol {
    var header: TypographyHeaderProtocol { get }
    var paragraph: TypographyParagraphProtocol { get }
    var small: TypographySmallProtocol { get }
    var tiny: TypographyTinyProtocol { get }
}

// MARK: - TypographyProvider

public class TypographyProvider: TypographyProviderProtocol {
    public var header: TypographyHeaderProtocol
    public var paragraph: TypographyParagraphProtocol
    public var small: TypographySmallProtocol
    public var tiny: TypographyTinyProtocol

    public init(header: TypographyHeaderProtocol = TypographyHeader(),
                paragraph: TypographyParagraphProtocol = TypographyParagraph(),
                small: TypographySmallProtocol = TypographySmall(),
                tiny: TypographyTinyProtocol = TypographyTiny()) {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            try? FontManager.registerAll()
        }
        self.header = header
        self.paragraph = paragraph
        self.small = small
        self.tiny = tiny
    }
}
