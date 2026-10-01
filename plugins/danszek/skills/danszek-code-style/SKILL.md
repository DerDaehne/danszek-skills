---
name: danszek-code-style
description: Code style for agent-written code that humans must understand by reading — readable code over comments, one repository language, lean but not dense, tests that prove the invariant they name, honest commits, errors with a way out, privacy-safe public repositories. Use before writing or reviewing code.
---

# Code style

## Core
- **Readable code over comments.** Intent through names, small well-named functions, explicit types and plain control flow. A few more lines following best practice beat one dense line plus a comment.
- **Comment only what code cannot say:** a non-obvious *why*, a workaround (name the cause), a security or concurrency invariant, a deliberate simplification marked with its limit and upgrade path. One short line.
- **No comments that** restate code, narrate changes ("now uses…", "fixed…") or reference tickets, decision records or planning content. History belongs in commit messages, knowledge in documentation.
- **Doc comments only for non-obvious contracts** (units, side effects, thrown errors, invariants), one sentence. When a contract changes, update the doc of every function involved.
- **One repository language** for identifiers, comments, test names, commit messages and docs. User-facing strings follow the product language and stay grammatically correct.
- Models imitate the surrounding code more than written rules: keep the repository language even where old code deviates.
- **Lean means no unneeded features or abstractions — not dense code.** No speculative defensive branches: protect only against what can happen in the actual concurrency model.

## Tests
- Test names are sentences describing behaviour.
- A bug fix starts with a test that fails on main.
- **Every new test must fail against a mutant of the invariant it names** — run that mutant before reporting. (Classic trap: capturing the expected list before creating the data, so the assertion compares against an empty list and is always green.)
- Clean up in `finally`, including inside helpers (child processes, servers, temp dirs, timers). Skip permission-based tests when running as a privileged user.

## Commits
- Small commits; honest types (`test:` only tests, `fix:`/`feat:` code changes); a ticket reference only at the end of the subject.

## Errors
- Stable code + one-line message + concrete way out, true for **every** case that reaches it (derive from the error's operation and path instead of hard-coding one scenario).
- Nothing secret in errors, logs or events.

## Hygiene
- Follow the file's indentation; prefer a formatter check over manual care.
- Report test names, outputs and file lists exactly as they appear — never paraphrase from commit subjects.
- New dependencies only with a justification; standard library → platform → package.
- Public repositories carry no personal names, e-mail addresses, paths, hostnames, credentials, hardware details or internal planning references — including commit metadata.
