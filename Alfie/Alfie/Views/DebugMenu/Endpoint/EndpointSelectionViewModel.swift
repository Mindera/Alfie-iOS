import Foundation
import Models

final class EndpointSelectionViewModel: ObservableObject {
    private let apiEndpointService: ApiEndpointServiceProtocol
    @Published var selectedEndpointOption: ApiEndpointOption?
    @Published var customEndpointUrl: String
    @Published private(set) var shouldShowUrlError = false
    @Published private(set) var shouldShowSuccess = false
    private var isSaving = false

    var isInputDisabled: Bool {
        guard !isSaving else {
            return true
        }

        return selectedEndpointOption != .custom(url: nil)
    }

    var isSaveDisabled: Bool {
        guard !isSaving else {
            return true
        }

        if case .custom = selectedEndpointOption {
            if case .custom(let url) = apiEndpointService.currentApiEndpoint, let url {
                return url.absoluteString == customEndpointUrl
            } else {
                return false
            }
        }
        return selectedEndpointOption == apiEndpointService.currentApiEndpoint
    }

    var availableEndpointOptions = ApiEndpointOption.allCases

    var disabledEndpointOptions: [ApiEndpointOption] {
        guard !isSaving else {
            return ApiEndpointOption.allCases
        }

        return [.preProd, .prod]
    }

    init(apiEndpointService: ApiEndpointServiceProtocol) {
        self.apiEndpointService = apiEndpointService
        selectedEndpointOption = apiEndpointService.currentApiEndpoint
        if case .custom(let url) = apiEndpointService.currentApiEndpoint {
            customEndpointUrl = url?.absoluteString ?? ""
        } else {
            customEndpointUrl = apiEndpointService.apiEndpoint(for: .custom(url: nil)).absoluteString
        }
    }

    func didTapSave() {
        shouldShowUrlError = false

        guard let selectedEndpointOption else {
            return
        }

        if case .custom = selectedEndpointOption {
            guard !customEndpointUrl.isEmpty, let url = URL(string: customEndpointUrl) else {
                shouldShowUrlError = true
                return
            }

            isSaving = true
            apiEndpointService.updateApiEndpointAndReboot(.custom(url: url))
        } else {
            isSaving = true
            apiEndpointService.updateApiEndpointAndReboot(selectedEndpointOption)
        }

        shouldShowSuccess = true
    }

    func didDismissError() {
        shouldShowUrlError = false
    }
}
