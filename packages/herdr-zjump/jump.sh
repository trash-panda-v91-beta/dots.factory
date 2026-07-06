#!/bin/sh
# Overlay-pane entrypoint: zoxide picker -> new workspace + 3-tab layout.
set -eu

dir=$(zoxide query -i) || exit 0
[ -n "$dir" ] || exit 0

HERDR="$HERDR_BIN_PATH"

create_json=$("$HERDR" workspace create --cwd "$dir" --focus)
ws_id=$(printf '%s' "$create_json" | jq -r '.result.workspace.workspace_id')
tab1_id=$(printf '%s' "$create_json" | jq -r '.result.tab.tab_id')
tab1_pane=$(printf '%s' "$create_json" | jq -r '.result.root_pane.pane_id')

exec sh "$HERDR_PLUGIN_ROOT/apply-layout.sh" "$ws_id" "$tab1_id" "$tab1_pane"
