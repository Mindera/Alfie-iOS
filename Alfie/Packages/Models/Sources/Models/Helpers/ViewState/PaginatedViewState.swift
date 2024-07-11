import Foundation

public enum PaginatedViewState<Value, StateError: Error> {
    case loadingFirstPage(Value)
    case loadingNextPage(Value)
    case success(Value)
    case error(StateError)
}

public extension PaginatedViewState {
    var value: Value? {
        switch self {
            case .loadingFirstPage(let value),
                 .success(let value),
                 .loadingNextPage(let value):
                return value
            case.error:
                return nil
        }
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
        guard case let .error(type) = self else {
            return nil
        }
        return type
    }
}
