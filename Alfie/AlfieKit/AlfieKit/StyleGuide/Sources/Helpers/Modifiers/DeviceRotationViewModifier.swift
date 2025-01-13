import SwiftUI

public struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    let excludingFlatOrientation: Bool

    public init(action: @escaping (UIDeviceOrientation) -> Void, excludingFlatOrientation: Bool = true) {
        self.action = action
        self.excludingFlatOrientation = excludingFlatOrientation
    }

    public func body(content: Content) -> some View {
        content
            .onAppear {
                guard
                    let scene = UIApplication.shared.connectedScenes.first,
                    let sceneDelegate = scene as? UIWindowScene,
                    sceneDelegate.interfaceOrientation.isPortrait
                else {
                    action(.landscapeLeft)
                    return
                }
                action(.portrait)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                let orientation = UIDevice.current.orientation
                if excludingFlatOrientation {
                    if !orientation.isFlat {
                        action(orientation)
                    }
                } else {
                    action(orientation)
                }
            }
    }
}

public extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void, excludingFlatOrientation: Bool = true) -> some View {
        modifier(DeviceRotationViewModifier(action: action))
    }
}
