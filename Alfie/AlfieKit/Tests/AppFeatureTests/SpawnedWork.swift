final class SpawnedWork {
    private var operations: [() async -> Void] = []

    func spawn(_ operation: @escaping () async -> Void) {
        operations.append(operation)
    }

    func run() async {
        let pending = operations
        operations = []

        for operation in pending {
            await operation()
        }
    }
}
