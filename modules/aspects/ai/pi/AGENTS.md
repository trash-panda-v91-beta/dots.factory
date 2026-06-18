# Global Pi Instructions

## Repo metadata routing

Per-repo metadata (CONTEXT, ADRs, ticket notes, investigation notes) is **not** stored in the repo itself. It lives in an Obsidian vault, picked by the git remote:

- Remote on `github.concur.com/*` (work / SAP) – use the **vault-nil** skill (`~/SAPDevelop/vaults/nil`)
- Otherwise (personal `github.com`, no remote) – use the **vault-mist** skill (`~/vaults/mist`)

Do not create `docs/adr/` or `CONTEXT.md` in any repo. If a repo has no vault note yet, run the `setup-skills` skill.

## Stack

Mostly Nix (nix-darwin, home-manager, nixvim) and TypeScript. Check the project AGENTS.md for project-specific rules; if absent, ask.
