import SwiftUI

public protocol RemoteImageProvider: View {
    associatedtype Content: View
    associatedtype ProviderContent: View
    init(url: URL?, transaction: Transaction, @ViewBuilder content: @escaping (RemoteImageState) -> ProviderContent)
}

public enum RemoteImageState {
    case empty
    case success(Image)
    case failure(Error)
}
