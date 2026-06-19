---
name: setup-skills
description: Onboard a repo into the vault-based metadata workflow. Creates the project's CONTEXT note in the appropriate vault (mist for personal, nil for work). Run once per repo before using other engineering skills.
disable-model-invocation: true
---

# Setup Skills

Onboard the **current repo** into the vault-based metadata workflow. Per-repo metadata (CONTEXT, ADRs, ticket enrichment) lives in your Obsidian vault under `Coding/`, not in the repo itself.

## What this skill does

1. Detect which vault to use (mist or nil) from the git remote
2. Pick the project's canonical name (default: repo name)
3. Create the project's main note: `Coding/<project>.md` with CONTEXT frontmatter
4. (Optional) Append an `## Agent skills` block to `CLAUDE.md` / `AGENTS.md` referencing the vault notes — this is the only thing written into the repo, and it's just a pointer

## Prerequisites

- Obsidian is running (for `obsidian-cli`)
- For work repos: `vault-nil` skill available (CMB only)
- For personal repos: `vault-mist` skill available

## Process

### 1. Detect the repo and pick the vault

```bash
git remote -v
basename "$(git rev-parse --show-toplevel)"
```

Decision rule:
- Remote contains `corp-github.example.com` (or any internal corp host) → **nil vault** (`$VAULTS_DIR/nil`). See `vault-nil` skill.
- Otherwise (personal `github.com`, no remote, etc.) → **mist vault** (`$VAULTS_DIR/mist`). See `vault-mist` skill.

The user can override the choice.

### 2. Pick the project name

Default: the repo's directory name (e.g. `dots.factory`, `nebular-grid`).

Confirm with the user — they may want to use a different canonical name (e.g. several related repos sharing a project label).

### 3. Check for existing notes

```bash
ls "$VAULT/Coding/" | grep "^<project>"
```

If `<project>.md` already exists, the repo is already onboarded — just confirm and exit. Don't overwrite.

### 4. Create the CONTEXT note

Write `<vault>/Coding/<project>.md`:

```markdown
---
project: <name>
type: context
status: active
tags: [coding, project/<name>]
---

# <name>

<one-paragraph project description>

## Domain

<key terms, ubiquitous language>

## Constraints

<things the agent should know — invariants, gotchas>

## Links

- Repo: <url>
- (Jira project, ticket tracker, etc.)
```

Interview the user briefly to fill in:
- One-paragraph description (ask: "what does this repo do?")
- Key terms (ask: "any domain terms an agent should know?")
- Constraints (ask: "any conventions or gotchas?")

Keep it short — they can grow the note over time.

### 5. (Optional) Add a CLAUDE.md pointer

Ask the user: "Add an `## Agent skills` block to `CLAUDE.md` pointing to the vault?"

If yes, append (or update existing) in `CLAUDE.md`:

```markdown
## Agent skills

This repo's metadata (CONTEXT, ADRs, ticket notes) lives in the **<mist|nil> vault** under `Coding/<project>`. Use the `vault-<mist|nil>` skill to read or update them. Do not create `docs/adr/` or `CONTEXT.md` in this repo.
```

### 6. Done

Tell the user:
- Vault note created at `<vault>/Coding/<project>.md`
- Future ADRs go in `Coding/<project> - ADR NNN - <slug>.md`
- Future issue notes go in `Coding/<project> - <issue-key> - <slug>.md`
- The `vault-<mist|nil>` skill explains the conventions

## Triage labels

Triage labels (the 5-role state machine in the `triage` skill) map to your tracker:

- **GitHub Issues**: use the role names as labels — `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Create them on first use if missing.
- **Jira CAT**: there are no labels — use transition states. Suggested mapping (the `triage` skill should follow this on CMB):
  - `needs-triage` → state `Ready` not yet groomed (use a comment "needs triage")
  - `needs-info` → state `Blocked` with a comment requesting info
  - `ready-for-agent` → state `Ready` with comment "agent-ready"
  - `ready-for-human` → state `Ready`
  - `wontfix` → state `Cancel`

Don't overengineer — most personal repos don't need triage; this only matters when you actually run `/triage`.
