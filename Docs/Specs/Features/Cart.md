# Feature: Cart / Bag

**Status**: Ready for implementation
**Created**: 2026-08-26
**Last Updated**: 2026-08-26
**Jira**: ALFMOB-491 (epic) · ALFMOB-498 (this spec)
**Implementation PR**: _pending_

> All seven team questions were answered on 26 Aug 2026 — see Questions & Decisions → Answered by
> the team. Nothing in this spec is pending, and no story is blocked on another team.

---

## Overview

The iOS bag is local-only. `BagService` is an actor over a `UserDefaults` array of `SelectedProduct`,
with no quantity concept — `addProduct` silently no-ops on a duplicate — and `BagViewModel.products`
is a plain array rather than a `ViewState`, because a local mutation cannot fail.

This feature replaces that with the BFF cart. The server becomes the source of truth for bag
contents: the client holds a cart id, reads the cart via `CartQuery(cartId:)`, and writes through
`createCart` / `addToCart` / `removeFromCart`. Every mutation returns the complete `Cart!`, so the
client replaces its state wholesale on each write and never reconciles a partial response.

Business value: a bag that survives a reinstall, is visible to the same cart on other surfaces, and
can eventually reach checkout. Checkout itself is **not** wired in this iteration — see Known
Limitations.

---

## User Stories

- **As a** shopper, **I want** items I add from a product page to persist in my bag **so that** I do
  not lose them between sessions
- **As a** shopper, **I want** to see what is in my bag with prices and a total **so that** I know
  what I am about to buy
- **As a** shopper, **I want** to remove something from my bag **so that** I can change my mind
- **As a** shopper, **I want** to add the same item again **so that** I can buy more than one
- **As a** shopper, **I want** to be told when adding to my bag fails **so that** I do not assume it
  worked

---

## Acceptance Criteria

### Scenario 1: First add creates a cart

**GIVEN** the user is on the _Product Details screen_ with a variant selected
AND no cart id is stored on the device
**WHEN** the user taps the _Add to bag button_
**THEN** the button shows an in-flight indicator
AND a cart is created containing that line in a single request
AND the returned cart id is persisted
AND a success _Snackbar_ is shown

### Scenario 2: Subsequent add appends to the existing cart

**GIVEN** the previous scenario THEN state
AND the user is on a different _Product Details screen_
**WHEN** the user taps the _Add to bag button_
**THEN** the line is appended to the existing cart
AND the returned cart replaces the client's cart state

### Scenario 3: Re-adding the same variant increases its quantity

**GIVEN** the bag already contains a line for a variant
**WHEN** the user adds that same variant again from the _Product Details screen_
**THEN** the cart returns one line for that variant with the quantity increased
AND the bag does not show two rows for the same variant

### Scenario 4: The bag reflects its contents without a manual refresh

**GIVEN** the user has added items
**WHEN** the user opens the _Bag tab_
**THEN** the bag shows the cart's line items, each with its image, name, quantity, unit price and
line total
AND the subtotal and total are shown

### Scenario 5: The bag is empty

**GIVEN** the user has a cart with no line items, or no cart at all
**WHEN** the user opens the _Bag tab_
**THEN** an empty state is shown with a title and message and no call to action

### Scenario 6: Removing a line

**GIVEN** the user is on the _Bag screen_ with at least one line
**WHEN** the user swipes a row and confirms delete
**THEN** the line is removed from the server cart
AND the returned cart replaces the client's cart state
AND the totals update

### Scenario 7: Adding to the bag fails

**GIVEN** the user is on the _Product Details screen_
AND the cart request will fail
**WHEN** the user taps the _Add to bag button_
**THEN** the in-flight indicator ends
AND an error _Snackbar_ is shown
AND nothing is added to the bag
AND no add-to-bag analytics event is fired

### Scenario 8: The bag cannot be read offline

**GIVEN** the device has no network connection
**WHEN** the user opens the _Bag tab_
**THEN** an _ErrorView_ is shown with a no-connection message and a retry action
AND tapping retry re-attempts the cart fetch

### Scenario 9: The stored cart id is no longer valid

**GIVEN** a cart id is stored on the device
AND the server no longer recognises it
**WHEN** the cart is fetched
**THEN** the stored cart id is discarded
AND the bag renders as empty rather than as an error
AND the next add creates a fresh cart

### Scenario 10: Signing out clears the cart

**GIVEN** a cart id is stored on the device
**WHEN** the user signs out
**THEN** the stored cart id is discarded
AND the bag renders as empty

### Scenario 11: No bag products remain in local storage

**GIVEN** the app has been upgraded to this version
**WHEN** the bag is opened
**THEN** no bag contents are read from or written to `UserDefaults`
AND the wishlist continues to work unchanged

### Scenario 12: Adding to an expired cart recovers without the user seeing it

**GIVEN** a cart id is stored on the device
AND the server no longer recognises it
**WHEN** the user taps the _Add to bag button_
**THEN** the stored cart id is discarded
AND a new cart is created containing that line, within the same user action
AND the new cart id is persisted
AND a success _Snackbar_ is shown — the user sees no error

---

## Data Models

