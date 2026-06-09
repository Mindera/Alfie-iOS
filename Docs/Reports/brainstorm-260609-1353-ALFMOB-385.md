# Brainstorm: Locale-aware price formatting for BFF Money

**Ticket**: ALFMOB-385
**Date**: 2026-06-09
**Branch**: claude/amazing-euclid-5fef84

## Problem Statement
ALFMOB-331 migrated the PLP to the BFF `productList` query. The new BFF `Money` type returns
only `{ amount: Float, currencyCode: String }` — no pre-formatted `amountFormatted`. To keep the
`Money.amountFormatted` model contract, both BFF→domain converters currently format client-side with
`String(format: "%.2f %@", amount, currencyCode)`, rendering **"10.00 GBP"** instead of **"£10.00"**.
Visible on the PLP today. Also mis-scales minor units for non-2dp currencies (JPY 0dp, KWD/BHD 3dp),
though that is latent while the store is GBP-only.

## Constraints & Requirements
- Prices must render locale/currency-symbol aware (`£10.00`) — AC1.
- Correct minor-unit handling per currency (no hardcoded 2dp) — AC2.
- iOS floor 16.0 → `Double.formatted(.currency(code:))` (iOS 15+) fully available.
- Store is **GBP-only, no near-term multi-currency/multi-locale plan** (confirmed).
- Honor CLAUDE.md: no `fatalError`, L10n for user strings (N/A — formatter output), DI rules.

## Key Findings (from scout + direct read)
- Formatting is centralized at the **converter boundary**; UI already speaks formatted Strings via
  `PriceType` (`.default/.sale/.range`). UI components need **no change**.
- SharedUI already ships **unused** helpers `PriceType.formattedDefault/Sale/Range(... currencyCode:)`
  built on `Double.formatted(.currency(code:))` — proof the idiomatic API works here.
- Domain `Money.amount` (Int minor units) is used for arithmetic in exactly **one** place:
  `ProductDetails+Converter.swift:152` sale comparison (`compareAt.amount > amount.amount`).
  Scale-relative → the `*100` bug does **not** corrupt it.
- **Display correctness is independent of the Int-scaling bug** if we format from the source `Double`
  the converter already holds, not from the descaled Int.
- The converter comment ("proper formatter lives in a follow-up") confirms this ticket IS that follow-up.

## Approaches Evaluated

### Approach A — Format at the BFF converter boundary (keep `amountFormatted`)  ✅ CHOSEN
- Replace `String(format:)` in `ProductListing+Converter` and `ProductDetails+Converter` with a
  locale/currency formatter applied to the **source `Double`**.
- Extract a tiny reusable helper (e.g. `CurrencyFormatter.string(forAmount: Double, currencyCode:)`
  wrapping `amount.formatted(.currency(code:))`) so a future move to UI-layer formatting is trivial.
- Optionally fix the Int minor-unit scaling to derive fraction digits from the currency (completeness for AC2).
- **Touches:** 2 converters, 1 new small helper, 2 converter test files, price fixtures.
- **Pros:** Minimal, low-risk; auto-handles JPY/KWD via `.currency`; UI/persistence/model-extensions untouched.
- **Cons:** Presentation string remains stored in domain + persisted → frozen-at-fetch locale. Latent only while GBP-only. Doesn't resolve architectural concern #3.
- **Effort:** S · **Risk:** LOW

### Approach B — UI-layer formatting, drop stored `amountFormatted`
- `Money` carries only `amount` + `currencyCode`; format at render time via existing `PriceType.formatted*`
  helpers wired into `Product+Extension` / `SelectedProduct+Extension`; drop field from `Money` +
  `PersistedMoneyDTO`; reformat on rehydration.
- **Touches:** Money model, 2 model extensions, PDP share text, PLP skeleton placeholder,
  PersistedProductDTO, ~3 fixtures/mocks, ~5 test files.
- **Pros:** Clean separation; single source of truth; always-current locale; reuses existing helpers;
  decode-safe persistence change.
- **Cons:** ~6 consumers + persistence + broad test/fixture churn for value that is latent until
  multi-currency/multi-locale ships. Fails YAGNI today.
- **Effort:** M · **Risk:** MED

## Recommendation
**Chosen: Approach A** (format from source `Double`; extract a small reusable currency-formatting helper;
fix per-currency minor-unit scaling).

**Rationale:** GBP-only with no near-term multi-currency/locale plan makes B's only real *correctness*
edge (live-locale rehydration) moot today → B's persistence + 6-consumer + test churn fails YAGNI.
B's helpers already exist, so deferring it is cheap. A ships the visible fix (`£10.00`) with a near-zero
regression surface. Extracting the formatter as a shared helper seeds the eventual B migration.

### Decimal vs Double / Int (decided after /alfie-sequential-thinking)

**Domain `Money.amount` stays `Int` minor units. `Decimal` is used as a transient conversion vehicle
inside the converter — NOT as the domain type (no retype).**

Reasoning (corrects the earlier "Decimal is theater" framing):
- `Decimal(Double)` *naively* preserves binary-float noise, but `Decimal(string: double.description)` /
  rounding-on-convert does **not** — it yields the clean decimal and fixes the half-cent rounding edge.
  So the conversion **path** matters; Decimal has a legitimate role.
- **The `Int` and the displayed value are decoupled, serving different purposes:**
  - `amount: Int` (minor units, e.g. `1023` for £10.23) — used ONLY by the sale comparison
    (`ProductDetails+Converter.swift:152`, exact integer compare) and persistence
    (`PersistedProductDTO`). **Never touches the UI.** Convention documented at `Price.swift:30`;
    encoded major→minor at `ProductListing+Converter.swift:73`. No code ever decodes minor→major.
  - `amountFormatted: String` — what the UI renders, built from the **major-unit source value**.
