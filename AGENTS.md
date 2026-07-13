# Learn Verb Activity

A single-file, kid-friendly web app for learning Spanish verbs, built for Kabir.
Organized into **levels** (each level = a verb list); lessons, games, sentences and
conjugation drills auto-generate from the verb data.

## Files
- `learn-verb-activity.html` — the entire app. Self-contained: vanilla JS + CSS, no
  build step, no npm deps. Only external dependency is Google Fonts (Baloo 2 + Nunito).
  Open it directly in a browser to run.

## Run / test
- Run: open `learn-verb-activity.html` in any modern browser.
- Syntax check (no test suite): extract the `<script>` block and run `node --check`, e.g.
  ```bash
  node -e 'const fs=require("fs");const h=fs.readFileSync("learn-verb-activity.html","utf8");
  require("fs").writeFileSync("/tmp/a.js",h.match(/<script>([\s\S]*)<\/script>/)[1]);' && node --check /tmp/a.js
  ```
- Pure-logic functions (buildPlan, learnedUpTo, conjugate, fillFor) can be unit-tested by
  eval-ing the script body up to the `Wire up` comment in a Node stub of `window`/`document`.

## Architecture (all inside the one `<script>`)
- **Data**
  - `LEVELS` — array of levels. Level object: `{id, name, blurb, verbs, fills}`.
  - Verb object: `{id, es, inf, en, t, em}` where `t` is `"ar"|"er"|"ir"`, `inf` is the clean
    single-word infinitive (used for scrambling/conjugation/audio), `es` is the display form
    (may contain a slash like `"andar / caminar"`), `em` is an emoji.
  - `LEVEL1_VERBS` (41 regular verbs) and `LEVEL1_FILLS` define Level 1.
  - `fills` map is keyed by **infinitive**; each entry `{p, es, en}` where `p` is the pronoun
    key for the blank and `es` has `___` placeholder. Missing entries fall back via `fillFor()`
    to a "Me gusta ___" infinitive sentence.
  - `ENDINGS` + `conjugate(verb, pron)` — regular present-tense conjugation. Pronoun keys:
    `yo, tu, el, nos, ellos`. **NOTE: only regular verbs conjugate correctly.**
- **Lesson plan**
  - `buildPlan(verbs)` auto-generates lessons: intro lessons (3 new verbs each), periodic
    reviews, one conjugation lesson per ending type present (ar/er/ir), mixed reviews, an
    "Ending master" mixed-conjugation lesson, and a finale. `planFor(level)` memoizes it.
  - `learnedUpTo(d)` returns verb ids unlocked through lesson `d` in the current level.
- **State / persistence** (`Store` IIFE; key `learn_verb_activity_v2`)
  - Saves to BOTH the artifact `window.storage` API AND `window.localStorage` (guarded in
    try/catch). localStorage is what makes a downloaded/local file remember progress.
  - State shape: `{ levels: { [id]: {completed, stars, collected} }, streak, lastDate }`.
  - `lvState(id)` lazily creates per-level progress. Backup/Restore = base64 of the JSON.
  - Do **not** introduce bare localStorage/sessionStorage without try/catch — it throws in
    the Codex.ai artifact sandbox.
- **Navigation / views** (no router; show/hide divs)
  - `#viewLevels` (level picker, `renderLevels`) → `openLevel(id)` → `#viewLevel`
    (lesson grid, `renderDash`) → `openDay(d)` opens the `#overlay` lesson sheet. `backToLevels()`.
- **Lesson flow** (`openDay` builds `stages`, `runStage` dispatches via a type→fn map)
  Order per lesson: `intro` → `wordbuild` → main game (`plan.game`) → `listenspell` →
  `voiceverb` → bonus (`fillblank` on odd days / `truefalse` on even) → `bloom`.
  - `pickFocus(n)` always includes the day's NEW verbs, then fills with older learned verbs
    (spaced review). `cur` holds the active lesson: `{plan, pool, newSet, oldSet, stages, idx,
    score, max}`.
- **Activities / games** (render fns)
  - `renderIntro` (flashcards), `renderScramble` (used for both `wordbuild` = today's words
    with English hint, and audio-less scramble), `renderListenSpell` (audio hint, spell from
    tiles), `renderVoiceVerb` (SpeechRecognition with graceful fallback; unscored),
    `renderMatch`, `renderQuiz`, `renderMemory`, `renderConj`, `renderFill`, `renderTF`,
    `renderBloom`.
  - Scoring games count `cur.score`/`cur.max`; stars (1–3) computed in `renderBloom` from the
    ratio. Multiple-choice + true/false + spelling allow **retry on wrong** (cute error) and
    only credit the first attempt.
- **Audio / feedback**
  - `speak(text)` — Spanish TTS via SpeechSynthesis (`es-ES`).
  - `SFX` (Web Audio) — `.right()` / `.wrong()` / `.pop()` cute tones; `sayOops()` speaks a
    playful "try again" on wrong answers.
- **Misc**: `toast()`, `confetti()`, `FLOWERS`/`flowerFor(d)` for the bloom icons.

## How to add a level (the main extension point)
1. Define a verb array, e.g.:
   ```js
   const LEVEL2_VERBS = [
     {id:1, es:"tener", inf:"tener", en:"to have", t:"er", em:"🤲"},
     // ...
   ];
   ```
2. (Optional) `const LEVEL2_FILLS = { tener:{p:"yo", es:"Yo ___ un perro.", en:"I have a dog."} };`
   Any verb without a fill gets the auto "Me gusta ___" sentence.
3. Append to `LEVELS`:
   ```js
   {id:2, name:"Level 2 · ...", blurb:"...", verbs:LEVEL2_VERBS, fills:LEVEL2_FILLS}
   ```
   Everything else (lesson grid, games, conjugation lessons, finale) generates automatically.

## Known limitations / TODO
- **Irregular verbs conjugate wrong.** `conjugate()` applies regular endings. For levels with
  irregular verbs (tener, ir, hacer, ser, estar, ...), add a per-verb `forms` override
  `{yo, tu, el, nos, ellos}` and make `conjugate()`/`renderConj`/`renderFill` prefer it.
- Only present tense exists. Other tenses would need new ending tables + UI.
- `voiceverb` SpeechRecognition needs mic permission and isn't available in all browsers /
  sandboxed iframes; it falls back to a trust-based "I said it!" button.
- No automated tests; consider extracting pure logic into a module for unit testing.

## Current status (as of handoff)
- Level 1 = 41 regular -AR/-ER/-IR verbs → `buildPlan` produces **25 lessons**.
- Kabir has completed **lessons 1–5** of Level 1 (lesson 5 is a Review; verbs 1–12 learned).
  A backup code representing this exists; Restore from the footer to reload it.

## Conventions / style
- Keep it a single self-contained HTML file (easy to share/download for a kid).
- Vanilla JS, no frameworks. Prefer small render functions that write into `#stage`.
- Kid-friendly tone, big tap targets, warm palette (CSS variables at `:root`).
- Guard all storage/audio/speech in try/catch so nothing crashes the experience.
