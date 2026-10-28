---
status: accepted
---

# Views style themselves with semantic tokens only, through `theme.*`

Every view reads colour, spacing and radius from **Semantic tokens** vended by `DesignSystem`
(`theme.color` is `Theme.Type`, `theme.sizing` is `Sizing.Type`, `theme.font` as before). No
**Primitive token** is read outside `SharedUI/Theme/`, DebugMenu included, and a lint rule
enforces it. Three spacing APIs and a raw palette forwarder let the same screen be styled three
ways, depending on which file was copied (#186).

Vending the generated enums' metatypes, rather than hand-written forwarders, keeps `DesignSystem`
in step with every token refresh at no cost. Views keep the `DesignSystem.shared` shortcut: the
generator pins one brand at compile time, so there is nothing to inject at runtime yet.

## Rules a migration follows

- **Spacing** (padding, stack spacing, gaps) rounds to the nearest semantic step; a tie rounds
  down (20 becomes 16).
- **Sizes** (tap targets, heights, icon and spinner sizes) are never rounded. They use a
  `Sizing.icons*` token when one matches, otherwise a named constant holding the primitive.
- **Colour** maps by role, never by value. A small shift that results (n900 to n800 for primary
  text) is accepted as the design's intent.
- **A role with no semantic token** keeps its primitive, on the lint allowlist, until design adds
  the token upstream in `Alfie-Mobile-Design-Tokens`. Tokens are never invented here.

## Considered options

- **`theme.spacing.spaceNNN` as the spacing API.** Rejected: a renamed copy of the primitive
  scale that carries no intent.
- **Primitives where no semantic step covers the value.** Rejected for spacing: it keeps the
  copy-the-neighbour drift alive. Accepted for sizes and colour gaps only, where rounding would be
  a redesign.

## Consequences

- Snapshot changes from rounding and role mapping are expected; the large ones are reviewed with
  design, not re-recorded blind.
- A component with a modern-design twin is replaced by it rather than migrated (`ThemedInput` by
  `TextInput`).
