import Combine
import SwiftUI

public final class NavigationAdapter<Screen: Hashable & Identifiable>: ObservableObject {
    @Published var path = NavigationPath()
    @Published var modalPath = NavigationPath()

    @Published var sheet: Screen?
    @Published var fullScreenCover: Screen?
    @Published var fullScreenOverlay: Screen?

    @Published var isPresentingSheet = false
    @Published var isPresentingFullScreenCover = false
    @Published public private(set) var isPresentingFullScreenOverlay = false

    private let didPopToRootSubject: PassthroughSubject<Void, Never> = .init()
    public lazy var didPopToRootPublisher: AnyPublisher<Void, Never> = didPopToRootSubject.eraseToAnyPublisher()

    public init() {}
}

// MARK: - Add Screen Methods

extension NavigationAdapter {
    public func push(_ screen: Screen) {
        if sheet != nil || fullScreenCover != nil || fullScreenOverlay != nil {
            modalPath.append(screen)
        } else {
            path.append(screen)
        }
    }

    public func replace(with screen: Screen) {
        if modalPath.count >= 1 {
            modalPath.removeLast()
            modalPath.append(screen)
        } else if sheet != nil {
            sheet = screen
        } else if fullScreenCover != nil {
            fullScreenCover = screen
        } else {
            path.removeLast()
            path.append(screen)
        }
    }

    public func presentSheet(_ screen: Screen) {
        isPresentingSheet = true
        self.sheet = screen
    }

    public func presentFullScreenCover(_ screen: Screen) {
        isPresentingFullScreenCover = true
        self.fullScreenCover = screen
    }

    public func presentFullscreenOverlay(with screen: Screen) {
        withAnimation(.easeOut(duration: 0.15)) {
            isPresentingFullScreenOverlay = true
            fullScreenOverlay = screen
        }
    }
}

// MARK: - Remove Screen Methods

extension NavigationAdapter {
    public func pop() {
        if modalPath.count >= 1 {
            guard !modalPath.isEmpty else {
                dismissFullScreenOverlay()
                return
            }
            modalPath.removeLast()
        } else {
            guard !path.isEmpty else {
                dismissFullScreenOverlay()
                return
            }
            path.removeLast()
        }
    }

    public func popToRoot() {
        if modalPath.count >= 1 {
            modalPath.removeLast(modalPath.count)
        } else {
            path.removeLast(path.count)
        }
        didPopToRootSubject.send()
    }

    public func dismissModal() {
        isPresentingSheet = false
        isPresentingFullScreenCover = false
        sheet = nil
        fullScreenCover = nil
        modalPath = NavigationPath()
    }

    public func dismissFullScreenOverlay() {
        withAnimation(.easeOut(duration: 0.15)) {
            fullScreenOverlay = nil
            isPresentingFullScreenOverlay = false
        }
    }
}
