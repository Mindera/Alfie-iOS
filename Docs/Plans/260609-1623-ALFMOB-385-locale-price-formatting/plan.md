---
title: Locale-aware price formatting for BFF Money
ticket: ALFMOB-385
status: completed
mode: auto
blockedBy: []
blocks: []
created: 2026-06-09
---

## Overview
BFF `Money` returns `{ amount: Float, currencyCode: String }` (no `amountFormatted`). The client converters
currently format with `String(format: "%.2f %@", amount, currencyCode)` → renders **"10.00 GBP"** instead of
**"£10.00"**, and scale to minor units with a hardcoded `*100` (wrong for JPY 0dp / KWD 3dp). Introduce a
locale-aware `CurrencyFormatter` in the `Model` module and route both BFF→Domain converters through it.
Design decided in [brainstorm report](../../Reports/brainstorm-260609-1353-ALFMOB-385.md).

## Acceptance Criteria
- **AC1** — prices render locale/currency-symbol aware (`£10.00`, not `10.00 GBP`).
- **AC2** — correct minor-unit scaling per currency (no hardcoded 2dp): JPY ×1 (0dp), GBP/USD/AUD ×100 (2dp), KWD/BHD ×1000 (3dp).
- **AC3** — unit tests assert symbol/grouping per currency + correct minor-unit `Int` scaling, with a pinned `Locale`.

## Approach
**Approach A** (chosen — see brainstorm). Format once at the BFF→Domain boundary; keep storing `amountFormatted`
on `Money`; UI/persistence/model-extensions untouched (they read the stored string). Domain `Money.amount`
**stays `Int` minor units** (BFF confirmed `Float`, no domain retype). `Decimal` is the transient conversion
vehicle: parse `Float → Decimal` once, then derive both the formatted `String` and the scaled `Int` from it.

Conversion path in `toDomainMoney()`:
```
BFF Double 10.23
  → Decimal (Decimal(string: String(amount)) ?? Decimal(amount))   // clean, avoids binary noise
      ├─ amountFormatted: CurrencyFormatter.string(amount: decimal, currencyCode:)   // "£10.23"
      └─ amount (Int):    NSDecimalNumber(decimal: decimal * pow(10, digits)).intValue  // digits = ISO-4217 exponent
```

## Phases
1. **Foundation** — `CurrencyFormatter` in `Model` + `ModelTests` target + unit tests.
2. **Converters** — route both `toDomainMoney()` sites through `CurrencyFormatter`; fix scaling.
3. **Tests & fixtures** — flip stale `"x.xx GBP"` assertions to `"£x.xx"`, update fixtures, add per-currency cases; optional SharedUI DRY.

## File Changes (Summary Table)
| File | Module | Type | Change |
|------|--------|------|--------|
| `AlfieKit/Sources/Model/Formatting/CurrencyFormatter.swift` | Model | New | Stateless formatter util |
| `AlfieKit/Package.swift` | — | Build | Add `ModelTests` test target |
| `AlfieKit/Tests/ModelTests/CurrencyFormatterTests.swift` | Tests | New | Unit tests (per-currency, pinned locale) |
| `AlfieKit/Sources/Core/Services/BFFService/Converters/ProductListing+Converter.swift` | Core | Converter | `toDomainMoney()` → Decimal path + CurrencyFormatter |
| `AlfieKit/Sources/Core/Services/BFFService/Converters/ProductDetails+Converter.swift` | Core | Converter | Same (shares `MoneyFragment.toDomainMoney()`) |
| `AlfieKit/Tests/BFFGraphTests/ProductDetailsConverterTests.swift` | Tests | Unit | Flip `"50.00 GBP"`→`"£50.00"`; add JPY/KWD cases |
| `AlfieKit/Tests/BFFGraphTests/ProductListingConverterTests.swift` | Tests | Unit | Add formatted-string + scaling assertions |
| `AlfieKit/Sources/Mocks/Fixtures/Base/Price+Fixture.swift` | Mocks | Fixture | Make default `amountFormatted` consistent with `amount`/code |
| `AlfieKit/Sources/SharedUI/.../PriceComponentView.swift` (optional) | SharedUI | DRY | Delegate `PriceType.formatted*` to `CurrencyFormatter` |

> Note: `toDomainMoney()` is defined **once** on `BFFGraphAPI.MoneyFragment` (in `ProductListing+Converter.swift:68-80`)
> and called from both converters — so the core change is a single function. Verify there isn't a second definition.

## Feature Flag
- n/a — display-correctness fix, no rollout gating. (No multi-currency on roadmap; GBP-only today.)

## Testing Strategy
- **Unit (`ModelTests`)** — `CurrencyFormatter.string` per currency with **pinned `Locale(identifier: "en_GB")`**:
  GBP→`£`, USD→`US$`/`$` (assert by pinned locale), JPY→0 decimals, KWD→3 decimals. `minorUnitDigits`: GBP=2, JPY=0, KWD=3, USD=2.
  Assert fraction-digit *count* + symbol-presence (avoid brittle exact-symbol asserts where locale-variant).
- **Unit (`BFFGraphTests`)** — converter integration: `19.99 GBP` → `amount==1999`, `amountFormatted=="£19.99"`;
  JPY `5000` → `amount==5000` (×1), `"¥5,000"`; KWD `19.999` → `amount==19999` (×1000).
- **Existing** — `ProductListingConverterTests` `.amount` assertions (2500/1000/5000 for AUD 2dp) **stay valid**;
  `ProductDetailsConverterTests:212-213` strings **must flip** to `£`.
- No snapshot/XCUITest changes (no new UI surface; `PriceComponentView` unchanged).
- `./Alfie/scripts/verify.sh` must end with **✅ FULL VERIFICATION PASSED**.

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| `.formatted(.currency)` output varies by device locale → flaky tests | HIGH | Pin `Locale` in all formatter tests; assert digit-count/symbol-presence not full string where variant |
| `Decimal(string: String(Double))` edge (sci-notation / huge values) | LOW | Retail magnitudes only; fallback `Decimal(amount)`; covered by tests |
| Existing fixtures hardcode mismatched `amountFormatted` (e.g. `"$1.23"` w/ AUD) → new converter tests vs old fixtures diverge | MED | Fixtures are static test data, not converter output — only update where a test asserts converter behavior |
| Second/hidden `toDomainMoney` definition missed | LOW | grep confirms single definition; verify in Phase 2 |
| Persisted `amountFormatted` frozen at fetch (stale on locale change) | LOW (GBP-only) | Accepted tradeoff (brainstorm); revisit with Approach B if multi-locale ships |

## Out of Scope
- Approach B (UI-layer `PriceFormatter`, dropping stored `amountFormatted`) — deferred.
- Domain retype `Money.amount` `Int → Decimal` — rejected (BFF stays `Float`).
- BFF `Money` contract change — BE-owned; `Float` confirmed to stay.
- PLP skeleton placeholder string (`"$000,00"`) — cosmetic loading state, leave as-is.

## Open Questions
- Any edge currency where `NumberFormatter.maximumFractionDigits` ≠ true ISO-4217 minor unit? (verify in Phase 1; add manual override only if found — YAGNI otherwise)
- Confirm `ModelTests` target naming/convention matches sibling test targets in `Package.swift`.
