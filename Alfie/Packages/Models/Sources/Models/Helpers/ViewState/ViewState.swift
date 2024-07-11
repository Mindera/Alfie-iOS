import Foundation

public enum ViewState<Value, StateError: Error> {
    case loading
    case success(Value)
    case error(StateError)
}

public extension ViewState {
    var value: Value? {
        guard case let .success(value) = self else {
            return nil
        }
        return value
    }

    var isLoading: Bool {
        guard case .loading = self else {
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
