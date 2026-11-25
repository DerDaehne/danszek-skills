---
name: danszek-prioritization
description: Long-range prioritisation for an orchestrator — keeps one durable global plan (goals, commitments, a ranked now/next/later queue, capacity shares, WIP limits, a decision log), prices every interjected request into that plan before acting on it, picks what starts in a free slot, guards long-term goals against a stream of small urgent asks, and reports plan changes as information. Use together with danszek-orchestration whenever a new request, bug report or idea arrives while work is running, when choosing what to start next, at the start and end of a session, or when goals, commitments and budget compete.
license: CC-BY-4.0
---

# Prioritisation

Sections: why · the global plan · ranking · interjections · starting work · capacity and budget · long-term goals · rhythm · telling the human · guardrails.

How to run agents is in `danszek-orchestration`; which questions go to the human and how is in `danszek-collaboration`. Read when the situation arises:
- no plan exists yet → copy [assets/global-plan.md](assets/global-plan.md) into a durable place and fill it with the human;
- an interjection does not fit the classes below, or you want to check a call against earlier ones → [references/interjection-cases.md](references/interjection-cases.md).

## Why
An orchestrator that reacts to every event works hard and moves the big goals slowly. In the session this skill was distilled from, every new request started an agent within minutes. Meanwhile an item the human had asked for two sessions earlier sat in a "next" list that nobody re-ranked, and parallel agents pushed the machine past its agreed load limit while reviews queued up. Prioritisation is the habit of putting every new thing into one ranked plan first, and only then deciding whether it runs now.

## The global plan
Keep one durable document, outside session memory and outside anything a reboot wipes. Its structure is in [assets/global-plan.md](assets/global-plan.md):
- **Goals** (two to four), each with its why, an observable outcome and its rank among the goals. Goals and their order come from the human; the orchestrator never reorders them on its own.
- **Commitments:** promises to the human or to outside people ("after X lands", "by Friday", "I will post when it ships"), each with its trigger. A commitment is never dropped silently.
- **Queue:**
  - **Now:** really running, within the WIP limits.
  - **Next:** ranked and ready to start.
  - **Later:** loosely ranked.
  - **Parked:** each item with its reason and a wake-up trigger.
- **Capacity:** WIP limits (agents, items in review, heavy jobs), the share of capacity per kind of work, and the budget windows.
- **Inbox:** interjections captured but not yet priced.
- **Decision log:** every re-ranking, one line each, with its reason.

Read the plan at session start and before choosing what to start. Update it in the same step as every event that changes it. The board holds the tickets; the plan holds their order and the reasons for it.

## Ranking
Rank by cost of delay over size, then adjust.
- **Cost of delay:** what is lost per day an item waits. Examples: a blocked human or outside party, a broken shared branch, a security or privacy exposure, harmed users, a dated commitment, a goal's milestone slipping. If little is lost, the item can wait, however small it is.
- **Size:** the total cost, not only the implementation: review rounds, quota, machine time and the human's attention.
- **Adjust up:**
  - it unblocks other ranked items;
  - it reduces a risk that grows (a flaky test, a red shared branch);
  - it finishes work already started: stop starting, start finishing.
- **Adjust down:**
  - it collides with files or areas of running work (serialise it instead);
  - it waits for an open decision;
  - its value is speculative.
- **Ties** go to the item that serves the highest-ranked goal. A goal that has not moved for a while gets the tiebreak.
- Write estimates coarse (S/M/L, high/medium/low) and mark them as estimates; never pretend precision.

## Interjections
An interjection is a request, bug report or idea that arrives while work runs.
1. **Capture it at once:** a ticket or an inbox line with the person's own words. Never lose it, and do not start it yet.
2. **Answer what is cheap now:** a question, a status, an acknowledgement to an outside reporter. Answering is not starting.
3. **Classify it:**
   - **Expedite** starts now and may displace ranked work, but only for one of these: a security or privacy exposure; the shared branch, release or CI broken for everyone; data loss or harm to a running system; the human or an outside party blocked right now; the human saying "now" or "first".
   - **Dated** is a commitment with a date. Rank it so it lands in time, which is not necessarily now.
   - **Standard:** price it and rank it.
   - **Opportunistic:** small and harmless. It only goes into a free slot that nothing ranked above it wants, and only if it collides with nothing running.
