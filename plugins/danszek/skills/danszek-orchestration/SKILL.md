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
- Limit parallel agents (e.g. 3). Assign tickets with **disjoint files** and tell each agent which areas belong to others.
- Keep author and reviewer **continuous**: resume the same agents for fix rounds and re-reviews; they keep context and re-reviews take minutes.

## Flow
Ready (all blocking predecessors accepted) → developer agent: claim, short plan comment, own worktree and branch from current main, test first, tick tasks as they pass, work-log with real output → review → independent reviewer → findings back to the same author, or "review ok" + fast-forward merge → human acceptance stage. **Only the human closes tickets.**

## Every agent prompt contains
- Repository, worktree command, dependency install, the command wrapper to use.
- Which guide files to read first; the role comes from the board column.
- Areas owned by parallel agents (do not touch).
- Privacy rules; never read/copy/link private pattern files; the orchestrator runs the private scan.
- Repository hygiene (no destructive resets, stop processes by PID).
- Which documentation to update and link.
- A time box and the **park protocol**: on "park" → WIP commit, WIP comment (done / open / next), clean tree, stop.
- Never hand agents internal comment ids or note identifiers as sources — they leak into public artefacts.

## Gates before pushing
1. Private-pattern scan over the outgoing diff, commit messages and file names.
2. Scan for internal references (comment ids, note links).
3. Secret scanner over history and staged changes.
4. Fast-forward push; watch CI and code scanning to green.
- After merges, refresh dependencies in the main checkout before running local checks.

## Quota guard
- Estimate usage of the billing window by **cost-weighted usage**, not raw tokens (plans weight models differently); calibrate with the figure the user sees.
- Below ~70 % continue; 70–85 % no new spawns and inform; ≥ 85 % park. Near a planned session end, **ask** before parking if quota allows continuing; local runs may continue detached if the user agrees.

## Local models in agent loops
- **Sandbox:** throwaway clone without a remote, explicit project commit identity (a fresh clone would otherwise use the machine's global identity), filesystem isolation with only the work dir writable and no home directory, deny push/reset/clean/recursive deletes; no planning-tool credentials inside — inject the ticket into the prompt and post the agent's report yourself.
- **Over-deliberation:** thinking models can spend the whole output budget on one reasoning step. Set a reasoning budget with an "act now" message; on a length stop, resume with "plan was good, do not re-plan, small steps: test → fix → commit".
- **Stagnation:** repeated failed exact-match edits, byte-level inspection loops, consecutive steps at the reasoning budget without file changes → stop, give a recovery hint (replace by line number or rewrite the block).
- **Context:** for long fix rounds start a **fresh run with injected state** (rules, ticket, branch log, open findings) instead of growing one session into compaction; never interrupt a compaction.
- One model server, one model at a time: serialize GPU jobs to avoid swaps mid-run.
- Fair comparisons replay the same task: same base commit, prompt, sandbox and review strictness, only the model or harness changes.

## Capture and learn
- Keep every message sent to an agent (never overwrite), event streams with reasoning, diffs per round, review verdicts and a structured episode log (type, category, severity, evidence, intervention, outcome, lesson) outside any repository — it is evaluation and training data.
- Run retrospectives on a cadence: deduplicate against earlier findings, file only new ones, record the retro, give the user at most a few recommendations, and refine these skills.
