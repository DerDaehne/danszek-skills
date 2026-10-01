---
name: danszek-refinement
description: Turn raw tickets into implementable, reviewable work items for agent-driven development — goal, scope, references, effort, UX/AX criteria, observable acceptance criteria, one task per criterion, correct dependencies, and a strict product-vs-technical split. Use for tickets in backlog/refine, when splitting large tickets, and when reviewing a refinement.
---

# Refinement method

## Shape of a refined ticket
- **Goal** — one paragraph about the outcome, not the implementation.
- **Scope in / Scope out** — bullets; every "out" item names where it goes instead.
- **References** — related tickets, knowledge notes, and files/functions that exist *now* (search the code before naming them).
- **Effort** — S / M / L. **L is split** into S/M tickets with an explicit dependency order, unless the split would produce pieces that cannot be accepted on their own — then say why.
- **UX / AX** — both the human and the agent side of every surface (UI, tool, prompt, CLI, error message), as testable statements. If one side is unaffected, say why in one line.
- **Acceptance criteria** — numbered, observable, each with its proof type (test, browser check, log, document).
- **One task per acceptance criterion**, short titles (respect tool length limits).
- Mark tickets that change architecture, data model or shared contracts as requiring documentation.

## Thinking rules
- **Product vs. technical:** only product decisions go to a human (options A/B/C + recommendation). Decide technical ones yourself and record them as "technical decision (own responsibility): …". Asking technical questions as product questions is the most common refinement failure — check against examples first.
- **Verify premises:** before reasoning about a function, column or flag, confirm it exists.
- **Interplay rule:** when a rule or behaviour changes, list every other component that consumes the same data (search callers) and add an acceptance criterion for the interplay. Missing this is how a correct-looking change breaks a neighbour.
- **Edge cases become criteria**, not prose ("only future-dated entries exist", "equal timestamps", "a non-human actor tries the human-only action").
- **Dependencies:** "A blocks B" means A must be finished before B starts. Read direction carefully; justify non-obvious links.
- **Read comments** on the ticket and its related tickets — decisions made later live there.
- No requirements beyond the ticket, the decision records and the comments; label assumptions.
- Concrete numbers (thresholds, limits, sizes) with their source (configuration/catalog, not scattered constants).

## Hand-off
- No open product decision → ready. Otherwise leave the question with options and a recommendation.
- Prefer that a **different model or person reviews the refinement** before it becomes ready; small corrections can be made directly and listed as binding clarifications.

## Reviewing a refinement
Facts match the code? Question premises correct? Interplay criteria present? Large tickets split or justified? Tasks equal criteria? Dependency directions right? Typos don't block; wrong premises do.
