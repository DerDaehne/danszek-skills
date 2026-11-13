---
name: danszek-review
description: Independent, evidence-based code review — re-runs every check, diffs against the merge base, drives user-facing surfaces the way users reach them (browser, device, CLI, API client), mutation-probes every fix and every new test, and reports findings as file:line with fix and required test plus a category/severity table and an explicit verdict. Load it before looking at the code when reviewing a branch, pull request or fix round, when checking whether an author's reported fixes or test claims hold, or for work produced by another agent or a local model.
license: CC-BY-4.0
---

# Review method

## Stance
- **Independent:** never review your own work. Same strictness for every author — human, frontier model or small local model.
- **Re-run, don't trust:** type check, full test suite and build yourself; state whether the author's claims held. Compare reported test counts with the suite size: "6 passed" from a suite of 67 is a partial run reported as green.
- **Diff against the merge base** (`main...branch`), never against a main that has moved on — otherwise you count other people's changes as deletions.
- **Full gate after every rebase,** before reviewing, even when the rebase had no conflicts: tests another branch added after the fork broke on a clean rebase, and a parallel branch added a same-named handler so a file no longer loaded. Grep for conflict markers, and re-run any check that inspects results (did the generator write its files?), not only the tests.

## Procedure
1. Read the ticket with all comments (later decisions live there), the role instructions and the author's stated deviations.
2. Verify each acceptance criterion with your own evidence. For a user-facing surface: drive the production build the way a user reaches it, with fresh data — a headless browser for web, an emulator or offscreen session for mobile and desktop UIs, the real binary for a CLI, a real client for an API. For UIs check light/dark, narrow width, reduced motion/transparency, keyboard focus and accessibility semantics. **Measure** (element positions, overflow, contrast) instead of eyeballing — measurements catch layout bugs screenshots hide. Automation defaults can hide bugs: some drivers disable the back/forward cache, so test full navigations and back/forward with it enabled. **One sweep, all findings:** before the verdict, walk every criterion once more against the edge kinds (human-only targets, blocked targets, empty states, exactly-once rendering). Findings that trickle in over later rounds cost a full fix-and-review round each.
3. **Mutation probes** in a throwaway clone or stash (never destructive resets in shared trees). Revert each fix alone → its test must fail; break the invariant each new test *names* → that test must fail. A surviving mutant is a finding unless you can show it is unobservable.
   - **The mutant must be real:** confirm a non-empty diff (a substitution that matched nothing once "confirmed" an unchallenged test), confirm it is valid code (one mutant "failed" only because the engine lacked a function it called; read the failure message), and confirm it changes behaviour: deleting a property set to its library default changes nothing, so look up the default and mutate to the opposite; a mutated rule that another check also enforces is a no-op. Replacing a fixed wait by firing its timer can silently drop a deferred call the wait let run; probe every such swap.
   - **Mutate where the author did not:** the author's own probes cover the paths they thought of. Mutate the guards and the disabled paths first ("does nothing when …", "no call when off"); every behaviour the author claims needs a guard whose mutant some test kills.
   - **Thresholds and inputs:** move a threshold by one at the exact boundary (`>` to `>=`); moving it far proves little. A mutant can be equivalent only for the test's inputs: integer coordinates could not separate `>` from `>= +1`, a diagonal move could. A test that moves "by the threshold" moves with the mutated threshold; use literal values. For "the user's value wins", mutate to a stronger priority, not only to absence.
   - **Fixes in two parts:** revert each half alone; both gaps must be real.
   - **A survivor is not automatically a missing test:** the test may reach the path but cannot observe the change (undo cannot run twice once its toast closed) — come from another direction; in a race, read how wide the window really is, since some orderings can only be shown correct from the source.
   - **To prove a refactor left a test empty,** run the same mutant on the branch and on main and list the tests red only on main; it finds what a name audit misses.
   - **Code no test loads** (a native plugin, a packaged extension): mutate it in a package build and probe it live.
   - **Rebuild before end-to-end probes** that run a build artefact, or the probe tests old code and a "surviving mutant" is false. A build tool that caches checks by input replays an old verdict; force the rebuild with full logs. **Re-run the probes on the rebased commit**, the state that actually merges.
   - **Environment-independent tests:** self-tests and scripts must not depend on the developer's machine (global git identity, home directory, locale, installed tools, a host service a private bus can still activate). Run them once with an isolated environment; CI runners have none of it.
   - **Concurrency and timing:** run tests with concurrent writers or timing windows repeatedly under CPU pressure (one core, shortened timeouts); build the load up before the run, since load averages lag. Prove a flaky test's cause under load until it fails reliably, then bind the check to the event it really waits for, never to more time.
