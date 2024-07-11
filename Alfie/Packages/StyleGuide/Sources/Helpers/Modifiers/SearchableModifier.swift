import Core
import Models
import SwiftUI

// MARK: - PullToSearchConfig

public enum PullToSearchConfig {
    // swiftlint:disable:next enum_case_associated_values_count
    case enabled(scrollOffset: Binding<CGPoint>, searchBarMaxScaleFactor: CGFloat = 1.05, searchBarMinOpacity: CGFloat = 1, animateOffset: Bool = false, searchFocusThreshold: CGFloat = -80)
    case disabled

    var isEnabled: Bool {
        switch self {
            case .enabled:
                return true
            case .disabled:
                return false
        }
    }

    var searchBarMaxScaleFactor: CGFloat {
        switch self {
            case .enabled(_, let searchBarMaxScaleFactor, _, _, _):
                return searchBarMaxScaleFactor
            case .disabled:
                return 1
        }
    }

    var searchBarMinOpacity: CGFloat {
        switch self {
            case .enabled(_, _, let searchBarMinOpacity, _, _):
                return searchBarMinOpacity
            case .disabled:
                return 1
        }
    }

    var searchFocusThreshold: CGFloat? {
        switch self {
            case .enabled(_, _, _, _, let searchFocusThreshold):
                return searchFocusThreshold
            case .disabled:
                return nil
        }
    }

    var animateOffset: Bool {
        switch self {
            case .enabled(_, _, _, let animateOffset, _):
                return animateOffset
            case .disabled:
                return false
        }
    }
}

public enum SearchBarTransition: Equatable, Hashable {
    case growFromTrailingIcon
    case matchedGeometryEffect(id: String, namespace: Namespace.ID)

    var namespace: Namespace.ID? {
        switch self {
            case .matchedGeometryEffect(_, let namespace):
                namespace
            case .growFromTrailingIcon:
                nil
        }
    }

    var geometryEffectID: String? {
        switch self {
            case .matchedGeometryEffect(let id, _):
                id
            case .growFromTrailingIcon:
                nil
        }
    }

    var autofocusDelay: CGFloat {
        switch self {
            case .matchedGeometryEffect:
                0.0
            case .growFromTrailingIcon:
                0.1
        }
    }

    var isGrowFromTrailingIcon: Bool {
        switch self {
            case .growFromTrailingIcon:
                true
            case .matchedGeometryEffect:
                false
        }
    }

    var shouldAnimateSearchBarAppearance: Bool {
        switch self {
            case .growFromTrailingIcon:
                false
            case .matchedGeometryEffect:
                true
        }
    }
}

// MARK: - SearchableModifier

public struct SearchableModifier<ResultsView: View>: ViewModifier {
    @State private var searchBarScale: CGFloat = 1
    @State private var searchBarOpacity: CGFloat = 1
    @State private var searchBarYOffset: CGFloat = 0
    @State private var showOverlay = false
    @State private var animatingTransition: Bool
    @State private var showSearchBar: Bool
    @FocusState private var searchBarFocused
    @Binding private var searchText: String
    @Binding private var scrollOffset: CGPoint
    private let dismissConfiguration: ThemedSearchBarView.DismissConfiguration
    private let placeholder: String
    private let placeholderOnFocus: String
    private let contentOverlayColorWhenFocused: Color?
    private let pullToSearchConfig: PullToSearchConfig
    private let showDivider: Bool
    private let autoFocus: Bool
    private let inputAccessibilityId: String?
    private let clearAccessibilityId: String?
    private let hapticsService: HapticsServiceProtocol
    private let transition: SearchBarTransition?
    private let theme: ThemedSearchBarView.Theme
    private let verticalSpacing: CGFloat
    private var resultsView: () -> ResultsView
    private var onCancel: (() -> Void)?
    private var onSubmit: ((String) -> Void)?
    private var onFocusChange: ((Bool) -> Void)?
    private var containsResultsView: Bool {
        ResultsView.self != EmptyView.self
    }

