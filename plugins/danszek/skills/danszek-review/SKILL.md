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
2. Verify each acceptance criterion with your own evidence. For UI: a real headless browser against the production build with fresh data — light/dark, narrow mobile width, reduced motion/transparency, keyboard focus, ARIA semantics. **Measure** (element positions, overflow, contrast) instead of eyeballing — measurements catch layout bugs screenshots hide. Automation defaults can hide bugs: some drivers disable the back/forward cache, so test full navigations and back/forward with it enabled. **One sweep, all findings:** before the verdict, walk every criterion once more against the edge kinds (human-only targets, blocked targets, empty states, exactly-once rendering). Findings that trickle in over later rounds cost a full fix-and-review round each.
3. **Mutation probes** in a throwaway clone or stash (never destructive resets in shared trees): revert each fix alone → its test must fail; break the invariant each new test *names* → that test must fail. A surviving mutant is a finding unless you can show it is unobservable. **Environment-independent tests:** self-tests and scripts must not depend on the developer's machine (global git identity, home directory, locale, installed tools). Run them once with an isolated environment; CI runners have none of it. **Concurrency tests under pressure:** run tests with concurrent writers or timing windows repeatedly with CPU pressure (pinning to one core, shortened timeouts); two green local runs say little about a slower CI runner. **Rebuild before browser-level probes:** when the browser suite runs against a build artefact, rebuild after each mutation — otherwise the probe silently tests old code and a "surviving mutant" is a false finding.
4. **Delivery files** (CI/release workflows, container files): check names and paths against the target system's rules before the first run (e.g. registries require lowercase image names), defaults that make the artifact work without extra configuration, least-privilege permissions, pinned actions, language rules in comments.
5. **Changed existing tests:** compare old and new expectations line by line. A weakened assertion that makes a regression pass is a finding; so is a test whose name promises more than it checks.
6. **Decision records:** check changed behaviour against the decision records the affected docs reference; a contradiction needs a new record that supersedes the old one, not a silent change.
7. **Invented state:** look for new persistent state, marker files or naming conventions introduced only to make a test pass when the information is already derivable from existing data.
8. **Interplay:** check the callers and siblings that consume the same data as the changed code.
9. **Lifecycle and concurrency:** timers cleared on every exit path, no double completion, resources (slots, processes, temp dirs) released, cleanup also when a helper's own assertion fails.
10. **Style and hygiene** per the repository's guide: nesting depth and function length limits, readable code over comments, language rules, no change narration or internal references in code, honest commit types, no unjustified new dependencies.
11. **Numbers:** every cost, size or duration in docs and reports comes from a measurement with its source; estimates are labelled as such (an unmeasured cost estimate was off by more than an order of magnitude once).
12. **Docs:** the linked documentation matches the code; fix small inaccuracies yourself, otherwise report.
13. **Privacy:** scan the diff and messages for internal references; never touch private pattern files; stop every process you started.

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
