import Foundation

// MARK: - TypographyProviderProtocol

public protocol TypographyProviderProtocol {
    var display: TypographyDisplay { get }
    var heading: TypographyHeading { get }
    var body: TypographyBody { get }
    var label: TypographyLabel { get }
    var link: TypographyLink { get }
}

// MARK: - TypographyProvider

public class TypographyProvider: TypographyProviderProtocol {
    public let display: TypographyDisplay
    public let heading: TypographyHeading
    public let body: TypographyBody
    public let label: TypographyLabel
    public let link: TypographyLink

    public init(
        display: TypographyDisplay = TypographyDisplay(),
        heading: TypographyHeading = TypographyHeading(),
        body: TypographyBody = TypographyBody(),
        label: TypographyLabel = TypographyLabel(),
        link: TypographyLink = TypographyLink()
    ) {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            try? FontManager.registerAll()
        }
        self.display = display
        self.heading = heading
        self.body = body
        self.label = label
        self.link = link
    }
}
