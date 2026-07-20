---
name: talk-new
description: Create a talk from an LLMwiki topic or paper — beamer slides (tex, compiled) plus a spoken English script aligned frame-by-frame. Use when the user asks for a presentation, slides, or a talk script on a physics topic or paper.
---

# New talk: slides + script

Input: a topic, paper (arXiv id or wiki page name), plus optionally duration (default
20 min) and audience (default: hep-th group seminar). If duration or audience clearly
matter and weren't given, ask once before outlining — everything downstream depends on them.

Read `STYLE.md` first. Every accumulated preference there is binding.

## 1. Gather

Content comes from `../LLMwiki` only (protocol in this repo's `CLAUDE.md` § Knowledge
source): `Index.md` → relevant topic/paper/concept pages → `sources/` TeX for any equation
that goes on a slide. Collect: the storyline, the key equations (copied exactly, macros
expanded), the citations, and what the wiki flags as open questions (good closing frames).

If the wiki doesn't cover the topic, stop and tell the user — offer to run
`/wiki-ingest-arxiv` in the LLMwiki repo first. Never build a talk from model memory.

## 2. Outline → user checkpoint

Propose the frame list (title + one line each, ≈1 frame/min) with the narrative arc:
motivation → setup → main results → implications/open questions. **Show it to the user
and wait** — restructuring an outline is cheap, restructuring finished slides is not.
Skip this checkpoint only if the user asked for the whole thing in one shot.

## 3. Slides

- `talks/YYYY-MM-DD-<slug>/slides.tex` from `templates/slides.tex`.
- Conventions: `CLAUDE.md` § Slide conventions + the user's global LaTeX rules.
- Compile loop: `latexmk -pdf -interaction=nonstopmode -halt-on-error slides.tex` in the
  talk directory until it exits clean; then grep the `.log` for `Overfull` and fix any
  frame that overflows. Known exception: metropolis's title page always emits one
  `Overfull \vbox (~44.6pt too high)` — inherent to the theme, harmless, ignore it.
  Clean `latexmk -c` afterwards (keep the pdf).

## 4. Script

- `script.md` from `templates/script.md`, one `## N. <title>` section per frame.
- Conventions: `CLAUDE.md` § Script conventions.
- Mechanical alignment check — run it, don't eyeball:
  ```bash
  grep -E '\\begin\{frame\}' slides.tex | wc -l   # vs
  grep -cE '^## [0-9]+\.' script.md
  ```
  Counts must match and titles must correspond in order.
- Word-count check: total words / 130 must be within ±15% of the target duration; cut or
  expand the script (and if badly off, the frame count) until it is.

## 5. Self-review, log, commit

Re-read every slide and script sentence against the source pages (the checklist in
`~/.claude/rules/common/latex.md` § Self-review): no invented terminology, no unverified
formula, would the cited author accept the phrasing. Fix before presenting.

Then: append one `Log.md` line (`new | <slug> | <duration>, <audience>`), commit
(`feat: <slug> slides+script`), and give the user the pdf path plus a 2–3 sentence summary
of the arc.
