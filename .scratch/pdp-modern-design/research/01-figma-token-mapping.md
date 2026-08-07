# PDP Figma → design-token mapping

Research output for `issues/01-figma-token-mapping.md` (ALFMOB-441).

**Sources**
- Figma file `axx7Bz1fpQurtU6DHwVaJX`, canvas `1-10080`. Frames read:
  - `[COMPONENT] "PDP" #1:16374` (portrait, 375×812) → `[INSTANCE] "Product Details Panel" #89:37729` (expanded fetch)
  - `[COMPONENT] "PDP - Size Variants + Square Image" #673:89370` (375×1704)
  - `[FRAME] "S" #1:16489` / `#1:16499` — the bottom-sheet size-selector variants
  - `Accordion` component set `#725:12904` / `#725:12905`
- Renders: `.scratch/figma/pdp-main.png`, `pdp-size-variants-square.png`, `pdp-size-bottom-sheet.png`
- Tokens: `Alfie/AlfieKit/Sources/SharedUI/GeneratedTokens/{Theme,Primitives,Typography,Sizing}+Generated.swift`,
  `Sources/SharedUI/Theme/Spacing/SpacingProvider.swift`, `Theme/CornerRadius/RadiusProvider.swift`,
  `Theme/Typography/{TypographyProvider,Specifications/TypographyGroups}.swift`

Everything below is the **iPhone portrait PDP** unless noted.

---

## 1. Colours

Every hex in the PDP frame, resolved against `Primitives.Colours` and then against the `Theme.*` semantic layer.

| Figma hex | Where it is used | Primitive | Semantic `Theme.*` | Verdict |
|---|---|---|---|---|
| `#FFFFFF` | screen bg, details-panel bg, "Add to Bag" label, "Best Seller" badge label | `neutrals0` (exact) | `Theme.surfaceBackgroundPrimary` (as bg) / `Theme.contentContentInvertedPrimary` (as label on black) / `Theme.buttonPrimaryContentPrimaryDefault` (as button label) | ✅ exact |
| `#111111` | product name, price, size-chip label, "Select Your Size", "Size Guide", accordion labels, "+3" colour count, header title, selected pagination dot, "Add to Bag" fill + stroke, selected size-chip stroke | `neutrals800` (exact) | `Theme.contentContentPrimary` (text) · `Theme.buttonPrimaryBackgroundPrimaryDefault` / `…StrokePrimaryDefault` (CTA) · `Theme.linkLinkPrimaryDefault` (Size Guide) | ✅ exact |
| `#E9E9E9` | 1px top border of the details panel + inner content frame; frame outline | `neutrals200` (exact) | `Theme.borderSoft` | ✅ exact |
| `#CDCDCD` | **size-chip 1px border (default/unselected)**, unselected pagination dot, out-of-stock strikethrough line, bottom-sheet grab handle | `neutrals300` (exact) | **no border alias** — `Theme.surfaceBackgroundTerciary` is the only alias and it is a *surface* token | ⚠️ **gap** (see G1) |
| `#2B2B2B` | brand name (`Brand Name`), `Black \| Ref. 0273/393` meta line | `neutrals700` (exact) | **no content alias** — only `Theme.surfaceForegroundInvertedPrimary` | ⚠️ **gap** (see G2) |
| `#767676` | out-of-stock size label ("M"), muted price in the bottom sheet | `neutrals500` (exact) | `Theme.contentContentTerciary` | ✅ exact |
| `#06080A` | wishlist (secondary) button 1px stroke | `neutrals900` (exact) | `Theme.buttonSecondaryStrokeSecondaryDefault` | ✅ exact |
| `rgba(255,255,255,0)` | header icon-button fill + stroke, wishlist button fill | `transparentTransparent` | `Theme.buttonTerciaryBackgroundTerciaryDefault` / `…StrokeTerciaryDefault` | ✅ exact |
| `#F7F7F7` | product-image placeholder bg (recommendations cards) | `neutrals100` (exact) | `Theme.surfaceForegroundPrimary` | ✅ exact (out of scope) |
| `#000000` | "You might also like" heading | **none** (`neutrals800` is `#111111`) | — | ⚠️ **gap** (see G3) — out of scope, recommendations |
| `#A5A5A5` | struck-through old price, bottom-sheet size rows only | closest `neutrals400` = `#A1A1A1` (**not exact**) | `Theme.contentContentPrimaryDisabled` | ⚠️ near-miss (see G4) |
| `#949494` | Android nav-bar indicator on the Android artboard | none | — | not applicable to iOS |

