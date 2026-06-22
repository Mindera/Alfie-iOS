import Firebase
import SwiftUI

@main
struct Alfie_CompanionApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
