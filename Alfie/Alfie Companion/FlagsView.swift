import Model
import SwiftUI

struct FlagsView: View {
    @ObservedObject var store: CompanionStore
    @State private var showAddCustom = false
    @State private var customKeyName = ""
    @State private var customKeyValue = false

    var body: some View {
        List {
            Section {
                ForEach(ConfigurationKey.allCases, id: \.rawValue) { key in
                    FlagRow(
                        label: key.rawValue,
                        currentOverride: store.flagOverrides[key.rawValue],
                        onSet: { value in store.setFlag(rawKey: key.rawValue, value: value) },
                        onRemove: { store.removeFlag(rawKey: key.rawValue) }
                    )
                }
            } header: {
                Text("Feature Flags")
            } footer: {
                Text("Restart the main app to apply changes.")
            }

            Section("Custom Flags") {
                ForEach(customEntries, id: \.key) { entry in
                    FlagRow(
                        label: entry.key,
                        currentOverride: store.flagOverrides[entry.key],
                        onSet: { value in store.setFlag(rawKey: entry.key, value: value) },
                        onRemove: { store.removeFlag(rawKey: entry.key) }
                    )
                }
                Button("Add custom flag…") { showAddCustom = true }
            }
        }
        .navigationTitle("Flags")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    store.resetAll()
                } label: {
                    Label("Reset All", systemImage: "arrow.counterclockwise")
                }
                .tint(.red)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddCustom = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddCustom) {
            AddCustomFlagView(
                keyName: $customKeyName,
                value: $customKeyValue,
                onSave: {
                    guard !customKeyName.isEmpty else { return }
                    store.setFlag(rawKey: customKeyName, value: customKeyValue)
                    customKeyName = ""
                    customKeyValue = false
                    showAddCustom = false
                },
                onCancel: {
                    customKeyName = ""
                    customKeyValue = false
                    showAddCustom = false
                }
            )
        }
    }

    private var customEntries: [(key: String, value: Bool)] {
        let knownKeys = Set(ConfigurationKey.allCases.map(\.rawValue))
        return store.flagOverrides
            .filter { !knownKeys.contains($0.key) }
            .map { (key: $0.key, value: $0.value) }
            .sorted { $0.key < $1.key }
    }
}

private struct FlagRow: View {
    let label: String
    let currentOverride: Bool?
    let onSet: (Bool) -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.body, design: .monospaced))
            if let current = currentOverride {
                HStack {
                    Text("Override: \(current ? "true" : "false")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { current },
                        set: { onSet($0) }
                    ))
                    .labelsHidden()
                    Button(role: .destructive) { onRemove() } label: {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.borderless)
                }
            } else {
                HStack {
                    Text("No override")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Button("Set true") { onSet(true) }
                        .buttonStyle(.borderless)
                        .font(.caption)
                    Button("Set false") { onSet(false) }
                        .buttonStyle(.borderless)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

private struct AddCustomFlagView: View {
    @Binding var keyName: String
    @Binding var value: Bool
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Key") {
                    TextField("e.g. ios_my_feature", text: $keyName)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Section("Value") {
                    Toggle("Enabled", isOn: $value)
                }
            }
            .navigationTitle("Add Custom Flag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .disabled(keyName.isEmpty)
                }
            }
        }
    }
}
