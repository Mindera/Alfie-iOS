import SwiftUI
import UIKit

extension View {
    // Fixed logical container sizes (pt), not a device pin — the OS is what's pinned (see Docs/SnapshotTesting.md).
    var defaultSnapshotSize: CGSize { .init(width: 393, height: 852) }
    var fullHeightSnapshotSize: CGSize { .init(width: 393, height: 1500) } // taller, for long screens

    public func embededInContainer() -> UIView {
        embededInContainer(size: defaultSnapshotSize)
    }

    public func embededInFullHeightContainer() -> UIView {
        embededInContainer(size: fullHeightSnapshotSize)
    }

    // Scale is pinned via the snapshot strategy's traits (displayScale 3 in `defaultImage`), so the
    // container no longer mutates the process-global UIScreen.main.
    private func embededInContainer(size: CGSize) -> UIView {
        let uiViewWrapper = asUIView(backgroundColor: .white)
        uiViewWrapper.translatesAutoresizingMaskIntoConstraints = false
        uiViewWrapper.frame.size = size
        uiViewWrapper.layoutIfNeeded()
        return uiViewWrapper
    }

    private func asUIView(backgroundColor: UIColor = .clear) -> UIView {
        let hostingView = UIHostingController(rootView: self).view
        hostingView?.translatesAutoresizingMaskIntoConstraints = false
        hostingView?.backgroundColor = backgroundColor
        // We don't want to compress the views, we want them to use all the available space inside the UIView
        hostingView?.setContentHuggingPriority(.required, for: .horizontal)
        hostingView?.setContentHuggingPriority(.required, for: .vertical)
        return hostingView ?? UIView()
    }
}
