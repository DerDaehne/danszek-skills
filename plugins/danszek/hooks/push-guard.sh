#!/usr/bin/env bash
# PreToolUse hook for Bash: runs the project's push gate before a `git push` and blocks the push when the gate fails.
set -uo pipefail

usage() {
  cat <<'USAGE'
push-guard.sh — Claude Code PreToolUse hook (matcher Bash), installed by the danszek plugin.

Reads the hook's JSON from stdin. If the Bash command contains a `git push`
(also `git -C <dir> push`, `git -c k=v push`, inside `&&`, `;`, `|` chains) and
the project provides an executable gate, runs the gate in the project directory:
  exit 0  gate passed, or no push, or no gate: the command runs
  exit 2  gate failed: the push is blocked, the gate's output goes to stderr

Gate: $DANSZEK_PUSH_GATE if set, else $CLAUDE_PROJECT_DIR/scripts/pre-push-gate.
No gate, no cost: without an executable gate the hook exits 0 at once.
Needs only bash; it reads stdin and runs the gate, nothing else.
USAGE
}

case "${1:-}" in -h|--help) usage; exit 0 ;; esac

input="$(cat)"

# The command is the only "command" key in a PreToolUse payload; the regex reads its JSON string without jq.
# ponytail: matches on the still-escaped JSON text, so a quoted path with spaces after -C is not recognised.
string='"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)"'
[[ $input =~ $string ]] || exit 0
command="${BASH_REMATCH[1]//\\n/;}"

separator='(^|[;&|({`[:space:]])'
options='([[:space:]]+-[^[:space:]]+([[:space:]]+[^-;&|[:space:]][^;&|[:space:]]*)?)*'
push="${separator}git${options}[[:space:]]+push([[:space:];&|)]|$)"
[[ $command =~ $push ]] || exit 0

project="${CLAUDE_PROJECT_DIR:-$PWD}"
gate="${DANSZEK_PUSH_GATE:-$project/scripts/pre-push-gate}"
[[ -f $gate && -x $gate ]] || exit 0

output="$(cd "$project" && "$gate" </dev/null 2>&1)"
status=$?
((status == 0)) && exit 0
printf 'push blocked: %s exited %d\n%s\n' "$gate" "$status" "$output" >&2
exit 2
