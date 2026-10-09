# danszek-skills

Agent skills distilled from a long-running practice of orchestrating AI agents on a ticket board — methods,
working style, communication style and review culture, kept generic and free of personal or internal data.

| Skill | Use when |
|---|---|
| `danszek` | always, standalone: communication and solution style for any task or role (the others build on it) |
| `danszek-collaboration` | working with a terse, decision-oriented maintainer: answer shape, decisions, autonomy limits, privacy, rhythm |
| `danszek-refinement` | turning raw tickets into implementable ones; reviewing refinements |
| `danszek-review` | independent review with own runs, browser measurements and mutation probes |
| `danszek-orchestration` | running frontier subagents and local models through a board safely |
| `danszek-code-style` | writing or reviewing code humans must understand by reading |

Each skill is a folder with a `SKILL.md` (YAML frontmatter `name` + `description`, then instructions) — the
open Agent Skills layout, understood by Claude and by OpenAI's ChatGPT/Codex.

```
.claude-plugin/marketplace.json          Claude Code marketplace (this repository)
plugins/danszek/.claude-plugin/plugin.json
plugins/danszek/skills/<skill>/SKILL.md  the skills (single source of truth)
scripts/build-zips.sh                    dist/<skill>.zip for upload UIs
scripts/install.sh                       symlinks for local CLIs
```

## Install

Replace `<owner>` with the GitHub account that hosts this repository.

### Claude Code (CLI) — recommended

```sh
claude plugin marketplace add <owner>/danszek-skills
claude plugin install danszek@danszek-skills
```

Skills load automatically when relevant; invoke one explicitly as `/danszek:danszek-review`.
Update later with `claude plugin marketplace update danszek-skills`.

Without the marketplace (local clone, edits take effect immediately):

```sh
git clone https://github.com/<owner>/danszek-skills && cd danszek-skills
scripts/install.sh claude        # links every skill into ~/.claude/skills
```

### Claude apps (claude.ai, Claude Desktop)

Available on Pro, Max, Team and Enterprise plans.

1. Build the upload files: `scripts/build-zips.sh` → `dist/<skill>.zip` (each zip contains `<skill>/SKILL.md`).
2. Settings → Capabilities → enable **Code execution and file creation** (skills need it).
3. Sidebar **Customize → Skills → + → Upload a skill**, choose a zip. Repeat per skill.

Uploaded skills are private to your account.

### ChatGPT

Available on paid plans except Free and Go.

1. `scripts/build-zips.sh`
2. **Plugins → Skills → Create → Upload from your computer**, choose a zip (keep it zipped). Repeat per skill.

Skills uploaded in ChatGPT are also available in Codex.

### OpenAI Codex CLI

```sh
scripts/install.sh codex         # links every skill into ~/.agents/skills
```

Project-scoped instead: copy the skill folders into `.agents/skills/` of a repository.
In Codex, type `$` to pick a skill or `/skills` to list the loaded ones.

### Any other agent

Skills are plain Markdown. Where an agent has no skill support, paste the body of the relevant `SKILL.md`
into its system prompt, project instructions or `AGENTS.md`. Keep the `description` line as the "use when" hint.

## Contributing

- One rule per bullet, dense, generic: no personal names, no project or company internals, no paths or hosts.
- Explain *why* only where the rule is not self-evident; prefer a concrete failure the rule prevents.
- Validate before committing:

  ```sh
  claude plugin validate .
  claude plugin validate ./plugins/danszek
  ```

The skills are refined in regular retrospectives as new lessons come in.

## License

[CC BY 4.0](LICENSE) — share and adapt freely, including commercially, with attribution:
"danszek-skills by danszek, CC BY 4.0" plus a link to this repository and a note if you changed it.
