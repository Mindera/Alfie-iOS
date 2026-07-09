# Grill: Refactor ThemedButton to use design tokens
**Plan**: Docs/Plans/ALFMOB-271-refactor-themedbutton-tokens/plan.md   **Ticket**: ALFMOB-271   **Date**: 2026-07-09   **Branch**: ALFMOB-271-refactor-themedbutton-tokens

## Decisions
| # | Decision | Recommended | Chosen | Plan change |
|---|---|---|---|---|
| 1 | Semantic `Theme.button*` layer vs keep primitives | Adopt semantic | **Adopt semantic** | Approach + phase-1 mapping table point Primary/Secondary/Tertiary Default+Disabled at `Theme.button*` |
| 2 | Accept visual deltas from semantic values | Yes | **Yes** | Recorded as design-authoritative in Approach/Risks |
| 3 | Satisfy snapshot AC6 given disabled infra | Unit test now, defer snapshots | **Unit test now, defer** (no follow-up ticket) | AC6 reworded; snapshot re-enable stays Out of Scope |
| 4 | Underline color source (no semantic button group) | Keep primitives | **Use `Theme.linkLink*`** (text default/disabled) | Approach + phase-1: underline text→link tokens; pressed/bg/border→primitives |

## Answered by the codebase (not asked)
- **Pressed state has no semantic token** → must stay on `Primitives.Colours.*`. `Theme+Generated.swift:9-32` exposes only `…Default`/`…Disabled` per button group; no pressed. (auto-resolved)
- **`iconSize` tokenization** → `Sizing.iconsIconSmall` == `Primitives.Spacing.spacing16` == 16, exact match. `Sizing+Generated.swift:9`. (auto-resolved)
- **Button heights & 1pt stroke have no token** → `Sizing+Generated.swift` has no 36/44/52 height or stroke-width token; remain documented literals. (auto-resolved)
- **Ticket premise stale** (`Colors.primary.mono900`) → that facade doesn't exist on this branch; colors already on `Primitives.Colours.*`. scope.md + `ButtonTheme.swift:31-81`. (auto-resolved)

## Assumptions surfaced
- "Use generated tokens" was implicitly read as "primitive tokens"; the plan makes explicit the intent is the **semantic** `Theme.*` layer, and that this is a *deliberate visual change*, not a no-op.
- Underline text default/disabled numerically equal the link tokens **today** — mapping is zero-pixel now but couples underline to the design system's link color going forward (accepted).
- Snapshot suite being out of target membership is treated as a pre-existing repo condition, not this ticket's problem to fix.

## Still open (owner)
- Repo-wide snapshot-suite re-enable (target membership + committed refs) — **Design/Platform**, tracked outside ALFMOB-271; not blocking this PR.
- Whether the accepted disabled-shade shifts need Design sign-off — **Design/PM**; low-risk (neutral shades, dev integration branch), proceeding without a hard gate.