    public init(placeholder: String,
                placeholderOnFocus: String,
                searchText: Binding<String>,
                pullToSearchConfig: PullToSearchConfig,
                theme: ThemedSearchBarView.Theme,
                dismissConfiguration: ThemedSearchBarView.DismissConfiguration,
                verticalSpacing: CGFloat,
                showCancelButton: Bool = true,
                contentOverlayColorWhenFocused: Color?,
                showDivider: Bool = false,
                autoFocus: Bool = false,
                inputAccessibilityId: String? = nil,
                clearAccessibilityId: String? = nil,
                transition: SearchBarTransition? = nil,
                hapticsService: HapticsServiceProtocol = HapticsService.instance,
                @ViewBuilder resultsView: @escaping () -> ResultsView = { EmptyView() },
                onCancel: (() -> Void)? = nil,
                onSubmit: ((String) -> Void)? = nil,
                onFocusChange: ((Bool) -> Void)? = nil) {
        self.placeholder = placeholder
        self.placeholderOnFocus = placeholderOnFocus
        _searchText = searchText
        self.pullToSearchConfig = pullToSearchConfig
        self.dismissConfiguration = dismissConfiguration
        self.contentOverlayColorWhenFocused = contentOverlayColorWhenFocused
        self.showDivider = showDivider
        self.autoFocus = autoFocus
        self.resultsView = resultsView
        self.onCancel = onCancel
        self.onSubmit = onSubmit
        self.onFocusChange = onFocusChange
        self.inputAccessibilityId = inputAccessibilityId
        self.clearAccessibilityId = clearAccessibilityId
        self.hapticsService = hapticsService
        self.theme = theme
        self.transition = transition
        self.verticalSpacing = verticalSpacing
        self._animatingTransition = State(initialValue: transition != nil)
        self._showSearchBar = State(initialValue: transition?.shouldAnimateSearchBarAppearance == false || transition == nil)
        switch pullToSearchConfig {
            case .enabled(let scrollOffset, _, _, _, _):
                _scrollOffset = scrollOffset
            case .disabled:
                _scrollOffset = .constant(.zero)
        }

        if transition != nil {
            self.searchBarOpacity = 1
        } else {
            self.searchBarOpacity = 0
            animateOpacity(to: 1)
        }
    }

    public func body(content: Content) -> some View {
        VStack(spacing: Spacing.space0) {
            if showSearchBar {
                ThemedSearchBarView(searchText: $searchText,
                                    placeholder: placeholder,
                                    placeholderOnFocus: placeholderOnFocus,
                                    theme: theme,
                                    dismissConfiguration: dismissConfiguration,
                                    autoFocusWhenAppearing: autoFocus ? .on(delay: transition?.autofocusDelay ?? 0.0) : .off,
                                    inputAccessibilityId: inputAccessibilityId,
                                    clearAccessibilityId: clearAccessibilityId,
                                    onCancelTap: onCancelButtonTapped,
                                    onSubmitTap: { onSubmit?(searchText) },
                                    onFocusChange: onFocusChange)
                .optionalMatchedGeometryEffect(id: transition?.geometryEffectID,
                                               in: transition?.namespace)
                .focused($searchBarFocused)
                .padding(.horizontal, Spacing.space200)
                .padding(.bottom, verticalSpacing) // verticalSpacing is not applied to the VStack because if you have many items on content, it will affect all of them
                .scaleEffect(.init(width: (animatingTransition && transition?.isGrowFromTrailingIcon == true) ? 0.1 : searchBarScale,
                                   height: searchBarScale),
                             anchor: transition?.isGrowFromTrailingIcon == true ? .trailing : .center)
                .opacity(searchBarOpacity)
                .offset(y: searchBarYOffset)
                .task {
                    if animatingTransition {
                        withAnimation(.standardDecelerate) {
                            animatingTransition = false
                        }
                    }
                }
            }

            if showDivider {
                ThemedDivider.horizontalThin
            }

            content
                .overlay {
                    if showOverlay {
                        ZStack {
                            contentOverlayColorWhenFocused?
                                .transition(.opacity)
                                .edgesIgnoringSafeArea(.bottom)
                                .onTapGesture {
                                    searchBarFocused = false
                                }
                            resultsView()
                        }
                    }
                }
        }
        .task {
            guard let transition, transition.shouldAnimateSearchBarAppearance else {
                return
            }
            withAnimation(.easeOut(duration: 0.15)) {
                showSearchBar = true
            }
        }
        .onChange(of: scrollOffset) { newValue in
            guard pullToSearchConfig.isEnabled,
                  let threshold = pullToSearchConfig.searchFocusThreshold
            else {
                return
            }
            checkIfShouldTriggerSearchFocus(for: newValue.y, threshold: threshold)
            updateScaleFactor(for: newValue.y, threshold: threshold)
            updateOpacity(for: newValue.y, threshold: threshold)
            updateSearchBarYOffset(for: newValue.y)
        }
        .onChange(of: searchBarFocused) { newValue in
            updateOpacity(for: scrollOffset.y, threshold: pullToSearchConfig.searchFocusThreshold)

            guard containsResultsView else {
                return
            }

            withAnimation(.easeOut) {
                showOverlay = newValue
            }
        }
    }

