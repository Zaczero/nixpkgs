#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils jq gh nix
#shellcheck shell=bash
set -euo pipefail
cd -- "$(dirname -- "$0")"

release_json=$(
  gh release view \
    -R zen-browser/desktop \
    --json tagName,body,assets
)

url=$(
  jq -ren --argjson rel "$release_json" '
    $rel.assets[] | select(.name == "zen.source.tar.zst") | .url
  '
)
hash=$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url "$url")")

sources=$(jq -en \
  --argjson rel "$release_json" \
  --argjson prev "$(<sources.json)" \
  --arg hash "$hash" '
  {
    version: (($rel.body | capture("to Firefox (?<v>\\S+)")? | .v) // $prev.version),
    packageVersion: ($rel.tagName | ltrimstr("v")),
    hash: $hash
  }
')

echo "Updating sources.json"
echo "$sources" | tee sources.json
