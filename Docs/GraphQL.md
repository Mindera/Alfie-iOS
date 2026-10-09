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

## Running on a Physical iPhone Against the Mac's BFF

On a device, `localhost` is the phone. The phone reaches the Mac's BFF over Wi-Fi through a
forwarding proxy on port **8090**:

```
iPhone ──Wi-Fi──▶ Mac <wifi-ip>:8090 (bff-device-proxy.py) ──▶ 127.0.0.1:3000 (BFF)
```

1. Start the BFF on the Mac (port 3000, see above).
2. Start the proxy with **Apple's** Python and leave it running; it prints one line per request:
   ```bash
   /usr/bin/python3 Alfie/scripts/bff-device-proxy.py        # [listen-port] [upstream]
   ```
3. Read the Mac's Wi-Fi address: `ipconfig getifaddr en0`. It is DHCP, so re-read it each
   session — a stale address shows up as `URLError -1001` (timeout).
4. iPhone on the same Wi-Fi. Debug Menu → **Custom** → `http://<wifi-ip>:8090/` → Save.
5. Allow the **Local Network** prompt on the phone.

Done when the launch log shows `BFF probe ✅ connected: HTTP 200` (`BFFConnectivityProbe`, Debug
builds) and the proxy prints `HIT <phone-ip> POST /graphql` followed by `-> 200`.

### Why the proxy

A BFF started by an agent or background session (Claude Code, a CI-style runner) answers the Mac
itself but not other devices: the phone completes the TCP handshake with `<wifi-ip>:3000`, sends
its request, and is reset. The probe reports `URLError -1005`. The cause is attributed to macOS
Local Network privacy acting on that `node` process; `/usr/bin/python3` is Apple-signed and is let
through. Seen in September and October 2026.

A BFF started from your own Terminal, with the Mac's Local Network prompt allowed, is expected to
serve `http://<wifi-ip>:3000/` directly, with no proxy.

### Reading a failed probe

| Probe says | Meaning |
|---|---|
| `-1004` could not connect | Nothing listens on that port — start the proxy |
| `-1005` connection lost | Reached `:3000` directly and was reset — use the proxy port |
| `-1001` timed out | Wrong IP, or phone on another Wi-Fi |
| `-1009`, path `Local network prohibited` | Local Network denied on the phone — Settings → Alfie |
| `-1022` | ATS exception missing from `Info.plist` (`NSAllowsLocalNetworking`) |

`curl` from the Mac to its own Wi-Fi address succeeds in every one of these cases, so it proves
only that the BFF is up. The Mac's firewall and endpoint-security software (ESET, Cortex XDR) were
investigated twice and are not involved.

`GET /config/webviews` answering 404 is the BFF build lacking that route, not a connection fault.

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

1. In the Alfie-BFF repo: checks out `main` and pulls the latest. The script does change
   the BFF repo's checked-out branch and HEAD, but **never commits or pushes** to it.
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
