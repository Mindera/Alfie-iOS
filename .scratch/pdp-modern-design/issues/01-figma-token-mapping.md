# Extract the PDP Figma spec and map it onto the design tokens

Type: research
Status: resolved
Blocked by: —

## Question

What are the exact visual values in the PDP Figma, and which existing token does each one map to — and which have no token at all?

Produce a value-by-value table covering the iPhone PDP frame and its sub-frames:

- **Colours** — every fill and text colour, mapped to a `Theme.*` semantic alias from `Sources/SharedUI/GeneratedTokens/Theme+Generated.swift`. Where no semantic alias exists, say which `Primitives.Colours` primitive it is and flag it.
- **Spacing** — every padding and gap, mapped to `theme.spacing.spaceNNN` (`Sources/SharedUI/Theme/Spacing/SpacingProvider.swift`: space0/025/050/075/100/150/200/250/300/400/500/600/700/800/1000 → 0/2/4/8/8/12/16/20/24/32/40/48/56/64/80). Flag any Figma value that lands between steps.
- **Typography** — every text style (`heading/x-small` etc. in the Figma GLOBAL_VARS) mapped to `theme.font.{display,heading,body,label,link}.{size}`. Flag mismatched line-heights — PLP had to add explicit `lineSpacing` to hit a 24pt Figma line height.
- **Radii** — mapped to `theme.radius.soft/.strong/.rounded`.
- **Image gallery geometry** — the aspect ratio of the gallery in each variant (the canvas has both a portrait frame `#1:16374` and a `PDP - Size Variants + Square Image` frame `#673:89370`), whether it is full-bleed to the screen edges, and the position/style of the pagination dots.

Sources: Figma file key `axx7Bz1fpQurtU6DHwVaJX`, node `1-10080` (use `mcp__figma__get_figma_data`; output is large, query it rather than reading whole). Rendered PNGs in `.scratch/figma/`. Token definitions under `Alfie/AlfieKit/Sources/SharedUI/`.

Deliverable: a markdown table committed under `.scratch/pdp-modern-design/research/`, plus an explicit **gaps list** of Figma values with no token equivalent — those are the ones that will need a `// Figma: …` constant or a token-JSON change.

## Answer

Full value-by-value mapping written to `.scratch/pdp-modern-design/research/01-figma-token-mapping.md`.

The PDP is overwhelmingly token-clean: **every** padding and gap in the Figma (0/4/8/12/16/24) lands exactly on the `space*` scale — nothing between steps. Colours are exact `Primitives.Colours` hits (`#FFFFFF`→neutrals0, `#111111`→neutrals800, `#E9E9E9`→neutrals200, `#767676`→neutrals500, `#06080A`→neutrals900, `#CDCDCD`→neutrals300, `#2B2B2B`→neutrals700). Typography maps 1:1 for `label/small`, `body/medium`, `heading/x-small` (kerning included) and `link/medium`. Radii are only `rounded` (pagination pills) and 0 (everything else is square).

11 gaps recorded (G1–G11). The four that actually block implementation: **G1** `#CDCDCD` (neutrals300) is used as the size-chip/pagination border but no `Theme` border alias reaches that rung; **G2** `#2B2B2B` (neutrals700) is used for brand name and the `Black | Ref.` line with no `content/secondary` alias — a design decision is needed; **G9** the price uses `body/medium-bold` and `TypographyBody` has no `mediumBold` (only `theme.font.link.medium` matches the metrics); **G7** the accordion's `gap: -1px` hairline collapse has no token expression. Plus **G8**: every 16/24 style needs the PLP `lineSpacing` correction.

Gallery: **3:4** (375×500) in the primary portrait frame `#1:16374`; the 1:1 square frame `#673:89370` is drawn at `opacity: 0.2` so treat 3:4 as the spec. Horizontally full-bleed (zero panel padding; the 16pt gutter starts on the content frame below), but **not** behind the header. Pagination dots are centred, 12pt above the gallery bottom, 8pt gap, selected = 12×6 pill `#111111`, default = 6×6 `#CDCDCD`.
