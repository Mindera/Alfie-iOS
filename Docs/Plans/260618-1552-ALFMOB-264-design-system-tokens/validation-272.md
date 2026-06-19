# Validation Interview: ALFMOB-272 — Phase 1 Token Pipeline

_Interview 2026-06-19. Scope: ALFMOB-272 / Phase 1, focused on the open items from
`red-team-272-pipeline.md`. Complements the epic-level `validation.md` (which locked: no CI this
stage, fonts sourced by design, snapshots last, P1-spike-only). Decisions below are authoritative
for ALFMOB-272._

## Decisions

| # | Question | Decision | Plan impact |
|---|---|---|---|
| 1 | **J6** — ticket ACs vs "pipeline-only" P1 scope | **RESOLVED (2026-06-19): keep the ticket's full scope.** Do NOT re-scope. ALFMOB-272 therefore includes the integration ACs (generated structs conform to `PrimaryColorsProtocol`/`SecondaryColorsProtocol`/typography protocols; `Colors.xcassets` migrated; Figma-verbatim typography names) — not just the generator. | ALFMOB-272's implementation = plan **P1 (pipeline) + P2 (color integration / xcassets retire) + P3a (typography Figma-rename + shim, SF Pro retained)** combined. **Consequence to watch:** this overlaps the epic's ALFMOB-274 (color) and ALFMOB-266 (typography) sub-tickets — see note below. |
| 2 | DTCG JSON / private-repo availability | **Available now.** The 14 DTCG files can be provided immediately. | P1 spike is **unblocked** — composite/alpha/units/cross-file unknowns can be resolved against real data (closes epic M3's "blocked on creds" for the spike). |
| 3 | **C1** — how to gate the generator's own tests | **In `generate-design-tokens.sh` only** — run `swift test --package-path Tools/DesignTokenGen` there, as part of the developer's "tokens/generator changed" task. **NOT** in `verify.sh`, **NOT** in CI (regenerating runs rarely; per user + prior no-CI decision). | Drop the "add a CI step" half of red-team C1's fix. Keep: generate-script gate + document in `Docs/DesignTokens.md` that `verify.sh` does not cover the generator. |
| 4 | Execution scope this round | **Plan only — do NOT implement.** | No code this round. Plan + red-team + validation are the deliverables. Implementation (P1 spike) is a separate, later go. |

## J6 detail — the exact ticket language (answers "which part mentions pipeline?")

"Pipeline" / "pipeline-only" appears **nowhere** in ALFMOB-272. Title = *"Set up design token JSON
parser & code generation."* The body requires integration:

- Implementation Guidance #4: *"Wire up to existing protocols: Generated structs should conform to
  `PrimaryColorsProtocol`, `TypographyHeaderProtocol`, etc."*
- Implementation Guidance #5: *"Replace hardcoded values: Migrate `Colors.xcassets` and
  manually-defined token constants to reference the generated code."*
- AC: *"Generated code compiles and conforms to existing theme protocols."*
- AC: *"Theme tokens reference primitives (type-safe — no hardcoded hex colours)."*
- AC: *"Typography uses Figma token names verbatim (display/large, heading/medium, body/small)."*

⇒ The ticket is **broader** than the plan's P1; it overlaps the plan's P2 (color/xcassets) and P3a
(Figma typography names). **Resolved (decision 1): keep the full ticket scope** — 272 implements
P1+P2+P3a as one story.

### Consequence of keeping full scope — overlap with ALFMOB-274 / ALFMOB-266
The epic (`scout.md`) splits color into **ALFMOB-274** and typography into **ALFMOB-266**. Folding
their work into ALFMOB-272 means those sub-tickets now overlap 272. Handle by either:
- closing/absorbing 274 (color) and the 266 P3a-rename portion into 272 in Jira, or
- letting 272 deliver the foundational integration and trimming 274/266 to follow-on polish.
This is a **Jira bookkeeping** consequence only (not a code-design issue) — flag to PM so two tickets
aren't worked twice.

**Font blocker overturned (spike-findings-272):** the real fonts are **Libre Baskerville** (brand, free
OFL) + **SF Pro** (primary-ios, system) — NOT the licensed freightBook/circular the epic assumed. So
ALFMOB-266 **P3b** font-swap is **effectively unblocked** (only needs the free Libre Baskerville `.otf`
bundled). The remaining design dependency is narrower: the **legacy→Figma mapping** (which existing
`h1/h2/paragraph/…` getter forwards to which `display/heading/body/label` style) — still a design call
for the back-compat shim, in-scope for 272's typography portion.

## Readiness check

- **ACs mapped to phases**: **partial / contested** — see J6. The plan maps 272's integration ACs to
  P2/P3a; the ticket assigns them to 272. Reconcile in Jira.
- **Token JSON in hand**: yes (decision 2) — spike can proceed when implementation is greenlit.
- **Generator test gate**: settled (decision 3) — generate-script only.
- **Feature flag / accessibility / localization**: n/a — pure internal codegen tooling, no runtime
  surface, no new strings or accessibility ids (consistent with epic validation).
- **Rollback**: git revert of committed generated Swift + the (new) `Tools/DesignTokenGen` package and
  scripts. No runtime/migration risk at P1 (nothing consumes the output yet).
- **Design dependency**: legacy→Figma typography mapping (epic Open Q2) does NOT block the P1 pipeline
  itself, but DOES block any attempt to satisfy 272's Figma-naming AC inside P1 (ties into J6).

## Remaining open items (post-validation)

1. **Jira bookkeeping** — keeping 272's full scope overlaps ALFMOB-274 (color) and ALFMOB-266 (P3a
   typography rename). Close/absorb or trim those so the work isn't done twice. PM action; not a
   blocker for starting 272.
2. **Legacy→Figma typography mapping table (design, epic Open Q2)** — now an **in-scope blocker** for
   272's typography (P3a) portion. The pipeline (P1) and color (P2) portions do not depend on it.

## Status

Plan **validated as documentation only** — implementation deliberately deferred this round
(decision 4). J6 resolved: **272 keeps full scope** = pipeline + color integration + Figma typography
rename (plan P1+P2+P3a). The pipeline+color portions are unblocked (token JSON available, decision 2);
the typography portion is blocked on the design mapping table (open item 2). When implementation is
greenlit, sequence it pipeline → color → typography.
