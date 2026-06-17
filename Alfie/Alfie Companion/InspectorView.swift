import FirebaseRemoteConfig
import SwiftUI

struct InspectorView: View {
    @ObservedObject var store: CompanionStore
    @State private var remoteConfigEntries: [(key: String, value: String)] = []
    @State private var localConfigText = ""
    @State private var isFetchingRC = false
    @State private var rcError: String?

    var body: some View {
        List {
            Section {
                if isFetchingRC {
                    ProgressView("Fetching…")
                } else if let error = rcError {
                    Text(error)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                } else if remoteConfigEntries.isEmpty {
                    Text("No remote config values loaded.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(remoteConfigEntries, id: \.key) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.key)
                                .font(.system(.caption, design: .monospaced))
                            Text(entry.value)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Firebase Remote Config")
                    Spacer()
                    Button("Refresh") { fetchRemoteConfig() }
                        .font(.caption)
                        .disabled(isFetchingRC)
                }
            }

            Section("local_config.json") {
                if localConfigText.isEmpty {
                    Text("File not found in bundle.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                } else {
                    Text(localConfigText)
                        .font(.system(.caption2, design: .monospaced))
                        .textSelection(.enabled)
                }
            }

            Section {
                if store.allGroupEntries.isEmpty {
                    Text("No entries in App Group suite.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.allGroupEntries, id: \.key) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.key)
                                    .font(.system(.caption, design: .monospaced))
                                Text(entry.value)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                store.removeEntry(key: entry.key)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("App Group Browser")
                    Spacer()
                    Button("Refresh") { store.reload() }
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Inspector")
        .onAppear {
            fetchRemoteConfig()
            loadLocalConfig()
        }
    }

    private func fetchRemoteConfig() {
        isFetchingRC = true
        rcError = nil
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { _, error in
            if let error {
                isFetchingRC = false
                rcError = "Fetch failed: \(error.localizedDescription)"
                return
            }
            RemoteConfig.remoteConfig().activate { _, _ in
                let keys = RemoteConfig.remoteConfig().allKeys(from: .remote)
                let entries: [(key: String, value: String)] = keys
                    .sorted()
                    .map { key in
                        let val = RemoteConfig.remoteConfig().configValue(forKey: key)
                        return (key: key, value: val.stringValue ?? "(nil)")
                    }
                DispatchQueue.main.async {
                    remoteConfigEntries = entries
                    isFetchingRC = false
                }
            }
        }
    }

    private func loadLocalConfig() {
        guard
            let path = Bundle.main.path(forResource: "local_config", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let json = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
            let text = String(data: pretty, encoding: .utf8)
        else {
            localConfigText = ""
            return
        }
        localConfigText = text
    }
}
