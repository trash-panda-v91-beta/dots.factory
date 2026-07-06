#!/bin/sh
# Apply the standard 3-tab layout (nvim / pi / sh) to a workspace.
# Args: <workspace_id> <root_tab_id> <root_pane_id>
set -eu

ws_id=$1
tab1_id=$2
tab1_pane=$3
HERDR="$HERDR_BIN_PATH"

"$HERDR" tab rename "$tab1_id" nvim >/dev/null
"$HERDR" pane run "$tab1_pane" "nvim"

tab2_json=$("$HERDR" tab create --workspace "$ws_id" --label pi --no-focus)
tab2_pane=$(printf '%s' "$tab2_json" | jq -r '.result.root_pane.pane_id')
"$HERDR" pane run "$tab2_pane" "pi"

"$HERDR" tab create --workspace "$ws_id" --label sh --no-focus >/dev/null
