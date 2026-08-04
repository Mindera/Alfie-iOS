# Alfie iOS - AI Agent System

This file follows the [AGENTS.md standard](https://agents.md/) and contains essential project context for AI coding assistants.

---

## AI Agents

Alfie uses specialized AI agents for different development tasks. All agents are defined in `.ai/agents/` using standard markdown with YAML frontmatter, making them compatible with any AI coding assistant.

### Available Agents

| Agent | Purpose | File |
|-------|---------|------|
| `feature-orchestrator` | Coordinate full feature development lifecycle | `.ai/agents/feature-orchestrator.agent.md` |
| `spec-writer` | Create comprehensive feature specifications | `.ai/agents/spec-writer.agent.md` |
| `graphql-specialist` | GraphQL queries, mutations, and Apollo codegen | `.ai/agents/graphql-specialist.agent.md` |
| `feature-developer` | MVVM iOS feature implementation | `.ai/agents/feature-developer.agent.md` |
| `localization-specialist` | L10n string catalog management | `.ai/agents/localization-specialist.agent.md` |
| `testing-specialist` | Unit tests, snapshot tests, and test coverage | `.ai/agents/testing-specialist.agent.md` |
| `security-specialist` | Security audits and vulnerability identification | `.ai/agents/security-specialist.agent.md` |

### Usage

AI tools should read the agent definition from `.ai/agents/<agent-name>.agent.md` and follow the instructions within.

**Example:**
```
Acting as the feature-developer agent (see .ai/agents/feature-developer.agent.md),
implement the Product Details feature following the spec in Docs/Specs/Features/ProductDetails.md
```

---

## Project Essentials

**Alfie** is a native iOS e-commerce application built with:
- **SwiftUI** (iOS 16+)
- **MVVM Architecture** with Flow-based navigation
- **Swift Package Manager** modular structure (`AlfieKit/`)
- **GraphQL BFF API** (Apollo iOS client)

### Core Technologies
- Swift 5.9+
- SwiftUI with `@StateObject` and `@Published`
- Combine for reactive programming
- Apollo iOS for GraphQL
- Firebase (Analytics, Crashlytics, Remote Config)

---

## Critical Rules

### ✅ ALWAYS

- Use `ViewState<Value, Error>` or `PaginatedViewState<Value, Error>` enums for state
- Inject dependencies via `DependencyContainer` (never access `ServiceProvider` from ViewModels)
- Use `L10n` for all user-facing strings (from `L10n.xcstrings`)
- Define protocols for all ViewModels (for mockability)
- Pass navigation closures from `FlowViewModel` to `ViewModel`
- Use `AccessibilityID` from the `AccessibilityIdentifiers` module for every UI test identifier — never hardcode strings (see `Docs/Accessibility.md`)
- Run `./Alfie/scripts/verify.sh` after every code change (build + unit + integration). Add `--skip-integration` for the fast, server-free unit-only run when the local BFF/Node isn't available

### ❌ NEVER

- Access `ServiceProvider` directly from ViewModels
- Hardcode user-facing strings
- Bypass `FlowViewModel` for navigation
- Edit auto-generated files (`L10n+Generated.swift`, `BFFGraph/API/`, `BFFGraph/Mocks/`, `SharedUI/GeneratedTokens/`)
- Use `fatalError` (use `queuedFatalError` instead)
- Edit `Alfie.xcodeproj/project.pbxproj` directly
- Skip build verification
- Commit sensitive files unencrypted

---

## Verification (MANDATORY)

**Every code change MUST be verified:**

```bash
./Alfie/scripts/verify.sh                     # build + unit + integration (boots a local BFF)
./Alfie/scripts/verify.sh --skip-integration  # build + unit only (fast, no BFF/Node needed)
```

By default this runs build + unit tests (mocked BFF) + integration tests against a real local BFF
(see `run-integration-tests.sh`, needs Node + the `Alfie-BFF` repo). Use `--skip-integration` for
the fast unit-only loop. Only mark work complete after **"✅ FULL VERIFICATION PASSED"** (or
**"✅ VERIFICATION PASSED (... integration skipped)"** when skipped).

---

## Detailed Documentation

When you need specific guidance, read the appropriate guide:

- **Architecture & MVVM** → `Docs/Architecture.md`
- **GraphQL Integration** → `Docs/GraphQL.md`
- **Localization (L10n)** → `Docs/Localization.md`
- **Testing & Mocking** → `Docs/Testing.md`
- **Snapshot Testing** → `Docs/SnapshotTesting.md`
- **Accessibility Identifiers (UI tests)** → `Docs/Accessibility.md`
- **Feature Development Process** → `Docs/Development.md`
- **Code Style & Conventions** → `Docs/CodeStyle.md`
- **Quick Reference (dirs, commands, deps)** → `Docs/QuickReference.md`
- **Feature Spec Template** → `Docs/Specs/TEMPLATE.md`

---

## How to Use This Documentation

### For Developers

**Quick start:**
1. Read this file (AGENTS.md) for core rules
2. Consult specific guides in `Docs/` as needed
3. Use `Docs/QuickReference.md` for commands and directory structure

**Common scenarios:**
- **New to project?** Start with `Docs/Architecture.md`
- **Implementing feature?** Follow `Docs/Development.md`
- **Adding GraphQL?** See `Docs/GraphQL.md`
- **Need quick lookup?** Use `Docs/QuickReference.md`

### For AI Agents

AI agents automatically read AGENTS.md and load detailed guides on-demand based on task context.

**Agent workflow:**
1. Load AGENTS.md (core rules)
2. Identify task type
3. Load relevant guide (e.g., GraphQL.md for API work)
4. Execute task following guidelines

---

**This minimal document provides core context. Read detailed guides only when needed for specific tasks.**
