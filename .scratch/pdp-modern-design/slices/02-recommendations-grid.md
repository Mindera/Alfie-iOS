# Slice 2 — "You might also like" recommendations grid

**Epic:** ALFMOB-427 · **Blocked by:** unidentified badge data source

## Why separate

It is roughly the **bottom third** of the Figma page, and it is not a restyle — it needs a new fetch and a new component.

## Scope

- Select `OmniProduct.relatedProducts` in `ProductDetailsFragment`.
- Resolve the returned **IDs** into products — `relatedProducts: [String]` returns identifiers, not products, so this needs a second query.
- 2-column card grid with per-card wishlist toggle and a "Best Seller" badge.

## Blockers

- **"Best Seller" badge has no identified data source.** Not a field on `OmniProduct`; possibly `tags`, possibly merchandising, possibly computed.
- Confirmation that a second round-trip is acceptable, or whether BFF should return resolved products.

## Open questions (`.scratch/pdp-modern-design/to-questionnaire-pdp-control-behaviour.md`)

- Is the recommendations grid required for the first release?
- Where does "Best Seller" come from — merchandising flag, computed ranking, or per-product setting?

## Notes

An earlier note claimed the BFF exposed no recommendations field. **That was wrong** — `relatedProducts` exists at `schema.graphqls:145`. This is deferred on effort, not because it is backend-blocked.

`VerticalProductCard` already exists in SharedUI and was extended during the PLP rollout — check it before building a new card.
