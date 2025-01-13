import SwiftUI
import UIKit

extension View {
    public var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    public func embededInContainer(size: CGSize, scale: CGFloat) -> UIView {
        UIScreen.main.setValue(scale, forKeyPath: "scale")
        let uiViewWrapper = self.asUIView(backgroundColor: .white)
        uiViewWrapper.translatesAutoresizingMaskIntoConstraints = false
        uiViewWrapper.frame.size = size
        uiViewWrapper.layoutIfNeeded()
        return uiViewWrapper
    }

    public func asUIView(backgroundColor: UIColor = .clear) -> UIView {
        let hostingView = UIHostingController(rootView: self).view
        hostingView?.translatesAutoresizingMaskIntoConstraints = false
        hostingView?.backgroundColor = backgroundColor

        // We don't want to compress the views, we want them to use all the available space inside the UIView
        hostingView?.setContentHuggingPriority(.required, for: .horizontal)
        hostingView?.setContentHuggingPriority(.required, for: .vertical)

        return hostingView ?? UIView()
    }

    public func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        frame(width: size.width, height: size.height, alignment: alignment)
    }

    public func frame(size: CGFloat, alignment: Alignment = .center) -> some View {
        frame(width: size, height: size, alignment: alignment)
    }

    @ViewBuilder
    public func optionalMatchedGeometryEffect(
        id: String?,
        in namespace: Namespace.ID?,
        properties: MatchedGeometryProperties = .frame,
        anchor: UnitPoint = .center,
        isSource: Bool = true
    ) -> some View {
        if let id, let namespace {
            self.matchedGeometryEffect(
                id: id,
                in: namespace,
                properties: properties,
                anchor: anchor,
                isSource: isSource
            )
        } else {
            self
        }
    }

    public func writingSize(to size: Binding<CGSize>, keepValueUpdated: Bool = true) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        size.wrappedValue = geometry.size
                    }
                    .onChange(of: geometry.size) { newSize in
                        guard keepValueUpdated else {
                            return
                        }
                        size.wrappedValue = newSize
                    }
            }
        )
    }

    public func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
