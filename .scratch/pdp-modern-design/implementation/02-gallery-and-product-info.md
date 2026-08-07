# 02 — Gallery and product information block

**What to build:** The top of the page matches the design. Product imagery spans the full width of the screen with no padding and no rounded corners, in a 3:4 ratio, stopping short of the navigation header. Pagination indicators sit over the bottom of the image rather than below it, with the current image marked by a wider pill.

Beneath the gallery, the information block gains the brand name as its own smaller, lighter line above the product name, and the price renders in the medium-bold style. When a product comes in more than one colour, a compact summary — the selected swatch plus a count of the others — appears at the trailing edge of that block and is tappable.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] The gallery is full-width, square-cornered, and uses a 3:4 ratio
- [ ] The gallery does not render behind the navigation header
- [ ] Pagination indicators are overlaid near the bottom of the image; the selected indicator is a wider pill
- [ ] The brand name renders above the product name in the smaller label style
- [ ] The price renders in the medium-bold body style
- [ ] The colour summary shows the selected swatch and the remaining count, and is hidden for single-colour and no-colour products
- [ ] Tapping the colour summary opens colour selection
- [ ] Accessibility identifiers exist for the brand line and colour summary, and the existing collision — where the product name carries an identifier named for the brand — is resolved
- [ ] Snapshot baselines updated
- [ ] `./Alfie/scripts/verify.sh` passes

**Note.** The brand line's colour depends on a semantic token that does not yet exist upstream. Until it lands the line renders at primary weight, flattening the intended hierarchy against the product name. Ship anyway and correct when the token arrives.

Detail: `Docs/Specs/Features/ProductDetailsModernDesign.md`
