import Core
import Models

final class BagDependencyContainer: BagDependencyContainerProtocol {
    let bagService: BagServiceProtocol

    init(bagService: BagServiceProtocol) {
        self.bagService = bagService
    }
}
