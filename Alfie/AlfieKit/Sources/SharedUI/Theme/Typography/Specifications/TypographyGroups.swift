import Foundation

// Concrete sub-providers (no per-group protocol): mockability lives on the top-level
// `TypographyProviderProtocol`, matching the concrete-`let` design used for shape/spacing.

// MARK: - Display

public struct TypographyDisplay {
    public init() {}
    public var large: ThemedTypographyStyle { .init(style: Typography.Display.large) }
    public var medium: ThemedTypographyStyle { .init(style: Typography.Display.medium) }
    public var small: ThemedTypographyStyle { .init(style: Typography.Display.small) }
}

// MARK: - Heading

public struct TypographyHeading {
    public init() {}
    public var large: ThemedTypographyStyle { .init(style: Typography.Heading.large) }
    public var medium: ThemedTypographyStyle { .init(style: Typography.Heading.medium) }
    public var small: ThemedTypographyStyle { .init(style: Typography.Heading.small) }
    public var xSmall: ThemedTypographyStyle { .init(style: Typography.Heading.xSmall) }
}

// MARK: - Body

public struct TypographyBody {
    public init() {}
    public var large: ThemedTypographyStyle { .init(style: Typography.Body.large) }
    public var medium: ThemedTypographyStyle { .init(style: Typography.Body.medium) }
    public var mediumStrikethrough: ThemedTypographyStyle { .init(style: Typography.Body.mediumStrikethrough) }
    public var small: ThemedTypographyStyle { .init(style: Typography.Body.small) }
}

// MARK: - Label

public struct TypographyLabel {
    public init() {}
    public var small: ThemedTypographyStyle { .init(style: Typography.Label.small) }
    public var smallBold: ThemedTypographyStyle { .init(style: Typography.Label.smallBold) }
}

// MARK: - Link

public struct TypographyLink {
    public init() {}
    public var medium: ThemedTypographyStyle { .init(style: Typography.Link.medium) }
    public var small: ThemedTypographyStyle { .init(style: Typography.Link.small) }
}
