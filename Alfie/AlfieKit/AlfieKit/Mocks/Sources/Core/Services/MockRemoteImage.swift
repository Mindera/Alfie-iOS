import Models
import SwiftUI

public struct MockRemoteImage<Content: View>: RemoteImageProvider {
    var forcedState: RemoteImageState = .empty
    let content: (RemoteImageState) -> Content

    public init(url: URL?, transaction: Transaction, @ViewBuilder content: @escaping (RemoteImageState) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(forcedState)
    }
}
