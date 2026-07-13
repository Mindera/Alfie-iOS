import Combine
import SwiftUI

private enum Constants {
    static var backgroundOpacity: CGFloat { 0.7 }
    static let closeIconBackgroundOpacity: CGFloat = 0.7
}

public struct ZoomableCarousel<Content: View>: View {
    @Binding private var currentIndex: Int
    private let childViews: [Content]
    private var configuration: ZoomableCarouselConfiguration
    private let slidePublisher: AnyPublisher<Void, Never>
    private let slideSubject: PassthroughSubject<Void, Never> = .init()

    public init(
        currentIndex: Binding<Int>,
        configuration: ZoomableCarouselConfiguration,
        _ childViews: () -> [Content]
    ) {
        self._currentIndex = currentIndex
        self.configuration = configuration
        self.childViews = childViews()
        self.slidePublisher = slideSubject.eraseToAnyPublisher()
    }

    public var body: some View {
        ZoomableCarouselRepresentable(
            currentIndex: $currentIndex,
            childViews: childViews,
            configuration: configuration,
            slidePublisher: slidePublisher
        )
        .edgesIgnoringSafeArea(.all)
        .overlay {
            VStack {
                Button(action: {
                    configuration.isPresented.wrappedValue = false
                }, label: {
                    ThemedIcon(.close, size: .medium, tint: Primitives.Colours.neutrals800)
                        .padding(Primitives.Spacing.spacing4)
                        .background(Primitives.Colours.neutrals0.opacity(Constants.closeIconBackgroundOpacity))
                        .clipShape(Circle())
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .edgesIgnoringSafeArea(.bottom)
                .padding(.bottom, Primitives.Spacing.spacing16)
                .padding(.leading, Primitives.Spacing.spacing16)

                Spacer()

                if childViews.count > 1 {
                    PaginatedControl(
                        configuration: .init(),
                        itemsCount: childViews.count,
                        selectedIndex: $currentIndex,
                        slideSubject: slideSubject
                    )
                    .padding(Primitives.Spacing.spacing16)
                    .background(Primitives.Colours.neutrals0.opacity(Constants.backgroundOpacity))
                    .cornerRadius(Sizing.radiusSoft)
                }
            }
        }
    }
}
