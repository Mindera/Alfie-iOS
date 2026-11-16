Jira: ALFMOB-404

# How Android implements search suggestions

Question: exactly how does the Android app trigger, show and act on BFF search suggestions, so iOS can mirror it?

Read on 2026-11-16. Alfie-Android is at `f04240c` (`main`). Suggestions landed in `d6c8957` "[ALFMOB-407] Integrate search suggestions with the BFF (#75)", on top of the redesign `c6c13bb` "[ALFMOB-452] Modern Design Rollout — Search (#39)". Nothing after `d6c8957` touches search. Paths are relative to the Android repo root; `SearchViewModel.kt`, `SearchOverlay.kt`, `SearchUIFactory.kt` and `strings.xml` live under `feature/search/src/main/`.

## TL;DR

- **Trigger**: every change of the trimmed term cancels the previous job, shows a spinner at once, waits **500 ms**, then calls `suggestion(query: <trimmed term>, limit: 6)`. No minimum length: one non-whitespace character fetches. An empty or whitespace-only term fetches nothing and shows recent searches.
- **States**: `Empty` (recent searches) / `Loading` (centred spinner, nothing else) / `Loaded` / `NoResults` / `Error`. Old suggestions are never kept on screen while the next term loads.
- **Sections**, in order: "Search Suggestions" (keywords), "Brands", "Product Suggestions" (two-column product cards + a "More Products" button). An empty section is hidden with its header. All three empty is `NoResults`: `No results found for "<term>"` / `Please check the spelling or try different words.`
- **Taps**: keyword opens the search listing for the keyword; brand opens a listing that runs `searchProducts(searchTerm: <brand name>, filters.brandNames: [<key>])`, titled with the brand name; product opens the PDP by Handle; "More Products" opens the search listing for the term typed now. Keyword, brand and "More Products" record a recent search; a product tap does not.
- **Errors**: any failure, of any kind, is one full-panel message, `Something went wrong` / `We couldn't load suggestions. You can still search for "<term>".` with a `Try again` button that refetches without debounce. No snackbar, no analytics; the exception is logged with Timber.
- **Submit** is independent of suggestions: the keyboard Search action opens the search listing for the trimmed term and records a recent search; a blank term does nothing.
- **Recent searches**: Room table, newest first, max 5, de-duplicated by exact term, shown only when the field is empty.
- Typed-term highlighting (bold, case-insensitive, every occurrence) applies to keyword and brand rows only.
- Design was not checked against Figma and the copy was not confirmed (PR #75 "Known gaps").

## 1. Trigger

The search field reports every edit through `SearchState.updateSearchTerm`, which calls the overlay's listener (`designsystem/src/main/java/com/mindera/alfie/designsystem/component/searchbar/SearchTextField.kt:114-117`, `.../searchbar/SearchState.kt:69-73`, `SearchOverlay.kt:108-115`). The ViewModel then:

```kotlin
private fun handleUpdateSearchTerm(searchTerm: String) {
    val trimmedTerm = searchTerm.trim()
    if (trimmedTerm == this.searchTerm) return
    this.searchTerm = trimmedTerm
    loadSuggestions(debounce = true)
}
```
(`SearchViewModel.kt:84-89`)

- **Debounce**: `TYPING_DEBOUNCE_TIME = 500L` (`SearchViewModel.kt:53`), applied as `delay` inside the job (`:102`).
- **Limit**: `SUGGESTION_LIMIT_PER_TYPE = 6` (`SearchViewModel.kt:54`), always sent explicitly: `limit = Optional.present(limit)` (`data/src/main/java/com/mindera/alfie/data/search/service/SearchServiceImpl.kt:19-22`). The query document also defaults it to 6 (`network/src/main/graphql/bff/search-queries.graphql:1-4`).
- **Minimum length**: none. The only guard is `term.isEmpty()` (`SearchViewModel.kt:95-98`). No client maximum length either; the >100-character cut-off is the BFF's.
- **Trimming**: leading/trailing whitespace is trimmed before comparison and before the request. A keystroke that changes only surrounding whitespace is ignored: no state change, no new request (`:85-86`).
- **Each keystroke that changes the trimmed term**: cancel the running job, set `Loading` immediately, start a new job that waits 500 ms then fetches (`:93-104`).
- **Clearing the field** (clear button `SearchTextField.kt:198-201`, or deleting all text) and **whitespace-only input**: both trim to `""`, so the job is cancelled and state becomes `Empty` with no request (`:95-98`).
- Opening the overlay resets the term to `""` (`SearchState.kt:56-59`); closing it does too (`SearchTextField.kt:66-73`). The overlay therefore always opens on `Empty`.
- The field is single-line, IME action Search, sentence capitalisation (`SearchTextField.kt:118-124`).

## 2. Concurrency

- One `suggestionsJob: Job?`; `loadSuggestions` starts with `suggestionsJob?.cancel()` (`SearchViewModel.kt:67`, `:94`). No Flow operators (`debounce`/`flatMapLatest`) are used.
- Belt and braces: a result is applied only if its term is still the current one.
  ```kotlin
  private fun showIfStillCurrentTerm(term: String, state: SearchUIState) {
      if (term == searchTerm) _state.value = state
  }
  ```
  (`SearchViewModel.kt:127-132`), used for success and error alike (`:117`, `:120`). The commit message for `d6c8957` explains why: cancellation alone works today only because `unwrap()` catches the `CancellationException` and the `withContext(IO)` hop then refuses to resume a cancelled caller (`network/src/main/java/com/mindera/alfie/network/extension/ApolloCallExt.kt:10-28`).
- **On submit**: `handleOnSearchAction` does not cancel the job (`SearchViewModel.kt:134-139`). The in-flight request is dropped indirectly: submitting closes the overlay (`SearchState.kt:75-80`), closing resets the term to `""` (`SearchTextField.kt:66-73`), and that goes through `handleUpdateSearchTerm("")`, which cancels the job and sets `Empty`. The same happens after any tap that navigates, because the overlay calls `onDismiss()` after every navigation event (`SearchOverlay.kt:117-130`). This chain is read from code, not pinned by a test.

## 3. UI states

```kotlin
internal sealed interface SearchUIState {
    data object Empty : SearchUIState
    data object Loading : SearchUIState
    data class NoResults(val searchTerm: String) : SearchUIState
    data class Error(val searchTerm: String) : SearchUIState
    data class Loaded(val searchUI: SearchUI) : SearchUIState
}
```
(`feature/search/src/main/java/com/mindera/alfie/feature/search/model/SearchUIState.kt:6-17`). Initial state is `Empty` (`SearchViewModel.kt:57`). Rendering is one `when` (`SearchOverlay.kt:153-184`):

| State | When | Shown |
|---|---|---|
| `Empty` | term is empty | Recent searches panel: "Your Recent Searches" header + "Clear" link + rows, or blank space when there are none (`SearchOverlay.kt:311-341`). Nothing else: no trending terms, no popular Products. |
| `Loading` | from the keystroke, through the debounce and the request | A centred medium `LoadingSpinner` on an otherwise empty panel (`:158-165`). No skeleton. Previous suggestions are removed. |
| `Loaded` | at least one section non-empty | Suggestions list (§4). |
| `NoResults` | request succeeded, all three lists empty | Centred `StateMessage`, title + subtitle, no button (`:166-170`). |
| `Error` | request failed | Centred `StateMessage`, title + subtitle + "Try again" (`:171-179`). |

Recent searches are not shown in any state but `Empty`. Removing old suggestions while loading was a review fix (PR #75 finding 6): "a new term now shows the spinner straight away, so older suggestions are never left up to be tapped". Comment at `SearchViewModel.kt:91`.

## 4. Sections

Order is fixed: keywords, brands, products (`SearchOverlay.kt:202-229`). The BFF's lists are mapped one to one (`data/src/main/java/com/mindera/alfie/data/search/mapper/SearchSuggestionMapper.kt:8-32`).

| Section | Header (`strings.xml`) | Row |
|---|---|---|
| Keywords | `Search Suggestions` (`:6`) | One line of text, `keyword.value`, ellipsised |
| Brands | `Brands` (`:7`) | One line of text, `brand.name` (BFF `value`), ellipsised |
| Products | `Product Suggestions` (`:8`) | Two-column grid of vertical product cards, then a centred secondary button `More Products` (`:9`) |

- **Caps**: none on the client. Each list shows whatever the BFF returns for `limit: 6`.
- **De-duplication** (`SearchUIFactory.kt:29-43`): keywords by lower-cased `value`, brands by `key`, products by `id`; first occurrence wins. Added because the values are list keys and "the BFF doesn't promise uniqueness" (`:27-28`).
- **Empty section**: hidden together with its header (`isNotEmpty()` guards, `SearchOverlay.kt:202`, `:213`, `:224`). "More Products" belongs to the products section, so it disappears when there are no products (`:233-276`).
- **All empty**: `SearchSuggestions.isEmpty()` (`domain/repository/src/main/java/com/mindera/alfie/repository/search/model/SearchSuggestions.kt:13`) gives `NoResults(term)` (`SearchViewModel.kt:106-107`). Copy: `No results found for "%1$s"` and `Please check the spelling or try different words.` (`strings.xml:10-11`). Since the BFF swallows upstream errors into empty lists, an upstream failure also lands here.
- **Highlight**: keyword and brand rows render `text.highlightTerm(searchTerm)` (`SearchOverlay.kt:301`): bold weight on every case-insensitive, literal occurrence of the term the suggestions were fetched for (`core/ui/src/main/java/com/mindera/alfie/core/ui/extension/StringUIExt.kt:16-30`). The term is regex-escaped. Product cards are not highlighted.
- **`results` counts** are mapped to `resultCount` (`SearchSuggestionMapper.kt:14-23`) but dropped before the UI (`SearchUIFactory.kt:46-51`); no count is displayed.
- **Product card** (`SearchUIFactory.kt:53-63`; `designsystem/src/main/java/com/mindera/alfie/designsystem/component/productcard/size/VerticalProductCard.kt:55-79`, `:142-193`):
  - Image: first of `images`, 3:4 ratio. No images gives an empty URL (`feature/src/main/java/com/mindera/alfie/feature/mappers/MapImage.kt:10-18`); what the image component draws for an empty URL was not traced.
  - Brand: `brandName`, one line, small label style. Null becomes `""`; the text line is still laid out, blank.
  - Name: up to two lines.
  - Price: a single default price, `<currency symbol><amount to 2 decimals>`, e.g. `£8.00` (`data/src/main/java/com/mindera/alfie/data/product/mapper/ProductMapper.kt:54-58`, `core/commons/src/main/java/com/mindera/alfie/core/commons/string/MoneyFormatter.kt:25-32`). No sale or range price. Null price omits the row (`SearchUIFactory.kt:60`, `VerticalProductCard.kt:180`).
  - No Wishlist heart, no add-to-Bag button, no label (those card parameters are left null).
  - An odd trailing card keeps column width; a spacer fills the other column (`SearchOverlay.kt:254-257`).

## 5. Taps

| Tap | Destination | Recent search saved |
|---|---|---|
| Keyword | `ProductListType.Search(query = keyword.value)` (`SearchViewModel.kt:77`, `:177-182`) | `RecentSearch.Query(keyword.value)` |
| Brand | `ProductListType.Brand.Key(key, name)` (`:151-156`, `:184-200`) | `RecentSearch.Brand(searchTerm = name, key = key)` |
| Product | `Screen.ProductDetails(productDetailsNavArgs(handle = slug))` (`:202-204`) | none |
| More Products | `ProductListType.Search(query = <term typed now>)` (`:158-163`) | `RecentSearch.Query(term)` |

- **Brand listing**: `Brand.Key` maps to `ProductListQuerySource.Brand(key, name)` (`feature/plp/src/main/java/com/mindera/alfie/feature/plp/ProductListTypeMapper.kt:20`), which runs `searchProducts(searchTerm = source.name, filters = filters.withBrand(source.key))` where `withBrand` sets `brandNames = listOf(key)`, replacing any brand filter already present and keeping the other filters (`data/src/main/java/com/mindera/alfie/data/productlist/repository/ProductListRepositoryImpl.kt:49-64`). Reason: "The BFF has no catalogue-wide listing, and a blank search term returns nothing, so the name is the term" (`domain/repository/src/main/java/com/mindera/alfie/repository/productlist/model/ProductListQuerySource.kt:8-10`). The listing title is the brand name, not the key (`ProductListTypeMapper.kt:32`).
- **Keyword** tap does not fill the search field; it navigates. The overlay closes after every navigation (`SearchOverlay.kt:117-130`), which also clears the field.
- **More Products** uses the ViewModel's current trimmed term, not the term the visible suggestions were fetched for (`SearchViewModel.kt:158`, review finding 5). With `Loading` shown on every change the button is not visible mid-debounce, so the two terms match in practice.
- **Product** tap passes the BFF `slug` as the PDP Handle, with no Variant preselected (`core/navigation/src/main/java/com/mindera/alfie/core/navigation/arguments/ProductDetailsNavArgs.kt:3-9`).
- Recent-search taps reuse the same two routes: `Query` opens the search listing, `Brand` opens the brand listing by stored key, and both re-save, which moves them to the top (`SearchViewModel.kt:141-149`).

## 6. Errors

- Any failed result gives `SearchUIState.Error(term)` (`SearchViewModel.kt:119-121`). The ViewModel ignores the error type, so No connection, Timeout, Server error and GraphQL errors all look the same.
- Shown as a full-panel message replacing the suggestions (the suggestions analogue of a Blocking error; there is no Transient error/snackbar path): title `Something went wrong`, subtitle `We couldn't load suggestions. You can still search for "%1$s".`, primary button `Try again` (`strings.xml:12-14`, `SearchOverlay.kt:171-179`).
- `Try again` sends `OnRetrySuggestions`, which calls `loadSuggestions(debounce = false)`: spinner at once, refetch of the current term, no 500 ms wait (`SearchViewModel.kt:80`, `:102`).
- No automatic retry was found in the suggestions path.
- Logging: `Timber.e(it)` in the shared result mapper (`data/src/main/java/com/mindera/alfie/data/RepositoryResultMapper.kt:9-14`). Analytics: not found.
- The error of a superseded term is never shown (§2).
- A response with GraphQL errors or null data is a failure (`ApolloCallExt.kt:13-18`).

## 7. Recent searches

- **Storage**: Room table `recent_searches`, columns `search_term` (primary key), `search_timestamp`, `type` (`QUERY`/`BRAND`), `slug` (holds the brand key) (`data/database/src/main/java/com/mindera/alfie/data/database/search/model/RecentSearchEntity.kt:7-22`, `data/src/main/java/com/mindera/alfie/data/search/mapper/RecentSearchEntityMapper.kt:9-21`).
- **Order**: newest first (`data/database/src/main/java/com/mindera/alfie/data/database/search/RecentSearchDao.kt:13`).
- **Max**: 5; after each save everything outside the newest 5 is deleted (`RecentSearchDao.kt:22`, `data/src/main/java/com/mindera/alfie/data/search/repository/SearchRepositoryImpl.kt:25-28`).
- **De-dupe**: upsert on the primary key, so the same exact term (case-sensitive) is one row with a refreshed timestamp. Because the key is the term alone, a brand and a query with the same text overwrite each other.
- **Remove one**: the row's X button (`SearchOverlay.kt:402-416`). **Clear all**: the "Clear" link, no confirmation (`:361-368`).
- **Strings**: `Your Recent Searches`, `Clear`, content description `Remove %1$s from recent searches` (`strings.xml:3-5`). The header and link are hidden when the list is empty (`SearchOverlay.kt:327-329`).
- **Coexistence**: mutually exclusive with suggestions; shown only in `Empty` (§3).
- **Saved by**: submit, keyword tap, brand tap, More Products, recent-search tap. Not by a product tap.
- **Migration 4 to 5** deletes `BRAND` rows saved before ALFMOB-407, whose stored slugs are not BFF brand keys (`data/database/src/main/java/com/mindera/alfie/data/database/PersistentDatabaseMigrations.kt:6-17`).

## 8. Submit flow

The keyboard Search action calls `SearchState.onSearchAction()`, which closes the overlay (`shouldCloseOnSearchAction` defaults to `true`) and forwards the raw term (`SearchTextField.kt:125-130`, `SearchState.kt:75-80`). The ViewModel trims it; a blank term does nothing; otherwise it opens `ProductListType.Search(trimmedTerm)` and saves `RecentSearch.Query(trimmedTerm)` (`SearchViewModel.kt:134-139`, `:177-182`).

Suggestions do not affect submit: it works in `Loading`, `Loaded`, `NoResults` and `Error`, never waits for a response, and never substitutes a suggestion for the typed term. The error copy relies on this ("You can still search for…").

## 9. Test tags and analytics

Test tags (`core/ui/src/main/java/com/mindera/alfie/core/ui/test/TestTagConstants.kt:12-25`):

| Tag | On |
|---|---|
| `search-input`, `close-btn`, `back-btn` | field, clear button, back |
| `recent-search-title`, `clear-recent-searches`, `recent-search-item`, `remove-recent-search-item` | recent searches |
| `search-suggestions-loading` | spinner container |
| `search-suggestions-keyword-item` | each keyword row |
| `search-suggestions-brand-item` | each brand row |
| `search-suggestions-product-item` | each product card (inside: `product-card`, `product-image`, `product-designer`, `product-name`, `product-price-component`, `:45-51`) |
| `search-suggestions-more-products` | More Products button |
| `no-results-screen` | no-results message |
| `search-suggestions-error` | error message |

Section headers have no tag. Rows share one tag per kind (no index suffix). Analytics events for search or suggestions: not found.

## 10. Tests that pin behaviour

`feature/search/src/test/java/com/mindera/alfie/feature/search/SearchViewModelTest.kt`:

- `GIVEN screen start THEN state is Empty` (`:152`)
- `...OnUpdateSearchTerm WHEN term is blank THEN state is Empty and nothing is fetched` (`:157`)
- `...OnUpdateSearchTerm THEN shows Loading and fetches trimmed term after the debounce` (`:166`): `" shirt "` gives `Loading` at once, no call at 499 ms, then `query = "shirt", limit = 6`
- `...typed in quick succession THEN fetches only the last term` (`:182`)
- `...WHEN an older response arrives late THEN it never replaces the newer one` (`:195`)
- `...WHEN suggestions are empty THEN state is NoResults` (`:212`)
- `...WHEN the request fails THEN state is Error` (`:222`)
- `...OnRetrySuggestions THEN refetches the current term` (`:232`)
- `...OnUpdateSearchTerm cleared THEN returns to Empty` (`:247`)
- `WHEN a product suggestion is clicked THEN navigates to its PDP` (`:258`)
- `...OnKeywordSuggestionClick THEN saves recent search and navigates to search PLP` (`:274`)
- `...OnBrandSuggestionClick THEN saves recent brand and navigates to the brand PLP by key` (`:286`)
- `...OnMoreProductsClick THEN navigates to search PLP for the typed term` (`:299`)
- `...OnUpdateSearchTerm while suggestions are shown THEN replaces them with Loading at once` (`:316`)
- `WHEN a request for an older term fails after the term changed THEN its error is never shown` (`:329`)
- `...OnSearchAction THEN saves recent search and navigates to search PLP` (`:73`); `...OnSearchAction WHEN term is blank THEN does nothing` (`:87`)
- `...OnRecentSearchClick WHEN recent search is query / is brand THEN saves recent search and navigates` (`:99`, `:114`)

Elsewhere:

- `SearchUIFactoryTest`: `WHEN the BFF repeats a keyword, brand or product THEN each appears once` (`:77`, keyword compare is case-insensitive); `WHEN a product has no price or brand THEN omits the price and blanks the brand` (`:98`); `WHEN a product card is clicked THEN reports its slug` (`:63`)
- `SearchSuggestionMapperTest`: `WHEN the product has no price THEN price is null` (`:55`); `WHEN every section is empty THEN suggestions are empty` (`:78`)
- `SearchServiceImplTest`: `WHEN response has errors THEN returns failure` (`:53`)
- `ProductListRepositoryImplTest`: `WHEN source is brand THEN searches the brand name pinned to its key` (`:101`): an existing `brandNames: ["Other"]` is replaced by the key, `minPrice` is kept
- `ProductListTypeMapperTest`: `displayTitle - WHEN type is a brand key THEN shows the brand name, not the opaque key` (`:18`)
- `StringExtTest`: `Regex metacharacters in the term are matched literally instead of throwing` (`:42`); `A dot highlights only dots, not every character` (`:53`); `The match ignores case` (`:61`); `An empty term highlights nothing` (`:68`); `The term 'Lor' must be highlighted twice in 'Lorem Lorem'` (`:30`)
- `PersistentDatabaseMigrationsTest.migration4To5_deletesOnlyBrandRecentSearches` (`:31`)

There are no UI or screenshot tests for the overlay.

## 11. Recorded decisions and known gaps (PR #75)

Decisions:

- Empty sections are hidden "because platforms fill them differently" (PR body; comment `SearchOverlay.kt:200-201`).
- Spinner replaces suggestions on every term change so stale rows cannot be tapped (review finding 6).
- "More Products" searches the typed term (review finding 5).
- Results are de-duplicated on the client (review finding 2).
- A null price leaves the price row out instead of drawing a blank one (review finding 9).
- Late results are guarded by term as well as by cancellation (author's reply).
- Brand listing = brand-name search + `brandNames: [key]`, kept after review finding 3 ("the PLP can be nearly empty"): the author measured identical counts with and without the term (SKIMS 94, Gucci 1, Reselfridges 6 on SCAYLE; Kashmere on Shopify) and calls it "the only option until the BFF adds a brand listing query. That belongs in a BFF ticket."
- The brand key replaces brand filters rather than adding to them, since `brandNames` matches any listed brand (PR body). Review finding 4 (Refine brand chips would be ignored on a brand listing) was left: Refine does not send `brandNames` on Android today.
- Keyword and brand taps save recent searches "as before".

Known gaps listed in the PR:

- SCAYLE suggests brands only when a brand name is typed (BFF issue, raised on Alfie-BFF#123).
- SCAYLE keywords are category names ("Tops & T-shirts", "Shop by brand A-Z"), poor free-text searches (tenant data).
- "No Figma frame was checked… the copy reuses the pre-ALFMOB-339 strings. The ticket asks for copy and empty states to be confirmed with design."
- No screenshot-test infra; previews are the visual record.

No TODO or FIXME in the search feature or search data code.

## Behaviour to mirror on iOS

- [ ] Trim the term; ignore edits that leave the trimmed term unchanged.
- [ ] Empty or whitespace-only term: no request, show recent searches.
- [ ] No minimum length; fetch from the first non-whitespace character.
- [ ] On each term change: drop the previous request, show the spinner immediately, wait 500 ms, then request with `limit: 6`.
- [ ] Never show a result or an error that belongs to a term other than the current one.
- [ ] Loading is a centred spinner alone; previous suggestions are removed.
- [ ] Section order keywords, brands, products; headers "Search Suggestions", "Brands", "Product Suggestions"; hide an empty section with its header.
- [ ] De-duplicate keywords (case-insensitive value), brands (key) and products (id).
- [ ] Bold every case-insensitive, literal occurrence of the term in keyword and brand rows; one line, truncated.
- [ ] Products as a two-column grid of cards: first image at 3:4, brand, name (two lines), price; no price row when price is null; blank brand when null; no Wishlist or Bag controls.
- [ ] "More Products" button under the product grid only, searching the currently typed term.
- [ ] All sections empty: `No results found for "<term>"` / `Please check the spelling or try different words.`, no button.
- [ ] Any failure: `Something went wrong` / `We couldn't load suggestions. You can still search for "<term>".` / `Try again`; retry refetches the current term without debounce; no snackbar.
- [ ] Keyword tap: search listing for the keyword; save it as a recent search.
- [ ] Brand tap: listing titled with the brand name, querying `searchProducts(searchTerm: name, filters.brandNames: [key])` with the key replacing any other brand filter; save a brand recent search holding name and key.
- [ ] Product tap: PDP by Handle (`slug`); no recent search.
- [ ] Submit: trimmed non-blank term opens the search listing and saves a recent search, whatever the suggestion state; blank does nothing.
- [ ] Recent searches: newest first, max 5, one entry per exact term, per-row remove, clear all, re-tap moves to top; brand entries reopen the brand listing by key.
- [ ] Closing or reopening search clears the term and the suggestions.

## Open / Android does not decide

- Copy and layout were never confirmed with design; no Figma frame was checked.
- No analytics events exist for suggestions or search.
- Error kinds are not distinguished: No connection, Timeout and Server error share one message. Whether iOS should use its own failure vocabulary here is undecided.
- A BFF upstream failure is indistinguishable from No results (the BFF returns empty lists).
- `results` counts are fetched but never shown (always null from the BFF today).
- No per-section cap beyond `limit: 6`; whether 6 keywords + 6 brands + 6 Products is the intended density is unstated.
- Null brand leaves a blank line on the product card; the look of a product with no image was not traced.
- Product suggestions show a single price only; sale and range prices are not in the BFF suggestion shape.
- Brand listing by name + key can under-return if a brand's Products do not match its own name as a search term; a proper brand listing query is a BFF follow-up.
- Whether Refine's brand facet should combine with the pinned brand key is deferred until facets send `brandNames`.
- Recent searches key on the term alone, so a brand and a query with the same text overwrite each other, and de-dupe is case-sensitive; neither looks deliberate.
- A keyword tap does not fill the field, and returning from the listing reopens search empty; no decision recorded on preserving the term.
- Submit with a blank term still closes the overlay (the close happens in the search bar before the ViewModel's blank check). Submit sets search closed and the navigation handler then calls a toggle (`SearchState.kt:56-59`, `SearchOverlay.kt:129`); the net open/closed state after navigation was not traced.
- No UI tests cover the overlay; the submit/tap "closing clears the term and cancels the request" chain is unpinned.
- Accessibility beyond test tags (section headers as headings, announcements for loading/no results) is not addressed.
