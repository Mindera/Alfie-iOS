## Phase 1: Token pipeline foundation (ALFMOB-272)

### Goal
Stand up the DTCG → Swift codegen pipeline: pull JSON from the private token repo, parse +
resolve references in Swift, emit committed type-safe Swift that preserves the theme→primitive
reference graph. No theme types consume it yet (that's P2–P4). Gates the whole epic.

### Prereqs
- Access to `Mindera/Alfie-Mobile-Design-Tokens` (Open Q5).
- ADR-293 (Done) for the contract/alias rules.

### Steps

1. **Pull + inspect the token export** (new: `Alfie/scripts/pull-design-tokens.sh`)
   - Mirror `Alfie/scripts/run-apollo-codegen.sh` style: `set -ex`, clone/sparse-fetch the private
     repo into a temp dir, copy the 14 DTCG files into `Alfie/AlfieKit/Sources/SharedUI/DesignTokens/`.
   - **First run is manual/exploratory**: inspect the file set, token categories, the typography
     ramp names, the `{reference}` alias depth, and which font families are referenced. Record
     findings → resolves Open Q1/Q2. *Do not write the emitters until the JSON shape is known.*
   - why: the ticket says copy-in; user wants pull-on-demand. This script is the reconciliation.

2. **Build the generator** (new SwiftPM executable `Tools/DesignTokenGen/`)
   - `Package.swift` (executable target, Foundation only — no third-party deps).
   - `Sources/DesignTokenGen/`:
     - `DTCG.swift` — Codable models for DTCG (`$value`, `$type`, group nesting, `{alias}` strings).
     - `AliasResolver.swift` — resolve `{a.b.c}` references; handle chains ≤5 deep; **detect cycles**
       and **error on missing refs** (don't silently emit empty). This is the unit-test core.
     - `Emit+Color.swift`, `Emit+Typography.swift`, `Emit+Spacing.swift`, `Emit+Radius.swift` —
       string-builder emitters per category.
     - `main.swift` — read input dir, write `*+Generated.swift` to the output dir, stamp an
       "AUTO-GENERATED — do not edit" header **and `// swiftlint:disable all`** on every file
       (red-team M1: generated identifiers like `mono050`/`green050` + file length trip
       `opt_in_rules: [all]`, which runs as a build phase).
   - **Reference-graph requirement**: emit primitives as one namespace and semantic tokens as
     references to them, e.g.
     ```swift
     enum Primitives { enum Color { static let neutrals800 = Color(red: …) } }
     enum ThemeTokens { static let buttonPrimaryBackground = Primitives.Color.neutrals800 } // reference preserved
     ```
     (Flatten only at the leaf hex; keep the alias as a symbol reference, per AC.)
   - why: standalone Swift = no Node; testable; output committed so the package build never runs it.

3. **Generation wrapper** (new: `Alfie/scripts/generate-design-tokens.sh`)
   - `swift run --package-path Tools/DesignTokenGen DesignTokenGen \
       --input Alfie/AlfieKit/Sources/SharedUI/DesignTokens \
       --output Alfie/AlfieKit/Sources/SharedUI/GeneratedTokens`
   - Document that devs run `pull` then `generate` then commit, only when tokens change.

4. **Wire into the package** (`Alfie/AlfieKit/Package.swift:277` SharedUI target)
   - Add `exclude: ["DesignTokens"]` so the committed JSON is **not** compiled/bundled at runtime
     (only the generated Swift under `GeneratedTokens/` is a normal source — needs no resource entry).
   - Do **not** add `Tools/DesignTokenGen` to the AlfieKit graph (separate package → app/CI builds
     don't compile the generator).
   - test: `swift build` of AlfieKit succeeds with the new `GeneratedTokens` sources + excluded JSON.

5. **Lint exclude** (`Alfie/.swiftlint.yml`) — add `AlfieKit/Sources/SharedUI/GeneratedTokens` to
   `excluded:` (alongside the existing `L10n+Generated.swift` / `BFFGraph` entries). Belt-and-braces
   with the per-file `swiftlint:disable all` header (step 2). Without this, P1's own verify gate fails.

6. **Drift detection — LOCAL this stage** (validation: no CI involvement yet). Document in
   `Docs/DesignTokens.md` that the iOS dev runs `generate-design-tokens.sh` then `git diff` before
   committing, so generated Swift can't silently diverge from `design-token.json` (red-team M2).
   *Deferred:* promote to a CI `git diff --exit-code -- '**/GeneratedTokens/*'` gate (Swift toolchain
   only, no private-repo access needed) when CI is in scope.

7. **Mark generated paths** — add `Alfie/AlfieKit/Sources/SharedUI/GeneratedTokens/` to
   `generated_paths` in `.claude/ios-profile.md` and to the NEVER-edit list in `CLAUDE.md`/`AGENTS.md`,
   matching how `L10n+Generated.swift` / `BFFGraph/API` are treated.

8. **Docs** (new: `Docs/DesignTokens.md`) — how to pull, generate, commit; the alias→Swift mapping;
   the "never hand-edit generated" rule.

### Verification
- Run `./Alfie/scripts/verify.sh` → must reach `✅ FULL VERIFICATION PASSED` (incl. SwiftLint build phase).
- Generator unit tests pass: `swift test --package-path Tools/DesignTokenGen` — alias chains, cycle,
  missing-ref error, hex/number formatting, **AND an assertion that a semantic token emits as a
  reference to a primitive symbol (e.g. `= Primitives.Color.neutrals800`), not a flat literal**
  (red-team M4 — satisfies the reference-graph AC).
- Generated files compile in AlfieKit; nothing references them yet (no behaviour change → app
  snapshots unchanged).
- Manual: `generate-design-tokens.sh` run twice produces a **byte-identical** diff (deterministic output).

### Estimated Effort
**Spike first** (pull + inspect JSON + resolve Q1/Q2/Q5 auth) = S–M, **blocked on private-repo creds**.
Emitters + wiring + lint/drift + tests = L–XL once the JSON shape is known. Do NOT write emitters
against an assumed contract (red-team M3).

---

### Red-team additions — pipeline hardening (2026-06-19)
_Source: `red-team-272-pipeline.md`. These are accepted and MUST be folded into the steps above._

**Spike: ✅ DONE (2026-06-19) — see `spike-findings-272.md`.** The token repo ships a full contract
(`DESIGN_TOKENS_FORMAT.md` + `PLAN.md`); the unknowns are resolved. Net contract facts that change P1:
- **color** = sRGB float `components:[r,g,b(,a)]` (NOT hex; no alpha in current export) → `Color(.sRGB,
  red:green:blue:opacity:)`, default opacity 1 (corrects J4).
- **dimension** = `{value, unit:"px"}` **px-only** → `CGFloat(value)`, error on non-px (J5 downgraded).
- **typography** = composite `{fontFamily, fontWeight, fontSize, lineHeight, letterSpacing}`, subfields
  are refs; `fontWeight` inlined as `"Regular"`/`"Medium"` → 400/500 (confirms J2).
- **manifest-driven, mode-selected load** (resolves J1): read `manifest.json`; build ONE name→token map
  from the **iOS load list** — `.primitives`, `theme`, `sizing`, `typography.alfie-theme`,
  `typography.styles`, `system.ios`, `screen-size.small-(s)`; **skip** `system.{android,web}`,
  `screen-size.{m,l,xl}`, `.documentation`, and any `~~doc-*` token. Mode-selection de-collides names.
- **NEW — allowlist handling (not in the original plan):** the resolver must honor
  `.cycle-allowlist.json` (7 known `(file,token)` cycle edges → resolve to primitive + warn; fail on
  any other cycle) and `.broken-ref-allowlist.json` (2 FONT_STYLE font-weight targets). Both are
  **exhaustive** — stale entries must fail. Replaces the plan's blunt "error on cycles/missing refs."
- **Fonts NOT blocked** (overturns epic): brand = Libre Baskerville (free OFL), primary-ios = SF Pro
  (system). The "licensed freightBook/circular" blocker was wrong → P3b font-swap is effectively
  unblocked (just bundle Libre Baskerville `.otf`).

Still to verify against real data when implementing: exact `toSwiftIdentifier()` collisions across the
loaded set (J3), and that `screen-size.small` actually supplies the responsive sub-tokens the
composites reference.

**Generator contract (extend step 2):**
- `DTCG.swift` models `$value` as a **tagged union on `$type`** (color/dimension/fontWeight/typography/
  shadow…), not a single scalar — a single composite token otherwise fails decode → no output (J2).
- **Merge all input files into ONE path-keyed graph BEFORE resolving aliases** (cross-file refs are the
  norm); detect duplicate-path collisions, decide last-write-wins vs error, test it (J1).
- Add `toSwiftIdentifier()`: leading-digit prefix (Figma `050`/`2xl`), separator→camelCase
  (`display/large`), Swift-keyword backtick-escape (`default`/`case`/`static`/`repeat`/`operator`);
  plus a **collision check** (two distinct paths must not map to one identifier). The team already
  hand-hacks this (`Spacing.space025`, `CornerRadius` swiftlint header) — bake it in (J3).
- **Deterministic output**: sort every emitted collection by token path; **no timestamp/version/`Date()`
  in the generated header** (C3).
- **Clean before emit**: `rm` all `*+Generated.swift` (or `git clean -fdx GeneratedTokens/`) before
  writing, so a removed token category can't leave an orphaned stale file (C2).

**Wiring & gating:**
- `generate-design-tokens.sh` runs `swift test --package-path Tools/DesignTokenGen` **fail-fast before
  emitting** — gated here (the dev's "tokens/generator changed" task), **NOT in `verify.sh` and NOT in
  CI** (validation-272 decision 3: regeneration is rare; CI out of scope this stage). `verify.sh`/CI
  only `xcodebuild` the Alfie scheme and never touch the generator package, so document in
  `Docs/DesignTokens.md` that the generator's tests are the developer's responsibility on token change (C1).
- `pull-design-tokens.sh`: use SSH or `gh` auth (no token in the command line); wrap any auth-bearing
  line in `set +x`; copy **only** `*.json` by explicit glob (never `cp -R` the clone); `rm -rf` temp
  clone in a `trap` (n2).
- Path-exact `exclude:`; assert `swift build` of SharedUI emits **zero** "unhandled files" warnings (n1).

**Verification additions (extend the Verification section):**
- Generator tests also assert: **byte-identical output on two runs** (C3), a token category removed →
  its generated file is deleted (C2), cross-file alias resolves (J1), composite token decodes (J2),
  `toSwiftIdentifier` handles leading-digit/keyword/separator + collision (J3), 8-digit hex preserves
  alpha (J4), `rem`/`px` dimension converts to the right point value (J5).

**Open process item (J6 — NOT a code change):** ALFMOB-272's own ticket ACs (conform to existing
protocols, replace `Colors.xcassets`, Figma names verbatim) are met by **P2–P4**, not P1-as-scoped.
Reconcile in Jira before anyone marks ALFMOB-272 Done — re-scope the ticket to "pipeline only" or move
those ACs to ALFMOB-274/266. Confirm with PM.
