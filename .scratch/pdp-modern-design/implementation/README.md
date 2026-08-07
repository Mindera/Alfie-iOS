# ALFMOB-441 implementation tickets

The five tickets that build [slice 1](../slices/01-alfmob-441-restyle.md). Written from
[`Docs/Specs/Features/ProductDetailsModernDesign.md`](../../../Docs/Specs/Features/ProductDetailsModernDesign.md).

Kept separate from `../issues/` (the wayfinder *decision* tickets, all resolved) and from
`../slices/` (the release-level slices, of which this is slice 1).

## Dependency order

```
01 Foundation ──┬── 02 Gallery + product info
                ├── 03 Size selector
                ├── 04 Colour selection
                └── 05 Description + accordions
```

**01 must land first.** It removes the bottom sheet, migrates the screen to design tokens, and
introduces the shared rules type and test fixtures every later ticket asserts against.

**02–05 are mutually independent** — parallelisable across people, or takeable in any order.

## Before starting 01

- The **design-token refresh** must have merged (adds the medium-bold type style the price needs).
- Ideally the **two upstream token aliases** have landed too. Without them, 02 and 03 ship two
  knowingly off-design elements — the brand line and the size-chip borders. See
  [`../token-requests.md`](../token-requests.md).

## Open questions

Four rules in 03 and 04 are inferences from static design frames, not design instructions. All four
live in the shared rules type introduced by 01, so correcting them after design answers is a
one-file change. See [`../to-questionnaire-pdp-control-behaviour.md`](../to-questionnaire-pdp-control-behaviour.md).
