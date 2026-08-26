# Feature Development Process

## Spec-Driven Approach

### Phase 1: Write the Spec First

Create a comprehensive spec document in `Docs/Specs/Features/<FeatureName>.md`.

`Docs/Specs/TEMPLATE.md` defines the required sections — its headings are the checklist.

### Phase 2: Break Down Into Tasks

After the spec is complete:

1. **Extract Small Tasks** - Break the spec into the smallest possible, independent tasks
2. **Create Task List** - Each task should be completable in a short session
   - Example: "Add ProductListingQuery GraphQL query"
   - Example: "Implement ProductFragment converter"
   - Example: "Create ProductListingViewModel"

### Phase 3: Implement Feature (One Task at a Time)

Tackle tasks **one by one**, following the implementation checklist below.

**Always refer back to the spec** for requirements. If requirements change during implementation, **update the spec first**, then update code.

## Feature Implementation Checklist

Use this checklist for systematic feature implementation:

1. ✅ **Create Spec Document** in `Docs/Specs/Features/<Feature>.md`
2. ✅ **Define Domain Models** in `Alfie/AlfieKit/Sources/Model/Models/<Feature>/`
3. ✅ **Create Service Protocol** in `Alfie/AlfieKit/Sources/Model/Services/<Feature>/`
4. ✅ **Add GraphQL Query** (if API needed):
   - Create `Queries.graphql` in `AlfieKit/Sources/BFFGraph/CodeGen/Queries/<Feature>/`
   - Create fragments in `Fragments/` subdirectory
   - Extend schema in `CodeGen/Schema/schema-<feature>.graphqls`
5. ✅ **Run Apollo Codegen**: `cd Alfie/scripts && ./run-apollo-codegen.sh`
6. ✅ **Create Converters** in `Core/Services/BFFService/Converters/<Feature>+Converter.swift`
7. ✅ **Implement Service** in `Core/Services/<Feature>/`
8. ✅ **Register Service** in `Alfie/Alfie/Service/ServiceProvider.swift`
9. ✅ **Create Feature Module** in `AlfieKit/Sources/<Feature>/` — the full file skeleton is in
   [Architecture.md](Architecture.md#feature-module-structure)
10. ✅ **Create Mock ViewModel** in `Mocks/Core/Features/Mock<Feature>ViewModel.swift`
11. ✅ **Add to Package.swift**: Add new target and product in `AlfieKit/Package.swift`
12. ✅ **Integrate with Navigation**: Add route to parent feature's Route enum
13. ✅ **Add Localization Strings** in `L10n.xcstrings` (all keys from spec)
14. ✅ **Verify** - Execute `./Alfie/scripts/verify.sh` (build + unit + integration; add `--skip-integration` for the fast unit-only run when no local BFF is available)
15. ✅ **Verify Against Spec** - Check all acceptance criteria met
16. ✅ **Update Spec Status** - Mark as "Implemented" with PR link and date

## 🏗️ Verification

`AGENTS.md` §Verification is authoritative for what `verify.sh` runs and which success string to
wait for. The scripts below are for iterating mid-implementation:

```bash
# Build only (iterate on compilation)
./Alfie/scripts/build-for-verification.sh

# Tests only (after a successful build)
./Alfie/scripts/test-for-verification.sh --skip-build
```

Finish on a full `./Alfie/scripts/verify.sh` regardless — the partial scripts don't gate a task as
complete.

**Why the script rather than raw `xcodebuild`?** No hardcoded simulator IDs, finds an available
simulator, clear pass/fail messages, and saves a build log for debugging.

### Common Build Errors

| Error | Fix |
|-------|-----|
| Missing imports | Add `import Model`, `import SharedUI`, `import Core`, etc. |
| Unresolved symbols | Check L10n key typos, missing enum cases |
| Type mismatches | Verify protocol conformance |
| Missing files | Notify user to add files to Xcode project |

## 🚫 Xcode Project File Management

**CRITICAL**: Never edit `Alfie.xcodeproj/project.pbxproj` directly.

### Files Requiring Xcode Integration

When creating new `.swift` files in `Alfie/Alfie/` (app target), notify the user:

```
⚠️ ACTION REQUIRED: Please add this file to the Xcode project:
1. Open Alfie.xcodeproj in Xcode
2. Right-click the appropriate folder
3. Select "Add Files to Alfie..."
4. Select the file and ensure "Alfie" target is checked
5. Run: ./Alfie/scripts/verify.sh
```

### Files Auto-Discovered (No Action Needed)

- Files in `AlfieKit/Sources/` and `AlfieKit/Tests/` (Swift Package - auto-discovered)
- GraphQL `.graphql` files
- Documentation and scripts

**Note**: Most new feature code goes in AlfieKit modules and is auto-discovered.
