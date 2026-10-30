import Combine
import Core
import SwiftUI
import UIKit

struct ZoomableCarouselRepresentable<Content: View> {
    typealias ViewControllerType = UIKitZoomableCarouselViewController<ImagePipelineForwarding<Content>>

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
            items: childViews.map { ImagePipelineForwarding(content: $0, source: context.environment) }
        )
    }

    func updateUIViewController(_ uiViewController: ViewControllerType, context: Context) {}
}

struct ImagePipelineForwarding<Content: View>: View {
    let content: Content
    let source: EnvironmentValues

    var body: some View {
        content.environment(\.imagePipeline, source.imagePipeline)
    }
}
