# Interjection cases

Read this when an interjection does not fit the classes in the skill, or to check a call against earlier ones. The cases come from one long orchestration session, where an orchestrator ran up to nine agents on a product, a design system and its packaging. Each case gives what arrived, what happened, the call the skill makes, and why.

## 1. A performance complaint from real users while six agents ran
- **Arrived:** the human relayed that users found the product drained their batteries and kept CPU and memory busy while idle. Performance was a binding top goal.
- **Happened:** a ticket and an investigation agent started within minutes, as about the seventh parallel agent. The machine went over its agreed load limit, and several timing measurements of other agents ran above it.
- **Call:** standard, high cost of delay (a top goal, harmed users), but not expedite: nothing broke further while it waited. Rank it first in Next, start it in the next free slot, and say so.
- **Why:** a measurement task on an overloaded machine yields numbers that need repeating, and it degrades the measurements of the agents already running.

## 2. Issues from outside reporters on the public tracker
- **Arrived:** two feature requests from people outside the project, in another language than the team's.
- **Happened:** labels and a friendly reply in the reporter's language came within the hour. A decision page went to the human the same session, and both features started as soon as they were decided, ahead of older plan items. Nobody said which items moved down.
- **Call:**
  - Answer at once: cheap, high trust value, and it is a commitment ("I will post when it ships").
  - The work itself is standard: price it and rank it. Starting it ahead of older items may well be right, but the displacement belongs in the decision log and in the status line to the human.
- **Why:** outside goodwill is real value; silent displacement of the human's own asks is not free.

## 3. The shared branch's CI turned red from a flaky test
- **Arrived:** the CI run of a freshly pushed merge failed in a test file that had passed locally and on the previous commit.
- **Happened:** the run was repeated to confirm flakiness and passed. A ticket with the suspected cause was filed and sequenced after the work that held the same test file, then started as soon as that work merged.
- **Call:** expedite class (the shared branch is red for everyone), but sequenced against the colliding work.
- **Why:** collisions in the same test file cost more than waiting minutes for the other merge.

## 4. "Can we parallelise more? Any small tickets to slot in?"
- **Arrived:** the human asked for more throughput.
- **Happened:** the answer named the binding constraints: file collisions with running work, machine load, review capacity and the weekly budget. Three small items that collided with nothing were added.
- **Call:** right. Answer from the plan, name the constraint that binds, and add only work that fits all of them.
- **Why:** more authors without more review capacity only lengthen the review queue.

## 5. An item the human had asked for slipped for two sessions
- **Arrived:** nothing new. The human had asked two sessions earlier for a design update: a new background picture as the ground and a matching theme. It sat in a "next in order" list.
- **Happened:** each session, interjections and agent reports filled the free slots. The item never started and was never mentioned again.
- **Call:** the starvation guard. After two sessions of slipping, promote the item, re-scope it, or defer it explicitly with the human.
- **Why:** a list that only grows at the bottom is a log, not a plan; the human's own asks deserve at least a sentence when they wait.

## 6. A bug from live use: "the new menu entry does nothing"
- **Arrived:** the human could not use a feature they had just received.
- **Happened:** the cause was found the same evening: the running system still held an older component until the next login. A ticket started at once and shipped in the next release, with a follow-up for a visible hint.
- **Call:** expedite: the human was blocked in daily use by the team's own release.
- **Why:** a release that breaks the human's day ranks above roadmap work.

## 7. A wind-down request: "let's come to an end"
- **Arrived:** the human wanted to stop within the hour.
- **Happened:** no new starts. Running agents finished their current step and parked with a handover, the release was cut, and the next session's first moves were written down.
- **Call:** right. Stop starting; finish, park and record. Finishing ranks above everything except expedite.

## 8. A side finding during review
- **Arrived:** a reviewer found a problem that predated the change under review: a clipped focus ring in a shared container.
- **Happened:** a separate ticket was filed. Because it broke a binding rule of the design system, it was moved straight to the ready column, and it started when a slot was free.
- **Call:** standard. File it, do not grow the current ticket, and rank it by the rule it breaks.
