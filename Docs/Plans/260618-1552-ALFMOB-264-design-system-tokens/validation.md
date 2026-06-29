# Validation Interview: ALFMOB-264 Design System Token Plan

_Interview 2026-06-18. Decisions below are authoritative; plan + phase files updated to match._

## Decisions

| # | Question | Decision | Plan impact |
|---|---|---|---|
| 1 | Private token-repo access / CI | **No CI involvement this stage.** An iOS dev runs the generate script locally against `design-token.json` and commits the Swift output. | Drop the CI drift-gate from P1 scope (deferred, not cancelled). Generation = local manual step. Private-repo pull is a manual/local concern, not a CI secret. |
| 2 | Licensed fonts (freightBook/circular*) | **Design is sourcing them.** | P3a (Figma rename + shim, SF Pro retained) proceeds now. P3b (real font swap) stays queued, no date — externally blocked as planned. |
| 3 | Snapshot baseline policy (ALFMOB-274 AC) | **Tokens are the source of truth.** Pixel changes caused by token values differing from today's hardcoded values are re-baselined and accepted after review; design owns the look. | Open Q3 CLOSED. Snapshot diffs in P2–P5 are reviewed-then-approved, not auto-blockers. This is NOT a pure no-visual-change refactor. |
| 4 | Execution mode | **P1 spike only, this round.** Hold P2+ until the legacy→Figma mapping (design) and a usable `design-token.json` are in hand. | Solo start. Team/parallel deferred until P1 lands. |
| 5 | Snapshot phase ordering (post-validation note) | **Snapshot harness + baselines moved to LAST (P6).** Baselining before the token refactor has no value when tokens are the source of truth (decision 3) — the look is expected to change. | Former "Phase 0" → **P6**, after components are final. During P2–P5: no component snapshot guard; rely on `verify.sh` + manual review + app-level snapshots. |

## Readiness check

- **ACs mapped to phases**: yes — epic ACs ↔ P1 (codegen/reference graph), P2 (color), P3a (Figma names/back-compat), P4 (spacing/shape), P5 (5 components + snapshots). Font-rendering AC is explicitly split to P3b.
- **Feature flag**: n/a (no runtime flag; not a `high_rigor_domain`). Rollback = git revert of committed generated files + theme edits; baseline policy (decision 3) makes intended diffs explicit.
- **Design sign-off**: typography mapping table is the one **still-open** design dependency → blocks P3a start (not the P1 spike). Tracked as Open Q2.
- **Localization / accessibility ids**: no new L10n keys or accessibility ids — this is an internal theming refactor; existing strings/ids untouched.
- **QA / snapshot bandwidth**: P6 establishes the SharedUI snapshot harness (last); during P2–P5, reviewing token-driven visual diffs needs design/QA review cycles (decision 3). Flag to QA before P2.

## Remaining open items (post-validation)
- **Open Q2** — legacy→Figma typography mapping table (design). Blocks P3a.
- **`design-token.json` availability** — P1 emitters need the real file in hand (decision 1 makes this a local dev artefact, not CI).
- **Fonts (P3b)** — awaiting design delivery (decision 2).

## Status
Plan validated and ready to execute the **P1 spike**. P2+ gated on the items above; snapshot harness +
baselines run **last (P6)** once components are final.
