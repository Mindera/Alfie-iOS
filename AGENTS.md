# Alfie iOS - AI Agent Instructions

**Project**: Alfie iOS E-Commerce Application  
**Platform**: iOS 16+ | **Language**: Swift 5.9+ | **Architecture**: MVVM  
**Last Updated**: December 2024

This file provides quick context for AI coding assistants following the [AGENTS.md standard](https://agents.md/).  
📚 **For detailed implementation guidelines, see [`.github/copilot-instructions.md`](.github/copilot-instructions.md)**.

---

## 🚨 CRITICAL: Build Verification

**Every code change MUST be verified with a successful build.**

```bash
./Alfie/scripts/build-for-verification.sh
```

- ✅ Execute after making changes
- ✅ Wait for "BUILD SUCCEEDED" message  
- ✅ Fix errors and re-run until success
- ❌ Pre-build verification is NOT sufficient

---

## Project Overview

Alfie is a native iOS e-commerce app built with SwiftUI. Features include product browsing, search, wishlist, shopping bag, and user authentication. Data is fetched from a GraphQL BFF API.

---

## Architecture Summary

### MVVM Pattern

```
Feature/
├── FeatureView.swift              # SwiftUI View
├── FeatureViewModel.swift         # Business logic, @Published state
└── FeatureDependencyContainer.swift  # Filtered dependencies
```

- **State**: Use `ViewState<Value, Error>` or `PaginatedViewState<Value, Error>`
- **Navigation**: Always through `Coordinator` (never direct)
- **Dependencies**: Inject via `DependencyContainer` (never `ServiceProvider` directly)

### Module Structure (`Alfie/AlfieKit/`)

| Module | Purpose |
|--------|---------|
| **BFFGraphAPI** | Apollo-generated GraphQL types (auto-generated) |
| **Core** | Services layer (API, auth, analytics) |
| **Models** | Domain models and protocols |
| **StyleGuide** | Design system (colors, typography, components) |
| **SharedUI** | Localization resources |
| **Mocks** | Test mocks |

---

## Key Rules

### ✅ Always

- Create ViewModel protocols for mocking
- Use `L10n` for all user-facing strings
- Navigate through Coordinator
- Run build verification after code changes

### ❌ Never

- Access `ServiceProvider` from ViewModels
- Hardcode user-facing strings
- Edit auto-generated files (`BFFGraphAPI`, `L10n+Generated.swift`)
- Use `fatalError` (use `queuedFatalError`)
- Edit `project.pbxproj` directly

---

## Development Workflow

### 1. Spec-Driven Development

1. Write spec in `Docs/Specs/Features/<Feature>.md`
2. Break into small, independent tasks
3. Implement one task at a time

### 2. Feature Implementation

See [Feature Implementation Checklist](.github/copilot-instructions.md#feature-implementation-checklist) in copilot-instructions.md.

### 3. GraphQL Workflow

```bash
# After creating/updating .graphql files:
cd Alfie/scripts && ./run-apollo-codegen.sh
```

---

## Quick Commands

```bash
./Alfie/scripts/build-for-verification.sh    # Build (MANDATORY)
cd Alfie/scripts && ./run-apollo-codegen.sh  # GraphQL codegen
git secret reveal                             # Decrypt sensitive files
brew bundle install                           # Install dependencies
```

---

## Specialized Agents

All code-modifying agents **MUST execute build verification**.

| Agent | Responsibility | Build Required |
|-------|----------------|----------------|
| 🧑‍💻 ios-feature-developer | MVVM features, navigation | ✅ Yes |
| 🌐 graphql-specialist | Queries, fragments, converters | ✅ Yes |
| 🌍 localization-specialist | L10n.xcstrings entries | ✅ Yes |
| 🎨 ui-component-developer | StyleGuide components | ✅ Yes |
| 🐛 bug-fixer | Bug fixes, build issues | ✅ Yes |
| 🧪 testing-specialist | Unit tests, mocks | ❌ No |
| 📝 spec-writer | Feature specifications | ❌ No |
| 🔒 mobile-security-specialist | Security review | ⚠️ Recommended |

---

## Resources

- 📖 **Detailed Guide**: [`.github/copilot-instructions.md`](.github/copilot-instructions.md)
- 📋 **Spec Template**: [`Docs/Specs/TEMPLATE.md`](Docs/Specs/TEMPLATE.md)
- 🔗 **AGENTS.md Standard**: [https://agents.md/](https://agents.md/)

---

**Note**: This is a summary. See [copilot-instructions.md](.github/copilot-instructions.md) for complete details.
