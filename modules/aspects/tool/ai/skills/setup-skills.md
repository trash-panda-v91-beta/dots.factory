---
name: setup-skills
description: Onboard the current repo into the vault workflow - write its CONTEXT note. Use when a repo has no CONTEXT yet, when the user says "onboard this repo" / "set up skills" / "create the CONTEXT note", or when another skill (orient, coding, domain-modeling, diagnosing-bugs) discovers a missing CONTEXT and needs to bootstrap.
---

# setup-skills

Onboard the current repo: interview the user briefly, write `<repo>.md` in the
right vault. That's it.

Everything about vault selection, structure, and CONTEXT frontmatter lives in
the `vault` skill.

## 1. Pick the vault

Follow the `vault` skill's selection rule. On PMB this is always `mist`; on CMB
`vault-nil` overrides to `nil` for work repos.

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
```

Ask the user if the canonical name should differ from the repo directory (e.g.
a family of related repos sharing a project label). Default: use the repo name.

## 2. Bail if already onboarded

```bash
test -f "$VAULTS_DIR/$VAULT/$REPO.md" && { echo "already onboarded"; exit 0; }
```

Never overwrite an existing CONTEXT.

## 3. Interview

Three short questions - the user is likely at a keyboard, not writing an essay:

1. **What does this repo do?** (one paragraph)
2. **Any domain terms an agent should know?** (glossary seed)
3. **Any conventions or gotchas?** (constraints seed)

Skip a question if the user has nothing. Short beats padded.

## 4. Write the note

```bash
cat > "$VAULTS_DIR/$VAULT/$REPO.md" <<EOF
---
project: $REPO
projects:
  - "[[$REPO]]"
type: context
status: active
tags: [coding]
date: $(date +%Y-%m-%d)
---

# $REPO

<paragraph from Q1>

## Domain

<Q2 answers, one term per line>

## Constraints

<Q3 answers>

## Links

- Repo: $(git remote get-url origin 2>/dev/null || echo "<none>")
EOF
```

Follow the vault writing rule: brief and human, dev-note voice, hyphen-minus
only. See `vault` skill. **Link everything that could plausibly become a note**
in the Domain and Constraints sections - technologies, tools, vendors, people,
domain terms, patterns. Cast wide. Unresolved links become useful backlinks
later.

## 5. Done

Tell the user:

- CONTEXT note at `$VAULTS_DIR/$VAULT/$REPO.md`
- Future ADRs: `<repo> - ADR NNN - <slug>.md` at vault root (see `vault`)
- The `orient` skill will pick it up next session
