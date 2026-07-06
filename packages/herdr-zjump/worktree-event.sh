#!/bin/sh
# worktree.created / worktree.opened hook: apply the 3-tab layout to the
# workspace herdr just created for a worktree. Guarded so worktree.opened on
# a workspace that already has tabs is a no-op.
set -eu

HERDR="$HERDR_BIN_PATH"

ws_id=$(printf '%s' "$HERDR_PLUGIN_EVENT_JSON" | jq -r '.data.workspace.workspace_id // empty')
[ -n "$ws_id" ] || exit 0

# Skip if the workspace already has more than one pane - avoids doubling up
# when worktree.opened fires on an established workspace.
pane_count=$("$HERDR" pane list --workspace "$ws_id" | jq -r '.result.panes | length')
[ "$pane_count" = "1" ] || exit 0

pane_line=$("$HERDR" pane list --workspace "$ws_id" | jq -r '.result.panes[0] | "\(.pane_id) \(.tab_id)"')
tab1_pane=${pane_line% *}
tab1_id=${pane_line#* }

exec sh "$HERDR_PLUGIN_ROOT/apply-layout.sh" "$ws_id" "$tab1_id" "$tab1_pane"
