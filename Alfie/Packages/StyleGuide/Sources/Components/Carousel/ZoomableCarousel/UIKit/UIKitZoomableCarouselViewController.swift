import Combine
import SwiftUI
import UIKit

final class UIKitZoomableCarouselViewController<Content: View>: UIViewController {
    private let carousel: UIKitZoomableCarousel<Content>

    init(currentIndex: Binding<Int>,
         slidePublisher: AnyPublisher<Void, Never>,
         configuration: ZoomableCarouselConfiguration,
         items: [Content]) {
        self.carousel = UIKitZoomableCarousel(currentIndex: currentIndex,
                                              slidePublisher: slidePublisher,
                                              items: items,
                                              configuration: configuration)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = carousel
    }
}
