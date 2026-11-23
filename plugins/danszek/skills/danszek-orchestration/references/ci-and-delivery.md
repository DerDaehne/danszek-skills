# CI and delivery

Read this before pushing, while waiting for CI, and before shipping a container or touching a shared server. Everything in the main skill applies too.

- **After every push, check every workflow on the pushed commit**, not just the one you were waiting for. A red side workflow (secret scan, lint, packaging) can stay unnoticed for days otherwise: two workflows once stayed red for six days because the push routine checked only the local gates, although this rule already existed. Put the check into the push routine itself (the loop below lists every run of the full pushed hash) and look again a few minutes later, when the slow workflows finish. When the pushed work came from an external issue (a bug report moved into the board), comment on or close that issue in the same routine: one sat open for hours after its fix was merged.
- Wait loops for CI count pending runs with a JSON query and require the expected number of workflows; a text-match condition once ended the wait while three of four workflows were still running. Query by the full commit hash (resolve it with `git rev-parse` first): a short hash returned an empty list, and a loop that read the empty list as "not yet" waited silently until its timeout. Copy this loop (GitHub CLI) instead of retyping it: retyped from memory under time pressure, the same text-match bug came back despite this rule.
  ```sh
  sha=$(git rev-parse --verify 'HEAD^{commit}'); expected=4; q='group_by(.workflowName) | map(.[0])'
  for _ in $(seq 60); do   # 30 minutes
    read -r found pending < <(gh run list --commit "$sha" --limit 100 --json workflowName,status \
      --jq "$q"' | "\(length) \(map(select(.status != "completed")) | length)"')
    [ "$found" -ge "$expected" ] && [ "$pending" -eq 0 ] && break; sleep 30
  done
  gh run list --commit "$sha" --limit 100 --json workflowName,status,conclusion --jq "$q"'[] | [.workflowName, .status, .conclusion] | @tsv'
  ```
  Green means as many lines as expected, each `completed` with `success`, `skipped` or `neutral`; fewer lines or one still running is a timeout, not a pass.
- Back-to-back merges let CI's concurrency rule cancel the earlier commit's run; confirm that the newer run contains that commit and is green instead of treating "cancelled" as a failure or as a pass.
- When CI fails but every local run is green, read the CI artifacts first (page snapshot, trace, server log) for concrete IDs and state before more local reproduction attempts: an ID of 1 in a long suite once exposed database ID reuse that no local timing reproduced.
- **Treat a first CI-only failure as a lead, not noise.** Slow runners are where races show: a two-process file-watch test (an atomic replace, then a quick second one) failed only in CI and exposed a real race the local gate never hit.
- Build tools that cache results by input (a check of an unchanged commit) replay the old verdict without running anything; force a rebuild with full logs when you need the real output.
- Run every new CI command locally on the current main before merging it; a stress job built on an option that broke 87 tests would have filed a noise issue every night.
- Keep supply-chain checks (dependency audit, licence scan) in their own CI job. A newly published advisory otherwise stops the job before the tests run and hides real failures behind it.
- A plugin for a host without a stable plugin interface pins the exact host version it was built against; the host otherwise skips it silently after its next update. A shared-library plugin also builds when it uses symbols the host never exports; compare `nm -D --undefined-only` of the plugin with the host library's exports.
- Flaky tests surface on slow runners, not on the developer machine: schedule a periodic stress run (shuffled order, repeated runs, throttled CPU) that reports without blocking the main branch, and fix flakiness in the code rather than with retries.
- **A scheduled check reports where someone reads it, and you read its result daily.** A nightly stress run commented its failure into a tracker issue for a week while two releases shipped; nobody looked at the issue, and once the first step failed, the browser tests behind it never ran at all.
- Before swapping a live container, smoke-test the new image on a spare port with an empty data directory (start, health, one negative-config start) **and** with a copy of the latest backup, so a pending migration runs on real data first; after the swap, compare row counts of the automatic pre-migration backup and the live database. Keep the previous image tag ready for rollback, and never move or overwrite a published tag: a broken release gets the next version, with the reason in the tag message.
- Adding a site to a shared reverse proxy: back up the config, append only, validate, reload gracefully (never restart), and check the existing sites before and after.
- **A release step that can fail after the tag is published:** delete the orphan tag and fix forward with a new one. Never reuse or force-move a published tag. Why: consumers may already hold it.

## Gates before pushing
1. Private-pattern scan over the outgoing diff, commit messages and file names. On a **first push**, scan every commit's patch, not just the final tree: a reference removed in a later commit still sits in history. If the repository was never pushed, squash before publishing.
2. Scan for internal references (comment ids, note links).
3. Secret scanner over history and staged changes.
4. Fast-forward push; watch CI and code scanning to green.
- Run these gates before every push, yours and every agent's, and never push while one fails or did not run. A project that wants this enforced may add its own hook (a git `pre-push` hook, or a hook in the agent host that runs the gates before a push); these skills ship none.
- **Prove each gate sees what it guards:** plant a violation once on the exact path the gate runs. A privacy scan that checked "unpushed commits" ran in a checkout where HEAD equalled the remote, saw zero commits and reported clean; a gate should report how much it saw, and "saw nothing" is a failure.
- Scope secret scans to the outgoing commits when worktrees share refs (a sibling's unpushed test nonce blocked an unrelated merge), and let CI scan the full pushed history. Narrowing a security gate is the user's decision: ask with the trade-off, never just do it. Generate secret-shaped test data at runtime instead of committing literals.
- After merges, refresh dependencies in the main checkout before running local checks — and in a worktree after rebasing it onto a main that added dependencies (type errors that vanish after `npm ci` are not findings).