```swift
// Domain Models — Model/Models/Cart/
public struct Cart: Hashable {
    public let id: String
    public let lines: [CartLine]
    public let subtotal: Money
    public let grandTotal: Money

    /// Total quantity across all lines — the tab badge value, not `lines.count`.
    public var totalQuantity: Int {
        lines.reduce(0) { $0 + $1.quantity }
    }
}

public struct CartLine: Hashable, Identifiable {
    /// The server-assigned line id. This is what `removeFromCart(lineId:)` takes.
    public let id: String
    public let productId: String
    public let variantId: String
    public let sku: String?
    public let name: String?
    public let imageURL: URL?
    public let quantity: Int
    public let unitPrice: Money
    public let lineTotal: Money
}

// Error Types — Model/Services/BFFService/
public enum BFFCartRequestErrorType: Equatable {
    /// The stored cart id is unknown or expired. Discard it and start a new cart.
    case cartNotFound
    /// The server rejected the line — e.g. quantity beyond stock or the BFF's 1...100 bound.
    case invalidLine
    case generic
}
```

Additions to existing types:

```swift
// Model/Models/Product/Product.swift — Product.Variant
/// The platform variant id, required by every cart write.
/// `nil` for a variant synthesised by `syntheticDefaultVariant()`, which has no server counterpart.
public let id: String?

// Model/Services/BFFService/BFFRequestError.swift — BFFRequestErrorType
case cart(BFFCartRequestErrorType)

// BFFRequestError — new stored property, alongside the existing `graphqlErrorCode`
public let graphqlErrorStatus: Int?
```

`PersistedProductDTO` is **unchanged**. See Q16.

---

## API Contracts

Four operations are authored under `BFFGraph/CodeGen/Queries/Cart/`. `updateCart` and
`cartCheckoutUrl` are deliberately **not** authored — see Q27 and Known Limitations.

```graphql
query CartQuery($cartId: String!) {
    cart(cartId: $cartId) { ...CartFragment }
}

mutation CreateCartMutation($input: CreateCartInput!) {
    createCart(input: $input) { ...CartFragment }
}

mutation AddToCartMutation($input: AddToCartInput!) {
    addToCart(input: $input) { ...CartFragment }
}

mutation RemoveFromCartMutation($cartId: String!, $lineId: String!) {
    removeFromCart(cartId: $cartId, lineId: $lineId) { ...CartFragment }
}

fragment CartFragment on Cart {
    id
    lineItems { ...CartItemFragment }
    totals {
        subtotal { ...MoneyFragment }
        grandTotal { ...MoneyFragment }
    }
}

fragment CartItemFragment on CartItem {
    id
    productId
    variantId
    sku
    name
    quantity
    image { url altText }
    price { ...MoneyFragment }
    lineTotal { ...MoneyFragment }
}
```

The minimal fragment is deliberate. `Cart.status` is the hardcoded literal `"active"` and carries no
information; `platformId` is transitional (the BFF marks it for removal in AF-59);
`externalReferences` is platform plumbing; `checkoutUrl` is out of scope. `CartTotals.currency` is
not selected — the nested `Money.currencyCode` is the single source (Q18).

**Every line input sends both `productId` and `variantId`.** BigCommerce throws
`BadRequestException` without `productId`; Shopify ignores it.

**Server-side bounds to respect:** at most 50 lines per cart, quantity 1–100 per line. Neither is
stock-aware — the cart exposes no inventory, so an over-order fails at the platform and returns
`BAD_REQUEST` with the platform's raw message.

---

## Navigation

### Entry Points

- Tab bar → Bag tab → Bag screen
- Product Details → Add to bag → (stays on PDP, shows a snackbar)

### Exit Points

- Tap back / switch tab → Previous screen
- Toolbar → Account, Wishlist (unchanged)
- **Tapping a bag row does nothing.** Bag → PDP navigation is dropped by team decision (T6), so
  `CartItem` needs no product handle and no enrichment. See Q13.

### Routes and FlowViewModel Methods

This feature adds **no new routes**. `BagRoute` is unchanged, and the empty state has no call to
action (Q34), so no cross-tab navigation is introduced.

---

## Localization

| Key | English | Notes |
|-----|---------|-------|
| `bag.empty.title` | "Your bag is empty" | Empty state title |
| `bag.empty.message` | "Items you add will appear here" | Empty state message |
| `bag.quantity.label` | "Qty: %d" | Per-row quantity |
| `bag.subtotal.title` | "Subtotal" | Totals row |
| `bag.total.title` | "Total" | Totals row |
| `bag.remove.cta` | "Remove" | Swipe action |
| `bag.error_view.title` | "Oops!" | Error state title |
| `bag.error_view.generic.message` | "Something went wrong" | Generic error |
| `bag.error_view.no_internet.message` | "Check your connection" | Offline error |
| `bag.error_view.retry.cta` | "Try again" | Error retry action |
| `product.add_to_bag.success.message` | "Added to bag" | Success snackbar |
| `product.add_to_bag.error.message` | "Couldn't add to bag" | Error snackbar |

Existing and unchanged: `bag.title`, `tab.bag.title`, `product.add_to_bag.button.cta`,
`product.color.title`, `product.size.title`, `product.one_size.title`.

---

## Analytics

Both existing events keep their current signature. The only change is **when** they fire.

### Event: `add_to_bag`

**When**: after the cart mutation **succeeds** — not on tap.
**Parameters**: `product_id: String`

### Event: `remove_from_bag`

**When**: after `removeFromCart` **succeeds**.
**Parameters**: `product_id: String`

