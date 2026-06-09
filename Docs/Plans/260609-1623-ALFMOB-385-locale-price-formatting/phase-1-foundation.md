## Phase 1: Foundation — `CurrencyFormatter` util

### Goal
Add a stateless, locale-aware currency formatter to the `Model` module, with direct unit tests.

### Steps

1. **Create `CurrencyFormatter`** (file: `AlfieKit/Sources/Model/Formatting/CurrencyFormatter.swift` — new; create `Formatting/` dir)
   - What:
     ```swift
     import Foundation

     /// Locale-aware currency formatting. Stateless — single source of truth for price strings.
     public enum CurrencyFormatter {
         /// e.g. (Decimal(10.23), "GBP", en_GB) -> "£10.23"
         public static func string(amount: Decimal,
                                   currencyCode: String,
                                   locale: Locale = .current) -> String {
             amount.formatted(.currency(code: currencyCode).locale(locale))
         }

         /// ISO-4217 minor-unit exponent (GBP=2, JPY=0, KWD=3) used to scale major→minor units.
         public static func minorUnitDigits(for currencyCode: String) -> Int {
             let formatter = NumberFormatter()
             formatter.numberStyle = .currency
             formatter.currencyCode = currencyCode
             return formatter.maximumFractionDigits
         }
     }
     ```
   - Why: lowest layer (`Model`) so `Core` converter (now) + future UI helpers can reuse it without import cycle; no DI (pure value transform — `DependencyContainer` would be over-engineering per CLAUDE.md intent).
   - Note: `Model` already depends only on Foundation/Alicerce — no new SPM dependency needed.

2. **Add `ModelTests` test target** (file: `AlfieKit/Package.swift`)
   - What: add a `.testTarget(name: "ModelTests", dependencies: ["Model"], path: "Tests/ModelTests")` mirroring the existing `BFFGraphTests` testTarget block (~line 348). No new product/library entry needed for a test target.
   - Why: `Model` currently has no test target; `CurrencyFormatter` unit tests need a home. Editing `Package.swift` is allowed (only `Alfie.xcodeproj/project.pbxproj` is off-limits).
   - Verify: confirm naming convention against sibling test targets before adding.

3. **Add unit tests** (file: `AlfieKit/Tests/ModelTests/CurrencyFormatterTests.swift` — new)
   - What (XCTest, matching repo convention):
     - `minorUnitDigits`: GBP==2, USD==2, AUD==2, JPY==0, KWD==3, BHD==3.
     - `string` with **pinned `Locale(identifier: "en_GB")`**:
       - GBP `10.23` → contains `£`, 2 decimals → `"£10.23"`.
       - JPY `5000` → 0 decimals, no `.` → `"¥5,000"` (assert no decimal separator + grouping).
       - KWD `19.999` → 3 decimals.
       - USD under en_GB → assert 2 decimals + `$` present (avoid asserting exact `US$` vs `$`).
   - Why: AC3. Pinned locale = deterministic CI.

### Verification
- `./Alfie/scripts/verify.sh` → builds + `ModelTests` pass.
- Manual: none.

### Estimated Effort
S
