# Prototypes

How `/prototype` runs in this repo. The skill's rules stand; only the artifacts change, because
there is no web route or task runner here.

## Branch

Every prototype lives on a `prototype/<name>` branch, pushed, never merged and never opened as a
PR. Leave a pointer to the branch on the implementation issue.

## UI prototype ("what should this look like?")

A screen in the Debug Menu, in place of a route with a URL search param:

- Add the view under `Alfie/AlfieKit/Sources/DebugMenu/UI/Prototype/`, wrapped in `#if DEBUG`.
- Register it as a `DebugNavigation` case with a link in `DebugMenuView`, inside `#if DEBUG`.
- Variants switch through a segmented control pinned to the bottom of the screen, in place of the
  floating bottom bar.
- Feed it from `Mocks` (`Mock<Feature>ViewModel`, fixtures); no BFF calls.
- Run: launch the `Alfie` scheme in the Debug configuration, open the Debug Menu, tap the entry.

Files under `AlfieKit/Sources/` are auto-discovered, so `project.pbxproj` stays untouched.

## Logic prototype ("does this state model feel right?")

A Swift script, in place of the single HTML file:

- `Alfie/AlfieKit/Prototypes/<name>/main.swift`. The folder sits outside every package target, so
  it never reaches the build.
- Self-contained: copy the types it needs rather than importing AlfieKit modules.
- Drive the state machine from a list of named scenarios and print the full state after every action.
- Run: `swift Alfie/AlfieKit/Prototypes/<name>/main.swift`.
