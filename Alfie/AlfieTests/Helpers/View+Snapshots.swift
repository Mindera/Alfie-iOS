import Mocks
import SwiftUI
@testable import Alfie

extension View {
    var defaultSnapshotSize: CGSize { .init(width: 393, height: 852) } // iPhone 15 Pro
    var fullHeightSnapshotSize: CGSize { .init(width: 393, height: 1500) } // iPhone 15 Pro
    var defaultSnapshotScale: CGFloat { 3.0 }

    public func embededInContainer(coordinate: Bool = true) -> UIView {
        let view: any View = coordinate ? coordinatedView(view: self) : self
        return view.embededInContainer(size: defaultSnapshotSize, scale: defaultSnapshotScale)
    }

    public func embededInFullHeightContainer(coordinate: Bool = true) -> UIView {
        let view: any View = coordinate ? coordinatedView(view: self) : self
        return view.embededInContainer(size: fullHeightSnapshotSize, scale: defaultSnapshotScale)
    }

    private func coordinatedView(view: some View) -> some View {
        view
    }
}
