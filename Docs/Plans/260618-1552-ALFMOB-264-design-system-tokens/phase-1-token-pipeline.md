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
