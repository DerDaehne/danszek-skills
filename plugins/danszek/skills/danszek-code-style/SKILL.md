---
name: danszek-code-style
description: Code style for agent-written code that humans must understand by reading — readable code over comments, shallow nesting and short functions, one repository language, lean but not dense, tests that fail when the invariant they name breaks, honest commits, errors with a way out, privacy-safe public repositories. Use before writing, refactoring or reviewing code or tests.
license: CC-BY-4.0
---

# Code style

## Core
- **Readable code over comments.** Intent through names, small well-named functions, explicit types and plain control flow. A few more lines following best practice beat one dense line plus a comment.
- **Shallow nesting:** at most 2 levels of nested blocks inside a function, 3 only as a justified exception — flatten with early returns, guard clauses and extracted functions.
- **Short functions:** a function fits on one normal screen (about 40 lines); longer → split into well-named steps. Enforce both with a linter (e.g. `max-depth`, `max-lines-per-function`) rather than by review alone.
- **Comment only what code cannot say:** a non-obvious *why*, a workaround (name the cause), a security or concurrency invariant, a deliberate simplification marked with its limit and upgrade path. One short line.
- **No comments that** restate code, narrate changes ("now uses…", "fixed…") or reference tickets, decision records or planning content. History belongs in commit messages, knowledge in documentation.
- **Doc comments only for non-obvious contracts** (units, side effects, thrown errors, invariants), one sentence. When a contract changes, update the doc of every function involved.
- **One repository language** for identifiers, comments, test names, commit messages and docs. User-facing strings follow the product language and stay grammatically correct.
- Models imitate the surrounding code more than written rules: keep the repository language even where old code deviates.
- **Derive, don't store:** never add persistent state (marker files, name suffixes, extra columns) to make a test pass when the fact can be derived from data you already have.
- **Lean means no unneeded features or abstractions — not dense code.** No speculative defensive branches: protect only against what can happen in the actual concurrency model. A guard that survives its own mutation is often unneeded (a zero-length animation ends at once anyway): delete it rather than keep it alive with a test. Before deleting, build the uneven case it might exist for (one of several parts hidden alone): only that case separated "act while hidden" from "act when shown".
- Derive sizes from the element they act on, not from a fixed multiple of a spacing value: such a delta once cut more than the element had.

