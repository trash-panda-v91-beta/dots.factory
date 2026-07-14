#!/usr/bin/env bash
# Bump vendored Obsidian derivations to their latest GitHub release (version + hashes).
# Renovate can't recompute Nix hashes and nix-update needs pname/version attrs these
# runCommandLocal derivations don't have, so this handles both in one pass.
set -euo pipefail
cd "$(dirname "$0")"

bump() {
  local dir=$1 repo=$2
  shift 2
  local files=("$@")

  local latest
  latest=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
  local ver=${latest#v}

  local cur
  cur=$(sed -n 's/.*version = "\([^"]*\)";.*/\1/p' "$dir/default.nix")
  if [[ "$cur" == "$ver" ]]; then
    echo "$dir: up to date ($cur)"
    return
  fi
  echo "$dir: $cur -> $ver"

  sed -i '' "s|version = \"$cur\";|version = \"$ver\";|" "$dir/default.nix"

  local f
  for f in "${files[@]}"; do
    local url="https://github.com/$repo/releases/download/$latest/$f"
    local sri
    sri=$(nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url "$url" 2>/dev/null)")
    # replace the hash on the fetchurl block whose url ends in this filename
    perl -0pi -e "s{(url = \"[^\"]*/$f\";\s*\n\s*hash = \")[^\"]*(\";)}{\${1}$sri\${2}}" "$dir/default.nix"
  done
}

bump obsidian-tasknotes-plugin        callumalpass/tasknotes         main.js manifest.json styles.css
bump obsidian-minimal-settings-plugin kepano/obsidian-minimal-settings main.js manifest.json styles.css

# theme is a fetchFromGitHub with rev+hash (no release assets); bump separately
bump_repo() {
  local dir=$1 repo=$2
  local latest
  latest=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
  local cur
  cur=$(sed -n 's/.*rev = "\([^"]*\)";.*/\1/p' "$dir/default.nix")
  if [[ "$cur" == "$latest" ]]; then
    echo "$dir: up to date ($cur)"
    return
  fi
  echo "$dir: $cur -> $latest"
  local prefetch sri
  prefetch=$(nix-prefetch-url --unpack "https://github.com/$repo/archive/refs/tags/$latest.tar.gz" 2>/dev/null)
  sri=$(nix hash convert --hash-algo sha256 --to sri "$prefetch")
  sed -i '' "s|rev = \"$cur\";|rev = \"$latest\";|;s|hash = \"[^\"]*\";|hash = \"$sri\";|" "$dir/default.nix"
}

bump_repo obsidian-minimal-theme kepano/obsidian-minimal

echo "done. run: mise run build"
