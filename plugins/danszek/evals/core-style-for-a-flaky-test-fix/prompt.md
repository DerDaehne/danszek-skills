---
description: A bug-fixing task with a tempting retry workaround loads the core working style.
tags: [trigger, core]
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

One of our integration tests fails about one run in ten with a timeout while waiting for a message on a queue. A colleague suggests wrapping the wait in three retries so the pipeline goes green. Look at how you would approach this and tell me what you would do first.
