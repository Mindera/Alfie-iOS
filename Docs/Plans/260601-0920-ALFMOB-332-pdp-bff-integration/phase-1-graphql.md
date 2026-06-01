## Phase 1: Data / GraphQL operation

### Goal
Add the `productDetails` query + a `ProductDetailsFragment` and generate Apollo types. No Swift logic
yet — just the operation so the converter (Phase 2) has generated types to map from.

### Steps

1. **Create operation** (file: `BFFGraph/CodeGen/Queries/Products/Details/ProductDetailsQuery.graphql`)
   - Mirror `Products/Queries.graphql` (`ProductListQuery`) structure.
   - ```graphql
     query ProductDetailsQuery($handle: String!, $platform: String!) {
         productDetails(handle: $handle, platform: $platform) {
             ...ProductDetailsFragment
         }
     }
     ```

2. **Create fragment** (file: `BFFGraph/CodeGen/Queries/Products/Details/Fragments/ProductDetailsFragment.graphql`)
   - Field set on `OmniProduct` — only what the PDP consumes:
     ```graphql
     fragment ProductDetailsFragment on OmniProduct {
         id
         name
         slug
         brandName
         descriptionHtml
         defaultVariantId
         inventoryTotal
         priceRange { minVariantPrice { ...MoneyFragment } maxVariantPrice { ...MoneyFragment } }
         primaryImage { url altText }
         images { url altText }
         variants {
             id
             sku
             price { ...MoneyFragment }
             compareAtPrice { ...MoneyFragment }
             inventory { available }
             optionValues { name value }
             media { url altText }
             attributes { key value }
         }
     }
     ```
   - Reuse existing `MoneyFragment` (`BFFGraph/CodeGen/Queries/Fragments/MoneyFragment.graphql`) for DRY.
   - **Deliberately NOT fetching `OmniProduct.options`** — selector content & ordering come purely from
     the `variants[]` array order as the schema returns it (see Phase 2). Don't fetch unused fields.

3. **Run codegen** (file: generated `BFFGraph/API/**`)
   - `cd Alfie/scripts && ./run-apollo-codegen.sh` (downloads `apollo-ios-cli`, runs `generate`).
   - Confirm new generated types appear: `BFFGraphAPI.ProductDetailsQuery`, `ProductDetailsFragment`,
     and the `OmniProduct`/`ProductVariant`/`VariantOption` selection sets.
   - **NEVER hand-edit** `BFFGraph/API/` or `BFFGraph/Mocks/`.

### Verification
- `./Alfie/scripts/verify.sh` (build compiles with the new generated query — even before it is called).
- `git status` shows new `.graphql` files + regenerated `API/` files only (no unrelated churn).

### Estimated Effort
S
