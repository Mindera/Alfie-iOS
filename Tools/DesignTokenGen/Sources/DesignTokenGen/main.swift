import DesignTokenGenCore
import Foundation

// Usage: DesignTokenGen --input <DesignTokens dir> --output <GeneratedTokens dir>
func value(for flag: String) -> String? {
    guard let i = CommandLine.arguments.firstIndex(of: flag), i + 1 < CommandLine.arguments.count else { return nil }
    return CommandLine.arguments[i + 1]
}

guard let input = value(for: "--input"), let output = value(for: "--output") else {
    FileHandle.standardError.write(Data("usage: DesignTokenGen --input <dir> --output <dir>\n".utf8))
    exit(2)
}

do {
    let result = try Generator.run(
        inputDirectory: URL(fileURLWithPath: input, isDirectory: true),
        outputDirectory: URL(fileURLWithPath: output, isDirectory: true)
    )
    for warning in result.warnings { print("⚠️  \(warning)") }
    print("✅ Generated \(result.writtenFiles.count) file(s): \(result.writtenFiles.joined(separator: ", "))")
} catch {
    FileHandle.standardError.write(Data("❌ \(error)\n".utf8))
    exit(1)
}
