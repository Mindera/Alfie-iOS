import Foundation

public enum PaginatedViewState<Value, StateError: Error> {
    case loadingFirstPage(Value)
    case loadingNextPage(Value)
    case success(Value)
    case error(StateError)
}

public extension PaginatedViewState {
    var value: Value? {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .loadingFirstPage(let value),
             .success(let value), // swiftlint:disable:this indentation_width
             .loadingNextPage(let value):
            return value
        case .error:
            return nil
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    var isLoadingFirstPage: Bool {
        guard case .loadingFirstPage = self else {
            return false
        }
        return true
    }

    var isLoadingNextPage: Bool {
        guard case .loadingNextPage = self else {
            return false
        }
        return true
    }

    var isSuccess: Bool {
        guard case .success = self else {
            return false
        }
        return true
    }

    var didFail: Bool {
        guard case .error = self else {
            return false
        }
        return true
    }

    var failure: StateError? {
        guard case .error(let type) = self else {
            return nil
        }
        return type
    }
}
