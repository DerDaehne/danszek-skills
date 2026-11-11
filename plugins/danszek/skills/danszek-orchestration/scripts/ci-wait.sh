#!/usr/bin/env bash
# Waits until every expected GitHub Actions workflow has finished on one commit and reports each result.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ci-wait.sh EXPECTED_WORKFLOWS [REF] [TIMEOUT_SECONDS]

Waits until at least EXPECTED_WORKFLOWS distinct workflows have a run on the
full commit hash of REF (default HEAD) and the newest run of each has
completed, then prints one line per workflow: name, status, conclusion.
Run it from inside the repository; needs git and an authenticated gh.

Exit codes:
  0  every workflow concluded success, skipped or neutral
  1  at least one workflow failed or was cancelled (a cancelled run can mean
     a newer push superseded it: check that the newer run contains this commit)
  2  timeout (default 1800 s): fewer workflows than expected, or still running
  3  usage error

Example: ci-wait.sh 4 HEAD 2400
EOF
}

poll_seconds=30

latest_run_per_workflow() {
  gh run list --commit "$1" --limit 100 --json workflowName,status,conclusion \
    --jq 'group_by(.workflowName) | map(.[0]) | .[] | [.workflowName, .status, .conclusion] | @tsv'
}

main() {
  if [[ $# -lt 1 || $# -gt 3 || ! $1 =~ ^[1-9][0-9]*$ ]]; then
    usage >&2
    exit 3
  fi
  local expected=$1 ref=${2:-HEAD} timeout=${3:-1800}
  local sha runs found pending deadline=$((SECONDS + timeout))
  sha=$(git rev-parse --verify "$ref^{commit}")
  echo "waiting for $expected workflow(s) on $sha" >&2

  while :; do
    runs=$(latest_run_per_workflow "$sha")
    found=$(grep -c . <<<"$runs" || true)
    pending=$(awk -F'\t' '$2 != "completed"' <<<"$runs" | grep -c . || true)
    if ((found >= expected && pending == 0)); then
      break
    fi
    if ((SECONDS >= deadline)); then
      printf '%s\n' "$runs"
      echo "timeout: $found of $expected workflow(s) seen, $pending still running" >&2
      exit 2
    fi
    sleep "$poll_seconds"
  done

  printf '%s\n' "$runs"
  if awk -F'\t' '$3 != "success" && $3 != "skipped" && $3 != "neutral" { bad = 1 } END { exit !bad }' <<<"$runs"; then
    exit 1
  fi
}

main "$@"
