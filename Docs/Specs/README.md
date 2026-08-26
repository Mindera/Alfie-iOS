# Feature Specifications

This directory contains detailed specifications for all features in the Alfie iOS application.

## How to Write a Spec

Copy `TEMPLATE.md`. Its headings are the required sections — fill every one, and delete the
optional sections you don't need rather than leaving them empty.

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

Specs live in `Features/`, one file per feature, named `<FeatureName>.md`. `TEMPLATE.md` is the
starting point (`ls Docs/Specs/Features/` for what exists today).

## See also

See `AGENTS.md` for the critical rules, and `Docs/Development.md` for the spec-to-implementation loop.