    private func onCancelButtonTapped() {
        if let transition, transition.isGrowFromTrailingIcon {
            animateOpacity(to: 0)
            if #available(iOS 17.0, *) {
                withAnimation(.standardDecelerate) {
                    animatingTransition = true
                } completion: {
                    onCancel?()
                }
            } else {
                withAnimation(.standardDecelerate) {
                    animatingTransition = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    onCancel?()
                }
            }
        } else {
            onCancel?()
        }
    }

    private func animateOpacity(to newValue: CGFloat) {
        withAnimation(.standardAccelerate) {
            self.searchBarOpacity = newValue
        }
    }
}

extension SearchableModifier {
    private func checkIfShouldTriggerSearchFocus(for yOffset: CGFloat, threshold: CGFloat) {
        if yOffset < threshold && !searchBarFocused {
            hapticsService.trigger(.notification(.success))
            withAnimation(.standardDecelerate) {
                searchBarFocused = true
            }
        }
    }

    private func updateScaleFactor(for yOffset: CGFloat, threshold: CGFloat) {
        guard yOffset < 0 && !searchBarFocused else {
            if searchBarScale != 1 {
                withAnimation(.standardDecelerate) {
                    searchBarScale = 1
                }
            }
            return
        }

        let normalizedScrollOffset = (-yOffset / abs(threshold))
        withAnimation(.standardAccelerate) {
            searchBarScale = 1 + normalizedScrollOffset * (pullToSearchConfig.searchBarMaxScaleFactor - 1)
        }
    }

    private func updateOpacity(for scrollViewYOffset: CGFloat, threshold: CGFloat?) {
        let searchBarMinOpacity = pullToSearchConfig.searchBarMinOpacity

        guard searchBarMinOpacity < 1 else {
            searchBarOpacity = searchBarMinOpacity
            return
        }

        switch searchBarFocused {
            case true: // if it's focused, opacity is default (1.0)
                if searchBarOpacity != 1 {
                    withAnimation(.emphasizedDecelerate) {
                        searchBarOpacity = 1
                    }
                }
            case false where scrollViewYOffset >= 0: // if not focused, but also not being pulled, opacity is searchBarMinOpacity
                if searchBarOpacity != searchBarMinOpacity {
                    withAnimation(.standardDecelerate) {
                        searchBarOpacity = searchBarMinOpacity
                    }
                }
            default: // if it's not focused but being pulled, we calculate the dynamic opacity value
                guard let threshold else {
                    return
                }
                let normalizedScrollOffset = (-scrollViewYOffset / abs(threshold))
                withAnimation(.standardAccelerate) {
                    searchBarOpacity = searchBarMinOpacity + normalizedScrollOffset * (1 - searchBarMinOpacity)
                }
        }
    }

    private func updateSearchBarYOffset(for scrollViewYOffset: CGFloat) {
        guard pullToSearchConfig.isEnabled,
              pullToSearchConfig.animateOffset,
              scrollOffset.y < 0
        else {
            searchBarYOffset = 0
            return
        }

        searchBarYOffset = -scrollViewYOffset / 2
    }
}