A `quantity` dimension, a separate `variant_id` parameter, and normalising the existing
`product_id` inconsistency are **deferred** (Q29). The inconsistency is pre-existing and recorded
under Verified Facts.

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| No cart id stored, user opens the bag | Render the empty state. Do not create a cart just to look at it. |
| Stored cart id is unknown or expired | Discard the id, render empty, next add creates a fresh cart |
| `cart(cartId:)` fails with a server error (not 404) | `ErrorView` with a generic message and retry. **Do not** discard the cart id. |
| Malformed stored cart id | Surfaces as a 500, so it is treated as a server error and the id is kept. Accepted under T7 — unreachable in practice, since we only ever store an id the server gave us. |
| No internet on bag open | `ErrorView` with the no-connection message and retry |
| Stored cart id 404s during add-to-bag | Discard the id and `createCart` with the same line inside the same user action; the user sees a success snackbar (Scenario 12) |
| Non-finite `Money.amount` on a line total | Render `—` rather than the £0.00 that `toDomainMoney()`'s zero fallback would produce (Q36) |
| No internet on add-to-bag | Error snackbar; nothing added; no analytics event |
| Add exceeds available stock | Platform rejects with `BAD_REQUEST`; surface the error snackbar |
| Cart already has 50 lines | BFF rejects; surface the error snackbar |
| Product has no purchasable variant (`Variant.id == nil`) | Add-to-bag is disabled locally; no request is made |
| Line has a null `name` or `image` | Render the row without them; both are nullable on `CartItem` |
| Removing the last line on BigCommerce | The platform destroys the cart and the BFF returns a synthetic empty cart with a dead id. Treat the next 404 as Scenario 9. |
| User taps add-to-bag repeatedly | The button is disabled while in flight (Q8), so each tap is one request |

---

## Dependencies

### Services Required

- `CartService` (`Core/Services/API/`) — all cart operations, over `BFFClientServiceProtocol`
- `UserDefaultsProtocol` (`ServiceProviderProtocol`) — cart id persistence, no client-side TTL (Q1)
- `ReachabilityServiceProtocol` — offline detection
- `AlfieAnalyticsTracker` — add/remove events

### External Dependencies

- BFF GraphQL endpoint, Shopify Storefront API `2025-10`
- BFF schema: `Cart`, `CartItem`, `CartTotals` and the cart input objects

### Internal Dependencies

- ViewState: `ViewState<Cart, BFFRequestError>`
- Models: `Cart`, `CartLine`, `Money`, `Product.Variant.id`
- `BFFClientService.executeMutation` — **does not exist yet**, see Story 2

### Retired by this feature

`BagServiceProtocol` · `BagService` · `BagStoreProtocol` · the `BagStoreProtocol` conformance on
`UserDefaultsStore` · `MockBagService` · `MockBagStore` · `BagServiceTests` · `StorageKey.bagItems`.
`UserDefaultsStore` survives for the wishlist.

---

## Testing Strategy

### Service Tests (`CoreTests`)

- [ ] `CartService` create / add / remove / fetch success paths
- [ ] Cart-not-found maps to `.cart(.cartNotFound)` and discards the stored id
- [ ] A non-404 failure does **not** discard the stored id
- [ ] `Cart+Converter` field mapping, including null `name` / `image`
- [ ] Money conversion through `toDomainMoney()`, pinning `19.99`, `0.1` and a half-way case
- [ ] A non-finite line total renders `—`, never `£0.00` (Q36)
- [ ] A 404 on add-to-bag creates a new cart and reports success (Scenario 12)
- [ ] `Cart.totalQuantity` sums quantities rather than counting lines
- [ ] Mutations are not retried and not written to the cache

### Unit Tests (`BagTests`, `ProductDetailsTests`)

- [ ] `BagViewModel` state transitions: loading → success → error
- [ ] Empty cart yields `.success` with `lines.isEmpty`, not an error
- [ ] Remove updates state from the returned cart
- [ ] PDP add-to-bag: in-flight state, success snackbar, error snackbar
- [ ] PDP add-to-bag is disabled when `Variant.id` is `nil`
- [ ] Analytics fire on success only, never on failure

### Localization Tests (`SharedUITests`)

- [ ] Every new key exists in all supported languages
- [ ] `bag.quantity.label` formats correctly

### Snapshot Tests

- [ ] Bag loading, empty, populated and error states

### UI Tests (`AlfieUITests`)

- [ ] Add from PDP, open bag, see the line
- [ ] Swipe to remove a line
- [ ] Error state retry

### Manual verification (blocking Story 7)

- [ ] **Adding a variant already in the cart merges into one line with the quantity summed.** This is
  documented platform behaviour but is covered by no test in the BFF. The whole quantity-increase
  path depends on it.

---

## Design References

No Figma design exists for the bag's new elements — the quantity display, the totals row and the
empty state. A design request is raised alongside ALFMOB-443, which owns the bag's visual redesign.
This feature ships them using existing design tokens and `SharedUI` components, to be restyled by
443.

---

## Accessibility

New `AccessibilityID.Bag` entries: `bagView` · `lineItem` · `lineItemQuantity` · `lineItemRemove` ·
`subtotal` · `grandTotal` · `emptyState` · `errorView` · `errorRetry`.

`Bag+Toolbar.swift` and `HorizontalProductCard.swift` declare private, local `AccessibilityID` enums
rather than using the shared module. That predates this feature and is deliberately left alone.

Standard requirements apply: VoiceOver labels on every interactive element, Dynamic Type support,
and a loading announcement for the cart fetch.

---

## Known Limitations

- **Checkout is not wired.** `cartCheckoutUrl` stays unused and `WebFeature.checkout` untouched. The
  bag is a dead end by design. (`cartCheckoutUrl` also throws a bare `Error` on Shopify.)
