import SwiftUI

struct ContentView: View {
    @StateObject private var store = CompanionStore()

    var body: some View {
        TabView {
            NavigationStack {
                FlagsView(store: store)
            }
            .tabItem { Label("Flags", systemImage: "flag") }

            NavigationStack {
                EndpointView(store: store)
            }
            .tabItem { Label("Endpoint", systemImage: "network") }

            NavigationStack {
                InspectorView(store: store)
            }
            .tabItem { Label("Inspector", systemImage: "magnifyingglass") }
        }
    }
}

#Preview {
    ContentView()
}
