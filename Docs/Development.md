# Feature Development Process

## Spec-Driven Approach ⭐

**ALWAYS follow a spec-driven development approach for new features:**

### Phase 1: Write the Spec First

Create a comprehensive spec document in `Docs/Specs/Features/<FeatureName>.md`.

**Spec Location**: `Docs/Specs/Features/` - This directory is automatically indexed by all AI tools and accessible to developers.

**Required Sections in Every Spec:**
- **Feature Overview** - High-level description and business goals
- **User Stories** - Who needs this and why
- **Acceptance Criteria** - Clear definition of "done"
- **Data Models** - Structures and relationships (Swift code blocks)
- **API Contracts** - GraphQL queries/mutations with expected response shapes
- **UI/UX Flows** - Screen transitions and user interactions
- **Navigation** - Entry points, exit points, Routes and FlowViewModel methods
- **Localization** - All user-facing strings with their keys
- **Analytics** - Events to track with parameters
- **Edge Cases** - Error scenarios, empty states, loading states
- **Dependencies** - Required services, APIs, other features
- **Testing Strategy** - What tests are needed and where

**See `Docs/Specs/TEMPLATE.md` for full example structure.**

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

**After implementation, EXECUTE the build command to verify - this is MANDATORY.**

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
9. ✅ **Create Feature Module** in `AlfieKit/Sources/<Feature>/`:
   - Create `<Feature>DependencyContainer.swift` in `Models/`
   - Create `<Feature>FlowDependencyContainer.swift` in `Models/`
   - Create `<Feature>ViewModelProtocol.swift` in `Protocols/`
   - Create `<Feature>FlowViewModelProtocol.swift` in `Protocols/`
   - Create `<Feature>Route.swift` in `Navigation/`
   - Create `<Feature>Route+Destination.swift` in `Navigation/`
   - Create `<Feature>FlowView.swift` in `Navigation/`
   - Create `<Feature>FlowViewModel.swift` in `Navigation/`
   - Create `<Feature>View.swift` in `UI/`
   - Create `<Feature>ViewModel.swift` in `UI/`
10. ✅ **Create Mock ViewModel** in `Mocks/Core/Features/Mock<Feature>ViewModel.swift`
11. ✅ **Add to Package.swift**: Add new target and product in `AlfieKit/Package.swift`
12. ✅ **Integrate with Navigation**: Add route to parent feature's Route enum
13. ✅ **Add Localization Strings** in `L10n.xcstrings` (all keys from spec)
14. ✅ **Verify** - Execute `./Alfie/scripts/verify.sh` (runs build + tests)
15. ✅ **Verify Against Spec** - Check all acceptance criteria met
16. ✅ **Update Spec Status** - Mark as "Implemented" with PR link and date

## 🏗️ Verification

**Every code change MUST be verified with build + tests.**

### Verify Command

```bash
# Recommended: Run full verification (build + tests)
./Alfie/scripts/verify.sh

# Build only (if you need to iterate on compilation)
./Alfie/scripts/build-for-verification.sh

# Tests only (after successful build)
./Alfie/scripts/test-for-verification.sh --skip-build
```

### Process

1. Execute `./Alfie/scripts/verify.sh` after completing implementation
2. Wait for "✅ FULL VERIFICATION PASSED" message
3. If build fails: fix errors, re-run
4. If tests fail: fix logic, re-run
5. Only mark task complete after full verification passes

**Why use the script?**
- Works on all developer machines (no hardcoded simulator IDs)
- Automatically finds available simulator
- Provides clear success/failure messages
- Saves build log for debugging

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
