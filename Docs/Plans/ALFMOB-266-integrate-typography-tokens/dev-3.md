# Phase 4 (Migrate feature modules) — dev-3 summary

Mechanical migration of all feature-module typography call sites from the legacy
`theme.font.header/paragraph/small/tiny.*` API to the Figma token API
`theme.font.<group>.<style>` added by Phase 1. Legacy API is still present on the base
(removed later in Phase 5), so each touched module compiles independently.

Branch: `ALFMOB-266-dev3-features` (based on `ALFMOB-266-integrate-typography-tokens`).
Commit: `ALFMOB-266: Migrate feature-module typography call sites to Figma token API`
(13 files changed, 33 insertions / 33 deletions). Not pushed.

## Files migrated (13)

| File | Sites | Notes |
|---|---|---|
| `Home/UI/HomeView.swift` | 1 | `header.h3 → heading.small` |
| `MyAccount/UI/AccountSectionView.swift` | 1 | `paragraph.normal → body.medium` |
| `ProductListing/UI/ProductListingFilter.swift` | 1 | **UIFont** chained: `paragraph.normal.withSize(...).font → body.medium.uiFont.withSize(...).font` |
| `ProductListing/UI/ProductListingFilterBar.swift` | 2 | `paragraph.normal → body.medium`; `tiny.normal → body.small` |
| `Web/UI/WebView.swift` | 2 | `header.h2 → heading.medium`; `paragraph.normal → body.medium` |
| `CategorySelector/UI/BrandsView.swift` | 5 | `small.normal/small.bold → body.small` (both); `paragraph.normal → body.medium`; **UIFont** `Font(paragraph.bold) → Font(body.medium.uiFont)`; **UIFont** `Font(tiny.normal) → Font(body.small.uiFont)` |
| `CategorySelector/UI/CategoriesView.swift` | 1 | `paragraph.normal → body.medium` |
| `AppFeature/UI/ForceAppUpdateView.swift` | 2 | `header.h1 → heading.large`; `paragraph.bold → body.medium` |
| `AppFeature/UI/TabBarItemView.swift` | 2 | `small.bold/small.normal → body.small` (both) |
| `Search/UI/RecentSearchesView.swift` | 3 | `header.h3 → heading.small`; `paragraph.normal → body.medium`; `small.boldUnderline → body.small(x, underline: true)` |
| `Search/UI/SearchView.swift` | 2 | `paragraph.bold → body.medium`; `small.normal → body.small` |
| `ProductDetails/UI/ProductDetailsView.swift` | 8 | `paragraph.normal → body.medium` (x4); `small.normal/small.bold → body.small` (x3); `header.h2 → heading.medium` |
| `ProductDetails/UI/ProductDetailsColorAndSizeSheet.swift` | 3 | **UIFont** `Font(paragraph.normal.withSize(18)) → Font(body.medium.uiFont.withSize(18))`; `paragraph.normal → body.medium` (x2) |

UIFont-typed sites that received `.uiFont` (compiler-guided, per mapping): 4 total —
`ProductListingFilter:84`, `BrandsView:194`, `BrandsView:300`, `ProductDetailsColorAndSizeSheet:47`.
All other sites are AttributedString call-sites that just renamed.

## Grep gate result

GATE 1 — `grep -rE '\.font\.(header|paragraph|small|tiny)'` over the 13 files: **no matches**
(exit 1). PASS.

GATE 2 — re-read each diff: every UIFont-typed site appends `.uiFont`
(`ThemedTypographyStyle.uiFont: UIFont`), and `UIFont.withSize(_:)`/`Font(UIFont)`/the existing
`UIFont.font` getter all type-check. Every AttributedString site uses `callAsFunction(String,
underline:, strike:) -> AttributedString`, consumed by `Text.build`, `+`, and
`ErrorView(title:message:)` (all AttributedString-typed). PASS.

## Mapping decisions worth noting (not ambiguous, but emphasis intentionally dropped)

- bold/italic distinctions dropped per the plan (legacy bold already rendered as the single Medium
  face). Sites where a `.bold` and a `.normal` legacy variant sat side by side now both map to the
  same token:
  - `TabBarItemView` selected (`small.bold`) vs unselected (`small.normal`) tab → both `body.small`.
    The selected branch retains its `.foregroundStyle(mono900)` so it stays visually distinct.
  - `BrandsView:177-178` `small.normal + small.bold` (search-term emphasis) → both `body.small`.
  - `ProductDetailsView:460-462` size label (`small.bold`) vs value (`small.normal`) → both `body.small`.
  - `SearchView:63` empty-view title used `paragraph.bold` → `body.medium`.
  - `ForceAppUpdateView:30` message used `paragraph.bold` → `body.medium`.
- `small.boldUnderline` (RecentSearchesView clear-all CTA) → `body.small(x, underline: true)` —
  underline preserved via param, bold dropped.

## Ambiguous sites

None. All 33 call sites mapped cleanly via the documented table. No `.h3Underline`,
`*Strike`, or `LocalizedStringResource` call sites existed in feature modules.

## Verification

No full build run (per instructions; integration runs `verify.sh` once). Migration is type-sound
by construction (reasoned above). Grep gate clean.
