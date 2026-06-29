# Red Team Review: ALFMOB-264 Design System Token Plan

_Adversarial review, 2026-06-18. Findings grounded in the repo. Plan updated to absorb these — see "Disposition" tags._

> **Superseded note:** C1/C2 dispositions below say "Phase 0 added (first)." A later stakeholder
> decision (see `validation.md`) **moved the snapshot harness + baselines to LAST (P6)** — tokens are
> the source of truth, so pre-refactor baselines have no value. The harness/SharedUI-local-helper
> substance of C1 still stands; only its position changed.

## Verdict
Not shippable as written. Technically literate but rests on two load-bearing falsehoods: (1) snapshot baselines can be recorded "before refactor" — no SharedUI snapshot infra exists and the existing helper is welded to the app target; (2) this is a "5 component" change — 108 files consume `Spacing.`, 78 consume `Colors.`, 79 consume typography, so P2–P4 silently re-skin the whole app. Biggest single risk: P2–P4 are un-flagged, un-revertable big-bang theme swaps validated by a snapshot net that doesn't exist yet and can't be built where the plan says.

## Critical (block — must fix before execute)

### C1. Snapshot "baseline before refactor" is a fiction — no SharedUI snapshot infra; helper is app-bound
- **Evidence**: `Tests/SharedUITests/` has only `BadgeHelperTests`, `LocalizationTests`, and an empty `StyleGuideTests.testExample()`. `SharedUITests` target (`Package.swift:418`) depends only on `"SharedUI"` — no `TestUtils`/`SnapshotTesting`. App helper `Alfie/AlfieTests/Helpers/View+Snapshots.swift` does `@testable import Alfie`; not portable to a package target.
- **Why it breaks**: P5 "Step 0 — record reference images on main" is impossible (no harness on main). P2–P4 change pixels *before* P5 builds the harness → "baseline" is post-change → validates nothing.
- **Fix**: New **Phase 0** — build a real `SharedUISnapshotTests` target (add `TestUtils` dep), write a SharedUI-local snapshot helper (no `@testable import Alfie`), baseline on untouched `main` before P2. Budget as its own M/L task. **Disposition: ACCEPTED → Phase 0 added.**

### C2. Scope mis-sold as "5 components"; P2–P4 re-skin 100+ files with no coverage
- **Evidence**: repo-wide grep — `Colors.` in 78 files, `Spacing.` in 108, `font.{header|paragraph|small|tiny}` in 79.
- **Why it breaks**: P2/P3/P4 re-point shared theme types; any generated value ≠ current literal shifts every consumer app-wide, not just the 5 components. No inventory of which app screens are snapshot-guarded → unguarded screens drift to prod.
- **Fix**: Phase 0 also audits `Alfie/AlfieTests/Snapshots/` coverage and enumerates unguarded consumers; explicit design/PM sign-off on the gap. Reframe epic as app-wide reskin. **Disposition: ACCEPTED → Phase 0 + scope reframed.**

### C3. Typography cannot map 1:1; legacy variants vastly outnumber a Figma ramp
- **Evidence**: ~15 `UIFont` getters and ~70 `AttributedString` entry points across h1/h2/h3/paragraph/small/tiny, each with normal/bold/italic/underline/strike permutations. Doc-comments demand distinct families per level (freightBook/circularBold/circularMedium/circularBook…).
- **Why it breaks**: A Figma display/heading/body/label ramp won't carry tokens for every underline/strike combo — those are render-time attributes (`.build(isUnderlined:strike:)`), not font tokens. The "thin forwarder" shim is actually ~15 getter maps + ~70 preserved method bodies. The phase-3 example mapping is guesswork gated on design sign-off.
- **Fix**: Treat the legacy→Figma map + shim as the dominant cost of P3; pull the real ramp first; don't estimate P3 until then. **Disposition: ACCEPTED → P3 re-scoped + split (see C4).**

### C4. Intended fonts NOT bundled — only SF Pro; current code fakes every family with it
- **Evidence**: only `SF-Pro-Display-Medium.otf` on disk; `FontNames` has one case. `TypographyHeader.h1` (doc: freightBook) returns `sfProMedium.withSize(36)`; all paragraph/small/tiny variants and the *italic* getters also return SF Pro.
- **Why it breaks**: App currently renders everything in SF Pro regardless of intent. "Figma-verbatim typography" references freightBook/circular* families that don't exist in-repo and are licensed fonts the plan can't produce. P3 is effectively blocked, yet estimated "L (M if no new fonts)."
- **Fix**: Split P3 → **P3a** (rename/alias to Figma token names, keep SF Pro rendering — shippable now) + **P3b** (actual font swap — separate, externally-blocked story). **Disposition: ACCEPTED → P3 split.**

## Major (significant rework / wrong estimate)

