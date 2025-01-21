import Models
import SwiftUI

public struct RemoteImage<Success: View, Failure: View, Placeholder: View>: View {
    private let urlRequest: URLRequest?
    private let transaction: Transaction
    private let success: (Image) -> Success
    private let failure: (Error) -> Failure
    private let placeholder: () -> Placeholder

    public init(
        urlRequest: URLRequest?,
        transaction: Transaction = Transaction(),
        @ViewBuilder success: @escaping (Image) -> Success,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping (Error) -> Failure
    ) {
        self.urlRequest = urlRequest
        self.transaction = transaction
        self.success = success
        self.placeholder = placeholder
        self.failure = failure
    }

    public init(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder success: @escaping (Image) -> Success,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping (Error) -> Failure
    ) {
        let urlRequest = url.map { URLRequest(url: $0) }
        self.init(
            urlRequest: urlRequest,
            transaction: transaction,
            success: success,
            placeholder: placeholder,
            failure: failure
        )
    }

    public var body: some View {
        RemoteImageWrapper<LazyImageView>(urlRequest: urlRequest, transaction: transaction) { state in
            // swiftlint:disable vertical_whitespace_between_cases
            switch state {
            case .empty:
                placeholder()
            case .success(let image):
                success(image)
            case .failure(let error):
                failure(error)
            }
            // swiftlint:enable vertical_whitespace_between_cases
        }
    }
}

public extension RemoteImage where Failure == EmptyView, Placeholder == EmptyView {
    init(url: URL?, transaction: Transaction = Transaction()) where Success == Image {
        self.init(url: url, transaction: transaction) { image in
            image
        }
    }

    init(url: URL?, transaction: Transaction = Transaction(), @ViewBuilder success: @escaping (Image) -> Success) {
        var urlRequest: URLRequest?

        if let url {
            urlRequest = URLRequest(url: url)
        }

        self.init(
            urlRequest: urlRequest,
            transaction: transaction,
            success: success,
            placeholder: { EmptyView() },
            failure: { _ in EmptyView() }
        )
    }
}
