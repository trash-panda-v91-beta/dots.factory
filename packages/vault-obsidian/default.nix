# Focus (or open) the Obsidian window in a vault workspace, fullscreen.
# Ensures vault-workspace ran first, then focuses the Obsidian window.
#
# Usage: vault-obsidian <session> <workspace>
{
  writeShellApplication,
  aerospace,
  vault-workspace,
  jq,
}:
writeShellApplication {
  name = "vault-obsidian";
  runtimeInputs = [
    aerospace
    vault-workspace
    jq
  ];
  text = ''
    session="''${1:?usage: vault-obsidian <session> <workspace>}"
    workspace="''${2:?usage: vault-obsidian <session> <workspace>}"

    # Ensure vault workspace is open
    vault-workspace "$session" "$workspace"

    obs_id=$(aerospace list-windows --workspace "$workspace" --app-bundle-id md.obsidian --json \
      | jq -r '.[0]["window-id"] // empty')

    if [ -n "$obs_id" ]; then
      aerospace workspace "$workspace"
      aerospace layout --workspace "$workspace" --root accordion
      aerospace focus --window-id "$obs_id"
    fi
  '';
}
