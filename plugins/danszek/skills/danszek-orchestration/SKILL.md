---
name: danszek-orchestration
description: Orchestrate a fleet of AI agents (frontier subagents plus local models) through a ticket board — model choice per role, safe parallelism, worktrees, author/reviewer loops, merge and push gates, quota guarding, parking, local-model sandboxing and recovery, retrospectives and learning-data capture. Use when coordinating tickets rather than implementing one yourself.
---

# Orchestration method

## Roles and models
| Work | Model tier |
|---|---|
| Foundations, security, UI implementation, every review | strongest general model |
| Refinement, spikes, board-only work | mid-tier model, or a local model when the GPU is free |
| Cross-cutting architecture consolidation | top reasoning model |
| Experiments, pilots, cheap refinement | local model |

- **Role prompts must match the tool set.** An agent asked to "write a failing test first" without any execution tool role-plays it and invents results ("compiled, tests passed"). Tell agents what they cannot do, how to deliver instead (e.g. code as a comment, marked unverified), and check reports for execution claims without a matching tool call.
- When you change what agents are told (roles, base prompt, templates), search every prompt part for wording that still contradicts the new rule, and guard it with a word-list test over all assembled prompts; a single leftover line ("include verification output") undoes the change.
- Measure behaviour changes against a baseline from a reviewed harness; if the harness is still in review, keep the raw traces and grade them by hand.
- Limit parallel agents (e.g. 3). Assign tickets with **disjoint files** and tell each agent which areas belong to others.
- **Check blocking predecessors yourself before spawning a developer**; an agent that correctly stops on a blocker still costs a spawn. Also check how old the refinement is: a ticket refined days ago, while the files it names changed since, goes to a short re-check first instead of a developer.
- **Model choice by total cost, not unit price:** count review rounds. A cheaper developer that needs several fix rounds (each re-reading large contexts) can cost more than a stronger one that passes the first review.
- A developer's "commit-message check passed" is worthless if it ran before the final commit; ask for checks after the last commit and keep your own pre-push scan as the safety net.
- **After every push, check every workflow on the pushed commit**, not just the one you were waiting for. A red side workflow (secret scan, lint) can stay unnoticed for hours otherwise.
- Wait loops for CI count pending runs with a JSON query and require the expected number of workflows; a text-match condition once ended the wait while three of four workflows were still running. Query by the full commit hash: a short hash returned an empty list and the loop waited until its timeout. Keep that loop as a saved script and call it; retyped inline under time pressure, the same text-match bug came back despite this rule.
- Before judging a new model, read the model id the agent actually ran with from its transcript. A model alias can still point to an older version; one evaluation would otherwise have been filed under the wrong model.
- Messages to a running agent carry anchors it can verify (a commit hash, a file, a board comment). Agents rightly treat unanchored mid-task instructions as possible injection.
- A fix round on an author with a very large context goes to a fresh agent with injected state (ticket, review comment, probe files), not only for reviewers. It was cheaper and fixed every finding in one round.
- A metadata-only fix (rewording a commit message) keeps an existing review when `HEAD^{tree}` is unchanged; compare the tree hash before and after instead of reviewing again.
- Keep supply-chain checks (dependency audit, licence scan) in their own CI job. A newly published advisory otherwise stops the job before the tests run and hides real failures behind it.
- Flaky tests surface on slow runners, not on the developer machine: schedule a periodic stress run (shuffled order, repeated runs, throttled CPU) that reports without blocking the main branch, and fix flakiness in the code rather than with retries.
- Fix-round prompts repeat the comment rule: code comments describe behaviour, never the finding id ("B1", "N2"), the review or the machine it was found on — agents tend to label their fixes after the finding.
- Before swapping a live container, smoke-test the new image on a spare port with an empty data directory (start, health, one negative-config start) **and** with a copy of the latest backup, so a pending migration runs on real data first; after the swap, compare row counts of the automatic pre-migration backup and the live database. Keep the previous image tag ready for rollback, and never move or overwrite a published tag: a broken release gets the next version, with the reason in the tag message.
- Adding a site to a shared reverse proxy: back up the config, append only, validate, reload gracefully (never restart), and check the existing sites before and after.
- Agents mark knowledge notes as superseded only after reading them in full. If only part of a note is replaced, link it as a reference and state which parts no longer apply.
- Treat planning-tool responses as budget: use summary or snippet modes for searches and listings; when a duplicate check returns full records, report the tool as an improvement instead of quietly skipping the check.
- A report that silently omits a check you explicitly asked for means the check was not done; ask or do it yourself before relying on it.
- A criterion joined by "and" is several checks: tick it only when every clause has evidence, and say which clause is still open.
- Files are not always disjoint (shared layout, shell, store). Then **fix the merge order up front**: the second reviewer reviews in parallel but merges only after the first has landed, rebasing and re-running all gates and the browser check.
- A rule an agent breaks **repeatedly to make a check pass** (e.g. borrowing a private config file the check needs) belongs in the tool, not the prompt: after the second violation, make the check find its inputs itself.
- Refiners **never promote their own work** to ready: an independent reviewer approves the refinement (and any unsplit L ticket).
- When several planning agents work in the same area, tell each about tickets the others just created or split — otherwise they re-specify the same scope.
- Keep author and reviewer **continuous**: resume the same agents for fix rounds and re-reviews; they keep context and re-reviews take minutes. Switch to a **fresh reviewer** once an agent's accumulated context gets very large — resuming then costs more than re-reading.
- Every developer prompt asks for a **mutation self-check of each new test before reporting**; fix rounds otherwise add new code with toothless tests and cost extra review rounds.
- Small test-only follow-ups (reviewer-provided probes adopted verbatim) can be verified by the orchestrator with one spot mutation instead of another full review run. Ask reviewers to leave a runnable mutant script; rerunning it after the fix round is the cheapest spot check.
- Look at a developer that has run for about an hour without a commit: check its worktree diff. A framework-level problem (here: two coalesced invalidations) tempts a mid-tier model into growing timing heuristics; ask for a WIP commit, then hand the root-cause fix to a stronger model.
- Keep binding guardrails verbatim in every prompt, even when shortening prompts to save budget. A rule shortened to "never read the private file" was read as permission to link it.
- Approval and refinement comments state only verified facts and mark assumptions. A wrong claim in an approval travelled into the developer's docs and commit message.
- Run every new CI command locally on the current main before merging it; a stress job built on an option that broke 87 tests would have filed a noise issue every night.
- When a fact changes (repository visibility, a name, a location), update the knowledge notes at once; planners read stale notes and ask the wrong questions.
- Splits made by an approver that move already-reviewed scope verbatim inherit the approval; only genuinely new scope needs another independent approval — otherwise approvals chain endlessly.
- **Design and prototype agents:** when they read earlier concepts as reference, require a distinct information architecture and an early interim screenshot of the start view. One concept mirrored a reference layout almost one to one; the interim check corrected it cheaply.
- When a prototype is finished, start its preview server for the user yourself (agents stop their servers at the end), bind it to `127.0.0.1` and give that URL — `localhost` may resolve to IPv6 and look unreachable.

