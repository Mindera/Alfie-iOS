import Foundation

/// Orchestrates load → validate → emit → write. Cleans stale `*+Generated.swift` before writing so
/// a removed token category can't leave an orphaned committed file (red-team C2).
public enum Generator {
    public struct Result {
        public let writtenFiles: [String]
        public let warnings: [String]
    }

    public static func run(inputDirectory: URL, outputDirectory: URL) throws -> Result {
        let loaded = try TokenLoader.load(inputDirectory: inputDirectory)
        let cycleAllowlist = try CycleAllowlist.load(from: inputDirectory.appendingPathComponent(".cycle-allowlist.json"))
        let brokenRefAllowlist = try BrokenRefAllowlist.load(from: inputDirectory.appendingPathComponent(".broken-ref-allowlist.json"))

        let resolver = Resolver(loaded: loaded, cycleAllowlist: cycleAllowlist, brokenRefAllowlist: brokenRefAllowlist)
        let warnings = try resolver.validate()

        let files = try Emitter(loaded: loaded, resolver: resolver).emit()

        try cleanGeneratedFiles(in: outputDirectory)
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        for name in files.keys.sorted() {
            let url = outputDirectory.appendingPathComponent(name)
            try (files[name]! + "\n").write(to: url, atomically: true, encoding: .utf8)
        }
        return Result(writtenFiles: files.keys.sorted(), warnings: warnings)
    }

    /// Generate into memory only — used by determinism tests.
    public static func emitInMemory(inputDirectory: URL) throws -> [String: String] {
        let loaded = try TokenLoader.load(inputDirectory: inputDirectory)
        let cycleAllowlist = try CycleAllowlist.load(from: inputDirectory.appendingPathComponent(".cycle-allowlist.json"))
        let brokenRefAllowlist = try BrokenRefAllowlist.load(from: inputDirectory.appendingPathComponent(".broken-ref-allowlist.json"))
        let resolver = Resolver(loaded: loaded, cycleAllowlist: cycleAllowlist, brokenRefAllowlist: brokenRefAllowlist)
        _ = try resolver.validate()
        return try Emitter(loaded: loaded, resolver: resolver).emit()
    }

    static func cleanGeneratedFiles(in directory: URL) throws {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(atPath: directory.path) else { return }
        for file in contents where file.hasSuffix("+Generated.swift") {
            try fm.removeItem(at: directory.appendingPathComponent(file))
        }
    }
}
