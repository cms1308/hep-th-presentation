# Presentation harness — shared protocol

This repo turns topics/papers from the hep-th LLMwiki (`../LLMwiki`) into **beamer slides
plus a spoken English script**, and refines the script through the user's Korean nuance
feedback. The human picks the topic and gives taste feedback; the LLM does all content
gathering, slide writing, script writing, and bookkeeping.

This protocol and `harness/skills/` are shared by Claude Code, GPT/Codex, and other
file-capable agents. Use the tools available in the current environment; no provider's
private configuration or tool names are required. All working paths below are relative
to the repository root unless a command explicitly runs in a talk directory.

Before creating or revising a talk, read `STYLE.md` and the relevant shared skill.
For harness maintenance, edit the shared sources and run `node harness/sync.mjs`, then
`node harness/sync.mjs --check`. The provider entry files are generated adapters.

## Directory layout

```
harness/PROTOCOL.md  this shared protocol
harness/skills/      canonical talk-new and talk-revise workflows
harness/sync.mjs     generate/check provider adapters (Node.js 18+, no npm dependencies)
AGENTS.md            Codex and other AGENTS.md-aware agents' entry point
CLAUDE.md            Claude Code entry point
.agents/skills/      generated Codex skill adapters
.claude/skills/      generated Claude Code skill adapters
STYLE.md             accumulated user taste (slides + script). Read before every talk-new;
                     appended to by talk-revise when feedback generalizes.
Log.md               append-only operation log
templates/
  slides.tex         beamer skeleton — always start new talks from this
  script.md          script skeleton
talks/
  YYYY-MM-DD-<slug>/ one directory per talk
    slides.tex
    slides.pdf       committed (the deliverable)
    script.md        spoken English script, one section per frame
```

## Knowledge source: the LLMwiki

All physics content comes from the sibling `../LLMwiki` directory (or the wiki location
explicitly supplied by the user). Read its `AGENTS.md` § "Answering physics questions"
when present, falling back to `CLAUDE.md` for older vaults: read `Index.md` first, follow
wiki pages, and drop to `sources/` TeX only when equation-level exactness is required. Equations on slides are
copied from wiki pages / source TeX, never reconstructed from memory. Claims keep their
paper citations. If the wiki doesn't cover the requested topic, say so and offer
`/wiki-ingest-arxiv` in the LLMwiki repo first — don't present from model memory.
The wiki is read-only from this repository. If it is unavailable, report the missing
path and ask for its location; never silently replace it with model memory.

## Slide conventions

- beamer, `\usetheme{metropolis}`, compiled with `latexmk -pdf -interaction=nonstopmode
  -halt-on-error slides.tex` (run in the talk directory). A talk is not done until this
  exits clean; check the log for `Overfull` boxes on frames and fix them.
- Budget ≈ 1 frame per minute of talk time (title and thank-you frames excluded).
- One idea per frame. Slides carry keywords, equations, and figures — full sentences
  belong in the script, not on slides.
- Citations on slides: bottom-right of the relevant frame,
  `\hfill{\scriptsize [Author '{}YY, arXiv:XXXX.XXXXX]}` — no bibliography frame unless asked.
- Use plain standard LaTeX column specs and established physics terminology.
  Before presenting, re-read slides and script against the source pages: no invented
  terminology, no unverified formulas, and phrasing the cited author would accept.

## Script conventions

- `script.md`: YAML frontmatter (topic, wiki sources, audience, duration, status), then
  **one `## N. <frame title>` section per frame, in order** — section numbering and titles
  must match `slides.tex` frames exactly. This alignment is what makes nuance revision
  ("슬라이드 5 부분...") addressable; it is checked mechanically, not by eye.
- Spoken English, not written English: contractions, short sentences, first person.
  Never read the slide verbatim — the script says what the slide doesn't.
- Pace: ~130 words per minute. Each section notes its time and the running total
  (`*(~1 min, cumulative ~5 min)*`); total word count must land within ±15% of the
  target duration.
- Say equations aloud where nontrivial ("S equals the area over four G-Newton").
- Explicit transitions between frames ("So that's the setup. Now, ...").
- Hard line breaks only at sentence boundaries — never wrap mid-sentence. Long lines are
  fine; the user edits and reads the file directly.
- No stage directions (*(Point at the formula)*, *(Walk through the table)*) — spoken text
  only. The per-section time markers *(~N min)* / *(transition)* are the only allowed
  non-spoken annotations.

## Workflows (implemented as skills)

- **`talk-new <topic|paper|wiki page> [duration] [audience]`** — gather content from the
  LLMwiki, propose an outline, write `slides.tex`, compile until clean, write the aligned
  `script.md`, self-review, log.
- **`talk-revise <talk> <feedback>`** — apply the user's feedback (typically casual
  Korean nuance) to the script and/or slides: interpret intent, show before/after for
  every changed section, recompile if the tex changed. If the feedback expresses a
  *general* preference rather than a one-off fix, distill it into `STYLE.md` so future
  talks absorb it.

Invoke these as `/talk-new` and `/talk-revise` in Claude Code, or `$talk-new` and
`$talk-revise` in Codex. Natural-language requests use the same workflows. If skill
discovery is unavailable, read `harness/skills/<name>/SKILL.md` directly and follow it,
preserving the user's arguments and feedback.

## Saving work

Every operation ends with one `Log.md` line, a `git commit`, and `git push` (origin = the
**private** repo, `cms1308/hep-th-presentation-private`, full contents incl. `talks/`) — sessions
are disposable; the repo is the only state. Commit format: `feat: <slug> slides+script` /
`fix: <slug> revision — <gist>`; harness maintenance uses `chore: <gist>`.
Stage only files changed by the current task, preserving unrelated user changes.
Push to the configured private `origin`; report a missing remote or failed push without
claiming the work is backed up. Do not force-push or rewrite history.

The **public mirror** (`github.com/cms1308/hep-th-presentation`) is a separate, talks-free
history — refresh it only deliberately via `scripts/publish-public.sh`. Never push the
private history public: its commits contain the talks.

## STYLE.md format

One bullet per preference, grouped under `## Slides` / `## Script`, each with the date and
the feedback that spawned it, e.g.:

```
- Prefer understatement for own results — "we find", never "remarkably". (2026-07-20:
  "너무 자랑하는 톤이야, 좀 담백하게")
```

Only *generalizable* taste goes here; one-off content fixes don't.

## Log.md format

```
## [YYYY-MM-DD] new | 2026-07-20-holographic-qcd | 20 min, group seminar
## [YYYY-MM-DD] revise | 2026-07-20-holographic-qcd | softer tone on results frames; +1 STYLE rule
## [YYYY-MM-DD] harness | shared workflow | <maintenance summary>
```
