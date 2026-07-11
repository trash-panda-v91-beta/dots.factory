# Generic vault-workspace launcher, shared by dots.factory (mist) and
# dots.corpo (nil). Opens a two-window accordion aerospace workspace:
#   - Obsidian pointed at the vault, routed by window title
#   - Ghostty running herdr in a vault-rooted workspace, routed by window-id
#
# Usage: vault-workspace <session> <workspace>
#   session   = Obsidian vault name + herdr session name (e.g. "mist", "nil")
#   workspace = aerospace workspace letter (e.g. "m", "n")
#
# The vault path is resolved at runtime from $VAULTS_DIR so the same binary
# works on PMB ($VAULTS_DIR=~/vaults) and CMB ($VAULTS_DIR=~/SAPDevelop/vaults).
{
  writeShellApplication,
  aerospace,
  herdr,
  jq,
}:
writeShellApplication {
  name = "vault-workspace";
  runtimeInputs = [
    aerospace
    herdr
    jq
  ];
  # /usr/bin/open + /usr/bin/osascript are macOS system tools, called by abspath.
  text = ''
    session="''${1:?usage: vault-workspace <session> <workspace>}"
    workspace="''${2:?usage: vault-workspace <session> <workspace>}"
    vault="''${VAULTS_DIR:?VAULTS_DIR is not set}/$session"

    ghostty_ids() {
      aerospace list-windows --monitor all --app-bundle-id com.mitchellh.ghostty --json \
        | jq -r '.[]["window-id"]'
    }

    move_obsidian_by_title() {
      aerospace list-windows --monitor all --app-bundle-id md.obsidian --json \
        | jq -r --arg m "- $session - Obsidian" '.[] | select(.["window-title"] | contains($m)) | .["window-id"]' \
        | while read -r wid; do
            [ -n "$wid" ] && aerospace move-node-to-workspace --window-id "$wid" "$workspace"
          done
    }

    # herdr launcher: ensure the session has a workspace rooted at the vault
    # (herdr attach ignores process cwd), matching on label since `workspace
    # list` exposes no cwd - avoids piling up duplicate workspaces per launch.
    herdr_cmd="if ! herdr --session $session workspace list 2>/dev/null | jq -e '.result.workspaces[] | select(.label == \"$session\")' >/dev/null 2>&1; then herdr --session $session workspace create --cwd \"$vault\" --label $session --no-focus >/dev/null 2>&1 || true; fi; exec herdr --session $session"

    # Obsidian: open the vault if not already placed, then route by title.
    if [ "$(aerospace list-windows --workspace "$workspace" --app-bundle-id md.obsidian --count)" = "0" ]; then
      /usr/bin/open "obsidian://open?vault=$session"
      for _ in $(seq 1 25); do
        sleep 0.2
        move_obsidian_by_title
        [ "$(aerospace list-windows --workspace "$workspace" --app-bundle-id md.obsidian --count)" != "0" ] && break
      done
    fi

    # Ghostty: spawn a herdr window, place it by captured window-id.
    if [ "$(aerospace list-windows --workspace "$workspace" --app-bundle-id com.mitchellh.ghostty --count)" = "0" ]; then
      before="$(ghostty_ids)"
      /usr/bin/osascript -e "
        tell application \"Ghostty\"
          set cfg to new surface configuration
          set command of cfg to \"sh -lc '$herdr_cmd'\"
          new window with configuration cfg
        end tell"
      for _ in $(seq 1 25); do
        sleep 0.2
        new_id="$(comm -13 <(echo "$before" | sort) <(ghostty_ids | sort) | head -1)"
        if [ -n "$new_id" ]; then
          aerospace move-node-to-workspace --window-id "$new_id" "$workspace"
          break
        fi
      done
    fi

    aerospace layout --workspace "$workspace" accordion 2>/dev/null || true
  '';
}
