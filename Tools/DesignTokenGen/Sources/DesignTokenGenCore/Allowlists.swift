import Foundation

/// Pinned `(file, token)` cycle edges the Design Token Exporter produces — see the token repo's
/// `DESIGN_TOKENS_FORMAT.md` §Cycle Handling. Treated as exhaustive: a listed edge that no longer
/// matches a real cycle is stale and fails the build.
public struct CycleAllowlist: Equatable {
    public struct Edge: Equatable, Hashable {
        public let file: String
        public let token: String
    }
    public let edges: [Edge]

    public func contains(file: String, token: String) -> Bool {
        edges.contains(Edge(file: file, token: token))
    }

    public static func load(from url: URL) throws -> CycleAllowlist {
        let data = try Data(contentsOf: url)
        let raw = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let rawEdges = raw?["edges"] as? [[String: Any]] ?? []
        let edges = rawEdges.compactMap { dict -> Edge? in
            guard let file = dict["file"] as? String, let token = dict["token"] as? String else { return nil }
            return Edge(file: file, token: token)
        }
        return CycleAllowlist(edges: edges)
    }
}

/// Pinned missing-reference targets (FONT_STYLE-scoped font weights the exporter filters out).
/// Also exhaustive.
public struct BrokenRefAllowlist: Equatable {
    public let missingTargets: Set<String>

    public func contains(_ target: String) -> Bool { missingTargets.contains(target) }

    public static func load(from url: URL) throws -> BrokenRefAllowlist {
        let data = try Data(contentsOf: url)
        let raw = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let targets = raw?["missingTargets"] as? [String] ?? []
        return BrokenRefAllowlist(missingTargets: Set(targets))
    }
}
