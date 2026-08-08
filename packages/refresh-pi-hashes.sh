#!/usr/bin/env bash
# Refresh outputHash for pi-* packages that use a whole-build FOD.
# See .agents/skills/pi-package-builds/SKILL.md for why they're FODs.
#
# Source revisions for these packages are pinned via npins (see
# npins/sources.json). When you run `npins update <pkg>`, the source rev
# bumps, but the FOD outputHash in the package's default.nix stays stale.
# This script rebuilds each affected package, catches the hash mismatch,
# and rewrites default.nix in place. Wired into `mise run update`.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# Packages whose default.nix carries a top-level
# `outputHash = "sha256-...";` tied to an npins source.
pkgs=(
  pi-web-access
  pi-mcp-adapter
  pi-neuralwatt
)

for pkg in "${pkgs[@]}"; do
  file="packages/$pkg/default.nix"
  cur=$(sed -n 's/.*outputHash = "\(sha256-[^"]*\)".*/\1/p' "$file")
  echo "==> $pkg (current: $cur)"

  # On hash mismatch nix prints "got: sha256-<new>".
  log=$(nix build --impure --no-link --expr "
    let f = builtins.getFlake (toString ./.);
        pkgs = f.inputs.nixpkgs.legacyPackages.aarch64-darwin;
    in pkgs.callPackage ./packages/$pkg { inputs = f.inputs; }
  " 2>&1 || true)

  new=$(echo "$log" | sed -n 's/.*got: *\(sha256-[^ ]*\).*/\1/p' | head -1)

  if [[ -z "$new" ]]; then
    if echo "$log" | grep -q "error:"; then
      echo "  build failed with something other than a hash mismatch:"
      echo "$log" | grep -E "error:|Last" | head -5
      exit 1
    fi
    echo "  up to date"
    continue
  fi

  if [[ "$new" == "$cur" ]]; then
    echo "  up to date (hash unchanged)"
    continue
  fi

  echo "  $cur -> $new"
  sed -i '' "s|outputHash = \"$cur\";|outputHash = \"$new\";|" "$file"
done

echo
echo "Done. Re-run 'mise run build' to verify."
