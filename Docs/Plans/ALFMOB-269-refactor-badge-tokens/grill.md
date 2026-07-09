# Grill: Refactor Badge component to use design tokens
**Plan**: Docs/Plans/ALFMOB-269-refactor-badge-tokens/plan.md   **Ticket**: ALFMOB-269   **Date**: 2026-07-09   **Branch**: ALFMOB-269-refactor-badge-tokens

## Decisions
| # | Decision | Recommended | Chosen | Plan change |
|---|---|---|---|---|
| 1 | Color migration depth: elevate to semantic `Theme.*` vs keep raw `Primitives.*` (sizing-only) | Elevate to `Theme.*` | Elevate to `Theme.*` | Approach/File-Changes keep the `Theme.*` mapping; both files' colors migrate |
| 2 | Remove unused `badgePadding` constant | Remove | Remove | Phase-1 step 1 removes the orphan |

## Answered by the codebase (not asked)
- **Border-stroke token** → `Theme.surfaceBackgroundPrimary` (=neutrals0). Folded into Decision 1; the stroke is the surface behind the badge. Both candidates resolve to the same value, no visual risk.
- **Extra `1`/`9` label tests** — redundant: `BadgeHelperTests.swift:65-81` already covers the `≤maxVal` branch (99→"99") and `>maxVal` branch (147/1000→"99+"). `1`/`9` exercise the identical false-branch. Dropped.
- **Sizing token targets** — `Sizing+Generated.swift` has no badge-specific tokens; `Sizing` is itself defined over `Primitives.Spacing`. So raw dimensions use `Primitives.Spacing.spacing{4,12,16}` (verified equal to the old literals).
- **"999+" in the ticket AC** — badge caps at 99 (`BadgeHelper.maxVal=99` → "99+"). Existing intended behavior; a token refactor must not change it. Recorded in Out of Scope.
- **Call-site safety (AC4)** — public API `badgeView`/`tabItemBadge` signatures untouched; the 12 call sites (scope.md) need no edits.
- **Precedent for elevation** — ALFMOB-271 ("Source ThemedButton styling from semantic design tokens") in recent git history establishes the semantic-layer pattern for component refactors.

## Assumptions surfaced
- The ticket's premise ("currently references `Colors.*` and hardcoded sizing") is partly stale: colors/typography/radius are already token-based. The real gap is sizing + (by choice) semantic-layer elevation.
- No visual change is expected — every token substitution resolves to the current literal/primitive value. Correctness = builds, tests green, values identical, call sites untouched.

## Still open (owner)
- None. All decisions closed; plan ready for the approval gate.
