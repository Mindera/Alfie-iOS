# GraphQL & BFF Integration

## Running the App Against a Local BFF

The local development loop for working against the BFF:

### 1. Start the BFF locally

The BFF team owns the canonical "run the BFF locally" docs. In short, from the
**Alfie-BFF** repo:

```bash
cd ../Alfie-BFF
npm install          # first time only
npm run start:dev    # watch mode
```

It listens on `http://localhost:3000` (`PORT` in the BFF's `.env`); the GraphQL
endpoint is `http://localhost:3000/graphql`.

### 2. Point the app at it

A **Debug** build already targets the local BFF — the default `dev` endpoint is
`http://localhost:3000/`, so just build and run.

To point the app at a different BFF (a remote host, a different port), use the in-app
**Debug Menu** endpoint selector (opened from the toolbar on the Home screen):

- Choose **Custom** and enter the URL.
- The choice is persisted in `UserDefaults` under the key
  `com.alfie.config.api.endpoint`.

The app reboots to apply the change.

### 3. Regenerate types when the schema changes

See [Syncing the BFF Schema](#syncing-the-bff-schema) below — run `./sync-bff-schema.sh`.

## Syncing the BFF Schema

The GraphQL schema is **owned by the BFF**, not hand-written in this repo. The BFF
generates `src/schema.gql`; the iOS repo keeps a committed copy at:

```
Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Schema/schema.graphqls
```

Apollo codegen uses that file as its schema input. Committing it keeps codegen and
builds **self-contained** — they never need a running BFF or the BFF repo present.

### Prerequisites

Clone the **Alfie-BFF** repo as a sibling of this repo:

```
Workspace/
├── Alfie-iOS/   ← this repo
└── Alfie-BFF/
```

If it lives elsewhere, set `ALFIE_BFF_PATH` to its location (see below).

### How to sync

```bash
cd Alfie/scripts
./sync-bff-schema.sh
```

The script:

1. In the Alfie-BFF repo: checks out `main` and pulls the latest — **read-only**, it
   never writes to or commits in the BFF repo.
2. Copies the BFF's `src/schema.gql` → `BFFGraph/CodeGen/Schema/schema.graphqls`.
3. Runs Apollo codegen (`run-apollo-codegen.sh`) to regenerate the typed Swift API
   under `BFFGraph/API/`.

If the BFF repo is not a sibling, point the script at it:

```bash
ALFIE_BFF_PATH=/path/to/Alfie-BFF ./sync-bff-schema.sh
```

### When to sync

Whenever the BFF schema changes and iOS needs the update. Run the script, then commit
the resulting changes to `schema.graphqls` and `BFFGraph/API/`.

### After syncing

- Review the diff in `schema.graphqls` to see what the BFF changed.
- Apollo codegen validates **every** committed `.graphql` operation against the schema.
  If a sync changes or removes something an existing operation relies on, **codegen
  fails** until that operation — and its converters/models — is updated to match.

## Adding a New Query

The schema is synced from the BFF (see above) — you query against whatever the BFF
already exposes. If you need a field or query the BFF doesn't have, that is a BFF-side
change; once it lands, re-sync the schema.

1. **Create query file**: `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Queries/<Feature>/Queries.graphql`
2. **Define fragments**: `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Queries/<Feature>/Fragments/<Model>Fragment.graphql`
3. **Generate code**: Run `cd Alfie/scripts && ./run-apollo-codegen.sh`
4. **Create local models**: Add domain models in `Alfie/AlfieKit/Sources/Model/Models/`
5. **Add converters**: Create `<Model>+Converter.swift` in `Alfie/AlfieKit/Sources/Core/Services/BFFService/Converters/`
6. **Update BFFClientService**: Add fetch method in `Alfie/AlfieKit/Sources/Core/Services/BFFService/BFFClientService.swift`

**Query Pattern**:
```graphql
query GetProduct($productId: ID!) {
    product(id: $productId) {
        ...ProductFragment
    }
}
```

**Fragment Pattern**:
```graphql
fragment ProductFragment on Product {
    id
    name
    brand {
        ...BrandFragment
    }
    priceRange {
        ...PriceRangeFragment
    }
}
```

**Converter Pattern**:
```swift
extension BFFGraphAPI.ProductFragment {
    func convertToProduct() -> Product {
        Product(
            id: id,
            name: name,
            brand: brand.fragments.brandFragment.convertToBrand(),
            priceRange: priceRange?.fragments.priceRangeFragment.convertToPriceRange()
        )
    }
}
```

## Updating Existing Queries

1. Update the `.graphql` file
2. Run `cd Alfie/scripts && ./run-apollo-codegen.sh`
3. Update converters and local models as needed
