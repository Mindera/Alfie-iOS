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

        let emitter = Emitter(loaded: loaded, resolver: resolver)
        let files = try emitter.emit()
        // Language-neutral resolved-token JSON per theme, written to a subdirectory that is EXCLUDED
        // from the SharedUI SwiftPM target (only the sibling `*+Generated.swift` compile).
        let resolved = try emitter.emitResolvedThemes()

        try cleanGeneratedFiles(in: outputDirectory)
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        for name in files.keys.sorted() {
            try (files[name]! + "\n").write(to: outputDirectory.appendingPathComponent(name), atomically: true, encoding: .utf8)
        }
        var written = files.keys.sorted()
        if !resolved.isEmpty {
            let resolvedDir = outputDirectory.appendingPathComponent(resolvedSubdirectory, isDirectory: true)
            try FileManager.default.createDirectory(at: resolvedDir, withIntermediateDirectories: true)
            for name in resolved.keys.sorted() {
                try (resolved[name]! + "\n").write(to: resolvedDir.appendingPathComponent(name), atomically: true, encoding: .utf8)
                written.append("\(resolvedSubdirectory)/\(name)")
            }
        }
        return Result(writtenFiles: written, warnings: warnings)
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

    /// Subdirectory (under the output dir) for the resolved-token JSON export. Excluded from the
    /// SharedUI SwiftPM target so the non-Swift files don't trip SPM's source handling.
    static let resolvedSubdirectory = "ResolvedTokens"

    static func cleanGeneratedFiles(in directory: URL) throws {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(atPath: directory.path) else { return }
        for file in contents where file.hasSuffix("+Generated.swift") {
            try fm.removeItem(at: directory.appendingPathComponent(file))
        }
        // Wipe the resolved-JSON subdirectory wholesale so a removed theme leaves no orphan export.
        let resolvedDir = directory.appendingPathComponent(resolvedSubdirectory, isDirectory: true)
        if fm.fileExists(atPath: resolvedDir.path) { try fm.removeItem(at: resolvedDir) }
    }
}
