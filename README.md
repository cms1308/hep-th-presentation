# Presentation harness

Turn LLMwiki topics and papers into beamer slides and a spoken English script, then
revise them from Korean nuance feedback. Claude Code and GPT/Codex use the same
[protocol](harness/PROTOCOL.md), [style preferences](STYLE.md), and shared workflows.

## Use

Open this repository in Claude Code or Codex. Keep the knowledge vault at `../LLMwiki`,
or tell the agent where it lives. Slide compilation requires `latexmk` and a TeX
installation with beamer and the metropolis theme.

| Task | Claude Code | GPT/Codex |
|---|---|---|
| Create a talk | `/talk-new <topic> [duration] [audience]` | `$talk-new <topic> [duration] [audience]` |
| Revise a talk | `/talk-revise <talk> <feedback>` | `$talk-revise <talk> <feedback>` |

Natural-language requests work too: “이 wiki 주제로 20분 발표 만들어줘” or
“5번 슬라이드 설명을 좀 더 담백하게 고쳐줘”. A new talk starts with an outline checkpoint
unless you ask for the complete talk in one shot. Outputs go in `talks/YYYY-MM-DD-<slug>/`.

Codex uses `AGENTS.md` and `.agents/skills/`; Claude Code uses `CLAUDE.md` and
`.claude/skills/`. If a client does not discover these automatically, ask it to read
`harness/PROTOCOL.md` and the relevant `harness/skills/<name>/SKILL.md` directly.
For Codex discovery details, see the official [AGENTS.md guidance](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
and [skills documentation](https://learn.chatgpt.com/docs/build-skills).

## Maintain

Following the `hep-th-workbranch` harness pattern, policy and workflow bodies have one
source of truth:

```text
harness/PROTOCOL.md             shared project rules
harness/skills/*/SKILL.md        shared workflows
harness/sync.mjs                generate/check the provider adapters
AGENTS.md, CLAUDE.md            generated project entry points
.agents/skills/, .claude/skills/ generated skill entry points
STYLE.md                       accumulated user taste
templates/                     slide and script skeletons
Log.md                         append-only operation log
talks/                         private talk deliverables
```

Edit the shared sources, then run from the repository root (Node.js 18+, no npm install):

```sh
node harness/sync.mjs
node harness/sync.mjs --check
```

`--check` exits nonzero for missing or out-of-date adapters without changing files.
Generated files are committed, so using the workflows needs no setup command or
provider-specific global rules. The adapters are regular files and need no symlink support.
If newly added skills do not appear in Codex, restart the client.

Work is logged, committed, and pushed to the private `origin`, with only task-owned
changes staged. The public mirror is updated deliberately using
`bash scripts/publish-public.sh` (requires Bash and rsync); never push private history
to it. The script publishes a snapshot excluding `talks/` contents.
