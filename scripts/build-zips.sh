#!/usr/bin/env bash
# Builds one upload-ready zip per skill (dist/<skill>.zip containing the <skill>/ folder: SKILL.md plus any reference files) for Claude.ai and ChatGPT.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
skills="$root/plugins/danszek/skills"
mkdir -p "$root/dist"
for dir in "$skills"/*/; do
  name="$(basename "$dir")"
  rm -f "$root/dist/$name.zip"
  (cd "$skills" && zip -qr "$root/dist/$name.zip" "$name")
  echo "dist/$name.zip"
done
