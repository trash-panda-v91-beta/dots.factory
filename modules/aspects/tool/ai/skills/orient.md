---
name: orient
description: Session entry point - detect the repo, load its CONTEXT, and surface open tasks so the user can pick one. Use when the user says "start work", "orient me", "let's begin", "pick up a ticket", "what should I work on", or names a specific ticket to start on. Also use when a session opens on a repo without a clear task in scope. Onboards the repo via setup-skills if no CONTEXT exists.
---

# orient

Orient to the current repo: read CONTEXT, surface open tasks, pick one, load it,
and name the skills likely to help.

## 1. Identify repo and vault

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
```

Vault selection per the `vault` skill. Default is `mist`. Use `nil` only if
`vault-nil` appears in the session's available skills list (CMB only) - never
read vault-nil by guessing a path.

## 2. Query vault in one shot

Use the base-query recipe from `vault`. Include `note.issue` in the properties
block - it'll be empty on mist tasks and populated on nil tasks:

```yaml
filters:
  and:
    - projects.contains(link("$REPO"))
properties:
  note.type:      { displayName: Type }
  note.status:    { displayName: Status }
  note.issue:     { displayName: Issue }
  note.title:     { displayName: Title }
  note.priority:  { displayName: Priority }
views:
  - type: table
    name: All
    order: [type, status, issue, title, priority]
```

Filter the JSON client-side:

- `"Type": "context"` -> CONTEXT note. Read it: `obsidian-cli vault=$VAULT read path="<path>"`.
- `"Type": "adr"` -> ADRs. Read each.
- `"Type"` in `{task, story, bug, subtask}` and `"Status"` in `{open, in-progress}` -> open work.

## 3. Onboard if unonboarded

If the query returns no CONTEXT for `$REPO`, run `/setup-skills` inline. Don't
proceed to task surfacing without a CONTEXT - the interview is fast.

## 4. Surface open tasks

Present as a numbered list, one line each:

```
Open tasks for <repo>:
  1. [priority]  <issue or -->  <title>  (<status>)
  2. ...
```

If the vault has no open tasks for this repo, say so and offer to either create
one or proceed without.

## 5. Pick

- **User named a specific task/ticket**: use it. Skip the prompt.
- **One open task**: use it. Ask only if the user might want to skip.
- **Multiple**: ask "Which one?". Wait for a choice.
- **None**: offer to draft one (`to-issues` skill) or proceed without.

## 6. Load the picked task

```bash
obsidian-cli vault=$VAULT search query='[title: "<title>"]' format=json
obsidian-cli vault=$VAULT read path="<path>"
```

On nil, when the task has `issue:`, additionally fetch live tracker state - see
`vault-nil` for the workflow.

Summarise for the session: title, status, priority, Description body, any
Scratchpad notes.

## 7. Name relevant skills

Based on the task shape, name the skills likely to help this session (don't
load them - just name them):

| situation | skill |
|---|---|
| new feature needing breakdown | `to-issues` |
| implementation | `coding` |
| hard bug or regression | `diagnosing-bugs` |
| architecture decision | `domain-modeling` |
| PR ready | `create-pr` |
| handing session to a fresh agent | `handoff` |

## Done when

- CONTEXT and any ADRs are loaded into the session.
- A task is chosen (or the user has consciously chosen to proceed without).
- Task description and (on nil) live tracker state are summarised.
- Relevant skills for this session are named.

## Outbound privacy

Everything loaded here - CONTEXT, ADRs, task scratchpads - is local reasoning
context. See the `vault` privacy fence: never leak paths, ADR identifiers, or
scratchpad phrasing to code comments, PR/issue text, or commit messages.
