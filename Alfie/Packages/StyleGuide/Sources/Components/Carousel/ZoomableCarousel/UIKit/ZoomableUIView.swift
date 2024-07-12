import Foundation
import SwiftUI
import UIKit

protocol ZoomableViewConfigurationProtocol {
    var isPresented: Binding<Bool> { get }
    var minZoomScale: CGFloat { get }
    var maxZoomScale: CGFloat { get }
    var doubleTapZoomScale: CGFloat { get }
}

extension ZoomableCarouselConfiguration: ZoomableViewConfigurationProtocol {}

final class ZoomableUIView<Content: View>: UIScrollView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    private let hostingController: UIHostingController<Content>
    private let configuration: ZoomableViewConfigurationProtocol
    private let dismissHeightMultiplier: CGFloat
    private lazy var dismissPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
    @Published private(set) var dismissPanGestureYTranslation: CGFloat = 0
    private var trailingConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?

    private var isZoomed: Bool {
        super.isZooming || zoomScale > configuration.minZoomScale
    }

    private var uiView: UIView {
        hostingController.view
    }

    private var translationNeededToDismiss: CGFloat {
        frame.height * dismissHeightMultiplier
    }

    init(
        childView: Content,
        index: Int,
        dismissHeightMultiplier: CGFloat,
        configuration: ZoomableViewConfigurationProtocol
    ) {
        self.hostingController = UIHostingController(rootView: childView)
        self.dismissHeightMultiplier = dismissHeightMultiplier
        self.configuration = configuration

        super.init(frame: .zero)

        setupConstraints()
        setupScrollViewProperties()
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ensureViewIsCenteredInSelf()
    }

    // MARK: Private Methods:
    private func setupScrollViewProperties() {
        delegate = self
        minimumZoomScale = configuration.minZoomScale
        maximumZoomScale = configuration.maxZoomScale
        contentInsetAdjustmentBehavior = .always
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }

    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .clear
        addSubview(uiView)

        NSLayoutConstraint.activate([
            uiView.leadingAnchor.constraint(equalTo: leadingAnchor),
            uiView.trailingAnchor.constraint(equalTo: trailingAnchor),
            uiView.widthAnchor.constraint(equalTo: widthAnchor),
            uiView.heightAnchor.constraint(equalTo: heightAnchor),
            uiView.topAnchor.constraint(equalTo: topAnchor),
            uiView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func setupGestureRecognizers() {
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(doubleTapRecognizer)

        dismissPanGestureRecognizer.delegate = self
        addGestureRecognizer(dismissPanGestureRecognizer)
    }

    @objc
    private func onDoubleTap(_ sender: UITapGestureRecognizer) {
        let pointInView = sender.location(in: uiView)

        let newZoomScale = zoomScale == minimumZoomScale ? configuration.doubleTapZoomScale : minimumZoomScale
        let zoomSize = CGSize(width: bounds.size.width / newZoomScale, height: bounds.size.height / newZoomScale)
        let zoomOrigin = CGPoint(x: pointInView.x - zoomSize.width / 2, y: pointInView.y - zoomSize.height / 2)
        let zoomRect = CGRect(origin: zoomOrigin, size: zoomSize)

        zoom(to: zoomRect, animated: true)
    }

    private func ensureViewIsCenteredInSelf() {
        // Apply the content inset to the scrollView if the zoom scale is within limits
        guard zoomScale <= maximumZoomScale else {
            return
        }

        // how much the view has been streched (compared to its intrisic size)
        let widthRatio = uiView.frame.width / uiView.intrinsicContentSize.width
        let heightRatio = uiView.frame.height / uiView.intrinsicContentSize.height

        let scalingFactor = min(widthRatio, heightRatio)

        let widthWithScalingFactor = uiView.intrinsicContentSize.width * scalingFactor
        let heightWithScalingFactor = uiView.intrinsicContentSize.height * scalingFactor

        // Calculate the horizontal and vertical insets to center the uiView within the scrollView
        var horizontalInset: CGFloat {
            if widthWithScalingFactor * zoomScale > uiView.frame.width {
                return widthWithScalingFactor - uiView.frame.width
            } else {
                return frame.width - uiView.frame.width
            }
        }

        var verticalInset: CGFloat {
            if heightWithScalingFactor * zoomScale > uiView.frame.height {
                return heightWithScalingFactor - uiView.frame.height
            } else {
                return frame.height - uiView.frame.height
            }
        }

        let contentInset = UIEdgeInsets(
            top: verticalInset / 2 - safeAreaInsets.top,
            left: horizontalInset / 2,
            bottom: verticalInset / 2 - safeAreaInsets.bottom,
            right: horizontalInset / 2
        )

        self.contentInset = contentInset
    }

    @objc
    private func onPan(_ sender: UIPanGestureRecognizer) {
        let deltaTranslation = sender.translation(in: self)
        let velocity = sender.velocity(in: self)
        let isVerticalGesture = abs(velocity.y) > abs(velocity.x)
        // if it's not vertical we interrupt, unless it's already ongoing. sender.state == .changed won't work here
        let isGestureValid = isVerticalGesture || abs(dismissPanGestureYTranslation) > 0

        guard !isZoomed && !isTracking && isGestureValid else {
            sender.state = .cancelled
            dismissPanGestureYTranslation = 0

            if uiView.transform != .identity && !isZoomed {
                resetUIViewTransform()
            }
            return
        }

        var normalizedDismissalPercentage: CGFloat {
            dismissPanGestureYTranslation / translationNeededToDismiss
        }

        switch sender.state {
        case .began:
            dismissPanGestureYTranslation = 0

        case .changed:
            dismissPanGestureYTranslation += deltaTranslation.y
            uiView.transform = .identity.translatedBy(x: 0, y: dismissPanGestureYTranslation)
            sender.setTranslation(.zero, in: self)

        case .ended,
            .cancelled,
            .failed:
            if sender.state != .failed && normalizedDismissalPercentage > 1 {
                configuration.isPresented.wrappedValue = false
            } else {
                resetUIViewTransform()
            }

            dismissPanGestureYTranslation = 0

        default:
            break
        }
    }

    private func resetUIViewTransform() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4) {
            self.uiView.transform = .identity
        }
    }

    // MARK: Internal Methods:
    func anchorTo(trailing: NSLayoutXAxisAnchor?) {
        guard let trailing else {
            trailingConstraint?.isActive = false
            trailingConstraint = nil
            return
        }

        trailingConstraint = trailingAnchor.constraint(equalTo: trailing)
        trailingConstraint?.isActive = true
    }

    func anchorTo(leading: NSLayoutXAxisAnchor?) {
        guard let leading else {
            leadingConstraint?.isActive = false
            leadingConstraint = nil
            return
        }

        leadingConstraint = leadingAnchor.constraint(equalTo: leading)
        leadingConstraint?.isActive = true
    }

    // MARK: Delegate Methods:
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        !isZoomed
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { uiView }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        ensureViewIsCenteredInSelf()

        if isZoomed {
            removeGestureRecognizer(dismissPanGestureRecognizer)
        } else {
            if gestureRecognizers?.contains(dismissPanGestureRecognizer) == false {
                addGestureRecognizer(dismissPanGestureRecognizer)
            }
        }
    }
}
