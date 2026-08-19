---
name: handoff
description: Save a handoff note to Obsidian so a fresh agent can continue the work. Use when the user says "handoff", "create handoff", "write a handoff", "handoff note", "save handoff", "write handoff doc", "end session", or "hand off to next agent".
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the
work.

## Content Rules

- Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits,
  diffs). Reference them by path or URL instead.
- Redact any sensitive information (API keys, passwords, PII).
- Include a "suggested skills" section listing skills the next agent should invoke.
- If the user passed arguments, treat them as a description of what the next session will focus on
  and tailor the doc accordingly.

## Vault Routing

See the `vault` skill for vault selection (default `mist`; `vault-nil` on CMB
routes work repos to `nil`).

## Saving to Nil (Work Repos)

Use `tasknotes:capture`, then set properties. The handoff document body goes into `## Description`.

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
DATE=$(date +%Y-%m-%d)

RESULT=$(obsidian-cli tasknotes:capture vault=nil \
  title="Handoff - $REPO - $DATE" \
  priority=normal \
  scheduled="$DATE" \
  details="<handoff document body>")
PATH_REL=$(echo "$RESULT" | jq -r .path)

# Verify it landed in nil
test -f "$VAULTS_DIR/nil/$PATH_REL" \
  || { echo "wrong vault - check vault=nil was passed"; exit 1; }

# Set type, repo link, and handoff tag
obsidian-cli property:set vault=nil path="$PATH_REL" name=type value=task
obsidian-cli property:set vault=nil path="$PATH_REL" name=projects type=list \
  value='["[['"$REPO"']]"]'
obsidian-cli property:set vault=nil path="$PATH_REL" name=tags type=list \
  value='["task","handoff","project/'"$REPO"'"]'
```

## Saving to Mist (Personal Repos)

Use `obsidian-cli create`. Notes go in the vault root per mist conventions.

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H%M)

obsidian-cli vault=mist create silent \
  name="$DATE $TIME $REPO handoff" \
  content="---\nproject: $REPO\nprojects:\n  - \"[[$REPO]]\"\ntype: task\nstatus: active\ntags: [handoff, coding, projects]\ndate: $DATE\n---\n\n<handoff document body>"
```

## After Saving

Report the vault and the note path/name to the user so they can find it.
