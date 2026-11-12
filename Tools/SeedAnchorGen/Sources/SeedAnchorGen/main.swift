import Foundation
import SeedAnchorGenCore

func value(for flag: String) -> String? {
    guard let i = CommandLine.arguments.firstIndex(of: flag), i + 1 < CommandLine.arguments.count else { return nil }
    return CommandLine.arguments[i + 1]
}

guard let input = value(for: "--input"), let output = value(for: "--output") else {
    FileHandle.standardError.write(Data("usage: SeedAnchorGen --input <seed-anchors.json> --output <file.swift>\n".utf8))
    exit(2)
}

do {
    let source = try SeedAnchorsGenerator.swiftSource(fromJSON: Data(contentsOf: URL(fileURLWithPath: input)))
    try Data(source.utf8).write(to: URL(fileURLWithPath: output), options: .atomic)
    print("✅ Generated \(output)")
} catch {
    FileHandle.standardError.write(Data("❌ \(error)\n".utf8))
    exit(1)
}
