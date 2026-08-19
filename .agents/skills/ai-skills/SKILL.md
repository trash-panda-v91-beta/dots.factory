---
name: ai-skills
description: Locate and edit agent skills in this repo. Use when looking for a skill file, editing a skill's trigger phrases, adding a new skill, or debugging why an agent is not firing the right skill.
---

# ai-skills

Two locations, different scopes.

## Repo-local skills

`.agents/skills/<name>/SKILL.md`

Dotfiles-specific workflows. Active immediately - no build step, but new directories need `git add`.

Current skills: `add-aspect`, `den`, `keymaps`, `pi-package-builds`, `updates`, `ai-skills`.

## Tool-aspect skills

`modules/aspects/tool/ai/skills/<name>.md`

General coding/workflow skills deployed to all machines via the `ai` tool aspect.
Edit here; take effect after `mise run switch`.

## Editing a skill

The `description:` frontmatter field is what agents match against. Make trigger phrases explicit and varied. Body changes take effect immediately for repo-local skills.

## Adding a skill

- Repo-local: `mkdir .agents/skills/<name> && touch .agents/skills/<name>/SKILL.md`, then `git add`.
- Tool-aspect: add `<name>.md` to `modules/aspects/tool/ai/skills/`.
- Add a pointer in `AGENTS.md` Conventions so it appears in the available skills list.
