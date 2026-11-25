# Global plan

Keep this file somewhere durable that the orchestrator reads at every session start: outside the session's scratch space, and outside a public repository if it names private things. Update it in the same step as every event that changes it. The board holds the tickets; this file holds their order and the reasons for it.

Last re-ranked: <date, time> · by: <orchestrator / human>

## Goals
Set by the human, in rank order. Two to four.

| # | Goal | Why | Observable outcome | Current milestone and its exit criteria |
|---|---|---|---|---|
| 1 | … | … | … | … |
| 2 | … | … | … | … |

## Commitments
Promises to the human or to outside people. None is dropped silently.

| Promise | To whom | Trigger or date | Status |
|---|---|---|---|
| "I will post when it ships" | outside reporter of issue … | the release containing … | open |

## Capacity
- **WIP limits:** agents running at once …; items in review at once …; heavy jobs (builds, measurements) at once …
- **Machine:** load limit …; any shared resources that need an explicit go.
- **Shares** (set by the human): goals …%, interjections and bugs …%, tooling and improvement …%.
- **Budget windows:** session … (now …%), week … (now …%), with the resets.

## Queue

### Now
Really running.

| Item | Goal | Owner | Started | Blocks / blocked by |
|---|---|---|---|---|

### Next
Ranked and ready to start, best first.

| Rank | Item | Goal | Cost of delay | Size | Collides with | Age (sessions) | Why here |
|---|---|---|---|---|---|---|---|

### Later
Loosely ranked.

### Parked
| Item | Why parked | Wake-up trigger |
|---|---|---|

## Inbox
Interjections captured but not yet priced. Empty it at every event.

| When | Words (verbatim) | From | Class (expedite / dated / standard / opportunistic) | Placed as |
|---|---|---|---|---|

## Decision log
One line per re-ranking, newest last: date · what moved where · why · who decided.

## First moves of the next session
1. …
2. …
3. …