4. **Delivery files** (CI/release workflows, container files): check names and paths against the target system's rules before the first run (e.g. registries require lowercase image names), defaults that make the artifact work without extra configuration, least-privilege permissions, pinned actions, language rules in comments. **The CI starts every shipped artifact exactly as it ships** (from an empty directory, without the repository or dependencies) and waits for its health check: tests that run inside the repository cannot notice a runtime file the artifact forgot. **Workflows that only run on a release** (tags, manual dispatch) are exercised before the release by a run with publishing disabled, triggered by changes to the workflow itself; otherwise the release is their first test, and a failure costs exactly the release artifact (an action upgrade waited two days in review for the next tag).
5. **Changed existing tests:** compare old and new expectations line by line. A weakened assertion that makes a regression pass is a finding; so is a test whose name promises more than it checks.
6. **Decision records:** check changed behaviour against the decision records the affected docs reference; a contradiction needs a new record that supersedes the old one, not a silent change.
7. **Invented state:** look for new persistent state, marker files or naming conventions introduced only to make a test pass when the information is already derivable from existing data.
8. **Interplay:** check the callers and siblings that consume the same data as the changed code.
9. **Lifecycle and concurrency:** timers cleared on every exit path, no double completion, resources (slots, processes, temp dirs) released, cleanup also when a helper's own assertion fails. A short run that steps the real object through its lifecycle (hidden, shown, hidden, shown) answers questions stand-in tests cannot.
10. **Style and hygiene** per the repository's guide: nesting depth and function length limits, readable code over comments, language rules, no change narration or internal references in code, honest commit types, no unjustified new dependencies.
11. **Numbers:** every cost, size or duration in docs and reports comes from a measurement with its source; estimates are labelled as such (an unmeasured cost estimate was off by more than an order of magnitude once).
12. **Docs:** the linked documentation matches the code; fix small inaccuracies yourself, otherwise report.
13. **Privacy:** scan the diff, **every commit's own patch** and all messages for internal references and names — a later commit that removes a leak does not remove it from history; never touch private pattern files; stop every process you started.
14. **Error classification against the real client:** when code maps network or provider errors to classes, probe with the real HTTP client against a local server (refused port, silent server, dropped socket, timeout), not only with mocked errors. Mocks tend to cover just the case the author had in mind; a real-client probe found a too-broad catch and a latent timeout bug on the main branch.
15. **De-flaked concurrency tests:** when flaky multi-process tests are rebuilt in one process, check that atomicity is still tested. Running the two operations one after the other never overlaps their transactions; a deterministic interleaving probe (a second connection acting before every statement of the first) keeps the coverage. Also check the test's duration on the slowest runner, not only locally.
16. **Currency, not just validity:** catalogs and defaults (model lists, versions, prices) must contain the current recommended entries, not only valid ones. A catalog of correct but older models made the default model of the day fall back to "unknown". Tests read values the code chooses (a free port, a generated id) from its output instead of assuming them (`port + 1` flaked when that port was taken).
17. **Simulate the failure the user meets, not a convenient stand-in.** A blocked request fails at once; a lost network leaves the connection hanging silently. A click on "undo" is not the key press, and a test that releases a held toast at once never lets real time pass. Two acceptance findings in one release came from tests that were green on exactly such stand-ins. For each failure path, name how it shows up in real use and probe that form (offline mode, a stream that never answers under a fake clock, the keyboard path, time passing while held).
18. **Reach test states the way production reaches them.** A test that builds its precondition through an internal call no production path makes (a follow-up run created directly instead of through the human's resume or restart) proves a case that never occurs and misses the ones that do; a lost-answer bug hid behind exactly such a test. A mutant the author declares "equivalent" needs a proof or a probe: one such claim hid a real effect on a later question.
19. **Workarounds and "safeguards":** a workaround whose comment says the cause is unknown is not accepted as is. Reproduce without it and find the mechanism; a hidden framework bug behind one such workaround also explained an older one and a focus regression it caused. Code kept "as a safeguard" that no test needs (removing it leaves every test green) is removed or gets a test that fails without it.

20. **A defect found in a library you use: look for the same class in your own code.** A review of a design system's toast found that its countdown counted timer steps instead of the clock, so undo was offered after the server's deadline; the product's own toast, built on the same idea, had exactly that bug on its main branch.

21. **Siblings of the changed mechanism:** when the fix adds a per-surface mechanism (an overlay layer, a key router, a press handler per window), list every surface of the same kind and check each one, or file the missing ones as tickets in this round. A panel that got its own tooltip layer had a calendar popup beside it with the same gap, found only one review later.

22. **Tests that stay green on a broken change.** Look for these shapes in every new or changed test:
    - compares a value with the very constant the code reads (`angle == config.angle`): a wrong constant passes; check the produced result (where parts end up, their colour, the serialized output);
    - a premise that depends on the environment (text width with the installed font, screen size, locale, time zone): the test must assert the premise first ("this text is truncated"); one test failed only on another distribution, at an unrelated later check, because its premise had held by sub-pixel luck with one font version;
    - hands the looked-up object in directly instead of going through the real lookup: a regression that broke the lookup for every caller passed every test;
    - identity matching where both sides can be null or missing: "not found" turns into "found the first empty slot"; comparing a framework's own handle with your object is a similar trap, and a ten-line probe against the real framework settles it;
    - the suite switches motion, timers or network off by default, and a test whose name says "while", "during" or "after" then passes without the thing it names happening;
    - a guard that every test sidesteps by waiting for readiness first needs its own test that calls early;
    - a code comment's specific claim ("waits for X") untested: probe each such claim, not only the feature; one test for a hidden wait passed on the old code because it checked the wrong moment.
    - measures a sign or direction through the same transform the code uses (both agree while wrong): check it against rendered pixels or projected sizes;
    - aims a pixel probe at a box instead of the drawn ink, or never looked at the picture it measures: check one grab by eye first.

23. **Paths the author did not think of.** For each, ask whether a test exists:
    - the **repeat path** (the same state set again by key and pointer) besides the change path: duplicate side effects hide in repeated pointer events;
    - every **way into a state** the cleanup assumes, including ones another actor starts mid-gesture: some never trigger the step the cleanup waits for;
    - every action a user can take on an item the code **deliberately keeps stale**: null lookups hide there;
    - with a **per-row key** (duplicates allowed), every operation (resize, undo, remove) goes by that key; when a fix swaps "find by id" for a position-derived key, probe the action with a reorder in between;
    - a **test stand-in** for a risky dependency is installed before the first call that reaches it, on every path that calls it;
    - a disabled control: every key path that could still change its value; an announcement that stands in for tracked state fires only on a real change;
    - when porting from a reference implementation, what it catches from descendants (a container listener sees every child's events; focus leaving the whole container, not the one control) — ports often cover only the element the tests use;
    - a scrubbable animation sought backwards across a pause: sequential groups do not reset values on the way back;
    - a module option users can also set, checked against an explicit opposite user value: a plain value at normal priority turned a convenience into an evaluation error.

24. **Cheap strong proofs.** Byte-compare generated artefacts (rendered sheets, outputs) between base and branch to show a shared refactor changes nothing; a picture uniformly one colour step off means an animation was still running at capture, not a regression. In live probes read the real state before each step. Settle a dependency's magic numbers in its exact source the build uses, and check its line references separately from its values: wrong line numbers survive review next to right values.

## Findings (forwardable verbatim to the author)
`N. path:line — category, severity[, BLOCKING]. What is wrong (repro or surviving mutant). Fix: concrete change. Required test: what must exist and fail without the fix.`
- Categories: correctness, test quality, code style, lean, docs, privacy, UX.
- Check every file:line before posting; a findings comment often cannot be edited later.
- The report goes into the ticket (comment or attachment), never only into a scratch file the next agent cannot reach.
- Probes that demonstrated a finding become **permanent regression tests**; hand over the probe code.
- Suggestions affecting **other** tickets go to the human as a proposal, never as extra scope for this author.

## Verdict
- Findings → comment on the ticket, back to development, plus a short list for the author.
- No blocking findings → "review ok", rebase if needed, re-run, (a one-line fix the rebase forces, such as a convention newly merged code lacks, goes in openly as its own commit and is named in the report), fast-forward merge, clean up branch and worktree, verify docs, move to the human acceptance stage (the human closes, not the reviewer).
- Always include a **category × count × severity table** and one sentence comparing the work with what a strong developer would deliver on a ticket of this size — this feeds model evaluation.
- Accept or reject every stated deviation explicitly, with a reason.
