import Model
import SwiftUI

struct EndpointView: View {
    @ObservedObject var store: CompanionStore
    @State private var selectedOption: ApiEndpointOption = .dev
    @State private var customUrlText = ""

    var body: some View {
        List {
            Section {
                currentOverrideSummary
            } header: {
                Text("Current Override")
            }

            Section {
                Picker("Endpoint", selection: $selectedOption) {
                    ForEach(namedOptions, id: \.self) { option in
                        Text(option.label).tag(option)
                    }
                    Text("Custom").tag(ApiEndpointOption.custom(url: nil))
                }
                .pickerStyle(.inline)
                .labelsHidden()

                if case .custom = selectedOption {
                    TextField("https://…", text: $customUrlText)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }
            } header: {
                Text("Select Override")
            }

            Section {
                Button("Apply Override") { applyOverride() }
                    .disabled(!canApply)
                Button("Remove Override", role: .destructive) {
                    store.removeEndpoint()
                    syncFromStore()
                }
                .disabled(store.endpointUrlString == nil)
            } footer: {
                Text("Restart the main app to apply changes.")
            }
        }
        .navigationTitle("Endpoint")
        .onAppear { syncFromStore() }
    }

    private var namedOptions: [ApiEndpointOption] {
        [.dev, .preProd, .prod]
    }

    private var currentOverrideSummary: some View {
        Group {
            if let url = store.endpointUrlString {
                Text(url)
                    .font(.system(.body, design: .monospaced))
            } else {
                Text("None — default applies")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var canApply: Bool {
        if case .custom = selectedOption {
            return !customUrlText.isEmpty && URL(string: customUrlText) != nil
        }
        return true
    }

    private func applyOverride() {
        let urlString: String
        switch selectedOption {
        case .dev:
            urlString = "http://localhost:3000/"
        case .preProd:
            urlString = "https://preprod.bff.tbd.invalid/"
        case .prod:
            urlString = "https://prod.bff.tbd.invalid/"
        case .custom:
            urlString = customUrlText
        }
        store.setEndpoint(urlString: urlString)
    }

    private func syncFromStore() {
        guard let stored = store.endpointUrlString else {
            selectedOption = .dev
            customUrlText = ""
            return
        }
        let known: [ApiEndpointOption] = [.dev, .preProd, .prod]
        let knownUrls = ["http://localhost:3000/", "https://preprod.bff.tbd.invalid/", "https://prod.bff.tbd.invalid/"]
        if let idx = knownUrls.firstIndex(of: stored) {
            selectedOption = known[idx]
        } else {
            selectedOption = .custom(url: URL(string: stored))
            customUrlText = stored
        }
    }
}
