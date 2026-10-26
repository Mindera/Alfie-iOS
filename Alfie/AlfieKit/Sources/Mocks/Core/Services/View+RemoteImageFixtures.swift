import Core
import Nuke
import SwiftUI
import UIKit

public extension View {
    /// Serves `images` to every `RemoteImage` beneath this view; any other URL fails without touching the network.
    /// Builds a new pipeline per call, so apply it once to the view under test rather than inside a `body`.
    func remoteImageFixtures(_ images: [URL: UIImage]) -> some View {
        environment(\.imagePipeline, .fixtures(images))
    }
}

private extension ImagePipeline {
    static func fixtures(_ images: [URL: UIImage]) -> ImagePipeline {
        var configuration = ImagePipeline.Configuration(dataLoader: FixtureOnlyDataLoader())
        configuration.imageCache = ImageCache()
        let pipeline = ImagePipeline(configuration: configuration)
        images.forEach { url, image in
            pipeline.cache[ImageRequest(url: url)] = ImageContainer(image: image)
        }
        return pipeline
    }
}

private struct FixtureOnlyDataLoader: DataLoading {
    struct MissingFixture: Error {
        let url: URL?
    }

    func loadData(
        with request: URLRequest,
        didReceiveData: @escaping (Data, URLResponse) -> Void,
        completion: @escaping (Error?) -> Void
    ) -> any Cancellable {
        completion(MissingFixture(url: request.url))
        return NoopCancellable()
    }
}

private final class NoopCancellable: Cancellable {
    func cancel() {}
}
