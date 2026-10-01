---
name: danszek-review
description: Independent, evidence-based code review — re-run everything, diff against the merge base, verify UI in a real browser, mutation-probe every fix and every new test, report findings as file:line with fix and required test, and close with a category/severity table and an explicit verdict. Use for reviewing branches, fix rounds, and work produced by other agents or local models.
---

# Review method

## Stance
- **Independent:** never review your own work. Same strictness for every author — human, frontier model or small local model.
- **Re-run, don't trust:** type check, full test suite and build yourself; state whether the author's claims held.
- **Diff against the merge base** (`main...branch`), never against a main that has moved on — otherwise you count other people's changes as deletions.

## Procedure
1. Read the ticket with all comments (later decisions live there), the role instructions and the author's stated deviations.
2. Verify each acceptance criterion with your own evidence. For UI: a real headless browser against the production build with fresh data — light/dark, narrow mobile width, reduced motion/transparency, keyboard focus, ARIA semantics. **Measure** (element positions, overflow, contrast) instead of eyeballing — measurements catch layout bugs screenshots hide.
3. **Mutation probes** in a throwaway clone or stash (never destructive resets in shared trees): revert each fix alone → its test must fail; break the invariant each new test *names* → that test must fail. A surviving mutant is a finding unless you can show it is unobservable.
4. **Interplay:** check the callers and siblings that consume the same data as the changed code.
5. **Lifecycle and concurrency:** timers cleared on every exit path, no double completion, resources (slots, processes, temp dirs) released, cleanup also when a helper's own assertion fails.
6. **Style and hygiene** per the repository's guide: readable code over comments, language rules, no change narration or internal references in code, honest commit types, no unjustified new dependencies.
7. **Docs:** the linked documentation matches the code; fix small inaccuracies yourself, otherwise report.
8. **Privacy:** scan the diff and messages for internal references; never touch private pattern files; stop every process you started.

## Findings (forwardable verbatim to the author)
`N. path:line — category, severity[, BLOCKING]. What is wrong (repro or surviving mutant). Fix: concrete change. Required test: what must exist and fail without the fix.`
- Categories: correctness, test quality, code style, lean, docs, privacy, UX.
- Probes that demonstrated a finding become **permanent regression tests**; hand over the probe code.
- Suggestions affecting **other** tickets go to the human as a proposal, never as extra scope for this author.

## Verdict
- Findings → comment on the ticket, back to development, plus a short list for the author.
- No blocking findings → "review ok", rebase if needed, re-run, fast-forward merge, clean up branch and worktree, verify docs, move to the human acceptance stage (the human closes, not the reviewer).
- Always include a **category × count × severity table** and one sentence comparing the work with what a strong developer would deliver on a ticket of this size — this feeds model evaluation.
- Accept or reject every stated deviation explicitly, with a reason.
