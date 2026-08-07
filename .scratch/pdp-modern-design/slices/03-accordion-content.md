# Slice 3 — Rich in-panel accordion content

**Epic:** ALFMOB-427 · **Blocked by:** backend metafield contract

## Why separate

This is a content platform, not a restyle. Slice 1 ships the **shell** — `AccordionView` with honest expansion and today's three rows. This slice fills the panels.

## Scope

- A metafield namespace/key contract with backend, surfaced through the unused `productDetails(productMetafields:variantMetafields:)` arguments.
- Category→accordion mapping: the design has **12 content variants** (Cloth / Cosmetics / Home / Food × three accordions).
- Category-specific labels — `Materials`, `Care Guide`, `Ingredients`, `Shipping & Payments`, `Size & Fit` — replacing today's `.delivery` / `.paymentOptions` / `.returns`.
- Rendering structured key/value copy and imagery inside an expanded panel.
- Retire the web-view fallback Slice 1 leaves in the panel.

## Blockers

- **No data path.** `ProductDetailsFragment` selects no metafields; `OmniProduct.extensions: [Metafield]` is the only hatch and needs an agreed namespace/key contract.
- `productType` is not selected in the query, so the app cannot currently tell categories apart.

## Open questions (`.scratch/pdp-modern-design/to-questionnaire-pdp-control-behaviour.md`)

- Is the 12-variant category model real, or illustrative mock-up?
- Who authors the copy and images, and where do they live?
