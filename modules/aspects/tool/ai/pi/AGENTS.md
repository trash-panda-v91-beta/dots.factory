# Global Pi Instructions

## Repo metadata routing

Per-repo metadata (CONTEXT, ADRs, ticket notes, investigation notes) is **not** stored in the repo
itself. It lives in an Obsidian vault, picked by the git remote:

- Remote on the corp GitHub host (work) - use the **vault-nil** skill (`$VAULTS_DIR/nil`)
- Otherwise (personal `github.com`, no remote) - use the **vault-mist** skill (`$VAULTS_DIR/mist`)

Do not create `docs/adr/` or `CONTEXT.md` in any repo. If a repo has no vault note yet, run the
`setup-skills` skill.

Vault artifacts are **local to me** - public/shared channels have no access to them. Never mention
or reference them in any outbound or committed text: no ADR numbers, no "see ADR NNN", no CONTEXT /
vault / Obsidian / scratchpad references in code comments, docstrings, commit messages, PR titles or
descriptions, Jira issues/comments, or code review replies. This includes bare decision identifiers
like "ADR 003" - a reader cannot open it. If the reader needs the rationale, write it directly in
your own words; never point at a path or ADR they cannot see. Keep the *why* explanation, drop the
pointer.

## Stack

Mostly Nix (nix-darwin, home-manager, nixvim) and TypeScript. Check the project AGENTS.md for
project-specific rules; if absent, ask.

## Dashes - hard constraint

Every artifact you produce - chat output, file contents, code comments, docstrings, commit
messages, PR descriptions, Jira issues, vault notes, skill output - uses `-` (U+002D, hyphen-minus)
not `–` (U+2013, en dash) or `—` (U+2014, em dash). This is non-negotiable. The agent has
historically violated this rule repeatedly and must treat it as a hard constraint, not a style
preference.

Before writing any new file or external content (Jira, Obsidian), verify no `–` or `—` characters
are present. Replace any that appear with `-`.

## General behaviour
<!-- markdownlint-disable MD041 -->

- If the default provider doesn't have vision capabilities, use pi-vision-proxy for images.
- Read relevant local files first when the answer is available in the codebase. If not, research
  online via pi-web-access. Before making a big change based on online research findings, confirm
  with me first.
- Explain risky file edits and destructive commands before executing.
- Write simply. Avoid AI-slop language - no flowery adjectives, unnecessary adverbs, or overly
  formal phrasing.
- Code comments: be brief, no AI slop, and really think if they're needed. Avoid them when
  possible - variable, function, and class names should say what they do. Prefer a clearer name
  or a smaller function over a comment. Only add a comment when it explains *why* (intent,
  trade-off, non-obvious constraint), not *what* the code already says.
- After editing or creating any file, run `lsp_diagnostics` on it. Fix all diagnostics where the
  fix is clear. If suppressing a diagnostic makes more sense than fixing it, ask the user before
  adding an ignore comment.
