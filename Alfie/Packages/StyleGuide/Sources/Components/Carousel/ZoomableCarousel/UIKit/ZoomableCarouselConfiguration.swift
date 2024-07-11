import UIKit
import SwiftUI

public struct ZoomableCarouselConfiguration {
    let isPresented: Binding<Bool>
    let minZoomScale: CGFloat
    let maxZoomScale: CGFloat
    let doubleTapZoomScale: CGFloat

    public init(isPresented: Binding<Bool>,
                minZoomScale: CGFloat = 1,
                maxZoomScale: CGFloat = 3,
                doubleTapZoomScale: CGFloat = 3) {
        self.isPresented = isPresented
        self.minZoomScale = minZoomScale
        self.maxZoomScale = maxZoomScale
        self.doubleTapZoomScale = doubleTapZoomScale
    }
}
