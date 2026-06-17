## Phase 3: Orchestration — script

### Goal
One command that boots the local BFF, waits for a real GraphQL response, runs only the integration
target, and tears the BFF down on exit (no orphaned processes).

> Test plan + scheme registration already done in Phase 1. This phase is only the script.
> Red-team fixes applied: confirm real boot command, process-group teardown, GraphQL-POST readiness.

### Steps
1. **Orchestration script** (file: `Alfie/scripts/run-integration-tests.sh` — new; `set -o pipefail`, `set -m`)
   - **Resolve BFF path:** `${ALFIE_BFF_PATH:-../Alfie-BFF}` (path convention from
     [sync-bff-schema.sh](../../../Alfie/scripts/sync-bff-schema.sh) — note that script only copies SDL,
     it does NOT boot a server, so the boot mechanism below is new). Error clearly if the dir is absent.
   - **Prereqs:** if `node`/`npm` missing → fail with a clear message. If `$BFF/node_modules` absent →
     run `npm ci` (or instruct the dev to). Boot command is **TBD — confirm with BFF team** (Open Q #1):
     likely `npm run start:dev`.
   - **Pre-flight:** if `:3000` is already LISTEN (`lsof -i :3000`), fail fast — do NOT reuse a
     possibly-stale server (would test the wrong build / mask teardown bugs).
   - **Boot in its own process group + group-kill teardown** (PID-kill orphans the node grandchild):
     ```bash
     ( cd "$BFF" && npm run start:dev ) &
     BFF_PGID=$!
     trap 'kill -- -$BFF_PGID 2>/dev/null' EXIT INT TERM
     ```
   - **Readiness poll:** loop POST `{"query":"{__typename}"}` to `http://localhost:3000/graphql`;
     accept HTTP 200 + body containing `data`/`errors`; timeout ~60s → fail with a clear message.
     (Not a GET 200/400 heuristic — that matches strangers / landing pages.)
   - **Run:** `export ALFIE_BFF_BASE_URL=http://localhost:3000` (origin only — service appends `/graphql`),
     reuse the simulator auto-discovery from [test-for-verification.sh:74](../../../Alfie/scripts/test-for-verification.sh),
     then `xcodebuild test -project .../Alfie.xcodeproj -scheme Alfie -testPlan AlfieIntegration -destination <discovered>`.
   - Propagate xcodebuild's exit code as the script's exit code. `chmod +x`.

### Verification
- Locally with `../Alfie-BFF` present + Node deps: `./Alfie/scripts/run-integration-tests.sh` boots BFF,
  runs the 3 suites green, and **no node remains on :3000** afterward (`lsof -i :3000` empty).
- Ctrl-C mid-run → BFF torn down (trap fires on INT). Second consecutive run still passes (no stale server).
- `./Alfie/scripts/verify.sh` unaffected.

### Estimated Effort
M
