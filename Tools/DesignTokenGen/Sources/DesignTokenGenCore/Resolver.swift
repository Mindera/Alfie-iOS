import Foundation

/// Walks `{reference}` chains to a concrete value, honoring the two exhaustive allowlists:
/// known plugin cycles resolve to their Primitives value; pinned broken refs are tolerated.
/// Anything not allow-listed fails the build (per the token repo contract).
public struct Resolver {
    public enum Terminal: Equatable {
        case concrete(Token)              // chain ended at a concrete value
        case allowlistedBrokenRef(String) // chain hit a pinned missing target — caller skips emission
    }

    let map: [String: Token]
    let primitiveValues: [String: Token]
    let cycleAllowlist: CycleAllowlist
    let brokenRefAllowlist: BrokenRefAllowlist
    let loadedFiles: Set<String>
    let maxDepth: Int

    public init(loaded: LoadedTokens, cycleAllowlist: CycleAllowlist, brokenRefAllowlist: BrokenRefAllowlist, maxDepth: Int = 32) {
        self.map = loaded.map
        self.primitiveValues = loaded.primitiveValues
        self.cycleAllowlist = cycleAllowlist
        self.brokenRefAllowlist = brokenRefAllowlist
        self.loadedFiles = loaded.loadedFiles
        self.maxDepth = maxDepth
    }

    /// Result of resolving a single token, with any side-channel signals collected.
    struct Trace {
        var hitCycleEdges: Set<CycleAllowlist.Edge> = []
        var hitBrokenRefs: Set<String> = []
        var warnings: [String] = []
    }

    /// Resolve `start` to its terminal concrete token (or an allow-listed broken ref).
    func terminal(of start: String, trace: inout Trace) throws -> Terminal {
        var chain: [String] = []
        var current = start
        while true {
            if chain.count > maxDepth { throw DesignTokenError.referenceTooDeep(token: start) }
            guard let token = map[current] else {
                // `current` is a reference target that doesn't exist in the map.
                if brokenRefAllowlist.contains(current) {
                    trace.hitBrokenRefs.insert(current)
                    return .allowlistedBrokenRef(current)
                }
                throw DesignTokenError.missingReference(token: chain.last ?? start, target: current)
            }
            chain.append(current)
            guard case .reference(let target) = token.value else {
                return .concrete(token)
            }
            if let idx = chain.firstIndex(of: target) {
                return .concrete(try resolveCycle(loop: Array(chain[idx...]), trace: &trace))
            }
            current = target
        }
    }

    /// Every node in a detected cycle must be allow-listed; resolve to a Primitives value in the loop.
    private func resolveCycle(loop: [String], trace: inout Trace) throws -> Token {
        for name in loop {
            let file = map[name]?.file ?? ""
            if cycleAllowlist.contains(file: file, token: name) {
                trace.hitCycleEdges.insert(.init(file: file, token: name))
            } else {
                throw DesignTokenError.unexpectedCycle(file: file, token: name)
            }
        }
        for name in loop {
            if let primitive = primitiveValues[name] {
                trace.warnings.append("cycle on \(loop.joined(separator: "→")) resolved to primitive '\(name)'")
                return primitive
            }
        }
        let last = loop.last ?? ""
        throw DesignTokenError.unexpectedCycle(file: map[last]?.file ?? "", token: last)
    }

    /// Resolve every token, then enforce both allow-lists are exhaustive (no stale entries).
    /// Returns accumulated warnings. Allow-list staleness is scoped to the files actually loaded
    /// (the iOS subset) — entries pinned to android/web/other-breakpoint files are out of scope.
    @discardableResult
    public func validate() throws -> [String] {
        var trace = Trace()
        for name in map.keys.sorted() {
            _ = try terminal(of: name, trace: &trace)
            // Composite typography sub-fields hold their own references — walk them through the
            // same trace so a cycle/broken-ref reachable ONLY via a sub-field still feeds the
            // exhaustiveness accounting (not just the emit-time backstop).
            if case .typography(let typo) = map[name]?.value {
                for field in [typo.fontFamily, typo.fontWeight, typo.fontSize, typo.lineHeight, typo.letterSpacing] {
                    if case .reference(let target) = field {
                        _ = try terminal(of: target, trace: &trace)
                    }
                }
            }
        }
        for edge in cycleAllowlist.edges where loadedFiles.contains(edge.file) {
            if !trace.hitCycleEdges.contains(edge) {
                throw DesignTokenError.staleCycleAllowlistEntry(file: edge.file, token: edge.token)
            }
        }
        for target in brokenRefAllowlist.missingTargets.sorted() where !trace.hitBrokenRefs.contains(target) {
            throw DesignTokenError.staleBrokenRefAllowlistEntry(target: target)
        }
        return Array(Set(trace.warnings)).sorted()
    }

    /// Convenience for tests/emit: resolve to a concrete token, ignoring traces.
    public func resolvedConcrete(_ name: String) throws -> Token? {
        var trace = Trace()
        if case .concrete(let token) = try terminal(of: name, trace: &trace) { return token }
        return nil
    }

    public func isPrimitive(_ name: String) -> Bool { primitiveValues[name] != nil }
}
