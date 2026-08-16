---
name: review-comments
description: Evaluate PR review comments - especially bot-generated ones - to decide what to apply, what to skip, and what to push back on. Use when the user says "check review comments", "review bot feedback", "should I apply these comments", "any useful feedback on the PR", or asks to triage PR comments.
---

PR review comments range from blocking bugs to noise. The job is to separate signal from sediment - fast.

## Process

### 1. Fetch comments

`gh pr view --comments` only returns top-level PR comments. Inline review comments (on specific lines) require the API directly:

```bash
# Top-level PR comments only
gh pr view --comments
gh pr view <number> --comments

# Inline code review comments (line-specific) - always run this too
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '.[] | "[\(.path):\(.line // .original_line)] \(.user.login): \(.body)"'
```

Run both. Inline comments are where actionable bugs are most often posted. Group by author. Bot comments tend to cluster - read them last.

### 2. Triage each comment

Apply this filter in order - stop at the first that matches:

1. **Blocks correctness** - wrong behavior, data loss, security hole, broken contract. Apply immediately.
2. **Fixes a real defect** - a genuine bug, not a hypothetical. Apply.
3. **Enforces a rule already in the codebase** - a lint/format violation the tooling missed, an existing convention broken. Apply.
4. **Style preference with no right answer** - skip unless the reviewer is the codebase owner and has said this is a hard rule.
5. **Already handled** - the comment describes a problem the current code doesn't have, or was fixed by a later commit. Skip.
6. **Speculation** - "this might fail if...", "you could also consider...", "what about edge case X". Treat as input, not instruction. Apply only if you agree after checking.

### 3. Bot comments - extra skepticism

Bots summarise diffs and flag patterns. They are useful for catching obvious things (missing `---` in YAML, wrong permissions) and useless for anything requiring intent (architecture choices, why something was done a certain way).

For each bot comment:

- **Reproduce the claimed problem** before acting. Run the linter, check the schema, read the actual error. If you cannot reproduce it, skip.
- **Check if the fix is already in** - bots often lag behind recent commits and flag things already resolved.
- **Ignore "consider also..." suggestions** unless they catch a real defect. Bots generate alternatives to look thorough; that is not a reason to act.
- **Never apply a bot's architectural suggestion** without thinking through the actual impact in this codebase.

### 4. Apply or close

For each comment you apply: make the fix, note what you changed.

For each comment you skip: be ready to explain why in one sentence if asked. You don't need to reply to every comment, but replying is worth it when the thread carries a real question or when your "rejecting because..." reasoning will be useful to a future reader.

### 5. Reply and resolve (GitHub Enterprise)

**Before sending any reply**, run `leak-check` on the reply body. Reviewers see
the PR, not your vault - never write `see ADR NNN`, `per the CONTEXT note`,
`in the vault`, or any path they cannot open. If they need the reasoning,
put the reasoning in the reply directly.

`gh pr comment` posts a top-level comment, not a reply on a review thread. For inline replies, hit the API directly. On GitHub Enterprise Server the PR number MUST be in the path - `repos/{owner}/{repo}/pulls/comments/{id}/replies` (no PR number) returns 404 on GHES 3.19.

**Reply to one comment:**

```bash
gh api "repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies" \
  -f body="Fixed in abc1234."
```

**Reply to a batch** (e.g. answering every bot flag on one review):

```bash
reply() {
  gh api "repos/{owner}/{repo}/pulls/{pr}/comments/$1/replies" \
    -f body="$2" --jq '.id // .message'
}
reply 12345 'Removed in abc1234.'
reply 67890 'Fixed in abc1234 - added a unit test for the multi-package case.'
```

**Resolve the thread.** Replies do not resolve the thread; it stays open until you resolve it explicitly. REST doesn't cover this - use GraphQL. Two calls: one to find the thread ID for the comment you just replied to (`databaseId` on the GraphQL comment matches the REST comment `id`), one to resolve it.

```bash
# List threads with their comment databaseIds:
gh api graphql -f query='
  query($owner:String!,$repo:String!,$pr:Int!){
    repository(owner:$owner,name:$repo){
      pullRequest(number:$pr){
        reviewThreads(first:100){
          nodes{ id isResolved comments(first:1){nodes{databaseId}} }
        }
      }
    }
  }' -F owner={owner} -F repo={repo} -F pr={pr}

# Resolve one:
gh api graphql -f query='
  mutation($id:ID!){
    resolveReviewThread(input:{threadId:$id}){ thread{ isResolved } }
  }' -f id="<threadId>"
```

Reply first, resolve second. A resolved thread with no reply is fine for pure nits you're skipping silently; a reply + resolve is the right shape when you're rejecting a bot flag and want the reasoning captured.

### 6. Push

```bash
git add <files> && git commit -m "fix: address PR review comments" && git push
```

One commit per logical group of fixes, not one per comment.

### 7. Loop back if the fix needs real work

Applying a review comment often means writing new code, not just tweaking a line.
When that happens, hand off to `coding` for the next cycle - red / green /
refactor, then back through `review` before pushing.

## Signal vs noise at a glance

| Type | Default action |
|---|---|
| CI failure called out by bot | Verify and fix |
| Missing required file header / marker | Fix |
| Security or permissions issue | Fix |
| "You could simplify this by..." | Skip unless clearly better |
| "Consider handling edge case X" | Check if X is real; skip if not |
| Architecture suggestion from bot | Skip |
| Stale comment on already-fixed code | Skip |
