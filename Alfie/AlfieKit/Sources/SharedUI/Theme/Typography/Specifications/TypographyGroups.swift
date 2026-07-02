import Foundation

// Concrete sub-providers (no per-group protocol), matching the concrete-`let` design used for
// shape/spacing. Styles are stored and injectable (defaulting to the generated tokens), so a
// custom `TypographyProviderProtocol` conformer can substitute styles for tests/previews/themes.

// MARK: - Display

public struct TypographyDisplay {
    public let large: ThemedTypographyStyle
    public let medium: ThemedTypographyStyle
    public let small: ThemedTypographyStyle

    public init(
        large: ThemedTypographyStyle = .init(style: Typography.Display.large),
        medium: ThemedTypographyStyle = .init(style: Typography.Display.medium),
        small: ThemedTypographyStyle = .init(style: Typography.Display.small)
    ) {
        self.large = large
        self.medium = medium
        self.small = small
    }
}

// MARK: - Heading

public struct TypographyHeading {
    public let large: ThemedTypographyStyle
    public let medium: ThemedTypographyStyle
    public let small: ThemedTypographyStyle
    public let xSmall: ThemedTypographyStyle

    public init(
        large: ThemedTypographyStyle = .init(style: Typography.Heading.large),
        medium: ThemedTypographyStyle = .init(style: Typography.Heading.medium),
        small: ThemedTypographyStyle = .init(style: Typography.Heading.small),
        xSmall: ThemedTypographyStyle = .init(style: Typography.Heading.xSmall)
    ) {
        self.large = large
        self.medium = medium
        self.small = small
        self.xSmall = xSmall
    }
}

// MARK: - Body

public struct TypographyBody {
    public let large: ThemedTypographyStyle
    public let medium: ThemedTypographyStyle
    public let mediumStrikethrough: ThemedTypographyStyle
    public let small: ThemedTypographyStyle

    public init(
        large: ThemedTypographyStyle = .init(style: Typography.Body.large),
        medium: ThemedTypographyStyle = .init(style: Typography.Body.medium),
        mediumStrikethrough: ThemedTypographyStyle = .init(style: Typography.Body.mediumStrikethrough),
        small: ThemedTypographyStyle = .init(style: Typography.Body.small)
    ) {
        self.large = large
        self.medium = medium
        self.mediumStrikethrough = mediumStrikethrough
        self.small = small
    }
}

// MARK: - Label

public struct TypographyLabel {
    public let small: ThemedTypographyStyle
    public let smallBold: ThemedTypographyStyle

    public init(
        small: ThemedTypographyStyle = .init(style: Typography.Label.small),
        smallBold: ThemedTypographyStyle = .init(style: Typography.Label.smallBold)
    ) {
        self.small = small
        self.smallBold = smallBold
    }
}

// MARK: - Link

public struct TypographyLink {
    public let medium: ThemedTypographyStyle
    public let small: ThemedTypographyStyle

    public init(
        medium: ThemedTypographyStyle = .init(style: Typography.Link.medium),
        small: ThemedTypographyStyle = .init(style: Typography.Link.small)
    ) {
        self.medium = medium
        self.small = small
    }
}