`Glass Effect` = `backdropFilter: blur(16px)` on the header and on the details panel. No token; SwiftUI equivalent is
`.ultraThinMaterial` / `Material`. See G5.

---

## 2. Spacing

Scale: `space0/025/050/075/100/150/200/250/300/400/500/600/700/800/1000` → `0/2/4/8/8/12/16/20/24/32/40/48/56/64/80`.

| Figma value | Element | Token | Verdict |
|---|---|---|---|
| padding `16` | details-panel content frame (`#I89:37729;3890:79018`) — the single horizontal gutter for the whole panel | `theme.spacing.space200` | ✅ |
| gap `24` | between Product Main Info / Size Selector / Description / Accordion / Recommendations | `theme.spacing.space300` | ✅ |
| gap `8` | Product Main Info column (brand → name → price); button row (Add to Bag ↔ wishlist); Size Selector column (heading ↔ chips); size-chip wrap row; accordion inner column; pagination dots | `theme.spacing.space100` | ✅ |
| gap `0` | Main-info row (name block ↔ colour selector) — `space-between`, no gap | `theme.spacing.space0` | ✅ |
| padding `8 16` | "Add to Bag" button | `space100` / `space200` | ✅ |
| padding `0 16`, size `40×40` | wishlist secondary button | `space0` / `space200`; the 40pt square has no size token | ⚠️ see G6 |
| gap `16` | Section Heading row ("Select Your Size" ↔ "Size Guide") | `theme.spacing.space200` | ✅ |
| padding `8` (all sides) | `.size-selector-buttons` chip | `theme.spacing.space100` | ✅ |
| gap `16` | Description column (lead paragraph ↔ colour/ref line) | `theme.spacing.space200` | ✅ |
| gap `4` | "Black" `\|` "Ref. 0273/393" row | `theme.spacing.space050` | ✅ |
| padding `8 0` | accordion row | `space100` / `space0` | ✅ |
| gap `-1` | accordion stack (`#I89:37729;3224:11935`) — negative, to collapse adjacent 1px hairlines | **none** | ⚠️ **gap** (see G7) |
| padding `4`, gap `8` | header bar (`layout_7d74e1fe`) | `space050` / `space100` | ✅ |
| padding `8` | header icon buttons | `theme.spacing.space100` | ✅ |
| `24×24` | all icons (chevron, share, wishlist, accordion +, colour swatch, notify bell) | `Sizing.iconsIconMedium` | ✅ |
| `12` | pagination baseline offset from gallery bottom (dots at y=482 in a 500-tall gallery; y=357 in a 375-tall one) | `theme.spacing.space150` | ✅ |
| padding `16`, gap `16` | size bottom sheet `.base / tabBar` | `theme.spacing.space200` | ✅ |
| padding `4 16 12` | bottom-sheet variants (`EL-c81651e0` / `EL-67978bc7`) | `space050` / `space200` / `space150` | ✅ |
| padding `16 16 8` | legacy "Product Details Panel" frame in the bottom-sheet artboards (`EL-57fb6e1c`) | `space200` / `space200` / `space100` | ✅ |
| `40×2` | bottom-sheet grab handle | `space500` × — (2 = `space025`) | ✅ |
| `21 113 8` | iOS home-indicator container | system chrome, not app-authored | n/a |

**Nothing in the PDP proper lands between steps.** Every padding/gap is 0/4/8/12/16/24. The only off-scale
numbers are the `-1` accordion gap (G7) and the fixed `40×40` wishlist button (G6).

---

## 3. Typography

