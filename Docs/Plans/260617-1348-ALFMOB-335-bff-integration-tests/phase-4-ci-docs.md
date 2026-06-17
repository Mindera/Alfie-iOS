## Phase 4: CI + Docs

### Goal
A separate, non-blocking `integration-tests` CI job that runs the orchestration script, plus docs
for the local loop.

### Steps
1. **CI job** (file: `.github/workflows/alfie.yml:25` — add a sibling job to `unit-tests`)
   - `integration-tests:` on `macos-26`, `timeout-minutes: 30`. **Gate via `if:`**
     (`workflow_dispatch` or a `run-integration` label) — NOT `continue-on-error: true` on every PR.
     Red-team: `continue-on-error` + `XCTSkip`-when-down = a job structurally incapable of failing
     (skips everything, stays green, tests nothing). Do NOT add it to `release`'s `needs`.
   - **Fail on zero tests executed** — when the job DOES run, all-skipped must be a job failure
     (parse the `.xcresult`/junit test count; 0 executed ⇒ exit non-zero), so a silently-down BFF is caught.
   - Reuse the existing cache steps (Homebrew, gems, SPM, DerivedData) from `unit-tests`
     ([alfie.yml:33-68](../../../.github/workflows/alfie.yml)).
   - **Provision BFF** (Open Q #1, must-confirm): `actions/checkout` of `Alfie-BFF` into a sibling path +
     `actions/setup-node` + `npm ci`, exporting `ALFIE_BFF_PATH`; if BFF can't run in CI yet, keep the
     job `workflow_dispatch`-only as a manual smoke gate.
   - Step: `./Alfie/scripts/run-integration-tests.sh`.
   - Upload `*.xcresult` on failure (mirror [alfie.yml:100-108](../../../.github/workflows/alfie.yml)).
   - No fastlane lane required (script calls xcodebuild directly).
2. **Docs/Testing.md** (file: `Docs/Testing.md` — edit; append an "Integration suite" section)
   - Explain: unit tests stay mocked; integration suite runs the real client against local BFF.
   - How to run: clone `Alfie-BFF` as sibling (or set `ALFIE_BFF_PATH`), then
     `./Alfie/scripts/run-integration-tests.sh`; expected output; how to point at another port via
     `ALFIE_BFF_BASE_URL`; note tests `XCTSkip` when the BFF is down.
3. **README.md** (file: `README.md` — edit) — short pointer to the integration loop + link to
   Docs/Testing.md. Cross-reference [Docs/GraphQL.md:13](../../../Docs/GraphQL.md) for BFF setup.

### Verification
- `./Alfie/scripts/verify.sh` PASS (unchanged unit run).
- Trigger the CI job (dispatch) on a branch → it boots BFF (or runs dispatch-only), executes the suite,
  reports results, and does **not** block the `unit-tests`/`release` path.
- Docs reviewed: a fresh dev can follow README → run the script → green.

### Estimated Effort
M