### M1. Generated files WILL be linted and trip multiple rules — not excluded
- **Evidence**: `Alfie/.swiftlint.yml` has `opt_in_rules: [all]`; `excluded:` names `L10n+Generated.swift`/`BFFGraph` but not `GeneratedTokens/`. SwiftLint runs as a build phase (`project.pbxproj:350`), so `verify.sh` lints it. Hand-written `CornerRadius.swift:3` already needs `swiftlint:disable discouraged_none_name identifier_name`.
- **Why it breaks**: `mono050`/`green050` (leading-zero identifiers), `type_body_length`/`file_length` caps, etc. fail under `all`. P1's own verify gate fails.
- **Fix**: P1 adds `GeneratedTokens` to `.swiftlint.yml excluded` AND emitter stamps `// swiftlint:disable all` per file. **Disposition: ACCEPTED → P1 step added.**

### M2. No drift detection — stale generated Swift can diverge from JSON
- **Evidence**: CI (`.github/workflows/alfie.yml`) runs only `fastlane ios test`; no codegen/drift step (Apollo output is also committed+trusted). `generate-design-tokens.sh` is a manual dev step.
- **Why it breaks**: Edit JSON, forget to regenerate, commit → CI green, ships stale values. P1's "run twice → identical" proves determinism, not freshness.
- **Fix**: CI step runs `generate-design-tokens.sh` then `git diff --exit-code GeneratedTokens/`. Needs Swift toolchain only (not the private repo). **Disposition: ACCEPTED → P1 step added.**

### M3. P1 "L" optimistic — gated on an unpulled private repo of unknown shape
- **Evidence**: P1 step 1 itself says "don't write emitters until JSON shape is known"; Open Q1/Q2/Q5 unresolved.
- **Fix**: Make "pull + inspect + resolve Q1/Q2 + auth" a separate **spike** with its own estimate; re-estimate P1 emitters after JSON is in hand. **Disposition: ACCEPTED → P1 spike split, estimate L→XL.**

### M4. Reference-graph AC satisfiable, but phase-2 contradicts the risk-table sketch
- **Evidence**: AC wants theme→primitive references; risk-table emits `static let buttonPrimaryBackground = Primitives.Color.neutrals800` (good), but phase-2 says emit primitives as `Color(red:…)` and "flatten aliases at gen time." SwiftUI `Color` is a value type — only *symbol-level* indirection satisfies the AC.
- **Fix**: Lock emitter contract in P1: semantic tokens emitted as references to primitive symbols; primitives hold hex. Add unit test asserting semantic RHS is a primitive symbol, not a literal. **Disposition: ACCEPTED → P1 contract locked, phase-2 reworded.**

## Minor

### m1. Dark mode is a NON-issue — plan flagged it but never checked
- **Evidence**: 54 colorsets inspected; 53 are `idiom:universal` only. Sole exception `Blue050.colorset` has a `luminosity:dark` whose RGB == light (no-op). No `overrideUserInterfaceStyle`/`preferredColorScheme` anywhere. `Color.ui = UIColor(self)` (value conversion, no asset lookup).
- **Fix**: Option B loses *automatic* dark adaptivity in principle, but there are no real dark values to lose. **Downgrade risk to CLOSED.** **Disposition: ACCEPTED → risk closed in plan.**

### m2. `exclude: ["DesignTokens"]` is correct (verified — not `.copy`). No change.
### m3. Pre-existing bug `TypographyHeader.h3(_ res:)` calls `h2(...)` (`:63–65`) — file a separate ticket; conscious decision before a baseline locks it in.
### m4. Spacing `space0…space1000` cardinality matches plan. Fine.

## Unverifiable assumptions (unconfirmed — do not build against)
- DTCG JSON structure, file count ("14"), typography ramp names, alias depth (≤5) — private repo not pulled.
- Whether tokens carry freightBook/circular* families and who licenses/provides the `.otf`s (P3b blocker).
- Whether token hex == current asset/literal values (if not, C2's app-wide drift fires).
- Private-repo CI auth (Q5): committed-output model DOES remove CI's build-time need for the repo (CI runs only `fastlane test`); but the *generator* is still needed for drift (M2), and a human/runner still needs creds for periodic `pull`. Partly resolved.

## What the plan got RIGHT (don't regress)
- Standalone Swift generator over Style Dictionary/Node — correct for this repo (zero Node; mirrors committed `run-apollo-codegen.sh`).
- Committed-output genuinely removes CI's private-repo dependency at build time — confirmed.
- `Color.ui = UIColor(self)` survives xcassets deletion (`Utils/Extensions/Color+Extension.swift:4`) — `setupAppearance()` `.ui` calls keep working.
- Corrected the circular ticket `Depends On` graph into a linear order.
- Forwarding-enum for Spacing/CornerRadius (keep enum, `static let = Generated.x`) — minimal diff, preserves the `swiftlint:disable` header.
- Flagging the `h3→h2` bug with "don't silently improve" discipline.
