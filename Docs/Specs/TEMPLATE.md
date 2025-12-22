# Feature: [Feature Name]

**Status**: Draft  
**Created**: [Date]  
**Last Updated**: [Date]  
**Implementation PR**: [Link when implemented]

---

## Overview

[High-level description of the feature and its business value. What problem does it solve? Why are we building this?]

Example:
> This feature allows users to browse and discover products by category. It provides a paginated list view with filtering and sorting capabilities, enabling users to find products quickly and add them to their wishlist.

---

## User Stories

List who needs this feature and why:

- **As a** [type of user], **I want** [goal] **so that** [benefit]
- **As a** [type of user], **I want** [goal] **so that** [benefit]

Example:
- **As a** shopper, **I want to** view products by category **so that** I can browse relevant items
- **As a** shopper, **I want** to sort products by price **so that** I can find items within my budget
- **As a** shopper, **I want** to add products to my wishlist **so that** I can save items for later

---

## Acceptance Criteria

Clear, testable conditions that must be met. The acceptance criteria must cover all core functionality and scenarios but should avoid obvious or trivial scenarios where possible. 

Tips
- Where possible, order the acceptance criteria in the natural flow of the feature / user. 
- Use _italics_ to emphasis UI elements.
- UI element names should be capitalized. 
- Follow this acceptance criteria template.
- Write scenarios as regular markdown (no code fences) in your actual spec.

**Template Format:**
```markdown
### Scenario 1: A short human readable scenario description

**GIVEN** describe the initial state of the app, user or environment  
AND (optionally) concatenate additional states  
**WHEN** usually a single action or event  
**THEN** describe the main change in state  
AND (optionally) concatenate additional changes

### Scenario 2: Another short human readable scenario following on from the previous one if possible

**GIVEN** the previous scenario THEN state  
**WHEN** a new event happens  
**THEN** describe the main change in state
```

Example:

```markdown
### Scenario 1: Unauthenticated users are shown login screen on startup

**GIVEN** the app is starting
AND the user is not logged in
**WHEN** the _Splash screen_ finishes
**THEN** the user is navigated to the _Login screen_

### Scenario 2: User is shown validation errors on login

**GIVEN** the user is on the _Login screen_
AND the user has entered an invalid email / username
**WHEN** the user finishes entering their email (input loses focus, or Return press on keyboard)
**THEN** the user is shown a validation inline error (see [link to figma](https://www.figma.com/file))

### Scenario 3: User enters email and password

**GIVEN** the user is on the _Login screen_
AND the user has entered a valid email and password
**WHEN** the user taps on the _Login button_
**THEN** the login api service is called
AND the loading indicator is shown
```

---

## Data Models

Define all data structures in Swift:

```swift
// ViewModel State Model
struct [Feature]ViewStateModel {
    let property1: Type
    let property2: Type
}

// Domain Models
struct [Model] {
    let id: String
    let name: String
    // ... all properties
}

// Error Types
enum [Feature]ErrorType: Error {
    case generic
    case noInternet
    case noResults
}
```

Example:
```swift
// ViewModel State
struct ProductListingViewStateModel {
    let title: String
    let products: [Product]
}

// Error Types
enum ProductListingViewErrorType: Error {
    case generic
    case noInternet
    case noResults
}
```

---

## API Contracts

### GraphQL Queries/Mutations

Define the exact queries needed:

```graphql
query [QueryName]($param1: Type!, $param2: Type) {
    field(param1: $param1, param2: $param2) {
        ...FragmentName
    }
}

fragment [FragmentName] on [Type] {
    field1
    field2 {
        nestedField
    }
}
```

**Expected Response Shape**:
```json
{
  "data": {
    "field": {
      // Expected structure
    }
  }
}
```

Example:
```graphql
query ProductListingQuery(
    $offset: Int!
    $limit: Int!
    $categoryId: String
    $query: String
    $sort: ProductListingSort
) {
    productListing(
        offset: $offset
        limit: $limit
        categoryId: $categoryId
        query: $query
        sort: $sort
    ) {
        title
        pagination { ...PaginationFragment }
        products { ...ProductFragment }
    }
}
```

---

## Navigation

### Entry Points

Where can users access this feature?

- [Source] → [Action] → This Feature
- Deep link: `[scheme]://[path]`

Example:
- Shop tab → Categories → Tap category → Product Listing
- Search → Submit search → Product Listing (searchResults mode)
- Deep link: `alfie://category/{categoryId}`

### Exit Points

Where can users go from this feature?

- [Action] → [Destination]

Example:
- Tap product card → Product Details View
- Tap back button → Previous screen
- Tap wishlist icon → Wishlist View (if enabled)

### Coordinator Methods

```swift
// Required navigation methods
func [methodName](param: Type) {
    navigationAdapter.[action](.screen(configuration: config))
}
```

Example:
```swift
func didTap(_ product: Product) {
    navigationAdapter.push(.productDetails(configuration: .product(product)))
}

func didTapWishlist() {
    navigationAdapter.push(.wishlist)
}
```

