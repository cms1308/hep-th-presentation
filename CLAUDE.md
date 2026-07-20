# Presentation harness — Schema

This repo turns topics/papers from the hep-th LLMwiki (`../LLMwiki`) into **beamer slides
plus a spoken English script**, and refines the script through the user's Korean nuance
feedback. The human picks the topic and gives taste feedback; the LLM does all content
gathering, slide writing, script writing, and bookkeeping.

## Directory layout

```
CLAUDE.md            this schema
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

All physics content comes from `../LLMwiki` (read its `CLAUDE.md` § "Answering physics
questions" for the protocol): read `Index.md` first, follow wiki pages, and drop to
`sources/` TeX only when equation-level exactness is required. Equations on slides are
copied from wiki pages / source TeX, never reconstructed from memory. Claims keep their
paper citations. If the wiki doesn't cover the requested topic, say so and offer
`/wiki-ingest-arxiv` in the LLMwiki repo first — don't present from model memory.

## Slide conventions

- beamer, `\usetheme{metropolis}`, compiled with `latexmk -pdf -interaction=nonstopmode
  -halt-on-error slides.tex` (run in the talk directory). A talk is not done until this
  exits clean; check the log for `Overfull` boxes on frames and fix them.
- Budget ≈ 1 frame per minute of talk time (title and thank-you frames excluded).
- One idea per frame. Slides carry keywords, equations, and figures — full sentences
  belong in the script, not on slides.
- Citations on slides: bottom-right of the relevant frame,
  `\hfill{\scriptsize [Author '{}YY, arXiv:XXXX.XXXXX]}` — no bibliography frame unless asked.
- The user's global LaTeX rules apply (`~/.claude/rules/common/latex.md`): plain column
  specs, no invented terminology, self-review before presenting.

## Script conventions

- `script.md`: YAML frontmatter (topic, wiki sources, audience, duration, status), then
  **one `## N. <frame title>` section per frame, in order** — section numbering and titles
  must match `slides.tex` frames exactly. This alignment is what makes nuance revision
  ("슬라이드 5 부분...") addressable; it is checked mechanically, not by eye.
- Spoken English, not written English: contractions, short sentences, first person.
  Never read the slide verbatim — the script says what the slide doesn't.
- Pace: ~130 words per minute. Each section notes its time (`*(~1 min)*`); total word
  count must land within ±15% of the target duration.
- Say equations aloud where nontrivial ("S equals the area over four G-Newton").
- Explicit transitions between frames ("So that's the setup. Now, ...").

## Workflows (implemented as skills)

- **`/talk-new <topic|paper|wiki page> [duration] [audience]`** — gather content from the
  LLMwiki, propose an outline, write `slides.tex`, compile until clean, write the aligned
  `script.md`, self-review, log.
- **`/talk-revise <talk> <feedback>`** — apply the user's feedback (typically casual
  Korean nuance) to the script and/or slides: interpret intent, show before/after for
  every changed section, recompile if the tex changed. If the feedback expresses a
  *general* preference rather than a one-off fix, distill it into `STYLE.md` so future
  talks absorb it.

Every operation ends with one `Log.md` line, a `git commit`, and `git push` (origin = the
**private** repo, `cms1308/presentation-private`, full contents incl. `talks/`) — sessions
are disposable; the repo is the only state. Commit format: `feat: <slug> slides+script` /
`fix: <slug> revision — <gist>` (see `../.claude/rules/git-workflow.md`).

The **public mirror** (`github.com/cms1308/presentation`) is a separate, talks-free
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
```
