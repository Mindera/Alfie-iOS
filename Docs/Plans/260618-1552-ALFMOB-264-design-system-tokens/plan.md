---
title: Design System — Token Integration & Component Refactoring
ticket: ALFMOB-264
status: pending
complexity: HIGH
mode: hard
blockedBy: []
blocks: []
created: 2026-06-18
---

## Overview

Drive the iOS design system from the shared W3C **DTCG** design-token contract instead of
hardcoded Swift. A Swift codegen step reads the DTCG JSON (pulled from the private
`Mindera/Alfie-Mobile-Design-Tokens` repo) and emits type-safe Swift that preserves the token
reference graph (theme → primitives). Existing `SharedUI` theme types are re-pointed at the
generated values; 5 core components are refactored to consume them. All public APIs stay
backward-compatible. Epic = 9 stories across 2 phases (infra + integration, then component
refactors).

## Decisions locked (this planning session)

- **Generator = standalone Swift** (a `Tools/DesignTokenGen` SwiftPM executable run via a shell
  script), **not** Style Dictionary/Node. Repo has zero Node today; mirrors the existing
  `run-apollo-codegen.sh` + SwiftGen-plugin precedent. Cross-platform parity is guaranteed by
  the shared DTCG JSON, not the generator.
- **Tokens pulled on demand**: `pull-design-tokens.sh` fetches DTCG JSON from the private repo,
  commits it under `SharedUI/DesignTokens/`; codegen then runs offline for every other dev/CI
  build. Satisfies the ticket's "stored in repo" AC while keeping private-repo access to refresh-time only.
- **Typography naming = Figma-verbatim + compat shim**: generated `Typography.display.large` /
  `heading.medium` / `body.small` become the source of truth; legacy `header.h1` / `paragraph` /
  `small` / `tiny` protocols are kept as thin forwarders so all call sites compile (ADR-293).
- **Color backing = Option B (code-based `Color` from tokens)**, per ticket recommendation —
  retires `Colors.xcassets` as the source of truth (single source of truth, no asset-catalog drift).

## Acceptance Criteria (epic-level, from ALFMOB-264)

- [ ] DTCG JSON stored in repo (`SharedUI/DesignTokens/`)
- [ ] Build-time Swift codegen reads DTCG → generates Swift
- [ ] Generated Swift preserves token references (theme → primitives), not flat values
- [ ] Color, typography, spacing, shape tokens integrated into the existing theme system
- [ ] Typography uses Figma token names (`display.large`, `heading.medium`) — not `Header.h1`
- [ ] 5 core components use token-generated values
- [ ] Existing component APIs remain backward-compatible
- [ ] Snapshot tests validate visual consistency

## Approach

> **Scope reframe (red-team C2):** this is NOT a "5 component" change. P2–P4 re-point shared theme
> types consumed app-wide — `Colors.` in **78 files**, `Spacing.` in **108**, typography in **79**.
> Any generated value ≠ today's hardcoded value shifts the whole app, not just the 5 components.
> Per validation, **tokens are the source of truth** — those shifts are intended and accepted.

> **Snapshot phase moved to LAST (stakeholder):** since P2–P5 intentionally change the components,
> baselining the current look first has no assertion value. The SharedUI snapshot harness + baselines
> are captured at the **end** (P6), recording the final token-driven appearance as the regression
> baseline. During P2–P5 the refactor is guarded by `verify.sh` + manual review + app-level snapshots.

Sequential dependency chain (the ticket's stated `Depends On` links are internally
inconsistent — see Risks; this is the corrected order):

```
P1 pipeline ─▶ P2 274 color ─▶ P3a 266 rename+shim ─▶ P4 270 spacing+shape ─▶ P5 components ─▶ P6 snapshots
(272)                                                                         271/268/273/269/267  (baselines)
                            P3b font-swap = SEPARATE, externally blocked (licensed .otf)
```

Generated output is **committed** (no per-build codegen). Each theme type keeps its current
public surface and is re-implemented to read generated values, so component refactors (P5) are
mostly find/replace of `Colors.*` / `Spacing.*` / `CornerRadius.*` literals → generated refs.
Component snapshot baselines are recorded afterward in **P6**.

## Phases

1. **Token pipeline foundation** (ALFMOB-272) — pull script, DTCG parser + alias resolver,
   Swift emitters (reference-graph contract), lint-exclude + drift-detection, committed output, docs.
   *Front-loaded spike: pull + inspect the JSON before writing emitters.* Gates P2–P5.
2. **Color integration** (ALFMOB-274) — re-point `PrimaryColors`/`SecondaryColors` at generated
   primitives; retire `Colors.xcassets` (dark-mode is a confirmed non-issue — see Risks).
3a. **Typography rename + shim** (ALFMOB-266) — generated Figma-named typography mapped 1:1 to the
   ~15 legacy getters / ~70 builders; legacy protocols forward to it. **Keeps SF Pro rendering.** Shippable.
3b. **Typography font swap** (ALFMOB-266, split) — bundle/register the real `freightBook`/`circular*`
   families. **Externally blocked** on licensed `.otf` delivery; do not bundle into the 3a estimate.
