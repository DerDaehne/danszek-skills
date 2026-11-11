---
description: Run a retrospective — collect the agents' Retro sections and your own notes into the retro log, deduplicate, file tool feedback, fold generic lessons into the skills, report.
argument-hint: "[scope, e.g. since the last retro]"
---

Run a retrospective now, scope: $ARGUMENTS (default: everything since the last recorded retro).

Follow the procedure in `${CLAUDE_PLUGIN_ROOT}/skills/danszek-orchestration/SKILL.md`, section "Capture and learn", and the rhythm rules in `${CLAUDE_PLUGIN_ROOT}/skills/danszek-collaboration/SKILL.md`, section "Rhythm". Read both sections before you start; they are the authority, this command only starts them.

Inputs: the Retro section of every agent report in scope, your own notes from the session, and the retro log with its earlier entries. If you cannot find the retro log, ask where it is instead of starting a new one.

End with the status-update shape from `danszek-collaboration`: what was recorded, filed and changed (with ticket and commit references), then only the decisions the user really has to make.
