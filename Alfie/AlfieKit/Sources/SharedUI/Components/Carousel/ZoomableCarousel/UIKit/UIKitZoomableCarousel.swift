import Combine
import SwiftUI
import UIKit
import Utils

final class UIKitZoomableCarousel<Content: View>: UIScrollView, UIScrollViewDelegate {
    private var didLoad = false
    private var isAnimating = false
    private let items: [Content]
    private let configuration: ZoomableCarouselConfiguration
    private var childViews = [ZoomableUIView<Content>]()
    private var slidePublisher: AnyPublisher<Void, Never>
    private var subscriptions = Set<AnyCancellable>()
    @Binding var currentIndex: Int {
        didSet {
            actualCurrentIndex = currentIndex + 1
        }
    }
    private var actualCurrentIndex: Int

    init(
        currentIndex: Binding<Int>,
        slidePublisher: AnyPublisher<Void, Never>,
        items: [Content],
        configuration: ZoomableCarouselConfiguration
    ) {
        self._currentIndex = currentIndex
        self.slidePublisher = slidePublisher
        self.items = items
        self.actualCurrentIndex = items.count > 1 ? currentIndex.wrappedValue + 1 : 0
        self.configuration = configuration
        super.init(frame: .zero)

        setupItemsIfNeeded()
        setupScrollViewProperties()
        setupSubscriptions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // consider it loaded when the scrollView has its content (width > 0)
        if !didLoad && contentSize.width > 0 {
            setCorrectPage(for: actualCurrentIndex)
            didLoad = true
        }
    }

    // MARK: Private Methods:
    private func setupScrollViewProperties() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        isPagingEnabled = true
        delegate = self
    }

    private func setupItemsIfNeeded() {
        guard subviews.isEmpty else {
            return
        }

        guard items.count > 1 else {
            // single image -> no edge placeholders
            appendView(at: 0)
            return
        }

        // multiple image carousel -> edge placeholders
        appendView(at: items.count - 1)

        (0...items.count - 1).forEach { index in
            appendView(at: index)
        }

        appendView(at: 0)
    }

    private func setupSubscriptions() {
        Publishers.MergeMany(childViews.map { $0.$dismissPanGestureYTranslation })
            .map { $0 != 0 }
            .removeDuplicates()
            .sink { [weak self] isAnyViewSwipping in
                self?.isScrollEnabled = !isAnyViewSwipping
            }
            .store(in: &subscriptions)

        slidePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                autoSlide(to: currentIndex)
            }
            .store(in: &subscriptions)
    }

    private func zoomableView(for index: Int) -> ZoomableUIView<Content>? {
        guard let contentView = items[safe: index] else {
            return nil
        }

        return ZoomableUIView(
            childView: contentView,
            index: index,
            dismissHeightMultiplier: 1 / 4,
            configuration: configuration
        )
    }

    private func checkIndexOverflow() {
        if actualCurrentIndex == 0 {
            actualCurrentIndex = childViews.count - 2
        } else if actualCurrentIndex == childViews.count - 1 {
            actualCurrentIndex = 1
        } else {
            return
        }

        setCorrectPage(for: actualCurrentIndex)
    }

    private func appendView(at index: Int) {
        guard let newView = zoomableView(for: index) else {
            return
        }

        addSubview(newView)

        NSLayoutConstraint.activate([
            newView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor),
            newView.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor),
        ])

        if let lastView = childViews.last {
            lastView.anchorTo(trailing: nil)
            newView.anchorTo(leading: lastView.trailingAnchor)
        } else { // first view to be added; set same leading as parent (carousel)
            newView.anchorTo(leading: leadingAnchor)
        }

        newView.anchorTo(trailing: trailingAnchor)

        childViews.append(newView)
        layoutSubviews()
    }

    func autoSlide(to index: Int) {
        let newActualIndex = index < 0 ? 0 : index + 1
        guard !isAnimating, actualCurrentIndex != newActualIndex else {
            return
        }

        setCorrectPage(for: newActualIndex, animated: true, animationDuration: 0.2) { [weak self] in
            guard let self else { return }
            actualCurrentIndex = newActualIndex
            checkIndexOverflow()
            correctRealIndexIfNeeded()
            resetScalesIfNeeded()
        }
    }

    private func resetScalesIfNeeded() {
        childViews.enumerated()
            .filter { $0 != actualCurrentIndex && !$1.isVisible(in: self) }
            .forEach { $1.zoomScale = 1 }
    }

    private func correctRealIndexIfNeeded() {
        if actualCurrentIndex <= 0 {
            currentIndex = childViews.count - 2
        } else {
            currentIndex = actualCurrentIndex - 1
        }
    }

    private func setCorrectPage(for index: Int, animated: Bool = false, animationDuration: TimeInterval = 0.1, _ completion: (() -> Void)? = nil) {
        guard animated else {
            setContentOffset(.init(x: CGFloat(index) * frame.size.width, y: 0), animated: false)
            completion?()
            return
        }
        isAnimating = true

        UIView.animate(withDuration: animationDuration) {
            self.setContentOffset(.init(x: CGFloat(index) * self.frame.size.width, y: 0), animated: false)
        } completion: { _ in
            self.isAnimating = false
            completion?()
        }
    }

    // MARK: Delegate Methods:
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // we don't want sudden changes while the user has his finger on screen
        guard !scrollView.isTracking && !isAnimating else {
            return
        }

        let newVisibleIndex = childViews
            .enumerated()
            .min { $0.element.visibility(in: scrollView) > $1.element.visibility(in: scrollView) }?.offset

        guard
            let newVisibleIndex,
            newVisibleIndex != actualCurrentIndex
        else {
            return
        }

        // complete transition to new page; correct index afterwards if needed
        setCorrectPage(for: newVisibleIndex, animated: true) { [weak self] in
            self?.actualCurrentIndex = newVisibleIndex
            self?.checkIndexOverflow()
            self?.correctRealIndexIfNeeded()
            self?.resetScalesIfNeeded()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resetScalesIfNeeded()
    }
}

private extension UIView {
    func isVisible(in scrollView: UIScrollView) -> Bool {
        visibility(in: scrollView) > 0
    }

    func visibility(in scrollView: UIScrollView) -> CGFloat {
        let visibleRect = CGRect(
            origin: scrollView.contentOffset,
            size: CGSize(width: scrollView.bounds.size.width - 1, height: scrollView.bounds.size.height)
        )
        let subviewFrame = scrollView.convert(frame, from: superview)
        let intersectionRect = visibleRect.intersection(subviewFrame)
        guard !intersectionRect.isNull && intersectionRect.size.height > 0 && intersectionRect.size.width > 0 else {
            return 0
        }

        return intersectionRect.size.width
    }
}