4. **Spacing & shape integration** (ALFMOB-270) — generated `Spacing`/`CornerRadius`/shape values.
5. **Component refactors** (ALFMOB-271/268/273/269/267) — Button, Input, Chip, Badge, Label; verified
   by `verify.sh` + manual review + app-level snapshots (component baselines come in P6).
6. **Snapshot harness & baselines** (no ticket; runs LAST) — build the `SharedUISnapshotTests` target
   (none exists; app helper is `@testable import Alfie`-bound, not portable) and record the **final**
   token-driven component appearance as the going-forward regression baseline; audit coverage.

## File Changes (Summary)

| File / group | Module | Type | Change | Phase | Owner |
|---|---|---|---|---|---|
| `Alfie/.swiftlint.yml` | config | Edit | Add `GeneratedTokens` to `excluded` | P1 | dev-1 |
| `.github/workflows/alfie.yml` | CI | Edit | Drift check (regenerate + `git diff --exit-code`) — **DEFERRED** per validation; not this stage | later | dev-1 |
| `Tools/DesignTokenGen/**` (new SwiftPM exe) | tooling | New | DTCG models, alias resolver, reference-graph emitters; stamps `swiftlint:disable all` | P1 | dev-1 |
| `Alfie/scripts/pull-design-tokens.sh` | scripts | New | Fetch DTCG JSON from private repo | P1 | dev-1 |
| `Alfie/scripts/generate-design-tokens.sh` | scripts | New | `swift run` the generator | P1 | dev-1 |
| `SharedUI/DesignTokens/*.json` | SharedUI | New | Committed DTCG source (14 files) | P1 | dev-1 |
| `SharedUI/GeneratedTokens/*+Generated.swift` | SharedUI | New | Committed generated Swift | P1–P4 | dev-1 |
| `AlfieKit/Package.swift` | AlfieKit | Edit | Exclude DTCG JSON from target; drop `Colors.xcassets` resource | P1/P2 | dev-1 |
| `Docs/DesignTokens.md` | docs | New | Update/refresh process | P1 | dev-1 |
| `Theme/Color/PrimaryColors.swift`, `SecondaryColors.swift` | SharedUI | Edit | Back protocols with generated values | P2 | dev-1 |
| `Theme/Color/Colors.xcassets` | SharedUI | Delete | Retire (Option B) | P2 | dev-1 |
| `Theme/Typography/Specifications/*Protocol.swift` | SharedUI | Edit | Forward legacy names → generated Figma tokens | P3 | dev-1 |
| `Theme/Typography/Helpers/FontNames.swift`, `FontManager` | SharedUI | Edit | Register token-referenced font families | P3 | dev-1 |
| `Theme/Spacing/Spacing.swift`, `CornerRadius/CornerRadius.swift` | SharedUI | Edit | Forward to generated values | P4 | dev-1 |
| `Theme/Shape/DefaultShapeProvider.swift` | SharedUI | Edit | Token border/shadow (if present) | P4 | dev-1 |
| `Theme/Buttons/ButtonTheme.swift`, `ThemedButton.swift` | SharedUI | Edit | Token refs | P5 | dev-1 |
| `Theme/Inputs/ThemedInput.swift` | SharedUI | Edit | Token refs | P5 | dev-2 |
| `Components/Chips/Chip.swift` | SharedUI | Edit | Token refs | P5 | dev-2 |
| `Components/Indicators/Badge*ViewModifier.swift` | SharedUI | Edit | Token refs | P5 | dev-3 |
| `Theme/Typography/**` (Label render path) | SharedUI | Verify | Confirm all text uses tokens | P5 | dev-3 |
| `Tests/SharedUISnapshotTests/**` (new target) | tests | New | SharedUI-local helper + final component baselines (no `@testable import Alfie`) | P6 | dev-1 |
| `AlfieKit/Package.swift` | AlfieKit | Edit | Add `SharedUISnapshotTests` target (deps SharedUI+TestUtils) | P6 | dev-1 |

## Feature Flag

`n/a` for the codegen/theme swap (pure internal refactor, no behaviour change). **But** P2–P4
change *rendered pixels* if any token value differs from today's hardcoded value. There is no
runtime flag to gate this; the safety net is snapshot tests + a deliberate baseline review
(see Open Questions / ALFMOB-274 AC). If the team wants a staged rollout, the only lever is
shipping P1 (infra, invisible) ahead of P2–P5.

## Testing Strategy

