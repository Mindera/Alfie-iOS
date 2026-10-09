---
status: accepted
---

# Jira owns what to build; specs and tickets are GitHub issues

Work starts from a Jira `ALFMOB` ticket. A grilling session turns it into a spec and tickets
published as GitHub issues, each opening with `Jira: ALFMOB-<id>`, and the branch carries the same
key. The repo follows the `mattpocock-skills` flow as shipped (grill → spec → tickets → implement →
review), and a decision that outlives its ticket becomes an ADR.

This replaces the in-repo spec flow: spec files from a twenty-heading template, plan folders,
research notes merged to `main`, and seven role prompts under `.ai/agents/`. Those files went stale
once the feature shipped, the role prompts contradicted the guides (Given-When-Then against
`docs/Testing.md`), and the layer-by-layer task breakdown fought the vertical slices the skills cut.

The retired documents remain in history at `043ec40e`, the last commit on `main` that holds them
(under `Docs/` and `.ai/agents/`).

## Considered options

- **Keep both flows, with a rule for which wins.** Rejected. Every skill run would have to
  arbitrate between them.
- **GitHub issues as the only tracker.** Rejected. The team plans and prioritises in Jira.
- **Publish specs and tickets to Jira.** Rejected for now. The skills are built around `gh`, and
  agent-written tickets would crowd the team's board. Jira stays read-only to agents unless asked.
- **Keep the role prompts for Copilot and Codex.** Rejected. The team uses Claude Code only, which
  is also why `CLAUDE.md` is the one instruction file.

## Consequences

- A spec is no longer a file to keep current. It is an issue that closes; what must survive goes
  into `GLOSSARY.md`, an ADR, or a guide under `docs/`.
- Research and prototypes are captured on throwaway branches, not merged to `main`.
- Work with no Jira ticket needs one raised first, or the user's word that there is none.
- Moving specs into Jira later means rewriting `docs/agents/issue-tracker.md`, the one place
  tracker commands live.