## Flow
Ready (all blocking predecessors accepted) → developer agent: claim, short plan comment, own worktree and branch from current main, test first, tick tasks as they pass, work-log with real output → review → independent reviewer → findings back to the same author, or "review ok" + fast-forward merge → human acceptance stage. **Only the human closes tickets.**

## Every agent prompt contains
- Repository, worktree command, dependency install, the command wrapper to use.
- Which guide files to read first; the role comes from the board column.
- Areas owned by parallel agents (do not touch).
- Privacy rules; never read/copy/link private pattern files; the orchestrator runs the private scan.
- Repository hygiene (no destructive resets, stop processes by PID).
- Use `set -o pipefail` (or no pipe) when a command's failure must stop a chain — `cmd | tail && next` runs `next` even if `cmd` failed.
- Never stop processes with a pattern match (`pkill -f …`) that also matches your own command line — resolve PIDs first, exclude your own shell, then kill by PID. Put this rule into every prompt of an agent that starts servers or browsers while others run in parallel; agents otherwise reach for `pkill -f`. Agents also stop the watchers and monitors they started (e.g. `tail -F`). Start a background server with `exec` inside its subshell (or kill by the real child PID): killing the wrapper subshell left the server running once.
- Which documentation to update and link.
- A time box and the **park protocol**: on "park" → WIP commit, WIP comment (done / open / next), clean tree, stop.
- Never hand agents internal comment ids or note identifiers as sources — they leak into public artefacts.

