# Grill: Integrate spacing & shape tokens from design token JSON

**Plan**: Docs/Plans/ALFMOB-270-integrate-spacing-shape-tokens/plan.md   **Ticket**: ALFMOB-270   **Date**: 2026-06-24   **Branch**: ALFMOB-270-integrate-spacing-shape-tokens

## Governing principle (user)
> "We will use design-token JSON as the source of truth. If something conflicts, follow design token."

## Decisions
| # | Decision | Recommended | Chosen | Plan change |
|---|---|---|---|---|
| 1 | CornerRadius source style | Semantic where available | **Semantic where available** — `xs→Sizing.radiusSoft`, `l→Sizing.radiusStrong`, `full→Sizing.radiusRounded`; `none/xxs/s/m/xl → Primitives.Spacing.*`. Grounded in JSON: only 3 radius tokens exist (soft=4/strong=16/rounded=1000); every other value still traces to a spacing primitive → zero pixel change. | Decisions §1; CornerRadius mapping confirmed |
| 2 | Off-token spacing (`space075`=6, `space900`=72 — absent from JSON) | Escalate to design, no pixel change | **Conform now: `space075`→`spacing8` (6→8pt), delete `space900`** (demo-only). No off-token literals remain; design signs off on the 6→8 shift at PR. | Decisions §2; ACs + Risks + Testing + File table + phase-1 updated (demo row deletion, test `space075==8`) |
| 3 | PR base | `ALFMOB-274-integrate-color-tokens` (stacked) | **`ALFMOB-274-integrate-color-tokens`** — user pre-confirmed; `main` lacks generated tokens | Decisions §3 (already in plan) |

## Answered by the codebase / JSON (not asked)
- Radius token definitions — `sizing.alfie-theme.tokens.json:18-32`: only `radius-soft`(→spacing-4), `radius-strong`(→spacing-16), `radius-rounded`(1000). No none/xxs/s/m/xl radius tokens.
- Spacing primitives — `.primitives.alfie-theme.tokens.json:1-141`: `0,2,4,8,12,14,16,18,20,24,28,32,40,48,56,64,80,96,124,220` (no 6, no 72).
- No semantic spacing token set exists in the JSON (only raw primitives + a few `Sizing` semantics) → the hand-written `space*` scale maps to primitives by value, not by a semantic token.
- Shape/shadow out of scope — `ShapeProviderProtocol`/`DefaultShapeProvider` are pure geometry; `ShadowViewModifier` has no upstream shadow/elevation token (`Read` of all three files). `border-border-weight-default`=1 exists but no border surface consumes a token today → YAGNI.
- API must stay stable — epic `scout.md:36-41`: P5 sibling stories (ALFMOB-271/268/273) reference `Spacing.space100/200`, `CornerRadius.s/xs/full`. Option (a) keeps them compiling.
- `space900` usage — only `SpacingDemoView` (grep); safe to delete with its demo row.
- No value-pinning tests exist today — `StyleGuideTests.swift` is an empty stub.

## Assumptions surfaced
- "No hardcoded numeric remains" is now **fully** achievable (not partial) because the user chose to conform the 2 off-token values rather than defer them.
- This ticket is **no longer a zero-pixel-change refactor** — `space075` 6→8 is a real (small) production change requiring design sign-off; snapshots don't auto-catch it.

## Still open (owner)
- **Design sign-off** on the `space075` 6→8pt shift — at PR review (design). Tracked as a Risk.
- **Upstream (design-token repo)**: whether to add `spacing-6` / `spacing-72`, and whether to collapse CornerRadius to the 3 sanctioned radii — both out of scope for ALFMOB-270.
