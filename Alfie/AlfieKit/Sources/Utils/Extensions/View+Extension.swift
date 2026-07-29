import SwiftUI
import UIKit

extension View {
    public var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
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
