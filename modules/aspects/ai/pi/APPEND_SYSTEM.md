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