4. **Price and place it:** its value, urgency and size, the goal it serves, and its overlap with existing items (merge duplicates instead of adding twins). Insert it into the queue.
5. **Say where it landed,** in one line: "planned as Next #3, after A and B, because …; it starts now only if you want it first." If it displaces something, name what and why.
6. **If the human wants it now, do it.** Record the displacement in the decision log, and re-check the commitments it touches.

When unsure, capture it, acknowledge it and rank it; do not start it. A request that sounds urgent is not urgent because of its tone: check the criteria.

## Starting work
When a slot frees, pick in this order:
1. **Finish before starting:** a waiting review, a merge, a push, a red shared branch, a fix round of work already in review.
2. **Expedite items.**
3. **The top of Next that fits:** no collision with running work, predecessors done, within the WIP limits and the budget.
4. **Opportunistic items,** only when nothing from steps 1–3 fits.

- **Do not fill a slot just because it is free.** More parallel work than review capacity, machine load and budget allow only lengthens the review queue and makes timing measurements unreliable.
- **A finished agent's report is not automatically the next thing to act on.** It competes like everything else, though finishing usually wins.

## Capacity and budget
- **WIP limits** for running agents, items in review and heavy jobs at once are set with the human. Raise them only while reviews keep up and the load stays under the limit.
- **Shares of capacity** split the work by kind; the shares are the human's call. For example: goals 60 %, interjections and bugs 25 %, tooling and improvement 15 %. Measure the real split at each retro. If interjections eat the goals' share for two sessions, raise it with the human instead of quietly continuing.
- **Budget windows** (the session, the week) are capacity too. Plan the week's expensive work against the weekly figure, not only the session's: large reviews and premium models.
- **Count review rounds into size.** Three rounds on one ticket are the price of an under-specified brief; sharpen briefs before adding parallel work.

## Long-term goals
- **Milestones:** break each goal into milestones with exit criteria. At all times, keep at least one item of the top goal in Now or at the top of Next.
- **Starvation guard:** every item in Next carries its age. An item that has slipped behind others for two sessions is promoted, re-scoped or deferred together with the human, never left to drift. Items the human asked for personally weigh more.
- **Re-rank the whole queue at session start,** not only the newest items. A "next in order" list that only grows at the bottom is a log, not a plan.
- **A standing direction covers choices within the plan.** "Full speed" or "decide yourself" lets you choose between items inside the plan; it does not let you change the goals or their order.

## Rhythm
- **Session start:** read the plan, the board, the open questions and CI of the shared branch. Re-rank, then state the first moves in one line.
- **Each event** (a report, a merge, an interjection): update the plan in the same step.
- **Session end:** do the release and handover the project requires, then write the next session's first three moves into the plan with their reasons.
- **Retro:**
  - compare the planned split of capacity with the real one;
  - list the commitments kept and the ones missed;
  - list the items that aged.
  Turn each finding into a rule.

## Telling the human
- **Plan changes are information, not questions:** "X is planned after Y; earlier if you want."
- **Ask the human only when** two goals or two commitments conflict, or when an interjection would displace a goal's milestone. Offer A/B with a recommendation.
- **"What's next?" or "can we do more in parallel?"** Answer from the plan: the ranked next items, the constraint that binds (file collisions, review capacity, load, budget) and what would lift it.

## Guardrails
- Never let an interjection silently cancel or delay a commitment; say so when it does.
- Never reorder the human's goals on your own; propose a new order instead.
- Never expedite without one of the criteria.
- Never run more parallel work than the agreed limits to "go faster".
- Never re-open a decided priority without new facts.
- Keep the plan honest: what stands in Now is really running, and every parked item has a wake-up trigger.
