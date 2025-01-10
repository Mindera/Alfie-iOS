import Core
import Models

final class BagDependencyContainer {
    let bagService: BagServiceProtocol

    init(bagService: BagServiceProtocol) {
        self.bagService = bagService
    }
}
