# Accessibility Identifiers

Single source of truth for accessibility identifiers used by the app and consumed by `AlfieUITests` (XCUITest). The goal is stable, hierarchical identifiers that survive copy/localisation changes and let UI tests locate elements reliably.

---

## Convention

Format: **`screen.component[.subcomponent].type`**

Examples:

```
productListing.filter.button
productListing.results.label
productListing.row.{id}.image
productDetails.addToCart.button
checkout.shipping.textField
```

Rules:

- Lowercase, dot-separated. No kebab-case, no abbreviations (`btn`, `lbl`).
- The leading segment matches the screen / feature module.
- The trailing segment is the control type (`button`, `label`, `textField`, `image`, `stepper`, `segmentedControl`, etc.).
- Dynamic segments use stable model IDs — **never array indexes**.

## Where identifiers live

All identifiers are declared in the `AccessibilityIdentifiers` SPM module:

- Module: `Alfie/AlfieKit/Sources/AccessibilityIdentifiers/`
- Public namespace: `AccessibilityID`
- One nested enum per screen/feature

```swift
public enum AccessibilityID {
    public enum ProductListing {
        public static let filterButton = "productListing.filter.button"
        public static let resultsLabel = "productListing.results.label"

        public static func row(id: String) -> String {
            "productListing.row.\(id)"
        }
    }
}
```

Static constants for fixed elements; pure functions for dynamic ones.

## Applying in SwiftUI

```swift
import AccessibilityIdentifiers

Button { filterAction() } label: { … }
    .accessibilityIdentifier(AccessibilityID.ProductListing.filterButton)

Text(L10n.Plp.NumberOfResults.message(total))
    .accessibilityIdentifier(AccessibilityID.ProductListing.resultsLabel)
```

Apply the modifier to the **outermost relevant view** (e.g. directly on the `Button`, not on the inner `Label`).

## Gotchas

- **`accessibilityLabel` ≠ `accessibilityIdentifier`.** Labels are localised and read by VoiceOver. Identifiers are stable, unlocalised, and used by tests. Always use `accessibilityIdentifier` for test locators.
- **`.accessibilityElement(children: .combine)` hides child identifiers.** If you need both a parent identifier and child identifiers, do not combine — leave children as separate elements.
- **List rows can shadow inner controls.** When putting interactive elements inside a `NavigationLink` row, give each interactive element its own scoped identifier (e.g. `productListing.row.{id}.favorite.button`).
- **Dynamic identifiers must use stable model IDs.** `forEach { i, item in id_\(i) }` breaks when ordering changes; use `\(item.id)` instead.
- **Composite custom views.** Apply the identifier where the user interacts (the `Button`, the `TextField`), not on a wrapping `VStack`.

## Consuming from UI tests

The `AlfieUITests` target uses the Page Object pattern. Each screen has a page object under `Alfie/AlfieUITests/Pages/` that wraps `XCUIApplication` queries by `AccessibilityID.*`:

```swift
import XCTest
import AccessibilityIdentifiers

final class ProductListingPage {
    private let app: XCUIApplication
    init(app: XCUIApplication) { self.app = app }

    var filterButton: XCUIElement {
        app.buttons[AccessibilityID.ProductListing.filterButton]
    }

    @discardableResult
    func tapFilter() -> Self { filterButton.tap(); return self }
}
```

### One-time Xcode setup for the UITest target

The `AlfieUITests` target must link the `AccessibilityIdentifiers` package product so tests can reference `AccessibilityID.*` directly:

1. Open `Alfie.xcodeproj` in Xcode.
2. Select the `AlfieUITests` target → **General** → **Frameworks and Libraries**.
3. Click `+` → choose `AccessibilityIdentifiers` from the `AlfieKit` package.
4. Build.

Until that link exists, page objects under `Alfie/AlfieUITests/Pages/` use string literals that mirror the `AccessibilityID` values. Once linked, swap the literals for `AccessibilityID.*` references.

## Migration

The pilot migration covers `ProductListing`. The remaining ~16 files using file-local `private enum AccessibilityId` will be migrated incrementally:

```bash
# Find remaining call sites
grep -rn "private enum AccessibilityId" Alfie/AlfieKit/Sources
```

For each file:

1. Add a new namespace under `AccessibilityID` (e.g. `AccessibilityID.MyAccount`).
2. Add `import AccessibilityIdentifiers` to the view file.
3. Add `"AccessibilityIdentifiers"` to the target's dependency list in `Alfie/AlfieKit/Package.swift`.
4. Replace `AccessibilityId.foo` references with `AccessibilityID.<Screen>.foo`.
5. Delete the local `private enum AccessibilityId`.
6. Run `./Alfie/scripts/verify.sh`.

## Verification

- **Build + unit tests:** `./Alfie/scripts/verify.sh`
- **Identifier propagation:** Run on a simulator → Xcode → Open Developer Tool → Accessibility Inspector → hover the element → confirm the identifier matches.
- **UI tests:** `xcodebuild test -scheme Alfie -only-testing:AlfieUITests/ProductListingUITests` (after Xcode linkage above).
