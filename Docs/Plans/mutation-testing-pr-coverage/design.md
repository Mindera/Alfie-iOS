---
status: agreed, not started
complexity: medium
decided: 2026-09-07
---

# Mutation testing on PR changes — design

Outcome of a `/grill-with-docs` session. Every decision below was put to the user and answered;
the rationale is kept because most of these choices look arbitrary without it.

## Goal

After a PR is opened, check that the changed code is *meaningfully* covered — not just executed.
Coverage says a line ran. Mutation testing says a line's behaviour is actually asserted.

Two motivations, both stated:

1. A quality gate on new code, because reviewers cannot eyeball assertion strength.
2. Learning what the technique costs on a real iOS codebase.

Motivation 1 is **not delivered by this phase** — see "Known gap".

## Is mutation testing platform-specific?

Three layers, three answers:

- **The concept** is universal. Inject a small fault, re-run the tests, see if one fails.
- **The mutation operators** are language-specific — they are defined over syntax, so each
  language needs its own parser. Muter uses SwiftSyntax.
- **The execution engine** is platform-specific, and this is where it bites. Muter drives
  `xcodebuild` against a simulator, so it is macOS-only for an iOS app target. Muter gained Linux
  support in 2024, but only for pure-SPM/Foundation code.

The deeper asymmetry is economic. On the JVM, PIT mutates bytecode and hot-swaps mutants into a
live JVM — no recompile, milliseconds per mutant. That is why mutation testing is mainstream in
Java and niche in Swift. Swift is AOT-compiled, so the naive approach is a rebuild per mutant.
Muter's answer is **mutant schemata**: build one copy with every mutation inserted behind
environment-variable switches, then re-run the suite N times flipping one switch each run.

## Tooling landscape (checked 2026-09-07)