- **A bag row is not tappable and does not reach the PDP.** Decided, not a temporary gap: the team
  dropped bag → PDP navigation (T6), so no `handle` is requested on `CartItem` and no cross-repo
  ticket is raised.
- **The bag row shows no brand, colour, size or was-price.** `CartItem` carries none of them and no
  enrichment is asked for.
- **Quantity is display-only.** There is no stepper, so reducing a quantity means removing the line
  and re-adding. Deferred to ALFMOB-443 (Q27).
- **No clear-all action.** The BFF exposes no `clearCart`; emptying means removing lines one by one.
- **No offline support.** Reads error, writes are blocked (Q25).
- **Guest carts only.** BFF identity is guest-only; `customerAccessToken` is unused and a
  guest→signed-in merge is not attempted. User-owned carts follow authentication (T3), at which
  point the stored id must be dropped on sign-*in* as well as sign-out.
- **Deployed environments do not work.** No `Authorization` header is sent (`AuthorizationInterceptor`
  is a stub), so every operation 401s against a guarded BFF. Local and CI only until ALFMOB-503.
- **No wishlist changes.** The wishlist keeps its local storage and its add-to-bag stays navigation.

---

## Implementation Notes

- Every mutation returns the complete `Cart!` — replace state wholesale, never merge.
- `RetryInterceptor` and the cache interceptors must be excluded for mutations, or a retried
  `addToCart` silently double-adds.
- The first add uses `CreateCartInput.lines` to create-and-add in one round trip rather than two.
- BigCommerce's `updateCart` is non-atomic, and removing its last line yields a cart id that no
  longer resolves. Both are handled by treating any 404 as "start a new cart".
- Sequence against ALFMOB-443 so the two do not fight over `BagView` snapshot baselines (Q9).

---

## Story Breakdown

Raised as GitHub Issues (per `Docs/agents/issue-tracker.md`). With the team questions answered,
**every story is unblocked** and the only ordering left is the technical dependency below.

| # | Story | Depends on |
|---|---|---|
| 1 | Variant id through the domain — `Product.Variant.id: String?` | — |
| 2 | Mutation plumbing — `executeMutation`, exclude retry and cache | — |
| 3 | Schema sync + cart codegen — four operations, minimal fragment | — |
| 4 | Cart domain types + converter, with money and converter tests | 3 |
| 5 | `CartServiceProtocol` + `CartService`, one observable cart | 2, 4 |
| 6 | Cart identity — store, read, invalidate the cart id | 5 |
| 7 | Add to cart from the PDP, incl. the merge smoke test | 5, 6 |
| 8 | View bag — state, rows, totals, empty, error, remove | 5, 6 |
| 9 | Tab badge — total quantity across lines, read from `CartService` | 5 |

---

---

## Questions & Decisions

### Decided

