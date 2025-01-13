import Models
import SwiftUI

struct AsyncImageView<Content: View>: RemoteImageProvider {
    private let urlRequest: URLRequest?
    private let urlSession: URLSession
    private let transaction: Transaction
    let content: (RemoteImageState) -> Content

    init(url: URL?, transaction: Transaction, @ViewBuilder content: @escaping (RemoteImageState) -> Content) {
        let urlRequest = url.map { URLRequest(url: $0) }
        self.init(urlRequest: urlRequest, transaction: transaction, content: content)
    }

    init(
        urlRequest: URLRequest?,
        urlCache: URLCache = .shared,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (RemoteImageState) -> Content
    ) {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        self.urlRequest = urlRequest
        self.urlSession = URLSession(configuration: configuration)
        self.transaction = transaction
        self.content = content
    }

    var body: some View {
        AsyncImage(url: urlRequest?.url, transaction: transaction) { phase in
            // swiftlint:disable vertical_whitespace_between_cases
            switch phase {
            case .empty:
                content(.empty)
            case .success(let image):
                content(.success(image))
            case .failure(let error):
                content(.failure(error))
            @unknown default:
                content(.empty)
            }
            // swiftlint:enable vertical_whitespace_between_cases
        }
    }
}
