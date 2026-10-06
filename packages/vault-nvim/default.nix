# Open nvim for a vault in a separate Ghostty instance.
#
# Usage: vault-nvim <vault> [workspace]
{ writeShellApplication, aerospace, jq }:
writeShellApplication {
  name = "vault-nvim";
  runtimeInputs = [ aerospace jq ];
  text = ''
    name="''${1:?usage: vault-nvim <vault> [workspace]}"
    if [ -n "''${VAULTS_DIR:-}" ]; then
      vault="$VAULTS_DIR/$name"
    elif [ -d "$HOME/SAPDevelop/vaults/$name" ]; then
      vault="$HOME/SAPDevelop/vaults/$name"
    else
      vault="$HOME/vaults/$name"
    fi
    [ -d "$vault" ] || { echo "vault not found: $vault" >&2; exit 1; }

    find_window() {
      aerospace list-windows --monitor all --app-bundle-id com.mitchellh.ghostty --json \
        | jq -r --arg title "nvim:$name" '.[] | select(.["window-title"] == $title or .["window-title"] == "nvim" or (.["window-title"] | endswith("/nvim"))) | .["window-id"]' \
        | head -1
    }

    existing_id=$(find_window)
    if [ -n "$existing_id" ]; then
      if [ -n "''${2:-}" ]; then
        aerospace move-node-to-workspace --window-id "$existing_id" "$2" >/dev/null 2>&1 || true
        aerospace workspace "$2" >/dev/null 2>&1 || true
      fi
      aerospace focus --window-id "$existing_id"
      exit 0
    fi

    if [ -n "''${2:-}" ]; then
      aerospace workspace "$2" >/dev/null 2>&1 || true
    fi

    /usr/bin/open -na Ghostty.app --args \
      --window-save-state=never \
      --title="nvim:$name" \
      --working-directory="$vault" \
      -e "$HOME/.nix-profile/bin/nvim" --cmd "cd $vault" -c "Pick files"

    for _ in $(seq 1 50); do
      sleep 0.2
      existing_id=$(find_window)
      if [ -n "$existing_id" ]; then
        if [ -n "''${2:-}" ]; then
          aerospace move-node-to-workspace --window-id "$existing_id" "$2" >/dev/null 2>&1 || true
          aerospace workspace "$2" >/dev/null 2>&1 || true
        fi
        aerospace focus --window-id "$existing_id"
        break
      fi
    done
  '';
}
