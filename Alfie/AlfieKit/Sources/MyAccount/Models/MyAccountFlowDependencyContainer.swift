import Core
import Model

public final class MyAccountFlowDependencyContainer {
    let myAccountDependencyContainer: MyAccountDependencyContainer

    public init(myAccountDependencyContainer: MyAccountDependencyContainer) {
        self.myAccountDependencyContainer = myAccountDependencyContainer
    }
}
