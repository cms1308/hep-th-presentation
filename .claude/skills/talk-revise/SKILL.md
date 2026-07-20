---
name: talk-revise
description: Revise a talk's script and/or slides from the user's feedback — typically casual Korean nuance ("좀 더 담백하게", "5번 슬라이드는 청중이 모를 듯"). Use whenever the user gives feedback on an existing talk in talks/.
---

# Revise a talk from nuance feedback

Input: which talk (default: the most recently updated directory in `talks/`) and the
feedback, usually informal Korean describing a desired nuance, tone, emphasis, or level.

## 1. Interpret

Restate the feedback as concrete edit intents in one or two lines each, e.g.
"너무 자신만만한 톤" → *soften claims on the results frames: hedge "we show" → "we find",
drop superlatives*. If the feedback is genuinely ambiguous between different edits
(tone vs. content, which frames it targets), ask — one short question, then proceed.
Don't ask about things the feedback already implies.

## 2. Locate

Map each intent to specific script sections / frames. Nuance feedback usually targets the
script; touch `slides.tex` only when the feedback is about what's *on* the slide (too much
text, missing citation, equation level). Never let the two drift: if a frame title or the
frame count changes, update both files.

## 3. Apply

- Edit the mapped sections. Keep everything else byte-identical (surgical changes).
- Spoken-English and pacing rules from `CLAUDE.md` § Script conventions still apply —
  re-check the word count if sections grew or shrank materially.
- If `slides.tex` changed: recompile until clean (same loop as talk-new step 3) and re-run
  the frame/section alignment check.

## 4. Show the diff

In the reply, show **before → after for every changed section** (script: the changed
sentences; slides: the changed lines). The user judges nuance by comparison — never just
say "softened the tone".

## 5. Compound the taste

Decide: is this feedback a one-off content fix, or a *generalizable preference*?
Generalizable (tone, hedging, level of detail, how to open/close, slide density) →
append one dated bullet to `STYLE.md` (format in `CLAUDE.md` § STYLE.md format), quoting
the original Korean. One-off → don't pollute STYLE.md.

Update `script.md` frontmatter (`status: revised`, `updated:`), append one `Log.md` line
(`revise | <slug> | <gist>; +N STYLE rule(s)` if any), commit
(`fix: <slug> revision — <gist>`).