---

## Localization

All user-facing strings with their keys:

### Required Strings

| Key | English | Notes |
|-----|---------|-------|
| `[feature].[section].[item]` | "Text" | [Context] |

Example:

| Key | English | Notes |
|-----|---------|-------|
| `plp.title` | "Products" | Screen title |
| `plp.error_view.title` | "Oops!" | Error screen title |
| `plp.error_view.generic.message` | "Something went wrong" | Generic error |
| `plp.error_view.no_internet.message` | "Check your connection" | Network error |
| `plp.number_of_results.message` | "%d result" / "%d results" | Pluralization |
| `plp.sort.title` | "Sort By" | Sort modal title |
| `plp.empty_state.title` | "No products found" | Empty state |

---

## Analytics

Events to track:

### Event: `[event_name]`

**When**: [Trigger condition]  
**Parameters**:
- `param1`: Type - Description
- `param2`: Type - Description

Example:

### Event: `product_listing_viewed`

**When**: User views PLP  
**Parameters**:
- `category_id`: String - Category slug
- `result_count`: Int - Number of products shown
- `source`: String - Entry point (e.g., "shop_tab", "search", "deeplink")

### Event: `product_card_tapped`

**When**: User taps product card  
**Parameters**:
- `product_id`: String - Product identifier
- `position`: Int - Position in list (0-indexed)
- `source`: String - "plp"

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| [Scenario description] | [How system should respond] |

Example:

| Scenario | Expected Behavior |
|----------|-------------------|
| No internet on initial load | Show ErrorView with retry button, message: "Check your connection" |
| No results for search | Show empty state with message: "No products found" |
| Pagination request fails | Show snackbar error, keep existing products visible |
| Wishlist service unavailable | Revert UI optimistic update, show error snackbar |
| Deep link with invalid category | Navigate to generic PLP or show error screen |
| User scrolls very fast | Debounce pagination requests, prevent duplicate calls |

---

## Dependencies

### Services Required

- `[ServiceName]` (Location) - Purpose
- `[ServiceName]` (Location) - Purpose

Example:
- `ProductListingService` (Core/Services) - Fetch paginated products
- `WishlistService` (Core/Services) - Add/remove items from wishlist
- `AlfieAnalyticsTracker` (Core/Services) - Track user events

### External Dependencies

- GraphQL API endpoint: `/graphql`
- BFF schema: `schema-products.graphqls`

### Internal Dependencies

- ViewState: Uses `PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>`
- Navigation: Requires `Screen.productListing(configuration:)` case
- Models: `Product`, `Brand`, `Price`, `Media`

---

## Testing Strategy

### Unit Tests (`AlfieTests`)

- [ ] ViewModel state transitions (loading → success → error)
- [ ] Pagination logic (load more when scrolled to bottom)
- [ ] Wishlist toggle logic
- [ ] Sort option application

### Service Tests (`CoreTests`)

- [ ] ProductListingService.fetchProducts() success
- [ ] ProductListingService.fetchProducts() error handling
- [ ] GraphQL ProductFragment converter

### Localization Tests (`SharedUITests`)

- [ ] All keys exist in all supported languages
- [ ] Pluralization for result count (0, 1, 2+ items)

### UI Tests (`AlfieUITests`)

- [ ] Grid/list layout toggle
- [ ] Scroll pagination triggers
- [ ] Product card navigation
- [ ] Error state retry button

### Snapshot Tests

- [ ] Product card layout (grid vs list)
- [ ] Loading skeleton
- [ ] Error state
- [ ] Empty state

---

## Design References

[Link to Figma, mockups, or design documents if available]

---

## Performance Considerations

[Any specific performance requirements or concerns]

Example:
- Products should load within 2 seconds on 4G
- Pagination should feel instant (optimistic rendering)
- Image loading should be progressive (blur → full resolution)

---

## Accessibility

[Accessibility requirements]

Example:
- All interactive elements have VoiceOver labels
- Support Dynamic Type (font scaling)
- Product cards have descriptive labels: "[Brand] [Product Name], [Price]"
- Loading states announce "Loading products"

---

## Known Limitations

[What is explicitly out of scope for this feature]

Example:
- Filtering by attributes (price range, size, color) is NOT in scope
- Product comparison is NOT in scope
- Will be added in future iteration

---

## Implementation Notes

[Any technical considerations or implementation details]

Example:
- Use skeleton loading (12 items) for better perceived performance
- Implement wishlist toggle with optimistic UI update
- Cache product images using Nuke library
- Pagination offset should reset when category changes

---

## Questions & Decisions

[Track open questions and design decisions]

### Open Questions
- [ ] Should we support infinite scroll or "Load More" button?
  - **Decision**: Infinite scroll for better UX
- [ ] How many products per page?
  - **Decision**: 20 items per page

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| [Date] | Initial spec created | [Name] |
| [Date] | Updated API contracts | [Name] |
| [Date] | Marked as implemented | [Name] |
