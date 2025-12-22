# Feature Specifications

This directory contains detailed specifications for all features in the Alfie iOS application.

## Purpose

Feature specs serve as:
- **Single source of truth** for requirements
- **Context for AI assistants** (GitHub Copilot, Cursor, etc.)
- **Documentation** for developers
- **Reference during code reviews**

## Spec-Driven Development Process

1. **Write Spec First** - Before any code, create a comprehensive spec
2. **Break Into Tasks** - Extract small, independent tasks from the spec
3. **Implement One Task at a Time** - Follow the implementation checklist
4. **Update Spec if Requirements Change** - Keep specs in sync with reality

## How to Write a Spec

Use `TEMPLATE.md` as your starting point. Every spec should include:

### Required Sections

- ✅ **Feature Overview** - What is this feature and why does it exist?
- ✅ **User Stories** - Who needs this and what value does it provide?
- ✅ **Acceptance Criteria** - What must be true for this to be "done"?
- ✅ **Data Models** - Swift structs/classes with all properties
- ✅ **API Contracts** - GraphQL queries with expected response shapes
- ✅ **UI/UX Flows** - Step-by-step user interactions
- ✅ **Navigation** - Entry/exit points and Coordinator methods
- ✅ **Localization** - All user-facing strings with their L10n keys
- ✅ **Analytics** - Events to track with parameters
- ✅ **Edge Cases** - Errors, empty states, loading states
- ✅ **Dependencies** - What services, features, or APIs are needed?
- ✅ **Testing Strategy** - What tests to write and where

### Optional Sections

- 🔹 **Design Mockups** - Link to Figma/design files
- 🔹 **Performance Considerations** - Any specific performance requirements
- 🔹 **Accessibility** - VoiceOver labels, dynamic type support
- 🔹 **Known Limitations** - What is explicitly out of scope

## Spec Lifecycle

### Status Tags

Use these status markers in your spec:

```markdown
**Status**: Draft | In Review | Approved | In Progress | Implemented | Deprecated
```

### When to Update

- **During Review** - Incorporate feedback before approval
- **During Implementation** - If requirements change, update spec first
- **After Implementation** - Mark as "Implemented" with PR link and date
- **After Deprecation** - Mark as "Deprecated" with replacement feature link

## File Organization

```
Docs/Specs/
├── README.md                    # This file
├── TEMPLATE.md                  # Spec template
└── Features/
    ├── ProductListing.md
    ├── Search.md
    ├── Wishlist.md
    └── Bag.md
```

## Tips for Good Specs

✅ **Be Specific** - "User can sort by price" is better than "User can sort"
✅ **Include Code** - Show actual Swift structs, not just descriptions
✅ **Show Examples** - Include sample API responses, UI states
✅ **Think About Errors** - What happens when things go wrong?
✅ **Define Success** - Clear acceptance criteria prevent scope creep
✅ **Link to Designs** - Reference visual mockups if available

❌ **Avoid Vagueness** - "Nice UI" is not a requirement
❌ **Don't Skip Edge Cases** - Empty states and errors matter
❌ **Don't Forget Localization** - Every user-facing string needs a key
❌ **Don't Ignore Analytics** - What metrics should we track?

## AI Assistant Integration

This directory is automatically indexed by:
- 🤖 GitHub Copilot
- 🤖 Cursor
- 🤖 Cline
- 🤖 Other AI coding assistants

When you ask an AI assistant to "implement the Product Listing feature", it will automatically reference the spec in `Features/ProductListing.md` for context.

## Questions?

See `.github/copilot-instructions.md` for the full development workflow and architecture patterns.
