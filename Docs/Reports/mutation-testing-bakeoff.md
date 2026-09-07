---
status: complete
decided: 2026-09-07
subject: commit 5d90a4b, Core module only
---

# Mutation testing bake-off — Muter vs. agent

Two arms, run **blind and in parallel** on the same subject: the `Core`-module portion of
`5d90a4b` ("The bag screen renders and empties the server cart"), treated as an open PR.
Separate worktrees, separate simulators, separate DerivedData. Neither arm could see the other.

Design and decisions: `Docs/Plans/mutation-testing-pr-coverage/design.md`.

## Result

| | Arm A — agent, by hand | Arm B — Muter |
|---|---|---|
| Mutants run | 29 | 11 |
| Killed | 28 | 0 |
| Survived | 1 | 11 |
| **Survivors that are real** | **1** | **0 — unknowable** |
| Wall clock | ~35 min | ~11 min |
| Per-mutant cost | 43.9 s mean | 7–8 s |
| Trustworthy | Yes | **No** |

Arm B's numbers are not a bad score. They are **not a score at all** — see below.

## Cross-arm comparison — which arm is wrong

The two arms did **not** run the same tests. Both were instructed to run `CoreTests` +
`BFFGraphTests`; Arm A did (278 tests, green baseline, 15 s), Arm B could not (13 integration
tests, all skipped — see below). The mutant sets also differ: 29 semantic mutants against 11
syntactic ones. So the arms are not two measurements of one quantity.

They overlap enough to settle which one is wrong.

| Arm B's 11 "survivors" | Arm A's verdict | |
|---|---|---|
| `CartService.swift:66` — `cartSubject.send(nil)` | **SURVIVED** | agree — the one real gap |
| `Cart+Converter.swift:58,59,61,62` — `== nil` | **KILLED** by `test_a_healthy_cart_reports_no_unrepresentable_amounts` | **B is wrong ×4** |
| `ProductListing+Converter.swift:112` — `Int64.max` bound | **KILLED** by the overflow test | **B is wrong** |
| `BFFClientService.swift` ×4 — `logUnrepresentableAmounts` | excluded as arid | B mutates logging |
| `CartService.swift:54` — `Task` block | skipped as structural | not comparable |

Six of Arm B's eleven are directly contradicted by Arm A, which applied the mutation, watched the
build recompile, and recorded a **named failing test**. That is positive evidence, not opinion.

Muter did flag `CartService.swift:66` — the same line Arm A found. **This is a stopped clock, not
a hit.** A detector that marks every mutant as survived is automatically correct on whatever
genuinely survives, and carries no information. Marking all 11 is what makes the 1 worthless.

**Note for the general case:** even two *working* mutation tools would not agree exactly. Arm A
wrote semantic mutants (drop a guard, swap an argument, defeat a bound); Muter has four syntactic
operators and no others. Mutation score is not an objective scalar the way line coverage is —
it is defined relative to an operator set. Comparisons are only meaningful within one tool.

## Arm B — Muter

Muter built, ran, exited 0, and printed a mutation score. The score is meaningless, for two
independent reasons.

**1. The mutants were never applied.** Muter copies the project and prepares 268 files with its
`// swiftlint:disable all` preamble, then inserts **zero** mutation switches. The check is
empirical and independent of any diagnosis: repo-wide, not one file in the mutated copy contains
a `ProcessInfo.processInfo.environment[...]` switch, which is the mechanism schemata run on.

The cause is a post-v16 regression on master — `99624ec`, 2026-04-27, *"prevent memory exhaustion
on large codebases (2000+ files)"*. It changed mutation discovery to hand the apply step an empty
syntax-tree cache, so files get re-parsed on demand. But the mutation lookup is a dictionary keyed
on SwiftSyntax `CodeBlockItemListSyntax` nodes, whose `Hashable` conformance is **identity**-based
and rooted in the parse arena. Nodes from a re-parsed tree can never match nodes recorded during
discovery. Every lookup misses, silently. It only triggers on codebases large enough to take the
re-parse path — which is to say, on the codebases anyone would want this for.

**2. The mutant runs executed the wrong tests.** `MuterConfiguration.testWithoutBuildArguments`
rebuilds the argument list from scratch and **discards `-only-testing:`** for every mutant run.
Muter then selects "the most recent `.xctestrun`". This scheme has two test plans and it chose the
integration one, so all 11 runs logged `Executed 13 tests, with 13 tests skipped` — the
`BFFIntegrationTests` that `XCTSkip` without a local BFF. `CoreTests` and `BFFGraphTests` never ran.
No config field selects a test plan.

**This failure mode is benign only by luck.** Those 13 tests skipped. Had they errored, every
mutant would have been reported KILLED and Muter would have printed a confident **100%**.
A tool that reports 0% when it mutated nothing will report 100% under a slightly different wind.

### What Arm B did establish

Two things, both useful:

- **`muter-mappings.json` is a sound substrate for diff-pruning.** Each mutant record carries file
  path, line, column and UTF-8 offset, and survives a round trip through `run-without-mutating`.
  Arm B pruned 987 mutants to 11 and got exactly those 11 executed. The pre-run pruning design
  (decision 5) is confirmed workable — it is Muter's *execution* layer that fails, not its data model.
- **Position fidelity is 91.3% exact**, measured across all 987 mutants: 100% for
  `RelationalOperatorReplacement` and `ChangeLogicalConnector`, but **79.3% for
  `RemoveSideEffects`**. Every miss is negative: for a multi-line statement Muter records the
  statement's *end* line while a diff records where it *starts*. Naive exact-line pruning silently
  drops ~20% of side-effect mutants. Nothing documents this.

