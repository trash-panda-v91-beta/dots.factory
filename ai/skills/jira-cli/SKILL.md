---
name: jira-cli
description: Use when working with Jira issues, epics, sprints via command line, searching tickets, creating/editing issues, or managing Jira workflows
---

# JiraCLI

Interactive command line tool for Atlassian Jira. Avoid the Jira UI for common workflows: issue
search, creation, transitions, sprints, and epics.

## When to Use

- Searching and filtering Jira issues
- Creating, editing, or cloning issues
- Managing issue transitions and assignments
- Working with epics and sprints
- Bulk operations on tickets
- Scripting Jira workflows

## When NOT to Use

- Complex custom field operations (may need web UI)
- Admin configuration tasks
- Advanced reporting (use Jira dashboards)

## Prerequisites

Assumes jira-cli is installed and configured (`jira init` completed, `JIRA_API_TOKEN` set).

For multiple projects, use `--config` flag or set `JIRA_CONFIG_FILE` environment variable.

## Issue Commands

### List & Search

```bash
# Recent issues
jira issue list

# Created in last 7 days
jira issue list --created -7d

# Status filter
jira issue list -s"To Do"

# Assigned to me
jira issue list -a$(jira me)

# Unassigned, created this week
jira issue list -ax --created week

# High priority, in progress, with labels
jira issue list -yHigh -s"In Progress" -lbackend -l"high-prio"

# Issues I'm watching
jira issue list -w

# Custom JQL within project
jira issue list -q "summary ~ cli"

# Plain text output (for scripting)
jira issue list --plain

# CSV or JSON output
jira issue list --csv
jira issue list --raw

# Order by rank (as in UI)
jira issue list --order-by rank --reverse
```

### Create

```bash
# Interactive creation
jira issue create

# Non-interactive with parameters
jira issue create -tBug -s"Bug title" -yHigh -lbug -b"Description" --no-input

# Attach to epic on creation
jira issue create -tStory -s"Story title" -PEPIC-42

# Load description from template
jira issue create --template /path/to/template.md
jira issue create --template -  # From stdin

# Pipe description
echo "Description from stdin" | jira issue create -s"Title" -tTask

# Custom fields
jira issue create --custom "customfield_10001=value"
```

### Edit

```bash
# Interactive edit
jira issue edit ISSUE-1

# Update fields
jira issue edit ISSUE-1 -s"New title" -yHigh -lurgent

# Non-interactive
jira issue edit ISSUE-1 -s"Updated" --no-input

# Remove/add labels, components, fixVersions
# Use minus (-) to remove, no prefix to add
jira issue edit ISSUE-1 --label -p2 --label p1 \
  --component -FE --component BE \
  --fix-version -v1.0 --fix-version v2.0
```

### View

```bash
# View issue details in terminal
jira issue view ISSUE-1

# Show 5 recent comments
jira issue view ISSUE-1 --comments 5
```

### Assign

```bash
# Interactive assignment
jira issue assign

# Assign to user
jira issue assign ISSUE-1 "User Name"

# Assign to self
jira issue assign ISSUE-1 $(jira me)

# Assign to default assignee
jira issue assign ISSUE-1 default

# Unassign
jira issue assign ISSUE-1 x
```

### Transition

```bash
# Interactive transition
jira issue move

# Move to status
jira issue move ISSUE-1 "In Progress"

# Add comment during transition
jira issue move ISSUE-1 "In Progress" --comment "Started work"

# Set resolution and assign while moving
jira issue move ISSUE-1 Done -RFixed -a$(jira me)
```

### Link

```bash
# Link two issues
jira issue link ISSUE-1 ISSUE-2 Blocks

# Add remote web link
jira issue link remote ISSUE-1 https://example.com "Link text"

# Unlink issues
jira issue unlink ISSUE-1 ISSUE-2
```

### Clone

```bash
# Clone with interactive prompt
jira issue clone ISSUE-1

# Clone and modify fields
jira issue clone ISSUE-1 -s"Modified title" -yHigh -a$(jira me)

# Find and replace in summary/description
jira issue clone ISSUE-1 -H"find this:replace with this"
```

### Delete

```bash
# Delete issue
jira issue delete ISSUE-1

# Delete with subtasks
jira issue delete ISSUE-1 --cascade
```

### Comments

```bash
# Add comment interactively
jira issue comment add

# Add comment directly
jira issue comment add ISSUE-1 "Comment text"

# Internal comment
jira issue comment add ISSUE-1 "Internal note" --internal

# From template
jira issue comment add ISSUE-1 --template /path/to/comment.md

# From stdin
echo "Comment from pipe" | jira issue comment add ISSUE-1
```

### Worklog

```bash
# Add worklog interactively
jira issue worklog add

# Log time with no prompt
jira issue worklog add ISSUE-1 "2d 3h 30m" --no-input

# Add comment with worklog
jira issue worklog add ISSUE-1 "10m" --comment "Quick fix" --no-input
```

## Epic Commands

