import SwiftUI
import StyleGuide

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello World")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
