import Foundation
import Testing
@testable import AlfieCodeGenCore

@Suite("Generator")
struct GeneratorTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("AlfieCodeGenTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    @Test("one image file per handle, named after the product")
    func writesOneFilePerHandle() throws {
        let output = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: output) }

        let result = try Generator.run(
            list: "mens-jeans-slim-indigo\nwomens-coat-wool-camel, SKU-8842",
            outputDirectory: output,
            baseURL: AlfieCode.defaultBaseURL,
            size: .swingTag
        )

        #expect(result.files.map(\.lastPathComponent) == [
            "mens-jeans-slim-indigo.png",
            "womens-coat-wool-camel--sku-SKU-8842.png",
        ])
        for file in result.files {
            #expect(FileManager.default.fileExists(atPath: file.path))
        }
    }

    @Test("each written file decodes back to that product's link")
    func writtenFilesDecode() throws {
        let output = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: output) }

        let result = try Generator.run(
            list: "mens/jeans/slim-indigo, SKU-8842",
            outputDirectory: output,
            baseURL: AlfieCode.defaultBaseURL,
            size: .swingTag
        )

        let data = try Data(contentsOf: try #require(result.files.first))
        #expect(
            try PNGProbe.decodedMessage(in: data)
                == "https://localhost:4000/product/mens/jeans/slim-indigo?sku=SKU-8842"
        )
    }

    @Test("the output directory is created when it does not exist yet")
    func createsOutputDirectory() throws {
        let parent = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: parent) }
        let output = parent.appendingPathComponent("codes", isDirectory: true)

        let result = try Generator.run(
            list: "mens-jeans",
            outputDirectory: output,
            baseURL: AlfieCode.defaultBaseURL,
            size: .swingTag
        )

        #expect(result.files.count == 1)
    }

    @Test("a malformed list writes nothing at all")
    func malformedListWritesNothing() throws {
        let output = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: output) }

        #expect(throws: AlfieCodeError.self) {
            try Generator.run(
                list: "mens-jeans\nnot a handle",
                outputDirectory: output,
                baseURL: AlfieCode.defaultBaseURL,
                size: .swingTag
            )
        }

        let written = try FileManager.default.contentsOfDirectory(atPath: output.path)
        #expect(written.isEmpty)
    }

    @Test("an empty list is reported rather than silently succeeding")
    func emptyListIsReported() throws {
        let output = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: output) }

        #expect(throws: AlfieCodeError.emptyList) {
            try Generator.run(
                list: "# only a comment\n",
                outputDirectory: output,
                baseURL: AlfieCode.defaultBaseURL,
                size: .swingTag
            )
        }
    }

    @Test("a missing input file is reported by name")
    func missingInputFileIsReported() throws {
        let output = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: output) }
        let missing = output.appendingPathComponent("nope.txt")

        #expect(throws: AlfieCodeError.self) {
            try Generator.run(
                inputFile: missing,
                outputDirectory: output,
                baseURL: AlfieCode.defaultBaseURL,
                size: .swingTag
            )
        }
    }

    @Test("the example list shipped in the repo still generates")
    func generatesFromShippedExampleList() throws {
        let output = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: output) }

        // The file a reader is pointed at by the README — kept honest here so it cannot rot.
        let example = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // AlfieCodeGenCoreTests
            .deletingLastPathComponent()   // Tests
            .deletingLastPathComponent()   // AlfieCodeGen
            .appendingPathComponent("handles.example.txt")

        let result = try Generator.run(
            inputFile: example,
            outputDirectory: output,
            baseURL: AlfieCode.defaultBaseURL,
            size: .swingTag
        )

        #expect(!result.files.isEmpty)
        for link in result.links {
            #expect(link.absoluteString.hasPrefix("https://localhost:4000/product/"))
        }
    }
}
