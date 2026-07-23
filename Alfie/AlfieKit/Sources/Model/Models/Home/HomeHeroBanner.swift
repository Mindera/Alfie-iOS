import Foundation

/// A single Home hero-banner slide. Content is mock/placeholder for now; a future BFF query maps into
/// this same shape so the view layer doesn't change. `imageName` resolves against the Home module bundle.
public struct HomeHeroBanner: Equatable, Identifiable, Hashable {
    public let id: String
    public let imageName: String
    public let title: String

    public init(id: String, imageName: String, title: String) {
        self.id = id
        self.imageName = imageName
        self.title = title
    }
}

public extension HomeHeroBanner {
    /// Placeholder slides shown until the BFF provides home content. Image names match the Home
    /// module's `HomeAssets` catalog; titles stand in for server-driven copy (not L10n chrome).
    static let placeholders: [HomeHeroBanner] = [
        .init(
            id: "hero-1",
            imageName: "hero-1",
            title: "Transcending Trends\nfor Breezy Nights"
        ),
        .init(
            id: "hero-2",
            imageName: "hero-2",
            title: "Effortless Layers\nfor Cooler Days"
        ),
        .init(
            id: "hero-3",
            imageName: "hero-3",
            title: "Timeless Pieces\nMade to Last"
        ),
    ]
}
