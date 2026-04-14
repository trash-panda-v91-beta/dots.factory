---
name: release-please-pr
description: Use when creating PR descriptions or squash commit messages for release-please automation with multiple changes (features, fixes, breaking changes) that need individual changelog entries
---

# Release-Please PR Formatting

## Overview

Release-please automates releases based on conventional commits. When a PR contains multiple
changes, use footer syntax to represent each change individually - NOT a standard commit message
body.

## When to Use

- Creating squash commit message with 2+ changes (features/fixes/breaking changes)
- Formatting PR description for release-please automation
- Need each change as separate changelog entry

## Critical Format Rules

**Multi-change commits use FOOTER SYNTAX at bottom:**

```text
<primary-type>: <primary-description>

<primary-body>

<secondary-type>(<scope>): <secondary-description>
  <metadata-footer>: <value>
  BREAKING-CHANGE: <breaking-description>

<tertiary-type>(<scope>): <tertiary-description>
  <metadata-footer>: <value>
```

**Key rules:**

1. Primary change = standard conventional commit (top)
2. Additional changes = footers at BOTTOM (after primary body)
3. Each footer starts with conventional commit syntax
4. Footer metadata indented with 2 spaces
5. Use `BREAKING-CHANGE:` (hyphenated) not `BREAKING CHANGE:`

## Example: Multiple Changes

**Input:**

- Feature: adds v4 UUID to crypto
- Fix: unicode no longer throws exception (BREAKING)
- Feature: update encode to support unicode

**Output:**

```text
feat: adds v4 UUID to crypto

This adds support for v4 UUIDs to the library.

fix(utils): unicode no longer throws exception
  PiperOrigin-RevId: 345559154
  BREAKING-CHANGE: encode method no longer throws.
  Source-Link: googleapis/googleapis@5e0dcb2

feat(utils): update encode to support unicode
  PiperOrigin-RevId: 345559182
  Source-Link: googleapis/googleapis@e5eef86
```

## Quick Reference

| Element | Format | Example |
|---------|--------|---------|
| Primary change | `type(scope): description` + body | `feat: adds v4 UUID` |
| Footer entries | At bottom, blank line before | After primary body |
| Footer syntax | `type(scope): description` | `fix(utils): unicode bug` |
| Breaking change | `BREAKING-CHANGE:` (hyphenated) | `BREAKING-CHANGE: API changed` |
| Metadata | 2-space indent under footer | `Source-Link: googleapis/...` |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Multiple changes in body | Use footer syntax for additional changes |
| `BREAKING CHANGE:` (space) | Use `BREAKING-CHANGE:` (hyphen) |
| Footer at top | Footers must be at BOTTOM after primary body |
| No indentation on metadata | Indent metadata 2 spaces |
| Combined description | Each change needs separate footer entry |

## Red Flags - You're Doing It Wrong

These thoughts mean STOP - you're not following release-please format:

| Thought | Reality |
|---------|---------|
| "I'll combine all changes in the body" | Each change needs separate footer entry |
| "Standard conventional commit is enough" | Multi-change PRs require footer syntax |
| "BREAKING CHANGE: works fine" | Use `BREAKING-CHANGE:` (hyphenated) |
| "Footers can go anywhere" | Footers MUST be at bottom after primary body |
| "The most important goes at bottom" | Primary change at TOP, additional at BOTTOM |
| "I'll choose one primary type" | Each change gets its own type in footer |

## Markdown Styling for Squash Messages

When providing formatted output to users, use markdown code blocks:

````markdown
Here's your release-please formatted commit message:

```
feat: adds v4 UUID to crypto

This adds support for v4 UUIDs to the library.

fix(utils): unicode no longer throws exception
  BREAKING-CHANGE: encode method no longer throws.

feat(utils): update encode to support unicode
```
````

## Real-World Impact

**Without footer syntax:** release-please generates single changelog entry, loses individual changes

**With footer syntax:** Each change appears separately in CHANGELOG.md with correct version bumping
(breaking changes → major version)
