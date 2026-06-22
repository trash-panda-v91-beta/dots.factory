# Global Pi Instructions

## Repo metadata routing

Per-repo metadata (CONTEXT, ADRs, ticket notes, investigation notes) is **not** stored in the repo
itself. It lives in an Obsidian vault, picked by the git remote:

- Remote on `corp-github.example.com/*` (work) – use the **vault-nil** skill (`$VAULTS_DIR/nil`)
- Otherwise (personal `github.com`, no remote) – use the **vault-mist** skill (`$VAULTS_DIR/mist`)

Do not create `docs/adr/` or `CONTEXT.md` in any repo. If a repo has no vault note yet, run the
`setup-skills` skill.

## Stack

Mostly Nix (nix-darwin, home-manager, nixvim) and TypeScript. Check the project AGENTS.md for
project-specific rules; if absent, ask.

## General behaviour
<!-- markdownlint-disable MD041 -->

- If the default provider doesn't have vision capabilities, use pi-vision-proxy for images.
- Read relevant local files first when the answer is available in the codebase. If not, research
  online via pi-web-access. Before making a big change based on online research findings, confirm
  with me first.
- Explain risky file edits and destructive commands before executing.
- Write simply. Avoid AI-slop language – no flowery adjectives, unnecessary adverbs, or overly
  formal phrasing.
- Use en dashes (–) not em dashes (—).
- After editing or creating any file, run `lsp_diagnostics` on it. Fix all diagnostics where the
  fix is clear. If suppressing a diagnostic makes more sense than fixing it, ask the user before
  adding an ignore comment.
