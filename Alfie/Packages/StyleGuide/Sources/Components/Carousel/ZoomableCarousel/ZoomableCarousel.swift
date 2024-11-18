import Combine
import SwiftUI

private enum Constants {
    static var backgroundOpacity: CGFloat { 0.7 }
    static let closeIconSize: CGFloat = 24
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
                    Icon.close.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.closeIconSize, height: Constants.closeIconSize)
                        .padding(Spacing.space050)
                        .foregroundStyle(Colors.primary.mono900)
                        .background(Colors.primary.white.opacity(Constants.closeIconBackgroundOpacity))
                        .clipShape(Circle())
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .edgesIgnoringSafeArea(.bottom)
                .padding(.bottom, Spacing.space200)
                .padding(.leading, Spacing.space200)

                Spacer()

                if childViews.count > 1 {
                    PaginatedControl(
                        configuration: .init(),
                        itemsCount: childViews.count,
                        selectedIndex: $currentIndex,
                        slideSubject: slideSubject
                    )
                    .padding(Spacing.space200)
                    .background(Colors.primary.white.opacity(Constants.backgroundOpacity))
                    .cornerRadius(CornerRadius.s)
                }
            }
        }
    }
}
