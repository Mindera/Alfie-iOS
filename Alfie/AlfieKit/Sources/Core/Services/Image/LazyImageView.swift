import Model
import NukeUI
import SwiftUI

struct LazyImageView<Content: View>: RemoteImageProvider {
    private let url: URL?
    private let transaction: Transaction
    let content: (RemoteImageState) -> Content

    init(url: URL?, transaction: Transaction, @ViewBuilder content: @escaping (RemoteImageState) -> Content) {
        self.url = url
        self.transaction = transaction
        self.content = content
    }

    var body: some View {
        LazyImage(url: url, transaction: transaction) { imageState in
            if let image = imageState.image {
                content(.success(image))
            } else if let error = imageState.error {
                content(.failure(error))
            } else {
                content(.empty)
            }
        }
    }
}
