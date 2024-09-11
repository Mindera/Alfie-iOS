import SwiftUI

// MARK: - ThemedModal

struct ThemedModal<Modal: View>: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var isPresented: Bool
    @State private var offset: CGSize = .zero

    @State private var backOpacityLayer: CGFloat = 0
    @State private var modalFitsScreen = true
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
                        GeometryReader { gp in
                            ZStack(alignment: horizontalSizeClass == .compact ? .bottom : .center) {
                                Rectangle()
                                    .fill(Colors.primary.black.opacity(Constants.opacityBackground))
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
                                            Text.build(theme.font.header.h3(title))
                                                .foregroundStyle(Colors.primary.black)
                                            Spacer()
                                            Button {
                                                onDismiss()
                                            } label: {
                                                Icon.close.image
                                                    .resizable()
                                                    .renderingMode(.template)
                                                    .frame(
                                                        width: Constants.iconCloseSize,
                                                        height: Constants.iconCloseSize
                                                    )
                                                    .tint(Colors.primary.black)
                                            }
                                        }
                                        .padding(.vertical, Spacing.space100)
                                        .padding(.horizontal, Spacing.space200)
                                        if self.modalFitsScreen {
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
                                                .padding(.bottom, Spacing.space400)
                                                .padding(.horizontal, Spacing.space200)
                                                .onPreferenceChange(ViewHeightKey.self) {
                                                    self.modalFitsScreen = $0 < (gp.size.height - topMargin * 2)
                                                }
                                        } else {
                                            ScrollView {
                                                modal()
                                                    .simultaneousGesture(
                                                        DragGesture()
                                                            .onChanged { _ in
                                                                offset = .zero
                                                            }
                                                    )
                                                    .padding(.bottom, Spacing.space400)
                                                    .padding(.horizontal, Spacing.space200)
                                            }
                                        }
                                    }
                                    .padding(
                                        .horizontal,
                                        horizontalSizeClass == .regular ? Spacing.space1000 : Spacing.space0
                                    )
                                    .edgesIgnoringSafeArea(.bottom)
                                    .background {
                                        RoundedRectangle(cornerRadius: CornerRadius.m)
                                            .fill(Colors.primary.white)
                                            .edgesIgnoringSafeArea(.bottom)
                                            .padding(
                                                .horizontal,
                                                horizontalSizeClass == .regular ? Spacing.space1000 : Spacing.space0
                                            )
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
                        .onDisappear {
                            isPresented = false
                            modalFitsScreen = true
                            offset = .zero
                            withAnimation {
                                backOpacityLayer = 0
                            }
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