### Cost shape

Per-mutant cost is genuinely 7–8 s — schemata work as advertised. But it is bought with **two
forced cold builds**: `clean` is hard-coded into `build-for-testing`, and Muter's own baseline run
does a second full build in the mutated copy. Total 5 m 26 s for 11 mutants, against 32 s to run
the same tests directly.

**Fixed cost dominates by ~4× at PR scale.** Schemata amortise over hundreds of mutants — the
opposite of a diff-scoped run. The tool's central optimisation is aimed at a workload we do not have.

### Friction (15 items, none documented)

Highlights: no Homebrew formula; `swift build -c release` fails outright on an upstream test-target
bug (`TestingExtensions` is a `.target` that `@testable import`s a non-testable module), so the
documented `make install` cannot work; `muter init` generated `-workspace Alfie.xcworkspace`, a path
that does not exist. And a trap worth naming — **supplying `-derivedDataPath` corrupts the build
command** into `test clean build-for-testing`, running the whole suite before cleaning it away.
The sensible-looking config is the broken one.

## Arm A — agent, by hand

29 mutants, 28 killed, 1 survivor, no build failures.

Selection: 148 added lines → 14 blank, 64 comment, 70 code → **29 mutated, 41 arid**. All 29 were
confirmed covered from `xccov` execution counts. The 41 skipped were 14 closing braces, 15
declarations, **8 logging-only**, 4 structurally unmutatable. The mutant list was frozen before any
mutant ran and before the agent read any test bodies — the guard against picking easy targets.

The kills are not incidental: each failing test's name matches the semantics its mutant broke. The
three load-bearing guards in `representableAmount` are killed by *different* tests with *different*
inputs (`-.infinity`, `1e300`, `1e17`), and a fourth test pins the opposite direction so the guard
cannot be "fixed" by rejecting everything.

### The one survivor

**`CartService.swift:66` — deleting `cartSubject.send(nil)`** from `read()`'s no-stored-id branch.
All 278 tests still pass.

`test_fetch_withNoStoredCartId_publishesNoCartWithoutAskingTheServer` asserts
`XCTAssertNil(sut.cart)` — but `cartSubject` starts `nil` and the test never populates it. **The
assertion is satisfied by the initial value, not by the line under test.** It proves the server
round trip is skipped; it does not prove the held cart is cleared.

Not an equivalent mutant: `CurrentValueSubject.send(nil)` emits even when the value is already nil,
so a test counting publisher emissions distinguishes the two today with no production change.

Severity is low *today*. The agent checked reachability: nothing in `Core` or the app ever removes
`StorageKey.cartId`, so the stale-cart transition cannot currently occur. It is a defensive clear
with nothing asserting it, safe only because of an unstated and untested invariant — one that a
sign-out, "empty bag", or account-switch feature would break, producing exactly the failure the
PR's own comments say the design avoids.

### Cost shape

Mean 43.9 s per mutant (min 36, max 71), of which ~29 s is `xcodebuild` re-linking `Core` and only
15 s is the suite. **Cost is dominated by the rebuild, not the tests.** A 30-minute budget buys
roughly 40 mutants — enough for a 148-line diff, not for a 30-file PR.

This corrects the design's earlier 26 s estimate, which was measured against `CoreTests` alone.

## Findings that outlived both arms

- **Test target does not follow source module.** The `Core` converters in this diff are covered by
  `BFFGraphTests`. Scoping to `CoreTests` — the obvious heuristic — would have scored every
  converter mutant as survived. Arm A verified the stronger form: only `BFFGraphTests` and
  `CoreTests` have `@testable import Core`, and every mutated symbol is `internal`, so no other
  target can reach them. **Scoping must be derived from coverage data, never from file paths.**
- **A fresh worktree cannot build the app target.** `GoogleService-Info.plist` is `git secret`
  -decrypted and gitignored, so the `Copy GoogleService-Info.plist` build phase fails. Both arms
  hit this independently. Any automation must run `git secret reveal` first.
- **Coverage could not have found the survivor.** All 29 mutated lines were covered, including the
  one whose assertion is satisfied by an initial value. So were the 8 logging lines that mutation
  testing correctly declines to make any claim about.

## Verdict

**Arm A wins, on the criterion agreed in advance** — survivors worth acting on, not raw counts.
Arm A produced 1 real finding in ~35 minutes. Arm B produced 11 findings of which 0 are real, and
would have produced them just as confidently had it been wrong in the other direction.

Muter is not rejected for being old — Swift 6.3.3 compiles it fine, and v16 predates the regression.
It is rejected because **master silently disables mutation while reporting success**, and because
its cost shape is aimed at whole-codebase runs rather than diff-scoped ones.

Cheapest way to revisit: pin the v16 tag and re-run Gate 2. That predates `99624ec`, though it
addresses none of the execution-layer problems (forced `clean`, double cold build, dropped
`-only-testing:`, arbitrary test-plan selection).

## Caveats

- **One subject, one module, 148 lines.** A single data point.
- **The agent arm is non-deterministic and self-scoring.** Freezing the list before execution and
  before reading tests limits the bias; it does not remove it. Arm A self-reported an oversight —
  `CartService:53` was misclassified as structural and left unrun with ~9 minutes of budget spare.
- **All 9 added lines in `BFFClientService.swift` were skipped as arid** (logging). If you reject
  that classification, the new diagnostics are unmeasured here.
- **`BFFIntegrationTests` was excluded** from both arms.
- First-order mutants only, one per line.
