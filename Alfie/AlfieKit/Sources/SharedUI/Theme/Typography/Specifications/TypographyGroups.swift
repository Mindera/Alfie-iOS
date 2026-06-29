import Foundation

// MARK: - Display

public protocol TypographyDisplayProtocol {
    var large: ThemedTypographyStyle { get }
    var medium: ThemedTypographyStyle { get }
    var small: ThemedTypographyStyle { get }
}

public struct TypographyDisplay: TypographyDisplayProtocol {
    public init() {}
    public var large: ThemedTypographyStyle { .init(style: Typography.Display.large) }
    public var medium: ThemedTypographyStyle { .init(style: Typography.Display.medium) }
    public var small: ThemedTypographyStyle { .init(style: Typography.Display.small) }
}

// MARK: - Heading

// Named `TypographyHeading` to avoid clashing with the legacy `TypographyHeader`.
public protocol TypographyHeadingProtocol {
    var large: ThemedTypographyStyle { get }
    var medium: ThemedTypographyStyle { get }
    var small: ThemedTypographyStyle { get }
    var xSmall: ThemedTypographyStyle { get }
}

public struct TypographyHeading: TypographyHeadingProtocol {
    public init() {}
    public var large: ThemedTypographyStyle { .init(style: Typography.Heading.large) }
    public var medium: ThemedTypographyStyle { .init(style: Typography.Heading.medium) }
    public var small: ThemedTypographyStyle { .init(style: Typography.Heading.small) }
    public var xSmall: ThemedTypographyStyle { .init(style: Typography.Heading.xSmall) }
}

// MARK: - Body

public protocol TypographyBodyProtocol {
    var large: ThemedTypographyStyle { get }
    var medium: ThemedTypographyStyle { get }
    var mediumStrikethrough: ThemedTypographyStyle { get }
    var small: ThemedTypographyStyle { get }
}

public struct TypographyBody: TypographyBodyProtocol {
    public init() {}
    public var large: ThemedTypographyStyle { .init(style: Typography.Body.large) }
    public var medium: ThemedTypographyStyle { .init(style: Typography.Body.medium) }
    public var mediumStrikethrough: ThemedTypographyStyle { .init(style: Typography.Body.mediumStrikethrough) }
    public var small: ThemedTypographyStyle { .init(style: Typography.Body.small) }
}

// MARK: - Label

public protocol TypographyLabelProtocol {
    var small: ThemedTypographyStyle { get }
    var smallBold: ThemedTypographyStyle { get }
}

public struct TypographyLabel: TypographyLabelProtocol {
    public init() {}
    public var small: ThemedTypographyStyle { .init(style: Typography.Label.small) }
    public var smallBold: ThemedTypographyStyle { .init(style: Typography.Label.smallBold) }
}

// MARK: - Link

public protocol TypographyLinkProtocol {
    var medium: ThemedTypographyStyle { get }
    var small: ThemedTypographyStyle { get }
}

public struct TypographyLink: TypographyLinkProtocol {
    public init() {}
    public var medium: ThemedTypographyStyle { .init(style: Typography.Link.medium) }
    public var small: ThemedTypographyStyle { .init(style: Typography.Link.small) }
}
