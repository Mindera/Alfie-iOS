# Search suggestions: are the two "Duplicated Code" smells worth extracting?

Researched 2026-11-18 against `origin/feat/ALFMOB-404-keyword-suggestions` at `9b967dc3` (issue #273)
and `origin/main` at `bb3e0dde`. Paths are relative to `Alfie/AlfieKit/` unless they start with
`docs/` or are a root file. Line numbers are from the feature branch.

## Question

A review of #273 flagged two possible Duplicated Code smells. Is each one worth extracting now?

1. Two seen-set de-dupes in `Sources/Core/Services/BFFService/Converters/SearchSuggestions+Converter.swift`.
2. The same section-header shape in `Sources/Search/UI/KeywordSuggestionsView.swift` and
   `Sources/Search/UI/ProductSuggestionsView.swift`.

## Verdicts

| Smell | Verdict | Shape |
|---|---|---|
| 1. De-dupe | Valid. Extract now. | `Sequence.uniqued(on:)` in `Sources/Utils/Extensions/`, tested in `Tests/UtilsTests` |
| 2. Section header | Not valid today. Leave. Look again when the "Brands" header lands (#274). | If it then matches the keyword header: a view inside the `Search` module, not `SharedUI` |

## Smell 1: seen-set de-dupe

### Evidence for extracting

- The converter holds two `var` sets and two filters that differ only in the key:
  `seenKeywords.insert($0.value.lowercased()).inserted` and `seenProductIDs.insert($0.id).inserted`
  (`SearchSuggestions+Converter.swift:7-8`, `:12`, `:16`).
- A third copy is specified, not guessed. #271 §Service and models: "Client-side de-dupe ... Keyword
  suggestion by value (case-insensitive), Brand suggestion by key, Product suggestion by id." #274
  acceptance criteria: "Brand suggestions are de-duplicated by key." Brands are mapped with no
  de-dupe today (`SearchSuggestions+Converter.swift:13`), so #274 adds a third set and filter to the
  same function.
- The repo already has the same algorithm as a private helper:
  `private static func distinct<Element>(_ elements: [Element?], by id: (Element) -> String) -> [Element]`
  with `seen.insert(id(element)).inserted`, used twice
  (`Sources/Model/Models/ProductDetails/VariantSelection.swift:164`, `:195`, `:199-210`). It is
  `private` to `VariantSelection`, so the converter cannot call it. Counting it, the idiom has three
  implementations on the feature branch and will have four after #274.
- No shared helper exists. A grep of all Swift under `Alfie/` (generated `BFFGraph` excluded) for
  `uniqued`, `func unique`, `removingDuplicates`, `dedup` finds nothing. The `removeDuplicates()`
  hits are the Combine operator (`Sources/AppFeature/Navigation/AppFeatureViewModel.swift:243`,
  `RootTabViewModel.swift:130`, `UIKitZoomableCarousel.swift:85`). The only `Collection` extension in
  `Utils` is `subscript(safe:)` (`Sources/Utils/Extensions/Collection+Extensions.swift:3-7`).
- A home exists that both callers can reach: `Core` and `Model` both depend on `Utils`
  (`Package.swift:182-187`, `:257-259`), and `Tests/UtilsTests` exists.
- The mutable sets are captured by the `filter` closures, so each new kind adds one more `var` that
  must be paired with the right closure. A helper removes that state from the converter.

### Evidence against

- The two copies are six lines in one function, next to each other. They are easy to read and
  cannot drift apart unnoticed.
- No documented repo rule asks for it. `CODING_STANDARDS.md`, `docs/CodeStyle.md`,
  `docs/Architecture.md`, `docs/DesignTokens.md` and `docs/adr/` have no rule on duplication or on
  when to extract a helper (grep for `duplicat`, `extract`, `helper`, `reuse`, `abstraction`).
- `swift-algorithms` is not an option without a new dependency. It is in neither
  `Package.swift:105-114` nor either `Package.resolved`, and its own `Package.swift` pulls in
  `swift-numerics` (https://github.com/apple/swift-algorithms/blob/main/Package.swift).
  `swift-collections` is a dependency (`Package.swift:105`), but only `OrderedDictionary` is used
  (`AppFeatureViewModel.swift:37`, `Sources/SharedUI/Components/TabControl/TabbedView.swift:11`), and
  `OrderedSet` de-dupes by the element itself, not by a key.
- Other de-dupe in the repo is a different shape and would not use the helper:
  `RecentsService` checks `contains` before inserting
  (`Sources/Core/Services/RecentsService/RecentsService.swift:30`).

### Verdict: extract now

The third inline copy is an acceptance criterion of the next slice, and the repo already carries a
private copy of the same algorithm. The helper is small and has an obvious home.

Recommended shape: in `Utils`,
`func uniqued<Subject: Hashable>(on projection: (Element) throws -> Subject) rethrows -> [Element]`
on `Sequence`. This is the name and signature `swift-algorithms` documents; its guide says the
method uses "the result of the given closure to determine the \"uniqueness\" of each element" and
that "Both methods preserve the relative order of the elements"
(https://github.com/apple/swift-algorithms/blob/main/Guides/Unique.md). The converter becomes
`.uniqued { $0.value.lowercased() }` and `.uniqued(on: \.id)`.

Moving `VariantSelection.distinct` onto the helper is optional and out of scope for #273. It takes
optional elements, so the call would be `compactMap { $0 }.uniqued(on: \.id)`.

## Smell 2: section header

### Evidence for extracting

- Two lines are the same in both views:
  `Text.build(theme.font.heading.xSmall(<title>))` then `.frame(maxWidth: .infinity, alignment: .leading)`
  (`KeywordSuggestionsView.swift:22-23`, `ProductSuggestionsView.swift:26-27`).
- The Recent searches header has the same two lines
  (`Sources/Search/UI/RecentSearchesView.swift:29`, `:31`), so the `Search` module has three today.
- A fourth is coming: #274 adds a "Brands" section "after Keyword suggestions and before Product
  suggestions".
- `CLAUDE.md` says "Reach for existing `SharedUI` components before writing a new view", and
  `docs/Architecture.md:350-353` says "Browse the directory before writing a new view."

### Evidence against

- The headers are not identical. Everything after the two shared lines differs:

  | Header | Horizontal padding | Gap below | Other |
  |---|---|---|---|
  | Keyword (`KeywordSuggestionsView.swift:24-25`) | `spacingSpacingMd` on the header | `.padding(.bottom, spacingSpacingXs)` | none |
  | Product (`ProductSuggestionsView.swift:25-27`) | none on the header; the parent pads the whole section (`Sources/Search/UI/SuggestionsView.swift:45`) | parent `VStack(spacing: spacingSpacingMd)` | none |
  | Recent searches (`RecentSearchesView.swift:30-33`) | `spacingSpacingMd` on the header | `.padding(.bottom, spacingSpacingMd)` | `.accessibilityIdentifier` |

  The review's "plus padding" holds for the keyword header only. The product header has no padding
  of its own.
- What is shared is one themed `Text` and one `frame` modifier, both already built from design
  tokens. A helper that leaves padding to the caller saves one line per site. A helper that takes
  padding as parameters is longer than what it replaces.
- The two rules quoted above are about reusing components that exist. Neither asks for a new one.
  No section-header component exists in `SharedUI`: the only header view is `ProductCarouselHeader`,
  which uses `body.medium` and a CTA
  (`Sources/SharedUI/Components/Carousel/ProductCarousel/ProductCarouselHeader.swift:28`, `:40`).
- Outside `Search`, `heading.xSmall` appears only as PDP selector titles, with a foreground style and
  no full-width frame (`Sources/ProductDetails/UI/ProductDetailsView.swift:405-406`, `:439-440`).
  There is no cross-feature shape to share, so `SharedUI` is the wrong home.
- The layout is not settled. #271: "Figma was not checked (access failed). Layout follows Android",
  and a Figma comparison is listed as a follow-up. A component built now would fix spacing that may
  change.

### Verdict: leave; look again when the "Brands" header lands (#274)

This is two matching lines, not a duplicated component. If the brand header in #274 comes out the
same as the keyword header, padding included, extract a small view in the `Search` module that
takes the title and owns the horizontal padding. That is likely, since both are one-line row lists
(#274), but #274 does not specify header spacing, so it is an inference.

## Fowler: what could be verified

- Smells are prompts, not verdicts. Fowler's CodeSmell page: "smells don't always indicate a
  problem" and "they are often an indicator of a problem rather than the problem themselves"
  (https://martinfowler.com/bliki/CodeSmell.html).
- On duplication, Fowler's BeckDesignRules page lists "No duplication" among the four rules and
  warns that "adding duplication to increase clarity is often papering over a problem"
  (https://martinfowler.com/bliki/BeckDesignRules.html).
- Not verified: Fowler's definition of the Duplicated Code smell (Refactoring ch.3) and the rule of
  three. Neither was found on a first-party page. Pages read: the CodeSmell, BeckDesignRules and
  Yagni bliki entries, `refactoring.com` and its catalog, `martinfowler.com/books/refactoring.html`,
  `martinfowler.com/articles/refactoring-2nd-ed.html` (only the first ~40k of ~54k characters read
  verbatim) and `martinfowler.com/articles/workflowsOfRefactoring/` (headings only came back). The
  book was not consulted. The verdicts above rest on repo evidence and the spec, not on a quoted
  rule of three.

## Open questions

- Is the different gap under the keyword header (`Xs`) and the Recent searches header (`Md`)
  intended? No design source was checked here, and #271 says Figma was not checked either.
- Should `VariantSelection.distinct` move to the shared helper in the same change, or in a later
  one?
- `uniqued(on:)` in `Utils` would collide by name if `swift-algorithms` were ever added and both
  modules imported in one file. Not a problem today.

## Not verified

- Nothing was built or run. The recommended helper shape is untested.
- "First occurrence wins" for `swift-algorithms`' `uniqued(on:)` is inferred from the guide's
  example and its order-preservation sentence; the guide does not state it in words.
- Greps covered Swift under `Alfie/`, excluding generated `BFFGraph` code.
