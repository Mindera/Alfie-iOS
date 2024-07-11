import Models
import SwiftUI

public struct RemoteImageWrapper<Provider: RemoteImageProvider>: View {
    private let provider: Provider

    public init(urlRequest: URLRequest?,
                transaction: Transaction,
                @ViewBuilder content: @escaping (RemoteImageState) -> Provider.ProviderContent) {
        self.provider = Provider(url: urlRequest?.url, transaction: transaction, content: content)
    }

    public var body: some View {
        provider
    }
}
