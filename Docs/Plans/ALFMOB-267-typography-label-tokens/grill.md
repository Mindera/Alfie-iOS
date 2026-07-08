# Grill: Refactor Typography/Label components to use design tokens
**Plan**: Docs/Plans/ALFMOB-267-typography-label-tokens/plan.md   **Ticket**: ALFMOB-267   **Date**: 2026-07-07   **Branch**: ALFMOB-267-typography-label-tokens

## Decisions
| # | Decision | Recommended | Chosen | Plan change |
|---|---|---|---|---|
| 1 | How specs adopt tokens given no 1:1 scale match | Faithful adoption | Faithful adoption | Decisions §1; accept visual changes, refresh snapshots, PR flags for design |
| 2 | Apply token lineHeight/letterSpacing? | Font only this ticket | Font only | Decisions §2; metrics deferred to follow-up; Risk (double-subtraction) closed |
| 3 | Unblock the token-source defect | Edit JSON now + raise upstream | Edit JSON now + raise upstream | Phase 0 confirmed; upstream Figma follow-up noted |
| 4 | Where does `small` (14pt, no token) map? | Body.small (12) | Body.small (12) | Mapping table; small & tiny converge at 12/400 |
| 5 | How to map normal/bold/italic variants (no bold/italic tokens) | Keep current behavior | Keep current behavior | Decisions §4; all variants → same base token, no synthesis |

## Answered by the codebase (not asked)
- Blocker root cause + fix location — `Tools/DesignTokenGen/.../Emitter.swift:111-116` emits faithfully; defect is `SharedUI/DesignTokens/typography.styles.tokens.json:27` (fontWeight ref → `-font-family`). Correct alias exists unused at `typography.alfie-theme.tokens.json:54`.
- `Display.*` (brand "Libre Baskerville") out of scope — not bundled (`FontNames.swift:9` only has SF Pro) and no spec references it.
- Provider API (`header/paragraph/small/tiny`) stays stable — ticket scopes "components", not the ~78 call sites.
- SF Pro family → `UIFont.systemFont(ofSize:weight:)` (SF Pro is the system typeface) removes the "SF Pro Display Medium" hardcode without needing a bundled file.

## Assumptions surfaced
- The base branch (`claude/affectionate-hodgkin-b608a2`) does **not** currently compile — the generated typography file has a `String`→`Int` type error. Phase 0 is a hard prerequisite, not optional cleanup.
- "Phase 1 token integration" (per the ticket) generated the token *values* but never wired the spec classes to them — the specs are still fully hardcoded. This ticket is that wiring.
- Current italic/bold variants are visually identical to normal today (all `sfProMedium`); "keep current behavior" therefore introduces no variant-level visual change.

## Still open (owner)
- **Design**: sign-off on the accepted visual changes (h1 36→32; paragraph/small/tiny weight 500→400; small 14→12; small≈tiny convergence). Reviewed at PR.
- **Design/Figma owner**: correct the `body-medium-strikethrough` fontWeight binding in the Figma token source so `pull-design-tokens.sh` doesn't reintroduce the defect.
- **Follow-up ticket**: apply token lineHeight & letterSpacing in the AttributedString builders (deferred from this ticket).
