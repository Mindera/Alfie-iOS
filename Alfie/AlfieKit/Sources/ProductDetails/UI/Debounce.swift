import CombineSchedulers
import Foundation

/// A deadline only the latest caller owns.
///
/// Each `schedule` supersedes the deadline the one before it set, so a burst of taps runs `action`
/// once rather than per tap. `cancel` abandons the outstanding deadline for a caller acting now.
final class Debounce {
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let delay: DispatchQueue.SchedulerTimeType.Stride
    private var generation = 0

    init(scheduler: AnySchedulerOf<DispatchQueue>, delay: DispatchQueue.SchedulerTimeType.Stride) {
        self.scheduler = scheduler
        self.delay = delay
    }

    func schedule(_ action: @escaping () -> Void) {
        generation += 1
        let scheduled = generation
        scheduler.schedule(after: scheduler.now.advanced(by: delay)) { [weak self] in
            guard let self, scheduled == generation else { return }
            action()
        }
    }

    func cancel() {
        generation += 1
    }
}