| Tool | State |
|---|---|
| [Muter](https://github.com/muter-mutation-testing/muter) | The only maintained Swift option. 562 stars, master pushed 2026-07. **Last tagged release is v16, September 2023.** No Homebrew formula — install means building from master. |
| LLVM-based (Swift Forums, 2021) | Never became a maintained product. |
| `ericodx/swift-mutation-testing` | 3 stars. Not viable. |

Swift has one real tool. Java has several mature ones.

## Measured facts

All measured on this machine, 2026-09-07, Xcode 26.6 / Swift 6.3.3.

| Fact | Value | How |
|---|---|---|
| Full suite | 883 tests, **38s** execution | `/tmp/alfie_test.xcresult` |
| `CoreTests` | 199 tests, **18.4s** execution | scoped `xcodebuild` run |
| Cost of one hand-made mutant | **~26s** warm (≈8s incremental rebuild + 18s scoped tests) | force-recompiled one `Core` file, ran `CoreTests` |
| Typical PR churn | 2–30 non-generated source files, 16–1460 added lines | last 12 commits |
| `Core` module | 55 files / 3,491 lines; only 4 files use SwiftUI | `find` / `grep` |
| Source files | 585 total, 520 hand-written (65 generated) | `find` |
| Test framework | 100% XCTest, zero `import Testing` | `grep` |

The ~26s figure matters: it means the per-mutant recompile penalty on Alfie is about 8 seconds,
so **Muter's schemata advantage — the entire engineering reason that tool exists — is small at
this codebase's scale.** A 30-minute budget buys roughly 69 hand-made mutants.

## Decisions

| # | Decision | Choice | Why |
|---|---|---|---|
| 1 | Motivation | Gate on new code + learning | Stated by user |
| 2 | Gate or signal | **Signal only** | Muter's released build predates the toolchain by three years; gating merges on it is unearned trust |
| 3 | Where it runs | **Local only**, manual | macOS runners cost ~10× Linux; prove value before paying |
| 4 | Who runs it | The PR author, manually, posting a comment | No automation this phase |
| 5 | Diff granularity | **Prune the test plan before running**, never filter the report after | Cost is one test run per mutant; filtering afterwards pays for mutants you discard |
| 6 | Budget | **30 minutes** per PR-sized run | User's tolerance |
| 7 | Report contents | **Surviving mutants only, no score** | A score from a non-deterministic process is fake precision and will get quoted in standups |
| 8 | File scope | Everything in the diff **except SwiftUI views** | Logic lives outside ViewModels; view mutants only restate what coverage already shows |
| 9 | Muter vs agent | **Undecided — settled by bake-off** | Converts an argument into evidence |

### Method: diff-based mutation testing

Google's published practice, and what makes this viable at all. A line is mutated only if it is:

1. in the diff under review,
2. covered by tests, and
3. not **arid** — an AST node pointless to mutate, logging being the classic case.

Plus **one mutant per line**, not all possible mutants. Muter's equivalent lever for arid
suppression is `excludeCalls` on the `RemoveSideEffects` operator.

### Muter mechanics, if Muter wins

```
muter mutate-without-running   # emits muter-mappings.json (the test plan)
<prune the JSON to mutants whose line falls in a diff hunk; cap one per line>
muter run-without-mutating     # executes only the pruned plan
```

The README documents that `muter-mappings.json` exists but **not its structure**. Whether it
carries usable file/line positions is unverified, and the bake-off must answer it — if it does
not, the whole diff-pruning design collapses for the Muter arm.

Config notes: `exclude` uses **substring matching, not globs**, so the generated trees
(`BFFGraph/API`, `BFFGraph/Mocks`, `GeneratedTokens`, `L10n+Generated.swift`) must be excluded
explicitly or 65 generated files get mutated.

## The bake-off

**Subject:** commit `5d90a4b` restricted to `Core` — 6 files, 148 lines. Optional second round:
`e7c1a9e` (the cancelled-PLP-refresh fix, 2 files / 16 lines). That one is the highest-value
target available: it is a bug fix, so a surviving mutant there means the test that supposedly
proved the fix does not actually pin the behaviour.

**Two arms, parallel and blind.** Separate git worktrees, separate DerivedData (Xcode keys it by
project path), separate simulators. Neither arm sees the other's output — running them in
parallel is what makes the blinding airtight rather than a promise.

- **Arm A — agent, by hand.** One mutant per changed, covered, non-SwiftUI line. Edit, rebuild,
  run `CoreTests`, record kill/survive, revert.
- **Arm B — Muter.** Built from master. **Timeboxed to one day.** If it will not build on
  Xcode 26.6, or cannot compile the schemata against `Alfie.xcodeproj`, that *is* the result —
  "the only Swift mutation tool does not run on our toolchain" settles decision 9 on its own.

**Judged on:** the number of survivors the *user* judges worth writing a test for, plus
wall-clock cost. Explicitly **not** raw survivor count, which rewards noise — 40 survivors of
which 35 are equivalent mutants is worse than 5 real ones. The user judges actionability, not
the agent, since the agent is one of the contestants.

**Report:** `Docs/Reports/mutation-testing-bakeoff.md`.

### Why an agent arm at all

Not improvisation — it is where the industry went. Meta's ACH system uses LLM-generated mutants
and tests, deployed across Facebook, Instagram, WhatsApp and wearables from October to December
2024: 10,795 Kotlin classes, 9,095 mutants, 571 tests, 73% accepted by privacy engineers.
Research reports LLM mutants are more diverse and closer to real faults than rule-based ones.

| | Muter | Agent |
|---|---|---|
| Compile cost | Once for all mutants | Once per mutant (~8s here) |
| Setup risk | High — no release since 2023 | None |
| Mutant quality | Syntactic (`>` → `>=`) | Semantic (drop a cancellation guard) |
| Equivalent mutants | Reported as survived; hand triage | Can be reasoned about and discarded |
| Reproducibility | Deterministic, comparable | Non-deterministic, not comparable |
| Bias | None | **Real: may pick mutants it suspects are caught** |

## Risks

- Muter may not build on Xcode 26.6.
- `muter-mappings.json` structure is undocumented; diff-pruning may be infeasible.
- The agent arm is non-deterministic and has an incentive to pick easy mutants. Blind parallel
  arms limit this; they do not remove it.
- One 148-line diff in one module is a single data point, not a general verdict.
- Two cold builds (~10 min each) and ~10 GB of DerivedData. Noted separately: the machine already
  holds **50 `Alfie-*` DerivedData directories totalling 237 GB** across 23 registered worktrees.

## Known gap

Motivation 1 — a real quality gate — is **not satisfied by this phase**. A manual local tool
depends on the author choosing to run it, and an author who writes weak assertions is the least
likely to think they need checking. That closes only when this moves to CI. Recorded as a
phase-two gap rather than papered over.

## Deliberately deferred

- CI integration, and any `verify.sh` hook. `verify.sh` is the fast feedback loop that
  `CLAUDE.md` tells every agent to run after every change; a 10-minute mutation pass would wreck it.
- Per-mutant `-only-testing:` scoping. It is the piece most likely to produce wrong results —
  a mutant only another module's tests would kill scores as survived.
- `CONTEXT.md`. Mutation-testing terms are engineering-process vocabulary and would dilute a
  product glossary that should describe bags, wishlists and PDPs. Vocabulary goes to
  `Docs/Testing.md` once there is a winner.
- An ADR. A bake-off is reversible by design, so it fails the "hard to reverse" bar. The ADR
  becomes worth writing when a winner is picked — that choice is durable and a future reader
  will ask why.

## References

- [Muter](https://github.com/muter-mutation-testing/muter)
- [State of Mutation Testing at Google](https://research.google.com/pubs/archive/46584.pdf) — diff-based mutants, arid nodes
- [Scaling Mutation Testing in a Large iOS Codebase](https://ericsspace.com/articles/scaling-mutation-testing-in-a-large-ios-codebase/) — 8h → 52min full, 2–3min PR-scoped
- [LLMs Are the Key to Mutation Testing — Engineering at Meta](https://engineering.fb.com/2025/09/30/security/llms-are-the-key-to-mutation-testing-and-better-compliance/)