- **Snapshot harness is the FINAL phase (P6), not first** — new `SharedUISnapshotTests` target with a
  SharedUI-local helper (the app's `View+Snapshots` is `@testable import Alfie`-bound, unusable here).
  Baselines record the **final** token-driven appearance (tokens are source of truth → no value in a
  pre-refactor baseline).
- **During P2–P5 (no component snapshot guard)**: regressions caught by `verify.sh` + manual visual
  review + existing app-level snapshots in `Alfie/AlfieTests/Snapshots/` (partial coverage — gap
  audited in P6). Token-driven diffs are accepted per validation.
- **Unit**: DTCG alias resolver (P1) — table-driven tests incl. 5-level chains, cycles, missing refs,
  AND an assertion that semantic tokens emit as references to primitive symbols (not flat hex).
  Existing `BadgeHelperTests` stays green.
- **Drift gate**: this stage = **local** — the iOS dev runs `generate-design-tokens.sh` + `git diff`
  before committing (per validation: no CI involvement yet). Promote to a CI `git diff --exit-code`
  gate later when CI is in scope.
- **Verify gate**: `./Alfie/scripts/verify.sh` must end in `✅ FULL VERIFICATION PASSED` per phase.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| **App-wide reskin under-scoped** — P2–P4 shift 78/108/79 files, not 5 (red-team C2) | High | Tokens = source of truth (validation): shifts intended/accepted; P6 coverage audit + design/PM awareness |
| **No component-level snapshot guard during P2–P5** (snapshots moved to P6 per stakeholder; tokens = source of truth) | Medium | Guard refactor via `verify.sh` + manual review + app-level snapshots; capture final SharedUI baselines in P6. Conscious trade-off |
| **Typography shim is large, not "thin"** — ~15 getters / ~70 builders, no 1:1 Figma ramp (red-team C3) | High | Pull real ramp first; agree mapping table; P3a maps explicitly |
| **Intended fonts not bundled; code fakes all families with SF Pro** (red-team C4) | High | Split P3b as externally-blocked; P3a renames-only, keeps SF Pro — shippable |
| Token JSON structure unknown until private repo pulled | High | P1 spike = pull + inspect before writing emitters; resolves Open Q1/Q2 |
| Pixel drift when token values ≠ current hardcoded values | High | Accepted per validation (tokens = source of truth); manual review during P2–P5, final baselines in P6 |
| **Generated files fail SwiftLint (`opt_in_rules: all`, build-phase)** (red-team M1) | High | P1: add `GeneratedTokens` to `.swiftlint.yml excluded` + emit `swiftlint:disable all` header |
| **Stale generated Swift drifts from JSON — no detection** (red-team M2) | Medium | This stage: local regen + `git diff` before commit (no CI yet, per validation). CI gate deferred |
| Reference-graph AC vs flat-hex emitter contradiction (red-team M4) | Medium | Lock P1 contract: semantic `static let = Primitives.Color.x`; unit-test the emitted RHS is a symbol |
| Retiring `Colors.xcassets` breaks direct `Color("Mono900", bundle:)` users outside the color files | Medium | Grep all `Color("`/`UIColor(named:` repo-wide before deleting (P2 step 3) |
| ~~Dark mode breaks under code-based Color~~ **CLOSED** (red-team m1) | — | 53/54 colorsets universal; the 1 dark variant (Blue050) is a no-op; no dark mode wired app-wide. Not a blocker |
| Ticket `Depends On` graph is circular/inconsistent | Medium | Use corrected order in this plan; update tickets |
| Committed generated files cause noisy diffs / merge conflicts during P5 parallel work | Low | One owner for generated files (dev-1); regenerate-and-commit only on token refresh |

## Out of Scope

- Refactoring the other ~35 SharedUI components (only the 5 named).
- Dark-mode / multi-theme support (unless tokens already encode it — verify, don't build).
- Android/Flutter token consumption.
- Automating token pulls in CI (manual `pull` + commit is the agreed model).

## Open Questions

1. **Font families**: does the typography token set reference fonts beyond SF Pro Display Medium
   (doc-comments mention `freightBook`/`circularBold`/`circularMedium` — and today the code renders
   ALL of them as SF Pro)? Who provides + licenses the `.otf` files? **Blocks P3b (font swap); P3a
   ships without it.**
2. **Legacy→Figma type map**: exact mapping of `h1/h2/h3/paragraph/small/tiny` (~15 getters / ~70
   builders) → `display/heading/body/label.*`. Needs design confirmation. **Blocks P3a shim.**
   _Dark mode: CLOSED — confirmed non-issue (see Risks)._
3. ~~**Baseline policy**~~ **RESOLVED (validation)**: tokens are the source of truth — token-driven
   pixel changes are re-baselined + accepted after review. Not a no-visual-change refactor.
4. **DTCG JSON commit vs gitignore**: plan commits it (ticket AC). Generation is a **local dev step**
   (validation) — no CI pull. Commit both JSON + generated Swift.
5. ~~**Private repo / CI auth**~~ **RESOLVED (validation)**: no CI this stage; an iOS dev runs the
   generate script locally against `design-token.json`. (CI drift gate deferred.)

> **Execution scope this round (validation):** the **P1 spike** only (pull/inspect `design-token.json`
> + scaffold the generator). P2+ gated on the legacy→Figma mapping (Open Q2, design) and a usable
> `design-token.json`. P6 snapshots run last, after the components are final. Solo start.

## Per-phase detail

See `phase-1-token-pipeline.md` → `phase-6-snapshot-baselines.md`. Red-team findings + dispositions
in `red-team.md`; stakeholder decisions in `validation.md` (incl. snapshot phase moved to last).
