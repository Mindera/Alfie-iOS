# Issue tracker: Jira (team work) + GitHub Issues (agent work)

This repo uses two issue surfaces. Which one you touch depends on where the work
came from, not on which skill is running.

- **Jira** (`ALFMOB` project) is the team's tracker. Tickets here are written by
  and for humans. Treat it as read-mostly.
- **GitHub Issues** is the agent-owned surface. Tickets produced by `/to-tickets`,
  `/grill-with-docs`, `/wayfinder`, and anything `/triage` sorts live here.

## Routing rule

The identifier shape decides:

- `ALFMOB-123` -> Jira
- `#123`, or a bare number in a GitHub context -> GitHub Issues

If a request is ambiguous, ask. Don't guess and write to the wrong surface.

## Jira - team tickets

Site: `https://mindera.atlassian.net` · Project key: `ALFMOB` ·
cloudId: `d1f0340d-c33e-48c9-b29a-f13d9b14e217`

Access is via the Atlassian MCP tools, not a CLI. The tools are deferred - load
them with `ToolSearch` before calling.

- **Read a ticket**: `getJiraIssue` with `issueIdOrKey: "ALFMOB-123"`. Include
  `comment` in `fields` to get the discussion; use
  `responseContentFormat: "markdown"`.
- **Search**: `searchJiraIssuesUsingJql`, e.g.
  `project = ALFMOB AND status != Done ORDER BY updated DESC`.
- **Comment**: `addCommentToJiraIssue`.
- **Transition**: `getTransitionsForJiraIssue`, then `transitionJiraIssue`.
- **Create**: `createJiraIssue` - only when the user explicitly asks for a Jira
  ticket.

**Writes to Jira are visible to the whole team.** Ask before commenting on or
transitioning a ticket you didn't create.

**Don't apply triage labels in Jira.** Triage runs on GitHub; see
`triage-labels.md`.

## GitHub Issues - agent work

Repo: `Mindera/Alfie-iOS`. Use the `gh` CLI, which infers the repo inside a clone.

- **Create**: `gh issue create --title "..." --body "..."` (heredoc for multi-line bodies)
- **Read**: `gh issue view <number> --comments`
- **List**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`, with `--label` / `--state` filters
- **Comment**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

### Cross-linking

When a GitHub issue derives from a Jira ticket, make the first line of the body:

    Jira: ALFMOB-123

so the provenance survives without needing a Jira round-trip to reconstruct it.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs
as feature requests; `/triage` reads this flag.)_

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Apply the routing rule. `ALFMOB-123` -> `getJiraIssue`. `#123` ->
`gh issue view 123 --comments`.

## Wayfinding operations

Used by `/wayfinder`. Runs entirely on GitHub. The **map** is a single issue with
**child** issues as tickets.

- **Map**: an issue labelled `wayfinder:map`, holding the Notes /
  Decisions-so-far / Fog body. `gh issue create --label wayfinder:map`.
- **Child ticket**: an issue linked to the map as a GitHub sub-issue (`gh api` on
  the sub-issues endpoint). Where sub-issues aren't enabled, add the child to a
  task list in the map body and put `Part of #<map>` at the top of the child body.
  Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once
  claimed, assign the ticket to the driving dev.
- **Blocking**: GitHub's native issue dependencies. Add an edge with
  `gh api --method POST repos/Mindera/Alfie-iOS/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`,
  where `<blocker-db-id>` is the blocker's numeric **database id**
  (`gh api repos/Mindera/Alfie-iOS/issues/<n> --jq .id`, _not_ the `#number` or
  `node_id`). Fall back to a `Blocked by: #<n>` line in the child body if
  dependencies aren't available. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open children, drop any with an open blocker
  (`issue_dependencies_summary.blocked_by > 0`) or an assignee; first in map order wins.
- **Claim**: `gh issue edit <n> --add-assignee @me`, the session's first write.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, `gh issue close <n>`, then
  append a context pointer to the map's Decisions-so-far.
