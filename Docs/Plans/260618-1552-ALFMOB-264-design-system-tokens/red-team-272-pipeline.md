# Red Team Review: ALFMOB-272 — Phase 1 Token Pipeline (DTCG parser + Swift codegen)

_Adversarial review, 2026-06-19. Scope: **ALFMOB-272 / Phase 1 only** — the standalone Swift
DTCG→Swift generator. Findings grounded in the worktree. Complements the epic-level
`red-team.md` (M1–M4); everything here is **new** and specific to pipeline mechanics.
Plan updated to absorb the Accepted items — see "Disposition" tags + `phase-1-token-pipeline.md`._

## Verdict
The Phase-1 plan is directionally right (standalone Swift generator, committed output, reference
graph) but **under-specifies the DTCG contract and has no real verification of its own core
deliverable**. The generator's tests never run in any mandatory gate; "byte-identical determinism"
and "error on missing refs" are asserted with no implementing mechanism; and the spike step isn't
told to probe the contract features most likely to break it (composite tokens, color/alpha formats,
px/rem units, cross-file aliases). Several of these bake **silently-wrong values** into committed
Swift that nothing in P1 can surface — they detonate in P2–P4.

---

## Critical (block — fix before execute)

### C1. The generator's unit tests — the story's core deliverable — never run in any mandatory gate
- **Evidence**: `verify.sh` → `build-for-verification.sh` + `test-for-verification.sh` run **only**
  `xcodebuild -scheme Alfie` against `Alfie/Alfie.xcodeproj`. CI runs only `fastlane ios test`.
  The plan deliberately keeps `Tools/DesignTokenGen` **out of the AlfieKit graph**
  (`phase-1-token-pipeline.md:52-53`). So `swift test --package-path Tools/DesignTokenGen` (the
  alias-resolver/cycle/reference-graph tests — `:75-78`) is invoked by **nothing** automatic.
- **Why it breaks P1**: A dev can land a broken resolver, run `verify.sh`, get
  `✅ FULL VERIFICATION PASSED` (it only recompiles the *already-committed* generated Swift), and ship.
  The project's one completion signal is satisfiable with a completely broken generator.
- **Fix**: `generate-design-tokens.sh` runs `swift test --package-path Tools/DesignTokenGen`
  (fail-fast) **before** emitting — i.e. gated as part of the developer's "tokens/generator changed"
  task; document that `verify.sh` does NOT cover the generator. **Disposition: ACCEPTED (validation-272
  decision 3) → gate in the generate script ONLY. NOT in `verify.sh`, NOT in CI — regeneration is rare
  and CI is out of scope this stage (prior no-CI decision).**

### C2. No output cleaning on token removal — orphaned `*+Generated.swift` survives the drift gate
- **Evidence**: `main.swift` is "write `*+Generated.swift` to the output dir" (`:30`) — overwrite
  only, one file per category. The drift gate (step 6) is `git diff`, which flags content changes to
  **tracked** files, not files that should no longer exist. Output is normal compiled SharedUI source.
- **Why it breaks P1** (distinct from epic M2 = content drift): drop a category from the export (e.g.
  `radius.json`) → generator simply doesn't emit `Radius+Generated.swift`, but the committed one stays
  on disk, stays compiled, and `git diff` shows nothing. Committed Swift now references primitives the
  JSON no longer defines → silent stale values that pass the local drift gate.
- **Fix**: `main.swift` (or `generate-design-tokens.sh`) cleans the output dir before emitting
  (`rm` all `*+Generated.swift` / `git clean -fdx GeneratedTokens/`), so `git diff --exit-code`
  catches deletions too. **Disposition: ACCEPTED → P1 step added.**

### C3. "Run twice → byte-identical" has no mechanism — Dictionary/JSON key order is randomized
- **Evidence**: Verification AC `:81`. DTCG groups are open-ended name→token maps decoding into Swift
  `Dictionary`, whose iteration order is non-deterministic across runs (randomized hash seed). No sort
  step is specified in `main.swift` or any `Emit+*.swift` (`:28-30`).
- **Why it breaks P1**: the **local `git diff` drift gate is P1's only freshness signal** (epic M2).
  Non-deterministic ordering → regenerate produces reordered-but-equivalent files → `git diff` is
  permanently noisy → devs learn to ignore it → M2's mitigation collapses and the byte-identical AC
  silently fails.
- **Fix**: sort every emitted collection by token path before string-building; add a generator test
  that emits twice on the same input and asserts byte-equality. **No timestamp/version/`Date()` in the
  generated header.** **Disposition: ACCEPTED → P1 contract + test added.**