| Figma style | Spec | Used for | Token | Verdict |
|---|---|---|---|---|
| `label/small` | SF Pro Regular 12 / 16 | brand name, `Black \| Ref. 0273/393` | `theme.font.label.small` (12/16, kerning 0) | ✅ exact |
| `body/medium`, `body/medium (725:10620)`, `body/medium (498:7810)` — three alias ids, identical metrics, differing only in align | SF Pro Regular 16 / **24** | product name, description lead, size-chip label, "+3" colour count, "Add to Bag" label | `theme.font.body.medium` (16/24, kerning 0) | ✅ metrics match, ⚠️ needs `lineSpacing` (see G8) |
| `body/medium-bold` | SF Pro **Medium (510)** 16 / 24 | price (`£170`), "You might also like" | **no `body.mediumBold`** | ⚠️ **gap** (see G9) |
| `heading/x-small` | SF Pro Medium 16 / 20, letterSpacing `-0.0313em` (= −0.5pt @16) | "Select Your Size", accordion labels, header title | `theme.font.heading.xSmall` (16/20, `kerningTight` = −0.5) | ✅ exact, incl. kerning |
| `link/medium` | SF Pro Medium 16 / 24, `textDecoration: UNDERLINE` | "Size Guide" | `theme.font.link.medium(_, underline: true)` | ✅ exact |
| `body/small` | SF Pro Regular 12 / 16 | "Best Seller" badge (recommendations) | `theme.font.body.small` | ✅ exact (out of scope) |
| `Others/Label` | SF Pro Regular 12 / 16, letterSpacing `0.01em` | size-chip *additional information* ("25x26x18 cm") — bottom-sheet artboards only | `theme.font.label.small`; the `0.01em` (+0.12pt) tracking has no token (`kerningNone`/`kerningSpacious` = 0/1) | ⚠️ minor, ignorable |
| `Doc/*`, `style_*`, Roboto/Inter/Helvetica styles | — | Figma annotations & the Android artboard | not app content | n/a |

Note the Figma "Medium" weight is reported as `510` (SF Pro variable axis); the token scale uses
`fontWeightMedium = 500`. Treat as the same weight.

---

## 4. Radii

| Figma | Element | Token | Verdict |
|---|---|---|---|
| `50px` | pagination dots (6×6 and 12×6 pill) | `theme.radius.rounded` (1000pt pill) | ✅ equivalent |
| `100px` | home indicator, grab handle | `theme.radius.rounded` | ✅ equivalent |
| *(none)* | size chips, "Add to Bag", wishlist button, "Best Seller" badge, image cards | `0` — square corners; do **not** apply `radius.soft` | ✅ |
| `12px 12px 0 0` | size bottom-sheet top corners | **none** — `soft` = 4, `strong` = 16 | ⚠️ **gap** (see G10). Native `.presentationCornerRadius` on iOS 16.4+ makes this moot if the sheet stays a system sheet. |
| `5px` | Figma component-set wrapper | authoring artefact | n/a |

Stroke weight is `1px` everywhere → `Primitives.Border.borderWeightDefault`.

---

## 5. Image gallery geometry

| | Portrait frame `#1:16374` | Square frame `#673:89370` |
|---|---|---|
| Gallery frame | `375 × 500` per page (`layout_6e7e4e91`) | `375 × 375` (`layout_73d59332`) |
| Image component | `469:22152` — **`Ratio=3:4`** | `469:22151` — **`Ratio=1:1`** |
| Aspect ratio | `375:500` = **3:4** (0.75) | **1:1** |
| Fill mode | `scaleMode: FILL` / `objectFit: cover` | same |
| Pages | 4 images in a horizontal `row` (`layout_f05f6131`, `alignSelf: stretch`, `horizontal: fill`) | same |
| Full-bleed? | **Horizontally yes** — 375pt wide inside a 375pt frame; the Product Details Panel has zero padding and the 16pt gutter starts only on the *content* frame below the gallery. **Vertically no** — the gallery sits below the header in the column stack, it does not scroll under it. | same |
| Pagination position | absolute, `x: 160, y: 482` → horizontally centred (pagination is 54pt wide; 187.5 − 27 = 160.5), and **12pt above the gallery bottom** (482 + 6 = 488; 500 − 488 = 12) | absolute, `x: 160, y: 357` → same centring, **12pt above the bottom** (357 + 6 = 363; 375 − 363 = 12) |

