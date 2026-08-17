#!/usr/bin/env bash
# Refresh rev + fetchFromGitHub hash for the amazon-aws vicinae extension,
# and update the committed package-lock.json from the new source.
#
# Gets the latest commit touching extensions/amazon-aws from the
# raycast/extensions repo via the GitHub API, then recomputes the
# fetchFromGitHub sparse-checkout hash via a fake-hash build.
# Rewrites modules/aspects/tool/vicinae/default.nix in place.
#
# Wired into deps-update.yml alongside refresh-pi-hashes.sh.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

FILE="modules/aspects/bundle/aws.nix"
LOCKFILE="modules/aspects/bundle/aws-ext/package-lock.json"

cur_rev=$(sed -n 's/.*rev = "\([^"]*\)";.*/\1/p' "$FILE" | head -1)
cur_hash=$(sed -n 's/.*hash = "\(sha256-[^"]*\)";.*/\1/p' "$FILE" | head -1)

echo "==> amazon-aws ext (current rev: ${cur_rev:0:12})"

new_rev=$(curl -fsSL \
  "https://api.github.com/repos/raycast/extensions/commits?path=extensions/amazon-aws&per_page=1" \
  ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
  | python3 -c "import json,sys; print(json.load(sys.stdin)[0]['sha'])")

if [[ "$new_rev" == "$cur_rev" ]]; then
  echo "  up to date"
  exit 0
fi

echo "  rev: ${cur_rev:0:12} -> ${new_rev:0:12}"

nix_out=$(nix build --impure --no-link --expr "
  let pkgs = (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
  in pkgs.fetchFromGitHub {
    owner = \"raycast\"; repo = \"extensions\";
    rev = \"$new_rev\";
    hash = \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\";
    sparseCheckout = [ \"/extensions/amazon-aws\" ];
  }
" 2>&1 || true)
new_hash=$(echo "$nix_out" | sed -n 's/.*got: *\(sha256-[^ ]*\).*/\1/p' | head -1)

[[ -z "$new_hash" ]] && { echo "  failed to compute hash"; exit 1; }

echo "  hash: ${cur_hash:7:12}... -> ${new_hash:7:12}..."

# Copy the updated package-lock.json from the newly fetched source
new_src=$(nix build --impure --no-link --print-out-paths --expr "
  let pkgs = (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
  in pkgs.fetchFromGitHub {
    owner = \"raycast\"; repo = \"extensions\";
    rev = \"$new_rev\";
    hash = \"$new_hash\";
    sparseCheckout = [ \"/extensions/amazon-aws\" ];
  }
" 2>/dev/null)
cp "$new_src/extensions/amazon-aws/package-lock.json" "$LOCKFILE"
cp "$new_src/extensions/amazon-aws/package.json" "$(dirname "$LOCKFILE")/package.json"
echo "  lockfile updated"

sed -i '' \
  -e "s|rev = \"$cur_rev\";|rev = \"$new_rev\";|" \
  -e "s|hash = \"$cur_hash\";|hash = \"$new_hash\";|" \
  "$FILE"

echo "  done"
