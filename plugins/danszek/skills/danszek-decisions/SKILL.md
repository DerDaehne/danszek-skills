---
name: danszek-decisions
description: Builds a decision page that puts visual, motion or far-reaching product choices to a human — every option drawn with the project's real design system, one section per decision with cited context and the recommendation first, picks stored per decision id and recorded on the ticket. Use when choosing between layouts, colours, sizes, animations, gestures or other variants that are better seen than described, or when several related product decisions are open at once; plain multiple choice covers everything else.
license: CC-BY-4.0
---

# Decision pages

A human decides faster and better on what they can see. Words like "subtle", "snappy" or "a thin line" mean something different to every reader; a page that draws the options with the real components removes that gap and leaves a record of what was chosen.

## When to build one
- **Visual** (layout, colour, density, iconography), **motion** (durations, curves, what moves) or **broad in consequence** (a choice that shapes many screens, a data model, a workflow the user will live with) → a decision page.
- Everything else (naming, a yes/no, a scope question) → plain multiple choice in the conversation: options A/B/C, recommendation first, one trade-off each.
- Technical choices are not put to the human at all; decide them and state the reason.
- **Ask related decisions together,** on one page, never one by one: each round costs the human a context switch, and decisions that interact (a size and the spacing around it) must be seen side by side.
- Before asking, look for an earlier answer in the ticket, its comments and the decision records; ask only what is really open, and name its scope.

## What the page shows
- **The real design system, not a lookalike.** Inline its token file and component stylesheet into the page *byte-identical*: copy them by script, never retype or "clean up", and verify by script that every inlined block equals its source (e.g. the page text contains each source file's exact content). Inline both: a component stylesheet without its tokens defines no values and renders blank. Options are drawn with the system's own components and tokens; only the variant under decision differs.
- **One section per decision,** each with a stable id:
  - **context**: what is being decided and why now, with source citations (file:line in the design system, the ticket, the code) — every citation checked against the source before publishing;
  - **what the design system says**, quoted — or, when it is silent or contradicts itself, a plain statement that it is, instead of an invented rule; such a gap becomes a report to the design system's owners, phrased independently of this project's platform;
  - **the options side by side,** at real size, in the states that matter (light/dark, narrow width, focus, empty and full);
  - **the recommendation first and marked,** with a one-line reason.
- **The dense case,** not only a sparse mock: a stagger formula picked from a sparse mock let rows overtake each other on a populated screen and ran 524 ms instead of 340.
- **Motion** plays on demand with a replay and a slow-motion control (e.g. a quarter of the speed); a looped animation hides where it starts and ends.
- **Gestures** (drag, swipe, pull) get a slider that scrubs the progress, so every intermediate frame can be inspected.
- Picks: one choice per decision id plus an optional free-text note, and a visible "answered / open" state per section.

## Storing picks
- Any hosted page with a small key-value store works (a chat artifact with a database is one way; a form backed by a file is another). Key = decision id, value = choice + note + time.
- **Apply only the ids this page defines.** A store that is shared across versions or pages holds stale and foreign entries; a page that applied every stored pick once showed answers to questions it no longer asked.
- Changing an option after the page was published gets a new id; never reuse an id for a different question.

## Building it
- Start from the previous decision page of the project, or from [assets/decision-page.html](assets/decision-page.html) for the first one: one section per decision with its stable id, play and slow motion for `[data-motion]`, a progress slider for `[data-gesture]`, picks with note and open/answered state, an export of the page's own picks, and a `store` with `load`/`save` to point at the host's shared store (it falls back to browser storage).
- Inline and verify with the bundled script (Python 3, standard library only; paths relative to this skill's directory):
  ```sh
  python3 scripts/inline.py build page-template.html page.html tokens=path/to/tokens.css components=path/to/components.css
  python3 scripts/inline.py verify page.html path/to/tokens.css path/to/components.css
  ```
  `page-template.html` is your copy of the template with the sections filled in. `build` replaces each `/*@inline:NAME@*/` placeholder literally and then runs `verify`; `verify` exits non-zero and names the first missing line when the page no longer holds a source file byte for byte. Re-run `verify` after every later edit of the page.
- Where no Python is available, check which interpreters the build environment really has before writing a generator, and substitute file contents literally: some replace functions interpret `$&` and similar sequences in the replacement text (in JavaScript, `split(placeholder).join(content)` is literal, `String.replace` is not), which silently corrupts an inlined stylesheet — the byte-identity check catches it.
- When a shipped motion "feels off", log the running program's real per-element plan and check the mock against one measured frame before drawing options: it separates "built wrong" from "designed wrong". Web animations are captured frame-exactly headless by pausing them and setting `currentTime`. A platform's global animation-speed setting may only tell instant from normal; slow down through the duration tokens in a throwaway copy instead.
- Animation APIs may not resolve CSS custom properties (Web Animations' `easing` does not take `var()`); read the computed value and pass the literal.
- Headless browsers can enforce a minimum window width; read the real viewport width before trusting a "phone width" check.

## Before publishing (the orchestrator, not only the page agent)
1. Run the byte-identity check yourself (`scripts/inline.py verify`).
2. Read the whole page: everything except the inlined design system is the agent's own drawing and can be wrong.
3. Render it (light, dark, narrow) and look at every section; play every motion.
4. Check every citation and every quoted rule against its source.
5. Privacy: the page is shareable; nothing private or internal belongs on it.

## After the human picked
- Read the picks from the store, not from memory of the conversation; ask about any decision left open.
- Record them on the ticket (decision id → choice + note, link to the page); the ticket, not the page, is the authority from then on.
- A note that changes an option is a refinement: fold it into the ticket and say which sub-decision you took on your own.
- File the design-system gaps the page named, and keep the affected part out of Ready until they are answered.