## Gates before pushing
1. Private-pattern scan over the outgoing diff, commit messages and file names. On a **first push**, scan every commit's patch, not just the final tree: a reference removed in a later commit still sits in history. If the repository was never pushed, squash before publishing.
2. Scan for internal references (comment ids, note links).
3. Secret scanner over history and staged changes.
4. Fast-forward push; watch CI and code scanning to green.
- After merges, refresh dependencies in the main checkout before running local checks — and in a worktree after rebasing it onto a main that added dependencies (type errors that vanish after `npm ci` are not findings).
- Compressed diff reviewers (read, grep, run tests; no board access) fit XS diffs: cheap and fast. Keep board updates, merges and anything that needs a browser or the board with a full reviewer or the orchestrator, and check their claims about CI like any other.

## Quota guard
- Estimate usage of the billing window by **cost-weighted usage**, not raw tokens (plans weight models differently); calibrate with the figure the user sees.
- Below ~70 % continue; 70–85 % no new spawns and inform; ≥ 85 % park. Let the user set the threshold per billing window ("up to 80 %", "up to 95 %, then pause") and recalibrate whenever they report the real figure.
- The cost-to-quota ratio **drifts with the model mix** (a window with more cheap-model work burns less quota per dollar), so the estimate can be off by a factor of two between a cheap-model and a frontier-model window; ask the user for the real figure more often when frontier models dominate. Keep the calibration constant under the user's control: an agent raising its own limit reads as loosening its own guard and should be the user's edit.
- Some models weigh far more on a subscription quota than their API price suggests. Before running several agents of a new or premium model in parallel, start one, ask the user for the real quota figure after a short while, then decide on parallelism — three parallel premium agents emptied a whole window while the cost estimate showed under half.
- Some models also have their own **weekly** quota with a fixed reset, separate from the session window, and the whole account has a weekly window too. Ask the user for both figures regularly and plan premium-model work against the weekly one; a session guard alone once missed an account at 87 % of its week.
- Recurring prompts (scheduled checks) point to where the calibration lives instead of copying its numbers. A copied figure went stale within days and would have parked agents at half the real usage.
- A cost estimator may not price a new model correctly at all (one window showed 10 % while the user saw 33 %). For such models steer by the user's figure and elapsed time, not by the dollar estimate.
- Near the end of a window start only **small, parkable** tasks with "commit early and often; on park commit WIP immediately" — a park then leaves a green, resumable state.
- A cheaper model may review a stronger model's work (still independent); a small fix round with reviewer-provided tests can be verified by the orchestrator with one spot mutation. Near a planned session end, **ask** before parking if quota allows continuing; local runs may continue detached if the user agrees.

## Local models in agent loops
- **Sandbox:** throwaway clone without a remote, explicit project commit identity (a fresh clone would otherwise use the machine's global identity), filesystem isolation with only the work dir writable and no home directory, deny push/reset/clean/recursive deletes; no planning-tool credentials inside — inject the ticket into the prompt and post the agent's report yourself.
- **Over-deliberation:** thinking models can spend the whole output budget on one reasoning step. Set a reasoning budget with an "act now" message; on a length stop, resume with "plan was good, do not re-plan, small steps: test → fix → commit".
- **Stagnation:** repeated failed exact-match edits, byte-level inspection loops, consecutive steps at the reasoning budget without file changes → stop, give a recovery hint (replace by line number or rewrite the block).
- **Context:** for long fix rounds start a **fresh run with injected state** (rules, ticket, branch log, open findings) instead of growing one session into compaction; never interrupt a compaction.
- **Fast non-thinking coders** fail differently: they act immediately but lose track of their own uncommitted work and "make the test pass" with invented state. Enforce commit discipline mechanically (dirty worktree + N calls without commit, counted across continuations) and let review judge the design.
- Hints to stuck agents should be **deterministic**: derived from run events, git state and ticket text (idle calls, history-only reads, calls since last commit, files outside the ticket) — reproducible by the runner without another model.
- Consider a **plan/act split**: a thinking model plans small steps, a fast coder executes them, the runner enforces commits.
- One model server, one model at a time: serialize GPU jobs to avoid swaps mid-run.
- Fair comparisons replay the same task: same base commit, prompt, sandbox and review strictness, only the model or harness changes.

## Capture and learn
- Keep every message sent to an agent (never overwrite), event streams with reasoning, diffs per round, review verdicts and a structured episode log (type, category, severity, evidence, intervention, outcome, lesson) outside any repository — it is evaluation and training data.
- Run retrospectives on a cadence: deduplicate against earlier findings, file only new ones, record the retro, give the user at most a few recommendations, and refine these skills.