**Pagination dot style** (component `635:6081`, items `635:6076`):
- gap `8pt` between dots → `theme.spacing.space100`
- selected (`State=Selected`): rectangle `12 × 6`, `borderRadius: 50`, fill **and** 1px stroke `#111111` → `Theme.contentContentPrimary`
- default (`State=Default`): rectangle `6 × 6`, `borderRadius: 50`, fill `#CDCDCD` → `neutrals300`, **no semantic alias** (G1)
- The dots overlay the image (absolute, no scrim/background behind them).

---

## 6. Component-level notes (for the implementation spec)

- **Size chip** (`.size-selector-buttons`): column, `padding 8`, `gap 8`, `justify/align: center`, `horizontal: fill`
  inside a `wrap: true` row with `gap 8` — chips share the row width equally, wrapping to a second line.
  Default border `1px #CDCDCD`; **selected** border `1px #111111` (`EL-f7c89e21`); out-of-stock adds an absolute
  `LINE` strikethrough (`1px #CDCDCD`, `strokeAlign: CENTER`), a `#767676` label, and a 24×24 notify bell at
  `x: 81, y: 4` (bell = out of scope per map.md).
- **Section heading row**: `row`, `alignItems: center`, `gap 16`, `horizontal: fill` — "Select Your Size"
  (`heading/x-small`) left, underlined "Size Guide" (`link/medium`) right.
- **Product main info**: `column gap 8` → brand (`label/small`, `#2B2B2B`) / name (`body/medium`, `#111111`) /
  price (`body/medium-bold`, `#111111`); the colour selector (24pt swatch + `+3` in `body/medium`) is a sibling on
  the right of a `space-between` row.
- **CTA row**: `row gap 8` → "Add to Bag" (fill, `#111111` bg, white `body/medium`, `padding 8 16`) +
  40×40 wishlist button (transparent fill, `1px #06080A` stroke, 24pt icon).
- **Description**: `column gap 16` → lead paragraph (`body/medium`) + `row gap 4` colour/`|`/ref line
  (`label/small`, `#2B2B2B`).
- **Accordion**: three rows, each `column padding 8 0 gap 8`, header a `space-between` row of
  `heading/x-small` label + 24pt "Add" (plus) icon. Stack gap `-1px` to collapse adjacent hairlines; the render
  confirms a light hairline divider above and below each row (see G7).

---

## GAPS — Figma values with no token equivalent

