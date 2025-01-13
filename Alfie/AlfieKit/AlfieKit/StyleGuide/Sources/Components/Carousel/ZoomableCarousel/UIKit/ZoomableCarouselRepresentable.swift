import Combine
import SwiftUI
import UIKit

struct ZoomableCarouselRepresentable<Content: View> {
    typealias ViewControllerType = UIKitZoomableCarouselViewController<Content>

    @Binding private var currentIndex: Int
    private let childViews: [Content]
    private let configuration: ZoomableCarouselConfiguration
    private let slidePublisher: AnyPublisher<Void, Never>

    public init(
        currentIndex: Binding<Int>,
        childViews: [Content],
        configuration: ZoomableCarouselConfiguration,
        slidePublisher: AnyPublisher<Void, Never>
    ) {
        self._currentIndex = currentIndex
        self.childViews = childViews
        self.configuration = configuration
        self.slidePublisher = slidePublisher
    }
}

extension ZoomableCarouselRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewControllerType {
        .init(
            currentIndex: $currentIndex,
            slidePublisher: slidePublisher,
            configuration: configuration,
            items: childViews
        )
    }

    func updateUIViewController(_ uiViewController: UIKitZoomableCarouselViewController<Content>, context: Context) {}
}
