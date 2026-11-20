# `bff-tests` CI job: five review judgement calls

Researched 2026-11-20 against `origin/feat/259-bff-tests-ci` at `05d6d188` (draft PR #283, issue
#259, parent #251) and `origin/main` at `a9e2c843`. Line numbers are from the feature branch.
Pinned sources are cited at the pinned commit or tag; the list is in §Sources.

## Question

A review of #283 raised five judgement calls. For each: what is true, what are the options, which
one to take.

## Summary

| # | Finding | Recommendation | Effort |
|---|---|---|---|
| 1 | Workflow parses fastlane's dotenv line with `sed` | Move the three flags to workflow-level `env`; delete the line from `.env.default` | Small: 3 edits |
| 2 | `/tmp/alfie_*` paths repeated | Keep the fixed paths; upload one glob, `/tmp/alfie_*` | Trivial: 1 edit + 1 doc line |
| 3 | Two caches for the BFF's dependencies | Keep one. Drop `cache: yarn`, keep `node_modules` | Trivial: delete 2 lines |
| 4 | Same three inputs at every `setup-ios` call | Leave as is. Nothing better exists | None |
| 5 | Job `bff-tests` also runs `AlfieUI` | Do not rename | None |

## 1. Workflow parses fastlane's dotenv line

**Today.** `alfie.yml:131-133` extracts `EXTRA_XCARGS` from `fastlane/.env.default:17` with `sed`,
fails if empty, and exports it as `ALFIE_XCODEBUILD_ARGS`. The script splits it on spaces
(`run-integration-tests.sh:21`). The same variable feeds `SCAN_XCARGS` and `GYM_XCARGS`
(`.env.default:47`, `:87`).

**Sources.**

- fastlane 2.238.0 (`Gemfile.lock:65`) loads `.env` and `.env.default` with `Dotenv.load`, then
  `--env default` loads `.env.default` again with `Dotenv.overload` [S1 `:32`, `:45`]. The gem is
  dotenv 2.8.1 (`Gemfile.lock:44`).
- dotenv 2.8.1: an unquoted value runs to end of line or `#` [S2 `:25`], so
  `SCAN_DEVICE=iPhone 17 Pro (26.4)` is valid. Double quotes are stripped [S2 `:72`]. `$VAR` and
  `${VAR}` are substituted unless single-quoted [S2 `:100-106`]. There is no `${VAR:-default}`
  form [S3 `:12-19`].
- Under `overload`, a name defined in the file wins; a name not in the file comes from the process
  environment [S3 `:22`, `:35`]. That is how `ARTIFACTS_PATH` and `SPM_CLONED_DEPENDENCIES_PATH`
  already reach fastlane from `alfie.yml:26-28` (`.env.default:10`, `:84`).
- Sourcing the file in bash fails. Run here: `set -a; . .env.default` stops with
  `line 45: syntax error near unexpected token '('`, and every later variable is unset.
- The flags, from `xcodebuild -help` (Xcode 27.2, local): `-onlyUsePackageVersionsFromResolvedFile`
  "prevents packages from automatically being resolved to versions other than those recorded in the
  `Package.resolved` file"; `-skipPackagePluginValidation` "Skip validation of package plugins (this
  can be a security risk if they are not from trusted sources)"; `-skipMacroValidation` the same for
  macros. The repo uses a package plugin (`Alfie/AlfieKit/Package.swift:112`, `SwiftGenPlugin`) and
  resolves `swift-syntax` (`Alfie/AlfieKit/Package.resolved:229`). A fresh runner has no stored
  trust for either. No Apple reference page for these flags was found; the help text is the only
  first-party source.

**Options.**

| Option | Cost |
|---|---|
| Keep `sed` + guard | Works. A second parser of a format the workflow does not own; matches only the one-line double-quoted form |
| Workflow-level `env: EXTRA_XCARGS`, line removed from `.env.default`, step sets `ALFIE_XCODEBUILD_ARGS: ${{ env.EXTRA_XCARGS }}` | A local `fastlane` run must export the variable. The line must be removed, or `overload` wins over the workflow value |
| Source the dotenv file in bash | Broken (above) |
| Script reads the file itself | Same parser, moved; local runs would silently get CI's flags |
| Small file both read | dotenv cannot include a file; needs Fastfile code to set `SCAN_XCARGS`/`GYM_XCARGS` |
| Duplicate the flags | Two copies that can drift with no failure |

**Recommendation.** Workflow-level `env`. It is the pattern the file already uses for two other
values, and it removes the parser.

## 2. `/tmp/alfie_*` paths repeated

**Today.** The upload step lists three paths (`alfie.yml:143-146`). The script owns them
(`run-integration-tests.sh:19-20`, `:183`, `:188`). `docs/Testing.md:169-170` describes the
artifact in words, without paths, so the paths are in two places, not three. `CLAUDE.md:56` fixes
the `/tmp/alfie_*` convention. `build-for-verification.sh:34` reads its own log back;
`verify.sh` names no `/tmp` path itself.

**Sources (upload-artifact v5.0.0 README, S4).**

- `path` is "A file, directory or wildcard pattern" [`:100`]; a directory uploads whole [`:159`].
- "If a wildcard pattern is used, the path hierarchy will be preserved after the first wildcard
  pattern" [`:191`].
- "If multiple paths are provided as input, the least common ancestor of all the search paths will
  be used as the root directory of the artifact" [`:205`]. Today that is `/tmp`, so files sit at the
  artifact root.
- `if-no-files-found` defaults to `warn`: "the action will succeed but print out a warning"
  [`:110`, `:250`]. Seen on run 44489447764: upload step green with nothing to upload.
- Hidden files are excluded by default [`:441`].

**Options.**

| Option | Cost |
|---|---|
| One output directory, uploaded whole | Breaks the `CLAUDE.md:56` convention and the paths other scripts and docs name |
| Script exports paths through `$GITHUB_OUTPUT` | CI-only code in a script that also runs locally; behaviour when the step is killed by the timeout is unverified |
| One glob: `path: /tmp/alfie_*` | Also uploads the two test logs (`alfie_*_test.log`), which is useful. One prose line in `docs/Testing.md` |
| Leave | A new output file needs a workflow edit to be uploaded |

**Recommendation.** One glob. The workflow then depends only on the documented prefix. Layout is
unchanged (files at the artifact root).

## 3. Two caches for the BFF's dependencies

**Today.** `setup-node` with `cache: yarn` (`alfie.yml:109-114`), plus `actions/cache` on
`Alfie-BFF/node_modules` keyed on `.nvmrc` + `yarn.lock` (`:116-120`). The script always runs
`yarn install --frozen-lockfile` (`run-integration-tests.sh:116`).

**Sources.**

- setup-node v7.1.0 caches the output of `yarn cache dir` for Yarn 1 [S5 `cache-utils.ts:55-56`].
  "The action does not cache `node_modules`" [S5 `README.md:168`]. Key:
  `node-cache-<os>-<arch>-yarn-<hash of yarn.lock>`, with no fallback key for Yarn 1
  [S5 `cache-restore.ts:43-44`, `:61`]. Saved in a post step that runs only on job success
  [S5 `action.yml:46-47`] and only when the primary key missed [S5 `cache-save.ts:57-62`].
- GitHub's guidance: "It is not recommended to cache `node_modules`, as it can break across Node
  versions and won't work with `npm ci`" [S6]. setup-node gives the same reason: the global cache
  "can be reused between different Node.js versions" [S5 `docs/advanced-usage.md:272`].
- Yarn 1.22.22: after the resolve step, `install` compares `node_modules/.yarn-integrity` with the
  lockfile and, on a match, reports `upToDate` and returns before the fetch and link steps
  [S7 `install.js:462-474`, `:605`, `:639`]. The integrity record includes platform, arch and Node
  ABI [S7 `package-name-utils.js:12`]. It does not check that files exist unless `--check-files` is
  passed [S8].
- So with a complete `node_modules`, the global cache is never read. And both caches key on the
  same `yarn.lock` hash with no fallback, so they hit and miss together. The global cache adds
  something only when `.nvmrc` changes.
- Limits: 10 GB per repository; entries unused for 7 days are removed [S9]. The repo is at
  9.43 GB in 17 caches (`gh api repos/Mindera/Alfie-iOS/actions/cache/usage`, 2026-11-20). Each new
  cache evicts an older one; `derived-*` is 2.1 GB and `spm-*` 1.35 GB.
- Readable by forks: "forks of a repository can create pull requests on the base branch and access
  caches on the base branch" [S9]. `Alfie-BFF` is private. Either cache exposes its dependency
  set. In a local checkout all 901 `yarn.lock` entries resolve to the public registry, so no
  private package code is exposed; BFF `main` was not re-checked.

**Options.**

| Option | Cost |
|---|---|
| Keep both | Restores a cache that is unused on a hit; two entries against a full 10 GB |
| Keep `node_modules` only | Departs from the general guidance. Its two stated risks are covered: `.nvmrc` is in the key and Yarn re-checks the ABI; `npm ci` is not used |
| Keep `cache: yarn` only | The blessed shape. Every run pays the link step (371 MB locally; time unmeasured) |

**Recommendation.** Keep `node_modules`, drop `cache: yarn` and `cache-dependency-path`. It is the
only one of the two that skips work. #259 says "caching yarn and `node_modules`", so note the
change on the issue.

## 4. Same three inputs at every `setup-ios` call

**Today.** `alfie.yml:50-53`, `:124-127`, `:163-166` pass `gpg-private-key`, `gpg-passphrase` and
`spm-cloned-dependencies-path`; the action declares them at `action.yml:5-13`.

**Sources.**

- "The `secrets` context is not available for composite actions due to security reasons. If you
  want to pass a secret to a composite action, you need to do it explicitly as an input" [S10].
- Reusable workflows "are called directly within a job, and not from within a job step. You can't
  add steps to a job after calling a reusable workflow" [S11]. They can use secrets [S11], but as
  a separate job on its own runner. They cannot prepare the runner that then runs fastlane.
- Caller `env`: the runner copies the job's environment into a composite step's `env` context
  [S12 `:260-266`], so `${{ env.SPM_CLONED_DEPENDENCIES_PATH }}` would resolve inside the action.
  This is runner source, not a documented contract.
- YAML anchors are supported in workflows [S11]. They could alias the identical step in
  `unit-tests` and `release`, not the `bff-tests` one (no `ruby`). Merge-key support: unverified.

**Recommendation.** Leave it. The two secrets must be inputs. Reading the SPM path from the
caller's `env` would save three lines by hiding a dependency behind undocumented behaviour.

## 5. Job name `bff-tests` also runs `AlfieUI`

**Today.** The name is used at `alfie.yml:71`, `:151` (`needs`), `:142` (artifact
`bff-test-results`), `docs/Testing.md:148`, `:164`, `:166`, `:169`, the title of #259, and #251
("Both `unit-tests` and `bff-tests` become required status checks on the `main` ruleset").

**Sources.**

- The check context is the job name: PR #283 reports checks named `unit-tests` and `bff-tests`
  (`gh pr view 283 --json statusCheckRollup`).
- Nothing is required today: the `main` ruleset (id 1163363) has no status-check rule
  (`gh api repos/Mindera/Alfie-iOS/rulesets/1163363`).
- Once a name is required and stops reporting, "the pull request is blocked with 'Waiting for
  status to be reported.'" A check can be selected only if it "completed successfully in the chosen
  repository during the past seven days" [S13]. A rename after that point blocks every open PR
  until an admin edits the ruleset, and the new name must first go green once.

**Recommendation.** Do not rename. Both plans need the Mock BFF, so the name describes what sets
the job apart from `unit-tests`, and the spec uses it throughout. If the team still wants a new
name, the only cheap moment is before the admin adds the required check.

## Open questions

- [S13] also says a workflow skipped by path filtering leaves a required check "Pending" and
  advises "Avoid requiring workflows that can be skipped." `alfie.yml:11-13` ignores docs-only PRs,
  and `bff-tests` is skipped on fork and Dependabot PRs (`:72-75`). Settle this before the checks
  become required.
- The cache budget is nearly full before this job adds anything.

## Not verified

- The job has never run past "Mint Alfie-BFF read token" (failed on all six runs of the branch), so
  no cache size, `yarn install` time or artifact upload was observed in CI.
- Timing of `yarn install --frozen-lockfile` with a complete `node_modules`: read from source, not
  measured. Whether the resolve step touches the network: not read.
- That `actions/cache` v5.0.5 saves only on job success: not read.
- Whether `@actions/glob` follows macOS's `/tmp` symlink; whether an `.xcresult` holds hidden files.
- The Xcode version on `macos-26` and its help text; which package needs `-skipMacroValidation`.
- The dotenv parse was confirmed with a local dotenv gem of unknown version, and by reading 2.8.1.
- GitHub docs were read on 2026-11-20 from the live site and the `github/docs` `main` branch; they
  are not versioned.

## Sources

- S1 fastlane 2.238.0, `fastlane/lib/fastlane/helper/dotenv_helper.rb`:
  https://github.com/fastlane/fastlane/blob/2.238.0/fastlane/lib/fastlane/helper/dotenv_helper.rb
- S2 dotenv 2.8.1, `lib/dotenv/parser.rb`:
  https://github.com/bkeepers/dotenv/blob/v2.8.1/lib/dotenv/parser.rb
- S3 dotenv 2.8.1, `lib/dotenv/substitutions/variable.rb` and `lib/dotenv.rb:13-37`:
  https://github.com/bkeepers/dotenv/blob/v2.8.1/lib/dotenv/substitutions/variable.rb
- S4 actions/upload-artifact v5.0.0 README:
  https://github.com/actions/upload-artifact/blob/330a01c490aca151604b8cf639adc76d48f6c5d4/README.md
- S5 actions/setup-node v7.1.0 (`README.md`, `action.yml`, `docs/advanced-usage.md`,
  `src/cache-restore.ts`, `src/cache-save.ts`, `src/cache-utils.ts`):
  https://github.com/actions/setup-node/tree/949feb2413d6458794dcd2491c4babbbce0c15c1
- S6 actions/cache examples, "Node - npm":
  https://github.com/actions/cache/blob/main/examples.md#node---npm
- S7 Yarn 1.22.22, `src/cli/commands/install.js`, `src/integrity-checker.js`,
  `src/util/package-name-utils.js`: https://github.com/yarnpkg/yarn/tree/v1.22.22/src
- S8 Yarn 1 docs, `yarn install` (`--frozen-lockfile`: "Don't generate a `yarn.lock` lockfile and
  fail if an update is needed"; `--check-files`): https://classic.yarnpkg.com/en/docs/cli/install
- S9 GitHub Docs, dependency caching reference:
  https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching
- S10 GitHub Docs, contexts reference, `secrets` context:
  https://docs.github.com/en/actions/reference/workflows-and-actions/contexts#secrets-context
- S11 GitHub Docs, reusing workflow configurations (comparison table: "Can use secrets" /
  "Cannot use secrets"; YAML anchors and aliases):
  https://docs.github.com/en/actions/concepts/workflows-and-actions/reusing-workflow-configurations
- S12 actions/runner `main`, `src/Runner.Worker/Handlers/CompositeActionHandler.cs`:
  https://github.com/actions/runner/blob/main/src/Runner.Worker/Handlers/CompositeActionHandler.cs
- S13 GitHub Docs, troubleshooting required status checks:
  https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks
