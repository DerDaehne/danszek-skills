---
name: danszek-refinement
description: Turns raw tickets into implementable, reviewable work items for agent-driven development — goal, scope, references, effort, UX/AX and observable acceptance criteria, one task per criterion, correct dependencies, and a strict product-vs-technical split. Use for tickets in backlog or refinement, when splitting large tickets or writing acceptance criteria, and when reviewing a refinement.
license: CC-BY-4.0
---

# Refinement method

## Shape of a refined ticket
- **Goal** — one paragraph about the outcome, not the implementation.
- **Scope in / Scope out** — bullets; every "out" item names where it goes instead.
- **References** — related tickets, knowledge notes, and files/functions that exist *now* (search the code before naming them).
- **Effort** — S / M / L. **L is split** into S/M tickets with an explicit dependency order, unless the split would produce pieces that cannot be accepted on their own — then say why.
- **UX / AX** — both the human and the agent side of every surface (UI, tool, prompt, CLI, error message), as testable statements. If one side is unaffected, say why in one line.
- **Acceptance criteria** — numbered, observable, each with its proof type (test, end-to-end check in a browser, on a device or against the running service, log, document).
- **One task per acceptance criterion**, short titles (respect tool length limits).
- Mark tickets that change architecture, data model or shared contracts as requiring documentation.

## Thinking rules
- **Product vs. technical:** only product decisions go to a human (options A/B/C + recommendation). Decide technical ones yourself and record them as "technical decision (own responsibility): …". Asking technical questions as product questions is the most common refinement failure — check against examples first.
- **Verify premises:** before reasoning about a function, column or flag, confirm it exists. Whether a platform hook can do something (follow a pointer continuously, stream, cancel) is read from its source wiring, not from its API name. Read the platform source behind every mechanism earlier tickets call "known" (three such assumptions were wrong in one refinement), and the interface a service or private module really ships (its introspection data, a model's role table) before choosing a data path: a needed listing or field may simply not exist.
- **Trace downstream before writing a state into a criterion:** a criterion "ends as dismissed" would have silently deleted data in a consumer. Check every user-facing word against the code or the design source.
- **Read the reference implementation next to the prose docs** of a dependency or design system: the code settles details the prose leaves vague and exposes contradictions.
- **Interplay rule:** when a rule or behaviour changes, list every other component that consumes the same data (search callers) and add an acceptance criterion for the interplay. Missing this is how a correct-looking change breaks a neighbour.
- **Edge cases become criteria**, not prose ("only future-dated entries exist", "equal timestamps", "a non-human actor tries the human-only action").
- **Dependencies:** "A blocks B" means A must be finished before B starts. Read direction carefully; justify non-obvious links.
- Two tickets that touch the same files: write down the interface one promises to keep and add a blocks link, instead of "coordinate".
- A global switch one feature needs (a setting that also changes every other edge, screen or mode) has side effects elsewhere; name them to the human as part of the product question.
- **Re-check inherited `blocks` links** when refining: links from an early planning round go stale. Keep one only if there is a real code or product dependency; otherwise remove it with a one-line reason, so a formal blocker never holds up, or gets silently ignored by, the developer.
- One stale link found → **audit every link of that ticket at once**; stale links cluster around tickets from the same early planning round.
- **Read comments** on the ticket and its related tickets — decisions made later live there. Before refining a "follow upstream" ticket, look for a recent decision that kept the opposite on purpose.
- No requirements beyond the ticket, the decision records and the comments; label assumptions.
- Concrete numbers (thresholds, limits, sizes) with their source (configuration/catalog, not scattered constants).

## Hand-off
- No open product decision → ready. Otherwise leave the question with options and a recommendation; visual, motion or far-reaching questions as a decision page (`danszek-decisions`).
- **Split along "spec complete" vs. "spec has a gap":** the buildable part reaches ready while the rest waits on the outside answer (a design system, an upstream library, a human). Before splitting, check that the library pieces the feature needs exist; the real size often hides in missing shared components. When the design authority contradicts itself, count which sources agree and whether one is its reference implementation: that turns "wait" into a decision with a cheap fallback.
- **Reports to an upstream owner** (a gap or contradiction in its spec) are phrased independently of your stack, and every file:line and quote in them is checked against the source before filing. Look for the owner's closed decision on the point first and ask to sharpen it rather than claim a gap; give measured numbers and the spec's file:line, and keep product and tool names out. Re-read a ticket before citing it ("as proposed in X").
- A **different model or person reviews the refinement** before it becomes ready — the refiner never promotes its own work. Small corrections can be made directly and listed as binding clarifications.
- Before creating or splitting tickets, check what was created or changed recently in the same area (other planners may be working in parallel). A refinement that turns out to be a slice of a broader ticket records the split on both tickets at once.

## Reviewing a refinement
Facts match the code? Question premises correct? Interplay criteria present? Large tickets split or justified? Tasks equal criteria? Dependency directions right? Typos don't block; wrong premises do.