| # | Decision | Rationale |
|---|---|---|
| Q3 | **Sign-out drops the cart id**, wired through `resetServices()`. | Not because the server binds cart to account — it doesn't — but so a shared device doesn't hand the next user the previous user's bag. Near-free while `SessionService.signOutUser()` is still a stub. |
| Q4 | **New `CartServiceProtocol`**; `BagServiceProtocol` and `BagService` are retired. | `getBagContent() -> [SelectedProduct]` cannot express quantity, totals or a checkout URL, and none of its methods can fail. Sets the convention for future API services. |
| Q6 | **New `Cart` / `CartLine` domain types**, kept separate from `SelectedProduct`. The wishlist and PDP navigation keep using `SelectedProduct` unchanged; the wishlist's add-to-bag calls the cart service rather than sharing a type. | A cart line carries three things `SelectedProduct` has nowhere to put: a server-assigned line id (what `removeFromCart(lineId:)` needs), a quantity, and cart-level totals. Extending it would give the wishlist a meaningless quantity and push a server line id into `.productDetails(.selectedProduct(_))` navigation. |
| Q8 | **Pessimistic writes** with an in-flight indicator. | Every cart mutation returns the complete `Cart!`, so the response *is* the new truth and there is nothing to merge. Optimistic would buy latency-hiding at the price of a rollback path and a second source of truth in the view. |
| Q9 | **Cart lands before ALFMOB-443** (Bag visual redesign). | 443's own Out of Scope excludes "bag/cart logic, pricing, or data changes", so it is written to sit on top of whatever data layer exists. Redesign-first means resnapshotting twice. |
| Q10 | **ALFMOB-492 is reopened.** ALFMOB-493 stays Done — the server-side auth bypass was the agreed outcome. | 492 is unrelated to auth: it threads the BFF variant id into `Product.Variant` and `PersistedProductDTO`. Its code exists on no branch, and `CartLineInput.variantId` is `ID!` and required — so no cart write can be constructed today. ALFMOB-499 is also written on the premise that 492 landed, which is currently false. |
| Q11 | **Regenerate the cart codegen from scratch** against the current BFF schema; the uncommitted worktree cut is discarded. Implementation tickets are raised as **GitHub Issues**, not Jira. | The worktree's `schema.graphqls` was hand-modified; regenerating is the only way to know the result matches the real schema. GitHub Issues per `Docs/agents/issue-tracker.md` (Jira `ALFMOB` for team tickets, GitHub for agent-generated work). |
| Q13 | **The bag row ships on `CartItem` as it stands** — name, image, quantity, unit price, line total (web's ALFMOB-463 scope). **No enrichment is requested and the row is not tappable.** | Resolved by T6: the team dropped bag → PDP navigation, so the one field that would have been needed — a product `handle` — is not worth a cross-repo ticket. `productDetails(handle:)` is slug-keyed on both platforms (`product.service.ts:82`), so `CartItem.productId` could never have substituted for it. Brand, colour, size and compare-at fall away with it: the PDP fetched those itself. |
| Q14 | **Both Shopify and BigCommerce are in scope.** | Both are fully implemented on the BFF — the epic's doubt was stale. See the two BigCommerce caveats under Verified Facts; they are handled, not excluded. |
| Q17 | **`CartLine.id` is the server line id** (`CartItem.id`) — use what the BFF gives us. | It is what `removeFromCart(cartId:lineId:)` takes, and the only id guaranteed unique per line. A product+variant composite breaks when the same variant appears twice and yields an id we cannot remove with. |
| Q18 | **Trust the nested `Money.currencyCode`; `CartTotals.currency` is not modelled in the domain.** | Domain `Money` already carries `currencyCode` and `toDomainMoney()` already reads it. Consuming the outer field would mean a second code path and a disagreement nobody wants to reconcile. |
| Q19 | **Bag read state is `ViewState<Cart, BFFRequestError>`.** An empty bag is `.success(cart)` with `lines.isEmpty` — the view renders the empty state. | Totals are cart-level and must move with the lines atomically; a `[CartLine]` state leaves totals in a second `@Published` that can lag. `ViewState` has no `.empty` case (`ViewState.swift:3`), so emptiness is a view concern. `.loading` reuses the existing shimmer, `.error` an `ErrorView` with retry (`ProductListingView` is the precedent). |
| Q20 | ~~Debounce each stepper, disable controls in flight, re-fetch on failure.~~ **Superseded by Q27** — with no stepper there is no `updateCart`, no debounce and no concurrent-update race in this epic. Reinstate if the stepper lands with ALFMOB-443. | `updateCart` takes the full `lines` array, so two in-flight updates clobber each other. Pessimistic writes (Q8) supply the disable; the debounce stops a tap burst becoming three round-trips. The re-fetch is required because BigCommerce's `updateCart` loops line-by-line and can fail mid-loop with earlier lines committed. |
| Q22 | **Add `.cart(BFFCartRequestErrorType)` to `BFFRequestErrorType`, mirroring `.product`, and carry `extensions.status` alongside the existing `graphqlErrorCode`.** | The status field is where the 404-vs-500 discrimination lives. T7 closed as "keep 404", so this is the permanent mechanism, not an interim one — see Q12. |
| Q15 | **`Product.Variant.id` is `String?`**, populated by `ProductDetails+Converter`; `syntheticDefaultVariant()` gets `nil`. | The BFF always sends an id for real variants (`ProductDetailsFragment.graphql:22` already selects it), but `syntheticDefaultVariant()` (`ProductDetails+Converter.swift:71`) fabricates a variant when the BFF returns none. A fake id would turn "not addable" into a server round-trip that fails; `nil` makes it a local `guard let`, unit-testable and free. |
| Q16 | **Withdrawn — `PersistedProductDTO` gains no `variantId`, and needs no change at all.** | Once Q4 retires `BagService`, the DTO is wishlist-only: it has one production consumer (`UserDefaultsStore`), instantiated twice (`ServiceProvider.swift:97,103`). The wishlist's add-to-bag navigates to the PDP (`WishlistViewModel.swift:45`), which re-fetches variants with live ids — so a persisted id buys nothing. Consequence: no `keyNotFound` silent-wipe risk, no stored-data migration, and `PersistedProductDTOTests` is untouched. |
| Q21 | **Add `executeMutation<Mutation: GraphQLMutation>` to `BFFClientService`, and exclude mutations from `RetryInterceptor` and from cache read/write.** Own GitHub issue, sequenced before any cart operation. | `executeFetch` (`BFFClientService.swift:173`) is constrained to `GraphQLQuery`, so mutations will not compile against it. And `NetworkInterceptorProvider` is generic over `GraphQLOperation`, so a mutation inherits the query chain — a retried `addToCart` adds the line twice. That is a duplicate-write bug, not a rough edge. |
| Q23 | **Wishlist add-to-bag stays as navigation to the PDP.** Unchanged. | Existing behaviour, outside this epic. A direct write would need a slug re-fetch on tap plus loading and error states on a card that has neither — and a saved wishlist variant may have changed price or gone out of stock since, which the PDP is the right place to surface. Raise separately if wanted. |
| Q24 | **No local-bag migration. ALFMOB-499 closes as won't-do**, and the epic's AC "products already in a user's local bag survive the upgrade" is struck. | The app is not released, so no user has a saved bag. Once the bag store is deleted nothing reads `StorageKey.bagItems` again, so a stale blob on a dev device is inert — the cleanup costs zero lines. This removes the slug re-fetch, per-slug batching, partial-failure UX and their tests entirely. |
| Q25 | **No offline support.** An offline read is `.error(.noInternet)` → `ErrorView` with retry; an offline write is blocked with an error snackbar. | A persisted cart mirror re-introduces the local source of truth this epic exists to delete, and would go stale against a server another device can mutate. The Apollo store is an `InMemoryNormalizedCache`, so a "cached cart" cannot survive a relaunch anyway. Within a session `.success(cart)` still holds the last good cart, so a write blip leaves the displayed bag intact. |
| Q26 | **PDP add-to-bag shows an in-flight indicator, then a snackbar.** `ThemedButton(isLoading:)` on the CTA (`ProductDetailsView.swift:523`), `.success` "Added to bag" / `.error` on failure. **No auto-navigation to the bag on success.** | Today it is fire-and-forget with no feedback at all (`ProductDetailsViewModel.swift:207`); pessimistic writes (Q8) give it an in-flight state and a failure case. Pieces already exist — `ThemedButton.swift:25`, `SnackbarView.swift:7`, with `ProductListingView` as the wiring precedent. Auto-navigation is a product decision outside this epic. |
| Q28 | **Empty bag reuses `ErrorView`** with bag copy. ~~…and a "Start shopping" CTA switching to the Shop tab.~~ **The CTA half is superseded by Q34** — title and message only. | Per Q19 an empty bag is `.success(cart)` with `lines.isEmpty`. `SharedUI` has no `EmptyState` component, and `ErrorView` already renders title + message (`ErrorView.swift:42`). `CLAUDE.md` requires reaching for existing `SharedUI` components before writing a new view. The component choice stands; only the CTA was dropped. |
| Q29 | **Analytics fire on success only.** The schema changes (a `quantity` dimension, a separate `variantId` parameter, normalising `productID`) are **deferred** — not done in this epic. | Writes can now fail, so firing on intent would inflate add-to-bag against real cart contents. The schema changes are deferred because they alter an existing event stream whose downstream owner has not been identified; the pre-existing `productID` inconsistency (`ProductDetailsViewModel.swift:211` sends a composite, `BagViewModel.swift:38` sends a bare id) is recorded under Verified Facts and left in place. |
| Q27 | **Quantity is display-only this epic.** The row shows the quantity as text; increasing means tapping add-to-bag again on the PDP (which merges server-side and shows the Q26 loading indicator); the only removal affordance is the existing swipe-to-delete wired to `removeFromCart`. The stepper is deferred to ALFMOB-443 **with a design request raised**. | Designing a control blind that ALFMOB-443 would redesign weeks later is the double-work Q9 chose to avoid, and this removes `updateCart`, the `QuantityStepper` component, the debounce and the whole concurrent-update race. **Two costs taken deliberately:** a user cannot decrement without deleting the line and re-adding, and this strikes two of ALFMOB-491's stated ACs (the stepper in Scope, and "changing a quantity updates totals without a full reload") — to be recorded on the epic. **Load-bearing risk:** the increase path depends entirely on `addToCart` merging duplicate variants, which is documented platform behaviour but covered by no test in the BFF. The first implementation story must smoke-test it against the real Shopify store. |
| Q30 | **Author exactly four operations** — `CreateCart`, `AddToCart`, `RemoveFromCart`, `Cart` — with a minimal fragment: `id`, `lineItems`, `totals { subtotal, grandTotal }`. Every line input sends both `productId` and `variantId`. | Q27 removes `updateCart`; checkout removes `cartCheckoutUrl`. `status` is a hardcoded `"active"`, `platformId` is transitional, `externalReferences` is platform plumbing, `checkoutUrl` is unwired. Authoring `updateCart` "for later" would freeze a schema shape before ALFMOB-443 needs it. |
| Q31 | **Write snapshot tests for all four bag states**, accepting that ALFMOB-443 will regenerate the baselines. | Regenerating a baseline is one command, and 443 regenerating them deliberately is what baselines are for. The alternative is implementing the cart with no visual regression net during the epic that replaces the bag's entire data source. |
| Q32 | **The bag gets a totals row** (subtotal + total), styled with existing tokens, flagged to design alongside the stepper. **No checkout CTA.** | Explicit epic scope ("view bag against real line items and totals"), and unlike a stepper it is static text with no interaction model to get wrong. Checkout is out of scope, so the bag is a dead end by design. |
| Q33 | **Twelve new L10n keys and a new `AccessibilityID.Bag` enum**, following the existing `plp.error_view.*` pattern. The private local `AccessibilityID` enums in `Bag+Toolbar.swift` and `HorizontalProductCard.swift` are **left alone**. | Those private enums contradict the `CLAUDE.md` rule, but they predate this feature and are unrelated to it — folding a cleanup in would break the surgical-changes rule. Noted, not fixed. |
| Q34 | **The empty state has no call to action** — title and message only. **Supersedes the CTA in Q28.** | `ErrorView.buttons` defaults to `[]`, so this is free. A "Start shopping" CTA would need a cross-tab escape hatch threaded through `FlowViewModel` into `RootTabViewModel.navigate(.shop)` — new navigation plumbing for one button on a screen the user is one tap from leaving via the tab bar. |
| Q35 | **Nine implementation stories**, raised as GitHub Issues in the order given under Story Breakdown. All nine are now unblocked. | Sequenced so the iOS-only groundwork runs first; with T1–T7 answered nothing waits on another team. |
| Q1 | **The cart id lives in `UserDefaults`, with no client-side TTL.** Stored on create, read on every operation, discarded on a 404 and on sign-out. | Closed by T1: carts expire after 30 days of inactivity, but "inactivity" is not something the client can track reliably — a second device or the web can touch the same cart. The server's 404 is the only authoritative expiry signal, so a client-side timer would either expire a live cart or lag a dead one. `UserDefaults` because the id is a non-secret server handle to a guest cart, and `UserDefaultsStore` already exists. |
| Q2 | **The cart is created lazily, by the first add.** `createCart(input:)` carries that first line, so create-and-add is one round trip. Opening an empty bag creates nothing. | Closed by T2: the BFF will **not** implicitly create a cart from an unknown id, so iOS owns creation. Consequence for recovery: a 404 from `addToCart` is not an error the user sees — discard the id, `createCart` with the same line, report success (Scenario 12). A 404 from `CartQuery` just renders empty; nothing is created until there is something to put in it. |
| Q5 | **One observable cart.** `CartService` holds a single published `Cart?`; the bag screen and the tab badge both read from it, and every mutation replaces it wholesale. No caller fetches its own. | Closed by T4. The badge value is `cart.lines.reduce(0) { $0 + $1.quantity }` — computed on the client, since `Cart` has no `totalQuantity` field (`cart.model.ts:135`) and needs none: every operation, query and mutation alike, returns the complete `Cart` with `lineItems { quantity }`. A server field would not have addressed the actual failure, which is two client-side copies of the cart drifting apart. |
| Q12 | **A cart-not-found is `extensions.status == 404`**, mapped to `.cart(.cartNotFound)`; anything else is a server error and the stored id is kept. | Closed by T7: the team keeps 404 rather than adding a distinguishable error code. One cost accepted with it — a *malformed* cart id surfaces as a 500 and so never self-heals. Unreachable in practice, because the only ids we store are ones the server issued. |
| Q36 | **A non-finite line total renders `—`.** The zero fallback in `toDomainMoney()` stays for listings; the bag suppresses the row total instead of printing it. | Closed by T5. Two halves, both small: there is no cross-platform major→minor rule to agree because iOS does no money arithmetic in the cart — the BFF returns `lineTotal` and both totals pre-computed, so the client only formats, and `CurrencyFormatter.minorUnits` (`CurrencyFormatter.swift:40`) already handles per-currency digits. What was left was the render: `toDomainMoney()` collapses NaN/±inf to zero (`ProductListing+Converter.swift:89`), which prints **£0.00** — cosmetic on a listing, but on a bag row it reads as "this item is free". |

### Answered by the team

Answered 26 Aug 2026. Each answer is folded into the decision it was blocking; nothing below is
still outstanding.

| # | Question | Answer | Lands in |
|---|---|---|---|
| T1 | What expires a cart, and after how long? | **30 days of inactivity.** | Q1 — persist the id, no client TTL |
| T2 | Will the BFF implicitly create a cart from an expired or absent id? | **No.** iOS calls `createCart` when the BFF errors. | Q2, Scenario 12 |
| T3 | Are user-owned carts on the roadmap? | **Yes, after authentication.** Out of scope here. | Guest-only stands; the id must also be dropped on sign-*in* once auth lands (Q3 covers sign-out) |
| T4 | One observable cart, or fetched per caller? | **One.** The badge comes from the same cart the bag screen renders, so it updates on every write. | Q5 |
| T5 | Canonical major→minor money rule, and what a malformed line total renders? | **No rule needed** (iOS does no cart-side arithmetic); malformed renders **`—`**. | Q36 |
| T6 | `CartItem` enrichment — brand, colour, size, compare-at, handle? | **None.** Bag → PDP navigation is dropped, which removes the need for a `handle`. | Q13; no AF ticket raised |
| T7 | A distinguishable error code for "cart not found"? | **No — keep 404.** | Q12, Q22 |

### Still open

**Nothing.** Every branch of the design tree is closed and every story is implementable.

---

## Verified Facts

Established by direct inspection, not inherited from ticket text. iOS at `origin/main` `81458a4`;
Alfie-BFF at `origin/main` `6aa0783` (25 Aug 2026).

### BFF

- **`Cart.status` carries no information.** Both adapters hardcode the literal `"active"`
  (`shopify-adapter.service.ts:407`, `bigcommerce-adapter.service.ts:106`), each with a comment
  noting the platform has no native cart-status field. It can never signal expiry. iOS must not read it.
- **No BFF-side cart TTL.** The BFF stores no cart state; every operation is a pass-through keyed on
  the platform's cart id.
- **An unknown or expired cart id is indistinguishable from a server fault.** Both adapters throw
  `NotFoundException` (`shopify.service.ts:71`, `bigcommerce.service.ts:154`), but `@nestjs/apollo`'s
  default transform maps only 400/401/403/422 — 404 falls through to
  `extensions.code: "INTERNAL_SERVER_ERROR"` with `extensions.status: 404`. A real fault is the same
  code with status 500. A *malformed* id makes Shopify return a GraphQL error, surfacing as 500.
- **All five cart operations are implemented on both platforms.** No "not yet implemented" throw
  exists anywhere in `src`. Platform is selected by a required `PLATFORM` env var with no code
  default; `.env.example` is `shopify`. Note `PLATFORM=mock` silently uses the **Shopify** cart path,
  because `CartService` only branches on `bigcommerce`.
- **BigCommerce caveat 1 — `updateCart` is not atomic.** BigCommerce's API is single-line, so the BFF
  loops (`bigcommerce.service.ts:301`); a mid-loop failure leaves earlier lines committed and the
  client holding stale state. The client must re-fetch.
- **BigCommerce caveat 2 — removing the last line destroys the cart entity.** The BFF returns a
  synthetic empty cart whose `id` no longer refers to anything upstream (`bigcommerce.service.ts:272`,
  `buildEmptyCart` at `:367`); a later `cart(cartId:)` on that id 404s.
- **No `clearCart` mutation.** Four mutations only. Emptying a bag is N× `removeFromCart`, and on
  Shopify each costs two upstream round-trips because the BFF re-fetches the cart to validate the
  line first (`shopify.service.ts:224`).
- **`cartCheckoutUrl` throws a bare `Error` on Shopify** (`cart.service.ts:139`) — not an
  `HttpException`, so it reaches the wire with no `extensions.status` at all. Out of scope here, but
  a trap for whoever wires checkout.
- The query signature is `cart(cartId: String!)`, not `ID!`. `PORT` defaults to **4000** (the BFF
  README saying 3000 is stale — ALFMOB-502).

- **`addToCart` on a variant already in the cart is expected to merge** into the existing line with
  the quantity summed, on **both** platforms. Neither adapter pre-checks — Shopify goes straight to
  `cartLinesAdd` (`shopify.service.ts:170`) sending only `{ merchandiseId, quantity }` with no
  attributes or selling plan (`shopify-adapter.service.ts:371`); BigCommerce goes straight to
  `addCartLineItems` (`bigcommerce.service.ts:207`). The BFF adds **no** de-duplication or merging of
  its own — `normalizeCart` is a 1:1 map on both sides. **⚠️ This is the documented platform
  contract, not repo-verified: no test on either adapter covers a duplicate-variant add.** Any design
  that depends on it must smoke-test it against a real store first.
- **Nothing on the cart exposes stock.** `Inventory { available }` hangs off `ProductVariant` only and
  is unreachable from the cart. A client cannot cap a quantity increase from cart data; over-adding
  fails at the platform and reaches iOS as `extensions.code: "BAD_REQUEST"` with the platform's raw
  message (`shopify.service.ts:151`).
- **The BFF enforces its own bounds:** at most 50 lines per cart, and quantity 1–100 per line
  (`cart.service.ts:16,41-53`). Not stock-aware.
- **BigCommerce requires `productId` on every line** and throws `BadRequestException` without it
  (`bigcommerce-adapter.service.ts:44`), whereas Shopify ignores it. Since Q14 puts both platforms in
  scope, every cart write must send `productId` as well as `variantId`.
- **Shopify's `SHOPIFY_STOREFRONT_URL` pins Storefront API `2025-10`** (`.env.example:6`); the version
  is env config, not hardcoded in the connector.

### iOS

- **`PersistedProductDTO` has exactly one production consumer** — `UserDefaultsStore`, instantiated
  twice (`ServiceProvider.swift:97` `bagItems`, `:103` `wishlistItems`). Nothing else reads it;
  `RecentsService` uses a separate service and key. Retiring the bag therefore makes it wishlist-only.
- **Retired by this epic:** `BagServiceProtocol`, `BagService`, `BagStoreProtocol`, the
  `BagStoreProtocol` conformance on `UserDefaultsStore`, `MockBagService`, `MockBagStore`,
  `BagServiceTests`, and (after migration) the `StorageKey.bagItems` key. `UserDefaultsStore` itself
  survives for the wishlist.

- **`Product.Variant` has no `id`.** `ProductDetails+Converter.swift:15` explicitly discards the BFF
  variant id it already fetches. `CartLineInput.variantId` is `ID!` and required, so **there is no
  domain source for any cart write**. Scanned across every local and remote branch: zero hits.
- **No cart operations exist in the repo.** `origin/main` has no `Queries/Cart/` directory, no
  `Mutations/` in the generated API, and its `schema.graphqls` lacks `updateCart`, `removeFromCart`
  and `UpdateCartInput`.
- **There is no mutation path in the BFF client.** `executeFetch` (`BFFClientService.swift:173`) is
  generic over `GraphQLQuery` only; `BFFClientServiceProtocol` is five queries.
- **The interceptor chain would retry and cache mutations.** `NetworkInterceptorProvider` is generic
  over `GraphQLOperation`, so `RetryInterceptor` and `CacheWriteInterceptor` apply — i.e. a retried
  `addToCart`.
- **The bag has no state machine.** `BagViewModel.products` is a plain
  `@Published [SelectedProduct]` (`BagViewModel.swift:6`) with no loading or error case.
- **The tab badge is dead code.** `CustomTabBarView.swift:33` only ever *clears* `badgeNumbers`; no
  service writes to it, and the binding setter is `{ _ in }`.
- **`BagService` has no quantity concept.** `addProduct` de-dupes by `SelectedProduct.id` and
  silently no-ops on a duplicate (`BagService.swift:15`).
- **`UserDefaultsStore.load()` fails silently** — any decode error returns `[]` (`:16`), so a DTO
  shape change wipes the stored bag *and* wishlist with no signal.
- **`WishlistViewModel.didTapAddToBag` does not add to the bag.** It navigates to the PDP
  (`WishlistViewModel.swift:45`) and never touches `bagService`.
- **Analytics disagree on what `productID` means.** `ProductDetailsViewModel.swift:211` passes the
  composite `selectedProduct.id`; `BagViewModel.swift:38` passes the bare `product.id`.
- **Only three bag-adjacent L10n keys exist** — `bag.title`, `tab.bag.title`,
  `product.add_to_bag.button.cta`. Nothing for quantity, totals, checkout, empty state, remove, or
  any cart error.
- **`AccessibilityID` has no `Bag` enum** — only `TabBar.bag` and `ProductDetails.addToBagButton`.

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2026-08-26 | Decision log and verified facts opened during the design session | khoi.nguyen |
| 2026-08-26 | Full spec written; 30 decisions closed, 7 questions deferred to the team | khoi.nguyen |