## Tests
- Test names are sentences describing behaviour.
- A bug fix starts with a test that fails on main.
- Existing tests are specification: changing an existing expectation needs an explicit reason in the commit message — never adapt a test just to make new behaviour pass.
- **Every new test must fail against a mutant of the invariant it names** — run that mutant before reporting. (Classic trap: capturing the expected list before creating the data, so the assertion compares against an empty list and is always green.)
- **Assert the premise** when it depends on the environment (text width with the installed font, screen size, locale, time zone, clock): a test about truncation first asserts that the text is truncated, so a font change fails loudly at the premise.
- Assert the produced result, not the constant the code reads; a test that compares with the same constant cannot catch a wrong one.
- A bug with two triggers gets one test per trigger: each mutant once caught only one of them.
- Test a key or event handler's return value (consumed or passed on), not only the state it changes.
- **Ports:** run the original source in a small harness for the expected values; find inputs where candidates tie or round on .5 before writing the tests, not after the review.
- When the unit you change cannot be instantiated in a test at all (a window type the harness cannot create), test the pieces on either side and name the glue that only lint, review and a live check cover.
- "A missing optional module must not break the screen" is tested by running the same test file a second time with that module removed from the import path.
- Put identity and lookup choices (which owner, which window, which record) into a function tests can call with stand-ins, and keep at least one test through the real lookup path; a test that hands the looked-up object in directly misses a broken lookup.
- When the unit runner cannot load the real framework or service, drive real instances over their own interface (IPC, HTTP, CLI) from a script. Keep socket paths short: Unix socket paths are limited to about 108 bytes, and a long temp dir made IPC fail without a clear error.
- A flaky test is reproduced under synthetic load until it fails reliably, then made to wait for the event it needs, never for more time. A rare race shows faster when you widen its window than under load alone: many independent readers spread their read moments over it (load alone hit about 1 % of runs, 30 readers about 90 %), or a probe sets the near-miss value by hand (a stress loop hit it 0 times in 20).
- **Wait for the event, not for time or a value.** A test framework's fuzzy "wait until value equals X" passes while an animation is still in its last millisecond, and a `running` flag also falls for a moment on a restart: wait for the animation's own finished signal. Read "from zero" values synchronously right after the trigger; a polling check reads them part-way. Two snapshots taken at different moments after creation diff on whatever is still loading: wait on that state in both. After one timing flake, sweep the suite for the same shape (a fixed wait or a fuzzy compare followed by a strict check) and convert them in one go; three such flakes surfaced one by one in a week.
- Waits: request the frame you wait for, or a wait where nothing changes runs to its full timeout; give every wait helper a timing check on a negative case. Let a newly shown item finish its layout before pressing or measuring it; force the layout in a probe, since layouts may skip items made invisible through an ancestor.
- **Hermetic tests:** a call that starts or activates a service (a retry that "starts the daemon") sits behind a replaceable function that tests stub; a private bus can still activate services installed on the host. A synthetic-input test that does nothing may run in a harness that never passes that input kind to your code: first look at the target's state (a screenshot: it had already released the input), then read where the input filter is installed, before debugging your own code or the platform's.
- **Pixel and motion probes:** look at one captured image by eye before building assertions on it (a capture helper may not return what the screen shows; a contact sheet showed a wrong order every assertion missed). On antialiased shapes sample whole-pixel positions picked from a printed map; aim at the drawn ink, not the box (the ink-weighted centre for tight tolerances), with a clean surround (pointer parked away). Fit a whole motion curve with a start-lag tolerance instead of one mid-way sample, or hold the motion at fixed times and measure. Give pointer coordinates in scene space or relative to something that stands still; relative to a moving item they add up and a threshold test passes for the wrong reason.
- Clean up in `finally`, including inside helpers (child processes, servers, temp dirs, timers), and release shared resources at the start of each test too: runners may order tests alphabetically, not as written. Skip permission-based tests when running as a privileged user.

## Commits
- Small commits; honest types (`test:` only tests, `fix:`/`feat:` code changes); a ticket reference only at the end of the subject.

## Errors
- Stable code + one-line message + concrete way out, true for **every** case that reaches it (derive from the error's operation and path instead of hard-coding one scenario).
- Nothing secret in errors, logs or events.

## Hygiene
- Follow the file's indentation; prefer a formatter check over manual care. Run a formatter only on the hunks you changed, or read its diff: another version reformats untouched code.
- In scripted conflict resolution, check the tools you call exist (a missing interpreter left markers that were committed), look at each hunk before deleting exact lines, and grep for markers afterwards.
- Match the one field you mean in structured input, not its raw text: a regex over a whole JSON event also fires on a description that mentions the command.
- **Check the diff after every scripted edit.** Edit code that contains regexes or `$` with an exact-replacement tool; substitute file contents literally (some replace functions interpret `$&` in the replacement — in JavaScript `split(a).join(b)` is literal, `replace` is not). A one-liner with an unlucky delimiter once mangled a whole file.
- Lint the files you changed directly and read the exit status or machine-readable output: a check that stops at the first warning elsewhere hides yours, and one linter's text output stayed silent while it exited non-zero.
- Report test names, outputs and file lists exactly as they appear — never paraphrase from commit subjects.
- New dependencies only with a justification; standard library → platform → package.
- Public repositories carry no personal names, e-mail addresses, paths, hostnames, credentials, hardware details or internal planning references — including commit metadata.
- Examples use documentation ranges and names (192.0.2.0/24, 2001:db8::/32, example.com) — never a realistic private address, which privacy scans rightly flag.
