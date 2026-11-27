import AlicerceLogging
import CombineSchedulers
import Foundation
import Model

public final class BagDependencyContainer {
    let cartService: CartServiceProtocol
    let analytics: AlfieAnalyticsTracker
    let log: Logger
    let scheduler: AnySchedulerOf<DispatchQueue>

    public init(
        cartService: CartServiceProtocol,
        analytics: AlfieAnalyticsTracker,
        log: Logger,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.cartService = cartService
        self.analytics = analytics
        self.log = log
        self.scheduler = scheduler
    }
}