```bash
# List epics (explorer view)
jira epic list

# List epics (table view)
jira epic list --table

# Filter epics (supports same filters as issue list)
jira epic list -r$(jira me) -sOpen

# List issues in epic
jira epic list EPIC-1

# Filter epic issues
jira epic list EPIC-1 -ax -yHigh

# Create epic
jira epic create
jira epic create -n"Epic name" -s"Summary" -yHigh

# Add issues to epic (up to 50)
jira epic add EPIC-1 ISSUE-1 ISSUE-2

# Remove issues from epic (up to 50)
jira epic remove ISSUE-1 ISSUE-2
```

## Sprint Commands

```bash
# List sprints (explorer view)
jira sprint list

# List sprints (table view)
jira sprint list --table

# Current active sprint
jira sprint list --current

# Current sprint, assigned to me
jira sprint list --current -a$(jira me)

# Previous/next sprint
jira sprint list --prev
jira sprint list --next

# Future and active sprints
jira sprint list --state future,active

# Issues in specific sprint (use sprint ID)
jira sprint list SPRINT_ID

# Filter sprint issues
jira sprint list SPRINT_ID -yHigh -a$(jira me)

# Order by rank
jira sprint list SPRINT_ID --order-by rank --reverse

# Add issues to sprint (up to 50)
jira sprint add SPRINT_ID ISSUE-1 ISSUE-2
```

## Other Commands

```bash
# Open project in browser
jira open

# Open specific issue in browser
jira open ISSUE-1

# List all projects
jira project list

# List boards in project
jira board list

# List releases (versions)
jira release list
jira release list --project KEY
```

## Scripting Examples

### Plain Output for Scripts

```bash
# Use --plain flag for simple layout
jira issue list --plain --columns created --no-headers

# Output formats
jira issue list --csv  # CSV format
jira issue list --raw  # JSON format
```

### Tickets per Day This Month

```bash
tickets=$(jira issue list --created month --plain --columns created --no-headers \
  | awk '{print $2}' | awk -F'-' '{print $3}' | sort -n | uniq -c)

echo "${tickets}" | while read -r line; do
  day=$(echo "${line}" | awk '{print $2}')
  count=$(echo "${line}" | awk '{print $1}')
  printf "Day #%s: %s\n" "${day}" "${count}"
done
```

### Issues per Sprint

```bash
sprints=$(jira sprint list --table --plain --columns id,name --no-headers)

echo "${sprints}" | while IFS=$'\t' read -r id name; do
  count=$(jira sprint list "${id}" --plain --no-headers 2>/dev/null | wc -l)
  printf "%10s: %3d\n" "${name}" $((count))
done
```

## Common Patterns

### Daily Workflow

```bash
# What's on my plate today?
jira sprint list --current -a$(jira me)

# What did I work on recently?
jira issue list --history

# Start work on issue
jira issue assign ISSUE-1 $(jira me)
jira issue move ISSUE-1 "In Progress"
```

### Filtering Combinations

```bash
# High priority bugs assigned to me
jira issue list -tBug -yHigh -a$(jira me)

# Open issues without assignee
jira issue list -sopen -ax

# Issues created this week, not done
jira issue list --created week -s~Done

# Watching tickets in specific project
jira issue list -w -pPROJECT
```

### Time-Based Queries

```bash
# Created within an hour
jira issue list --created -1h

# Updated in last 30 minutes
jira issue list --updated -30m

# Created before 6 months ago
jira issue list --created-before -24w
```

## Quick Reference

| Filter | Flag | Example |
|--------|------|---------|
| Status | `-s` | `-s"To Do"` `-s~Done` |
| Assignee | `-a` | `-a"User"` `-ax` (unassigned) |
| Reporter | `-r` | `-r$(jira me)` |
| Type | `-t` | `-tBug` `-tStory` |
| Priority | `-y` | `-yHigh` `-yMedium` |
| Labels | `-l` | `-lbackend` `-lurgent` |
| Component | `-C` | `-CBackend` |
| Resolution | `-R` | `-RFixed` `-R"Won't Do"` |
| Watching | `-w` | `-w` |
| Created | `--created` | `--created -7d` `--created week` |
| Updated | `--updated` | `--updated -1h` |
| History | `--history` | View recently opened |

## Tips

- Use `~` as NOT operator: `-s~Done` (status not Done), `-ax` (not unassigned)
- Combine filters: `-a$(jira me) -yHigh -s"In Progress" -lbackend`
- Use `$(jira me)` to reference yourself in scripts
- Use `--plain` for scripting, `--csv` or `--raw` for data export
- Use `--no-input` to skip interactive prompts
- Shell completion: `jira completion --help`

## Known Limitations

- Not all Atlassian document nodes render perfectly in terminal
- Some complex custom fields may require web UI
- Non-English on-premise installations may need manual config edits

## More Resources

- GitHub: <https://github.com/ankitpokhrel/jira-cli>
- Installation guide: <https://github.com/ankitpokhrel/jira-cli/wiki/Installation>
- FAQs: <https://github.com/ankitpokhrel/jira-cli/discussions/categories/faqs>
