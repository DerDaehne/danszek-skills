# Local models in agent loops

Read this when a local model (a self-hosted or on-device model run by your own harness) works tickets next to or instead of hosted subagents. Everything in the main skill applies too.

- **Sandbox:** throwaway clone without a remote, explicit project commit identity (a fresh clone would otherwise use the machine's global identity), filesystem isolation with only the work dir writable and no home directory, deny push/reset/clean/recursive deletes; no planning-tool credentials inside — inject the ticket into the prompt and post the agent's report yourself.
- **Over-deliberation:** thinking models can spend the whole output budget on one reasoning step. Set a reasoning budget with an "act now" message; on a length stop, resume with "plan was good, do not re-plan, small steps: test → fix → commit".
- **Stagnation:** repeated failed exact-match edits, byte-level inspection loops, consecutive steps at the reasoning budget without file changes → stop, give a recovery hint (replace by line number or rewrite the block).
- **Context:** for long fix rounds start a **fresh run with injected state** (rules, ticket, branch log, open findings) instead of growing one session into compaction; never interrupt a compaction.
- **Fast non-thinking coders** fail differently: they act immediately but lose track of their own uncommitted work and "make the test pass" with invented state. Enforce commit discipline mechanically (dirty worktree + N calls without commit, counted across continuations) and let review judge the design.
- Hints to stuck agents should be **deterministic**: derived from run events, git state and ticket text (idle calls, history-only reads, calls since last commit, files outside the ticket) — reproducible by the runner without another model.
- Consider a **plan/act split**: a thinking model plans small steps, a fast coder executes them, the runner enforces commits.
- One model server, one model at a time: serialize GPU jobs to avoid swaps mid-run.
- Fair comparisons replay the same task: same base commit, prompt, sandbox and review strictness, only the model or harness changes.
