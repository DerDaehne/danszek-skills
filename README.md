# danszek-skills

Agent skills distilled from a long-running practice of orchestrating AI agents on a ticket board — methods,
working style, communication style and review culture, kept generic and free of personal or internal data.

| Skill | Use when |
|---|---|
| `danszek` | always: communication style, solution approach, honesty and verification for any task or role (the others build on it) |
| `danszek-collaboration` | working with a person: status updates, decisions, autonomy limits, privacy, rhythm and retrospectives |
| `danszek-refinement` | turning raw tickets into implementable ones; reviewing refinements |
| `danszek-review` | independent review with own runs, measurements on the real surface and mutation probes |
| `danszek-decisions` | putting visual, motion or far-reaching product decisions to a human as a page drawn with the real design system (page template included) |
| `danszek-orchestration` | running frontier subagents and local models through a board safely (agent-rules template included) |
| `danszek-prioritization` | an orchestrator's long-range priorities: one global plan, ranking by cost of delay, interjected requests priced in before they start, long-term goals guarded (plan template included) |
| `danszek-code-style` | writing or reviewing code humans must understand by reading |

Each skill is a folder with a `SKILL.md` (YAML frontmatter `name`, `description` and `license`, then
instructions) — the open [Agent Skills](https://agentskills.io/specification) layout, understood by Claude and
by OpenAI's ChatGPT/Codex. Longer material sits beside it in `references/` (read when the skill says so)
and `assets/` (templates). The repository ships no executable scripts or hooks: everything is text you can read.

In Claude Code the plugin also brings a **reviewer subagent**, `danszek:reviewer`, which preloads
`danszek-review` and `danszek-code-style` and reviews work in its own context: ask for it by name ("have the
danszek reviewer check this branch") or with `@agent-danszek:reviewer`.

It also brings the command **`/danszek:retro`** (Claude Code only): it runs the retrospective procedure from
`danszek-orchestration` ("Capture and learn") — collect the agents' Retro sections and your own notes into the
retro log, deduplicate, file tool feedback with the tool's owner, fold generic lessons into the skills, report.
An optional argument narrows the scope (`/danszek:retro since the last release`).

```
.claude-plugin/marketplace.json          Claude Code marketplace (this repository)
plugins/danszek/.claude-plugin/plugin.json
plugins/danszek/skills/<skill>/SKILL.md  the skills (single source of truth; references/ and assets/ beside it)
plugins/danszek/agents/reviewer.md       the reviewer subagent (Claude Code only)
plugins/danszek/commands/retro.md        the /danszek:retro command (Claude Code only)
plugins/danszek/evals/                   trigger evals for `claude plugin eval`
```

## Install

Replace `<owner>` with the GitHub account that hosts this repository.

### Claude Code — recommended

```
/plugin marketplace add <owner>/danszek-skills
/plugin install danszek@danszek-skills
```

(From a shell: `claude plugin marketplace add …` and `claude plugin install …`.) Skills load automatically when
relevant; invoke one explicitly as `/danszek:danszek-review`. Update later with
`/plugin marketplace update danszek-skills`. A local clone works as a marketplace too:
`/plugin marketplace add ./danszek-skills`.

### Claude apps (claude.ai, Claude Desktop)

Available on Pro, Max, Team and Enterprise plans.

1. Zip each skill folder you want, the folder itself and not only its contents, e.g. from a clone:
   `cd plugins/danszek/skills && zip -r ../../../dist/danszek-review.zip danszek-review` (create `dist/` first;
   it is ignored by git).
2. Settings → Capabilities → enable **Code execution and file creation** (skills need it).
3. Sidebar **Customize → Skills → + → Upload a skill**, choose a zip. Repeat per skill.

Uploaded skills are private to your account.

### ChatGPT

Available on paid plans except Free and Go.

1. Zip each skill folder as for the Claude apps above.
2. **Plugins → Skills → Create → Upload from your computer**, choose a zip (keep it zipped). Repeat per skill.

Skills uploaded in ChatGPT are also available in Codex.

### OpenAI Codex CLI

Copy (or symlink) the skill folders from `plugins/danszek/skills/` of a clone into `~/.agents/skills/`.
Project-scoped instead: copy the skill folders into `.agents/skills/` of a repository.
In Codex, type `$` to pick a skill or `/skills` to list the loaded ones.

### Any other agent

Skills are plain Markdown. Where an agent has no skill support, paste the body of the relevant `SKILL.md`
into its system prompt, project instructions or `AGENTS.md`. Keep the `description` line as the "use when" hint.

## Contributing

- **No executable scripts or hooks; skills are text.** Users cannot vet the privacy and security of code a
  skill ships, and a hook runs it on their machine unasked. A rule may carry a short command example in
  Markdown; enforcement (a pre-push hook, a CI check) is each project's own to add.
- One rule per bullet, dense, generic: no personal names, no project or company internals, no paths or hosts,
  and no rule tied to the stack it was learned on (state the lesson, at most with a neutral example).
- Explain *why* only where the rule is not self-evident; prefer a concrete failure the rule prevents.
- Frontmatter holds only `name`, `description` and `license`: claude.ai uploads and the Skills API reject
  Claude-Code-only keys such as `argument-hint` or `disable-model-invocation`. Descriptions say what the
  skill does and when to use it, in the third person, under 1,024 characters, without `: ` (it breaks YAML).
- Keep a `SKILL.md` body under about 5,000 tokens; move material that is needed only in some situations into
  `references/` and name the situation where the body points to it.
- Raise `version` in `plugins/danszek/.claude-plugin/plugin.json` with every change: installed plugins stay on
  the version they have until it changes.
- Validate before committing:

  ```sh
  claude plugin validate .
  claude plugin validate --strict ./plugins/danszek
  ```

- After changing a description, run the trigger evals (real model calls on your account, a few cents per run):

  ```sh
  cd plugins/danszek && claude plugin eval . --runs 1 --ablation none --no-publish
  ```

  Write eval prompts the skill can answer without a lookup first: a prompt that makes the model search before the skill would load runs out of turns and fails for the wrong reason.

The skills are refined in regular retrospectives as new lessons come in.

## License

[CC BY 4.0](LICENSE) — share and adapt freely, including commercially, with attribution:
"danszek-skills by danszek, CC BY 4.0" plus a link to this repository and a note if you changed it.
