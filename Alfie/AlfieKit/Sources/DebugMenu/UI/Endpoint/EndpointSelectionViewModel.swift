import Foundation
import Model
import Utils

public final class EndpointSelectionViewModel: ObservableObject {
    private let apiEndpointService: ApiEndpointServiceProtocol
    private let apiKeyService: BFFApiKeyServiceProtocol
    @Published public var selectedEndpointOption: ApiEndpointOption?
    @Published public var customEndpointUrl: String
    @Published public var bffApiKey: String
    @Published public private(set) var shouldShowUrlError = false
    @Published public private(set) var shouldShowSuccess = false
    private var isSaving = false
    let closeEndpointSelection: () -> Void

    public var isInputDisabled: Bool {
        guard !isSaving else {
            return true
        }

        return selectedEndpointOption != .custom(url: nil)
    }

    public var isSaveDisabled: Bool {
        guard !isSaving else {
            return true
        }

        return !hasEndpointChange && !hasApiKeyChange
    }

    public var availableEndpointOptions = ApiEndpointOption.allCases

    public var disabledEndpointOptions: [ApiEndpointOption] {
        guard !isSaving else {
            return ApiEndpointOption.allCases
        }

        return [.preProd, .prod]
    }

    public init(
        apiEndpointService: ApiEndpointServiceProtocol,
        apiKeyService: BFFApiKeyServiceProtocol,
        closeEndpointSelection: @escaping () -> Void
    ) {
        self.apiEndpointService = apiEndpointService
        self.apiKeyService = apiKeyService
        self.closeEndpointSelection = closeEndpointSelection
        selectedEndpointOption = apiEndpointService.currentApiEndpoint
        bffApiKey = apiKeyService.storedApiKey ?? ""
        if case .custom(let url) = apiEndpointService.currentApiEndpoint {
            customEndpointUrl = url?.absoluteString ?? ""
        } else {
            let customUrl = apiEndpointService.lastCustomApiEndpoint
                ?? apiEndpointService.apiEndpoint(for: .custom(url: nil))
            customEndpointUrl = customUrl.absoluteString
        }
    }

    public func didTapSave() {
        shouldShowUrlError = false

        guard let selectedEndpointOption else {
            return
        }

        var customUrl: URL?

        if case .custom = selectedEndpointOption {
            guard !customEndpointUrl.isEmpty, let url = URL(string: customEndpointUrl) else {
                shouldShowUrlError = true
                return
            }
            customUrl = url
        }

        apiKeyService.updateApiKey(bffApiKey)
        isSaving = true
        apiEndpointService.updateApiEndpointAndReboot(customUrl.map { .custom(url: $0) } ?? selectedEndpointOption)
        shouldShowSuccess = true
    }

    public func didDismissError() {
        shouldShowUrlError = false
    }

    private var hasApiKeyChange: Bool {
        bffApiKey.trim() != (apiKeyService.storedApiKey ?? "")
    }

    private var hasEndpointChange: Bool {
        guard let selectedEndpointOption else {
            return false
        }

        if case .custom = selectedEndpointOption {
            if case .custom(let url) = apiEndpointService.currentApiEndpoint, let url {
                return url.absoluteString != customEndpointUrl
            }
            return true
        }

        return selectedEndpointOption != apiEndpointService.currentApiEndpoint
    }
}