---

## Major (significant rework / silent-wrong-value risk)

### J1. Cross-FILE alias resolution asserted, but no "merge 14 files into one graph" step
- **Evidence**: 14 separate JSON files (`:16`); resolver resolves `{a.b.c}`, errors on missing refs
  (`:27-28`). No stage says all files merge into one path-keyed graph **before** resolution. Semantic
  files routinely alias into primitive files.
- **Why it breaks P1**: per-file resolution → every cross-file `{primitive.color…}` is "missing ref"
  → generator errors and emits nothing (or emits broken refs). The reference-graph AC (M4) is
  unreachable if the graph was never unified.
- **Fix**: explicit "load all files → merge into one path-keyed dict → detect duplicate-path
  collisions (themes/modes: last-write-wins vs error — decide + test) → resolve" stage; test a
  reference that crosses two files. **Disposition: ACCEPTED → resolver contract expanded.**

### J2. Composite tokens (typography/shadow/border) are OBJECTS, not scalars
- **Evidence**: DTCG `$type: "typography"` has an **object** `$value`
  (`{fontFamily, fontSize, fontWeight, lineHeight, letterSpacing}`); shadow/border likewise. Existing
  typography is exactly this composite (`TypographySmallProtocol.swift`: family+size+weight+decoration
  variants). The emitter spec only describes the **color/leaf-hex** case (`:34-40`); `Emit+Typography`
  is listed with no composite-decode contract. DTCG `fontWeight` is string-or-number; `fontSize`/
  `lineHeight` are dimension objects.
- **Why it breaks P1**: if `DTCG.swift` types `$value` as a scalar, the first composite token fails to
  decode → no output. "Flatten at leaf hex" is meaningless for a typography object (no hex leaf).
- **Fix**: model `$value` as a tagged union on `$type`; decide the Swift representation of composites
  **before** writing emitters; decode-test each `$type`. The spike must explicitly enumerate composite
  types as a known unknown. **Disposition: ACCEPTED → spike checklist + DTCG model contract expanded.**

### J3. Swift identifier safety — leading-digit / reserved-word / dotted-path names won't compile
- **Evidence**: the team already hand-hacked around this: `CornerRadius.swift:9` ships
  `// swiftlint:disable discouraged_none_name identifier_name` for `none`/`xxs`; `Spacing.space025`
  carries a `space` prefix **only** to dodge the leading-digit identifier (`025`). Figma uses
  `display/large`, `2xl`, `050`. The emitter injects names verbatim into `static let <name>`.
- **Why it breaks P1**: a token named `2xl`/`050`/`default`/`repeat`/`case`/`static`/`operator` emits
  non-compiling Swift → `build-for-verification.sh` fails → P1's own gate red.
- **Fix**: define + unit-test a deterministic `toSwiftIdentifier()` (leading-digit prefix,
  separator→camelCase, keyword backtick-escape) **and** a collision check (two paths must not collapse
  to one identifier). **Disposition: ACCEPTED → P1 step + test added.**

### J4. Color-format coverage undefined; no existing hex→Color helper to lean on
- **Evidence**: zero hex parser in SharedUI (`grep "init(hex"`, `Color(red:` → nothing); colors come
  from `Colors.xcassets`. DTCG color `$value` is legally `#RGB`/`#RRGGBB`/`#RRGGBBAA`/`rgba()`/DTCG
  color object `{colorSpace, components, alpha}`. The emit example hand-writes `Color(red:…)` with no
  conversion routine and **no `opacity:`**.
- **Why it breaks P1**: generator invents its own parser (Foundation-only). Handle only `#RRGGBB` and
  the export uses 8-digit hex / objects → parse failure (no output) or silently dropped alpha
  (wrong committed color, undetectable until P2).
- **Fix**: enumerate accepted formats in the spike; implement + test each (3/6/8-digit, `rgba()`, DTCG
  object); emit `Color(red:green:blue:opacity:)` preserving alpha; round-trip test for alpha.
  **Disposition: ACCEPTED → spike checklist + emitter contract.**

### J5. Dimension units — DTCG `{value, unit}` may be px/rem; iOS uses points
- **Evidence**: existing tokens are raw points (`Spacing.space050 = 4`, `CornerRadius.xs = 4.0`). DTCG
  dimensions are `{value, unit:"px"|"rem"}`. Emitters (`:29`) state no unit policy; the spike note
  (`:18`) doesn't list px/rem.
