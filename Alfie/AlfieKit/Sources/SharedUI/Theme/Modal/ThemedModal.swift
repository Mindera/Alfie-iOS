import SwiftUI

// MARK: - ThemedModal

struct ThemedModal<Modal: View>: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var isPresented: Bool
    @State private var showModal = false
    private var title: String
    private var modal: () -> Modal

    init(isPresented: Binding<Bool>, title: String, modal: @escaping () -> Modal) {
        _isPresented = isPresented
        self.title = title
        self.modal = modal
    }

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                Group {
                    if showModal {
                        ThemedModalSheet(
                            title: title,
                            topMargin: topMargin,
                            onDismiss: onDismiss,
                            modal: modal
                        )
                        .onDisappear {
                            isPresented = false
                        }
                    }
                }
                .onAppear {
                    withAnimation {
                        self.showModal = true
                    }
                }
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                .background(ClearBackground())
            }
    }

    @MainActor
    private func onDismiss() {
        showModal = false
    }

    private var topMargin: CGFloat {
        if horizontalSizeClass == .regular {
            UIDevice.current.topMargin + 25.0
        } else {
            UIDevice.current.hasNotch ? UIDevice.current.topMargin : UIDevice.current.topMargin + 25.0
        }
    }
}

// MARK: - ThemedModalSheet

struct ThemedModalSheet<Modal: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var modalFitsScreen = true
    @State private var modalHeight: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var backOpacityLayer: CGFloat
    let title: String
    let topMargin: CGFloat
    let onDismiss: () -> Void
    let modal: () -> Modal

    init(
        title: String,
        topMargin: CGFloat,
        backOpacityLayer: CGFloat = 0,
        onDismiss: @escaping () -> Void,
        modal: @escaping () -> Modal
    ) {
        _backOpacityLayer = State(initialValue: backOpacityLayer)
        self.title = title
        self.topMargin = topMargin
        self.onDismiss = onDismiss
        self.modal = modal
    }

    private var horizontalInset: CGFloat {
        horizontalSizeClass == .regular ? theme.sizing.spacingSpacing2xl : theme.sizing.spacingSpacingNone
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: horizontalSizeClass == .compact ? .bottom : .center) {
                Rectangle()
                    // swiftlint:disable:next no_primitive_tokens - design review #186: no modal overlay token
                    .fill(Primitives.Colours.neutrals900.opacity(Constants.opacityBackground))
                    .onTapGesture {
                        onDismiss()
                    }
                    .onAppear {
                        withAnimation {
                            backOpacityLayer = 1
                        }
                    }
                    .animation(.standardAccelerate, value: backOpacityLayer)
                    .opacity(backOpacityLayer)
                    .ignoresSafeArea(.all)
                VStack {
                    if !self.modalFitsScreen {
                        Spacer()
                            .frame(height: topMargin)
                    }

                    VStack {
                        HStack {
                            Text.build(theme.font.heading.small(title))
                                .foregroundStyle(theme.color.contentContentPrimary)
                            Spacer()
                            Button {
                                onDismiss()
                            } label: {
                                Icon.close.image
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: Constants.iconCloseSize,
                                        height: Constants.iconCloseSize
                                    )
                                    .tint(theme.color.contentContentPrimary)
                            }
                            .accessibilityLabel(Text(L10n.Accessibility.close))
                        }
                        .padding(.vertical, theme.sizing.spacingSpacingXs)
                        .padding(.horizontal, theme.sizing.spacingSpacingMd)
                        ScrollView {
                            modal()
                                .simultaneousGesture(
                                    DragGesture()
                                        .onChanged { _ in
                                            offset = .zero
                                        }
                                )
                                .background(
                                    GeometryReader {
                                        ZStack {}
                                            .preference(
                                                key: ViewHeightKey.self,
                                                value: $0.frame(in: .local).size.height
                                            )
                                    }
                                )
                                .padding(.bottom, theme.sizing.spacingSpacingXl)
                                .padding(.horizontal, theme.sizing.spacingSpacingMd)
                        }
                        .scrollDisabled(modalFitsScreen)
                        .frame(height: modalFitsScreen ? modalHeight + theme.sizing.spacingSpacingXl : nil)
                        .onPreferenceChange(ViewHeightKey.self) {
                            modalHeight = $0
                            modalFitsScreen = $0 < (proxy.size.height - topMargin * 2)
                        }
                    }
                    .padding(.horizontal, horizontalInset)
                    .ignoresSafeArea(edges: .bottom)
                    .background {
                        RoundedRectangle(cornerRadius: theme.sizing.radiusStrong)
                            .fill(theme.color.surfaceBackgroundPrimary)
                            .ignoresSafeArea(edges: .bottom)
                            .padding(.horizontal, horizontalInset)
                    }
                    .offset(y: offset.height)
                    .transition(.move(edge: .bottom))
                    .animation(.interactiveSpring(), value: offset)
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { gesture in
                                if gesture.translation.height > 0 {
                                    offset = gesture.translation
                                }
                            }
                            .onEnded { _ in
                                if offset.height > Constants.modalScrollThreshold {
                                    onDismiss()
                                } else {
                                    offset = .zero
                                }
                            }
                    )
                }
            }
        }
    }
}

// MARK: - ViewHeightKey

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

// MARK: - Constants

private enum Constants {
    static let opacityBackground = 0.6
    static let modalScrollThreshold: CGFloat = 100
    static let iconCloseSize = 16.0
}

// MARK: - ClearBackground

struct ClearBackground: UIViewRepresentable {
    func makeUIView(context _: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            view.superview?.superview?.superview?.superview?.backgroundColor = .clear
            view.superview?.superview?.superview?.backgroundColor = .clear
            view.superview?.superview?.backgroundColor = .clear
            view.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_: UIView, context _: Context) {}
}

extension UIDevice {
    // swiftlint:disable:next strict_fileprivate
    fileprivate var topMargin: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return 0 }

        return window.safeAreaInsets.top
    }

    // swiftlint:disable:next strict_fileprivate
    fileprivate var hasNotch: Bool {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return false }

        return window.safeAreaInsets.top > 20
    }
}

// MARK: - View Extension to make it easier to write

extension View {
    public func modalView(isPresented: Binding<Bool>, title: String, content: @escaping (() -> some View)) -> some View {
        modifier(ThemedModal(isPresented: isPresented, title: title, modal: content))
    }
}