| # | Value | Where | Why it's a gap | Suggested handling |
|---|---|---|---|---|
| **G1** | `#CDCDCD` = `Primitives.Colours.neutrals300` used as a **border** | size-chip default border, unselected pagination dot, out-of-stock strikethrough, grab handle | `Theme` has `borderSoft` (`neutrals200`) and `borderMedium` (`neutrals400`) — **nothing maps to `neutrals300`**. The only `neutrals300` aliases are `surfaceBackgroundTerciary` and the `*Disabled` button tokens, none semantically correct here. | Use `Primitives.Colours.neutrals300` directly with `// Figma: #CDCDCD — no border token between borderSoft/borderMedium`, or request a `border/border-strong` token in `token.json`. **Do not** silently substitute `borderSoft` (#E9E9E9) — visibly lighter. |
| **G2** | `#2B2B2B` = `neutrals700` used as **secondary body text** | brand name, `Black \| Ref. 0273/393` | No `content/*` alias resolves to `neutrals700`. `contentContentPrimary` = `neutrals800` (#111111, too dark/identical to the name), `contentContentTerciary` = `neutrals500` (#767676, too light). A "content-secondary" rung is missing. | Either accept `Theme.contentContentPrimary` (1-step darker, near-invisible delta) as a deliberate simplification, or use `Primitives.Colours.neutrals700` + `// Figma: #2B2B2B — no content/secondary alias`. **Decision needed in the spec.** |
| **G3** | `#000000` pure black | "You might also like" heading | No pure-black primitive; `neutrals800` is `#111111`. | Out of scope (recommendations grid). If ever built, use `Theme.contentContentPrimary`. |
| **G4** | `#A5A5A5` | struck-through original price, bottom-sheet size rows only | Not an exact primitive; `neutrals400` = `#A1A1A1` (Δ4). | Snap to `Theme.contentContentPrimaryDisabled` (`neutrals400`). Note the app's existing `PriceComponentView` already handles strikethrough — likely no change. |
| **G5** | `Glass Effect` = `backdropFilter: blur(16px)` | header, and (oddly) the details panel itself | No effect/blur token exists in the design-token set at all. | Map to SwiftUI `Material` (`.ultraThinMaterial` / `.bar`). Header treatment is already flagged "Not yet specified" in `map.md`; the panel-level Glass Effect appears to be a Figma inheritance artefact (the panel is opaque `#FFFFFF` in the render) and should be ignored. |
| **G6** | `40 × 40` fixed wishlist button | CTA row | No button-size or touch-target token. `Sizing.iconsIconXlarge` is coincidentally 40 but is an *icon* token; `theme.spacing.space500` is also 40 but is a *spacing* token. | `// Figma: 40×40 wishlist button (24pt icon + 8pt inset)` and use `theme.spacing.space500`, matching the precedent set on PLP (`// Figma: 24pt icon centred in a 32×32 button`, `ProductListingListStyleSelector.swift`). |
| **G7** | `gap: -1px` on the accordion stack | Accordion | Negative spacing is not expressible as a token and SwiftUI `VStack(spacing:)` won't take it meaningfully. The Figma component itself carries **no stroke** — the hairline is implied by the `-1` collapse, and the render confirms a divider above/below each row. | Implement as `VStack(spacing: 0)` with an explicit 1px `Theme.borderSoft` divider between rows (`AccordionView` already exists at `Sources/SharedUI/Theme/Accordion/AccordionView.swift` — check what it draws before adding one). |
| **G8** | line-height `24` on a 16pt SF Pro style | product name, description, chip labels, "+3", CTA label, price | SF Pro's intrinsic line height at 16pt is ≈19–20pt, so `body/medium` renders too tight without help. This is the exact issue PLP hit. | Apply the PLP fix: `.lineSpacing(max(0, style.lineHeight - style.font.lineHeight))` (see `VerticalProductCard.swift` in `9ae85bc`). Applies to **every** 16/24 style on the PDP, and to `link/medium`. `heading/x-small` (16/20) needs no correction. |
| **G9** | `body/medium-bold` = SF Pro Medium 16/24 | **price** (`£170`), "You might also like" | `TypographyBody` has `large / medium / mediumStrikethrough / small` — **no `mediumBold`**. The only 16/24-Medium token is `theme.font.link.medium`, which is semantically a link (and `ThemedTypographyStyle` renders it underlined when asked). | Use `theme.font.link.medium(_, underline: false)` — byte-identical metrics — with `// Figma: body/medium-bold; no body.mediumBold token`, **or** add a `body/medium-bold` entry to `token.json` and regenerate. Prefer the token addition if the PDP is not the only surface needing it (check `PriceComponentView`, which already renders prices app-wide). |
| **G10** | `borderRadius: 12px 12px 0 0` | size bottom-sheet top corners | `radius.soft` = 4, `radius.strong` = 16, `radius.rounded` = 1000. No 12. | If the sheet remains a native `.sheet`, iOS supplies its own corner radius and this is moot. If a custom sheet is drawn, `// Figma: 12pt sheet corner` — do not force 16. |
| **G11** | `letterSpacing: 0.01em` on `Others/Label` | size-chip additional info (bottom-sheet artboards only) | `kerningNone` = 0, `kerningSpacious` = 1.0; 0.01em @12pt = 0.12pt. | Ignore — below perceptual threshold, and the element is only in the deferred bottom-sheet flow. |

### Not a gap, but decisions the spec must record
- **`#2B2B2B` vs `#111111`** (G2) is the single most-repeated ambiguous colour on the screen. Pick one and apply it consistently to brand name + colour/ref line.
- **Image aspect ratio**: the canvas draws *both* 3:4 (portrait, `#1:16374`) and 1:1 (`#673:89370`). The square frame is at `opacity: 0.2` — i.e. **deprioritised/exploratory**. Treat **3:4 as the spec** and the square as an alternate to confirm with design.
- **Gallery is horizontally full-bleed but not behind the header.** The 16pt gutter belongs to the content frame below the gallery, not to the panel.
