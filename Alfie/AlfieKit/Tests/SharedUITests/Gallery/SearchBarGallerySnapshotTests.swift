import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class SearchBarGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_light_search_bar_renders_placeholder() {
        assertSnapshot(of: searchBar(theme: .light).embededInContainer(height: 100),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_dark_search_bar_renders_placeholder() {
        assertSnapshot(of: searchBar(theme: .dark).embededInContainer(height: 100),
                       as: .defaultImage(),
                       record: isRecording)
    }

    // The text cursor blinks off wall-clock time; the precision allowance covers its few pixels only.
    func test_focused_search_bar_shows_focus_placeholder_and_cancel() {
        let window = hostedInKeyWindow(searchBar(theme: .light, autoFocus: .on(delay: 0)))
        assertSnapshot(of: window, as: .defaultImage(precision: 0.999), record: isRecording)
    }

    private func searchBar(
        theme: ThemedSearchBarView.Style,
        autoFocus: ThemedSearchBarView.AutoFocusSetting = .off
    ) -> some View {
        ThemedSearchBarView(
            searchText: .constant(""),
            placeholder: "Search Alfie",
            placeholderOnFocus: "What are you looking for?",
            theme: theme,
            dismissConfiguration: .init(type: .cancel(title: "Cancel")),
            autoFocusWhenAppearing: autoFocus
        )
        .padding(16)
    }

    private func hostedInKeyWindow(_ view: some View) -> UIWindow {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene.map(UIWindow.init(windowScene:)) ?? UIWindow()
        window.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        window.rootViewController = UIHostingController(
            rootView: view
                .ignoresSafeArea(.keyboard)
                .transaction { $0.disablesAnimations = true }
        )
        window.makeKeyAndVisible()
        addTeardownBlock { window.isHidden = true }
        let focused = expectation(for: NSPredicate { _, _ in Self.hasFirstResponder(in: window) },
                                  evaluatedWith: nil)
        wait(for: [focused], timeout: .default)
        window.layoutIfNeeded()
        return window
    }

    private static func hasFirstResponder(in view: UIView) -> Bool {
        view.isFirstResponder || view.subviews.contains { hasFirstResponder(in: $0) }
    }
}
