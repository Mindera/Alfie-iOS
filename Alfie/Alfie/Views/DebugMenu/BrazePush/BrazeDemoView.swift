import Core
import Models
import StyleGuide
import SwiftUI

// MARK: - BrazeDemoView

struct BrazeDemoView: View {
    @State private var showPushIDAlert = false
    @State private var showNotificationTriggeredAlert = false
    @State private var notificationsAuthorized = false
    private let delayForAlert: Double = 5
    private let brazeUserId: String

    init(brazeUserId: String) {
        self.brazeUserId = brazeUserId
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space200) {
                DemoHelper.demoSectionHeader(title: "Push Notification ID")
                Button(action: {
                    UIPasteboard.general.string = brazeUserId
                    showPushIDAlert = true
                }, label: {
                    Text.build(theme.font.paragraph.italic(brazeUserId))
                })
                .buttonStyle(.plain)

                ThemedButton(text: "Trigger Notification") {
                    Task {
                        await presentLocalNotificationIfPossible()
                    }
                }
            }
            .padding(.horizontal, Spacing.space200)
        }
        .alert("Push Notification ID copied to clipboard", isPresented: $showPushIDAlert) {}
        .alert(notificationTriggerAlertMessage, isPresented: $showNotificationTriggeredAlert) {
            Button(action: {
                guard !notificationsAuthorized else {
                    return
                }

                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }, label: {
                Text("OK")
            })
        }
    }
}

// temp stuff for local notification
extension BrazeDemoView {
    private func presentLocalNotificationIfPossible() async {
        notificationsAuthorized = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .authorized
        showNotificationTriggeredAlert = true
        try? await UNUserNotificationCenter.current().add(notificationRequest(delay: delayForAlert))
    }

    private var notificationTriggerAlertMessage: String {
        notificationsAuthorized ? "Notification scheduled. Please wait approximately 3 seconds." : "You must enable notifications first."
    }

    private func notificationRequest(delay: Double) -> UNNotificationRequest {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Quality never goes out of style!"
        notificationContent.body = "Discover new season pieces to love now and forever."

        return UNNotificationRequest(identifier: UUID().uuidString,
                                     content: notificationContent,
                                     trigger: UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false))
    }
}
