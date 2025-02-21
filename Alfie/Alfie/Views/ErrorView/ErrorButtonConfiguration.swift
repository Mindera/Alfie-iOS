import Foundation

struct ErrorButtonConfiguration: Identifiable {
    let id: String = UUID().uuidString
    let text: String
    let action: () -> Void
}