- **Display path is `Float → Decimal → String` directly** (`decimal.formatted(.currency(code:))`) —
  the `Int` is a parallel derived sibling, never an intermediate. So a £10.23 price never renders "£10.00".
- Retyping `amount` `Int → Decimal` was considered and **rejected for this ticket**: it's a model +
  persistence-schema change (old persisted minor-unit `1023` would re-read as major `£1023.00` → needs a
  migration/version bump) plus fixture/test churn — Approach-B-sized, and premature before the BFF
  contract is confirmed.

**Conversion path to implement (Approach A):**
```
BFF Double → Decimal (clean, via Decimal(string: amount.description))
   ├─ amountFormatted: decimal.formatted(.currency(code: currencyCode))      // locale + symbol + auto fraction digits
   └─ amount (Int):    Decimal × 10^(ISO-4217 exponent for currency), rounded // fixes hardcoded ×100 (problem #2)
```

**BFF contract (CONFIRMED — stays `Float`):** `Money.amount` is GraphQL `Float` → Swift `Double`,
**major units** (e.g. `10.23`); `MoneyFragment.graphql.swift:18,22`. The BFF team confirmed the contract
will **not** change. Therefore:
- The client owns the Float→Decimal cleanup and the minor-unit `Int` derivation — both stay.
- The lossy `Float` risk is accepted at the BFF boundary; client mitigates via `Decimal(string:)` cleanup.
- **No domain retype to `Decimal`** — `Int` minor units is the final client model. Decision is now
  unconditional (was previously parked on the BFF reply).

## Implementation Considerations
- **New helper — `CurrencyFormatter` in the `Model` module** (decided): `Model/Formatting/CurrencyFormatter.swift`.
  Stateless `enum` namespace, Foundation-only, **no DI** (deterministic value transform — `DependencyContainer`
  would be over-engineering). API:
  - `static func string(amount: Decimal, currencyCode: String, locale: Locale = .current) -> String`
    via `amount.formatted(.currency(code:).locale(locale))` — `locale` param defaulted, pinned in tests.
  - `static func minorUnitDigits(for currencyCode: String) -> Int` — ISO-4217 exponent via `NumberFormatter`.
  - **Why `Model`:** lowest layer in `SharedUI → Core → Model`, so the `Core` converter (now) and the
    `Model`/`SharedUI` render-time helpers (future Approach B) can all reach it without an import cycle
    (`Core` cannot import `SharedUI`). Single source of truth.
  - **DRY follow-up (optional):** refactor the existing unused `SharedUI` `PriceType.formatted*` helpers to
    delegate to `CurrencyFormatter` so there's one formatting code path.
- **Converters:** `ProductListing+Converter.toDomainMoney()` and `ProductDetails+Converter` convert the
  BFF Double to a clean `Decimal` once, then (a) format `amountFormatted` from it via the helper, and
  (b) compute `amount: Int` minor units as `Decimal × 10^(currency exponent)` rounded — fixing the
  hardcoded `×100` (problem #2). **Keep `amount` as `Int` minor units (decided).**
- **ViewState / DI / FlowViewModel:** no change.
- **BFF / Apollo:** no schema change.
- **L10n / AccessibilityID:** none (formatter output is not a catalog string; no new UI surface).
- **Feature flag:** not needed.
- **Migration / rollback:** pure formatting change; revert = revert the converter diff. Persisted bag/wishlist
  unaffected (still stores its own `amountFormatted`; new fetches format correctly).
- **Testing:** unit tests on the helper + converters asserting symbol/grouping per currency (£/$/¥) and
  correct fraction digits for 0dp (JPY) and 3dp (KWD/BHD). Update existing converter tests asserting
  "10.00 GBP" → "£10.00", and price fixtures.

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| `.formatted(.currency)` symbol/separators vary by device locale in snapshot/unit tests | MED | Pin a fixed `Locale` in the formatter or in tests for determinism |
| Stored/persisted `amountFormatted` goes stale on locale change | LOW (GBP-only) | Accepted now; revisit with Approach B when multi-locale ships |
| Int minor-unit scaling still wrong if later used for arithmetic | LOW | Fix scale derivation in this ticket; flag BFF for non-Float contract |

## Success Metrics
- PLP/PDP/cards render `£10.00` (symbol, grouping) instead of `10.00 GBP`.
- Unit tests pass asserting per-currency symbol + fraction digits (incl. JPY 0dp, KWD 3dp).
- `./Alfie/scripts/verify.sh` → FULL VERIFICATION PASSED.

## Out of Scope
- Moving formatting to a UI-layer `PriceFormatter` / dropping stored `amountFormatted` (Approach B).
- PLP BFF wiring (ALFMOB-331, done).
- Changing the BFF `Money` contract.

## Open Questions
- ~~**BE:** will `Money.amount` change type?~~ **RESOLVED — BFF confirmed it stays `Float`.** Client keeps
  the Float→Decimal cleanup + `Int` minor-unit derivation; no domain retype. Accept the `Float` boundary risk.
- ~~**PM:** multi-currency/multi-locale roadmap?~~ **RESOLVED — no near-term plan.**
- ~~Where should the shared currency helper live?~~ **RESOLVED — `Model` module** (`CurrencyFormatter`,
  stateless enum, no DI).
- ISO-4217 exponent source: `NumberFormatter`-derived (`minorUnitDigits(for:)`) — confirm no edge currencies
  need a manual override in /alfie-plan.