- **Why it breaks P1**: `rem` (common when web leads the token export) needs ×base — `1.5rem`→`24pt`,
  not `1.5`. Naive emit bakes a 10×-wrong value into committed Swift that nothing in P1 surfaces; it
  detonates in P4.
- **Fix**: spike records `unit` for every dimension token; implement explicit unit→point conversion
  (px→pt 1:1 by iOS convention, rem→pt × base, **error on unknown unit**); unit-test it.
  **Disposition: ACCEPTED → spike checklist + emitter contract.**

### J6. AC/scope mismatch — ALFMOB-272's own ticket ACs are silently deferred to P2–P4
- **Evidence**: the ALFMOB-272 ticket ACs require: generated code **conforms to existing theme
  protocols** (`PrimaryColorsProtocol`, `TypographyHeaderProtocol`…), **Figma names verbatim**, and
  **replace `Colors.xcassets`/hardcoded values**. The plan scopes P1 as "pipeline only — nothing
  consumes it yet (that's P2–P4)" (`:5-6`); protocol re-pointing → P2, xcassets deletion → P2,
  typography forwarders → P3 (`plan.md:103-110`). So P1-as-scoped does **not** meet ALFMOB-272's own
  ticket ACs.
- **Why it breaks P1**: a reviewer either wrongly closes ALFMOB-272 with unmet ACs, or is blocked
  because P1's deliverable can't satisfy its own ticket. The plan re-mapped the ticket's ACs onto
  P2–P4 **without confirming the Jira ticket was re-scoped** (validation decision 4 says "P1 spike
  only this round" but doesn't reconcile the ticket ACs).
- **Fix**: reconcile in Jira before execution — either re-scope ALFMOB-272 to "pipeline only, no
  consumers" (move the protocol/xcassets/Figma-name ACs to ALFMOB-274/266), or pull minimal
  protocol-conformance into P1. Flag to PM. **Disposition: ACCEPTED (process) → tracked as Open Q;
  needs PM/Jira action, not a code change.**

---

## Minor

### n1. `exclude: ["DesignTokens"]` + co-located `GeneratedTokens/` is path-fragile
- SharedUI target has no `exclude:` today (`Package.swift:278-294`). Generated Swift lands in a sibling
  dir under the same `Sources/SharedUI/` root as the excluded JSON. A slightly-wrong path either makes
  SPM try to compile/bundle the 14 JSON files (unhandled-resource build failure) or over-excludes the
  generated Swift (symbols vanish, P2 fails). **Fix**: unambiguous separate subdirs; assert
  `swift build` emits zero "unhandled files" warnings for SharedUI. **Disposition: ACCEPTED → P1 build
  check added.**

### n2. `pull-design-tokens.sh` clones a private repo — credential / secret-leak exposure
- Mirroring `run-apollo-codegen.sh` means `set -ex`, which **echoes every command** — a tokenized
  HTTPS clone URL would print creds into CI/Bitrise logs. A naive `cp -R` of the clone could drag
  `.git/config` (credential) or stray files into `Sources/SharedUI/DesignTokens/` and commit them.
  Design tokens are pulled **outside** the repo's `git-secret` mechanism. **Fix**: SSH or `gh` auth
  that never appears on the command line; `set +x` around any auth-bearing line; copy **only** `*.json`
  by explicit glob (never `cp -R`); `rm -rf` the temp clone in a `trap`. **Disposition: ACCEPTED → P1
  script hardening note.**

---

## What the plan already got right (don't regress)
- Standalone Swift generator (no Node), committed output, reference-graph contract (epic "got right").
- Spike-first discipline ("don't write emitters against an assumed contract") — C-tier findings make
  that spike's **checklist** explicit rather than relying on the dev to remember composites/units/alpha.

## Net new asks for the Phase-1 plan
1. Run generator tests in `generate-design-tokens.sh` (C1).
2. Clean output dir before emit (C2).
3. Sort emitted output + no header timestamp + byte-identical test (C3).
4. Merge-all-files-into-one-graph stage + collision policy (J1).
5. DTCG model as tagged union on `$type`; define composite Swift representation (J2).
6. `toSwiftIdentifier()` + collision check, unit-tested (J3).
7. Color format matrix incl. alpha → `opacity:` (J4).
8. Dimension unit→point conversion, error on unknown (J5).
9. Reconcile ALFMOB-272 ticket ACs with the "pipeline only" scope in Jira (J6 — PM action).
10. Path-exact exclude + zero-unhandled-files build check (n1); pull-script credential hardening (n2).
