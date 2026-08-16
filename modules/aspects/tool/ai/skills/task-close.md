---
name: task-close
description: Mark a task done - flip vault status and close the tracker ticket if one exists. Auto-fires when the user says "close this task", "mark done", "we're done here", "task complete", "wrap up this ticket", "finish this task", or when a merged PR clearly resolves an open task in the current session's context.
---

# task-close

Close one task. Vault + tracker adapter if any.

## 1. Identify the task

- **Already in context** (loaded by `orient` or referenced by name / CAT key):
  use it.
- **User gives a tracker key** (e.g. a CAT / JIRA / GH issue key like `AAA-1234` or `#42`): find the vault note by that
  key.
  ```bash
  obsidian-cli vault=$VAULT search query='[issue: "<KEY>"]' format=json
  ```
- **User gives a title fragment**: search by title.
  ```bash
  obsidian-cli vault=$VAULT search query='<title fragment>' format=json
  ```

If more than one result, confirm which one before closing.

## 2. Flip vault status

```bash
obsidian-cli property:set vault=$VAULT path="$PATH_REL" name=status value=done
```

TaskNotes adds the `archived` tag on the status flip. The file stays at vault
root (`moveArchivedTasks = false` in home-manager).

## 3. Adapter fires if configured

- **mist** - done.
- **nil** - if the task has `issue:` set, hand off to `vault-nil`. It closes
  the CAT ticket via the `jira-cli` closing recipe (the older `-RFixed` flag
  is broken - see `jira-cli` for the working transition sequence).

If `issue:` is empty on nil (draft task, never promoted), skip the tracker
step and just close the vault side. Warn the user that no CAT ticket existed.

## 4. Report

- vault: status = done
- tracker: closed with CAT key (if adapter fired)
- if the task had `blockedBy` relations on other open tasks - name them so the
  user can unblock the successors if wanted.
