#!/usr/bin/env bash
# Links every skill into a local agent's user skill directory.
# Usage: scripts/install.sh claude   → ~/.claude/skills   (Claude Code)
#        scripts/install.sh codex    → ~/.agents/skills   (OpenAI Codex CLI)
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
case "${1:-}" in
  claude) target="$HOME/.claude/skills" ;;
  codex)  target="$HOME/.agents/skills" ;;
  *) echo "usage: $0 claude|codex" >&2; exit 2 ;;
esac
mkdir -p "$target"
for dir in "$root"/plugins/danszek/skills/*/; do
  name="$(basename "$dir")"
  ln -sfn "${dir%/}" "$target/$name"
  echo "$target/$name → ${dir%/}"
done
