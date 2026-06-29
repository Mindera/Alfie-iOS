import Foundation

// MARK: - TypographyProviderProtocol

public protocol TypographyProviderProtocol {
    var display: TypographyDisplayProtocol { get }
    var heading: TypographyHeadingProtocol { get }
    var body: TypographyBodyProtocol { get }
    var label: TypographyLabelProtocol { get }
    var link: TypographyLinkProtocol { get }
}

// MARK: - TypographyProvider

public class TypographyProvider: TypographyProviderProtocol {
    public let display: TypographyDisplayProtocol = TypographyDisplay()
    public let heading: TypographyHeadingProtocol = TypographyHeading()
    public let body: TypographyBodyProtocol = TypographyBody()
    public let label: TypographyLabelProtocol = TypographyLabel()
    public let link: TypographyLinkProtocol = TypographyLink()

    public init() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            try? FontManager.registerAll()
        }
    }
}
