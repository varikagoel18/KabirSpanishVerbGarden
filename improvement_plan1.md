# Improvement Plan 1

Review date: 2026-07-20

Goal: improve maintainability and reduce future bug risk without changing current user-facing functionality or lesson logic.

Implementation branch: `improvements/phased-cleanup`

## Phased Implementation Approach

### Phase 1: Correctness Fixes

Implemented in this branch:
- Fix the undefined callback in Bonus Review paragraph fill.
- Make lesson progress saving idempotent for the same lesson run.
- Prevent zero-verb levels from triggering generic "all verbs learned" trophies.
- Replace hardcoded all-verb trophy thresholds with data-driven totals.
- Filter missing verb IDs when building lesson pools.
- Guard `conjugate()` against missing/invalid verb metadata.

### Phase 2: Shared Rules And State Cleanup

Implemented in this branch:
- Add `starsForScore(score, max)` in the main app and companion pages.
- Keep surprise quiz pending state disabled consistently.
- Stop companion pages from reintroducing `surpriseQuiz.pending`.
- Keep daily revive helper behavior aligned for the regular practice page.
- Move older one-time reset calls behind a schema-version migration runner.

### Phase 3: Low-Risk Maintainability Cleanup

Implemented in this branch:
- Clarify Level 4 lesson numbering so generated day numbers are the source of truth.
- Update stale storage comments.
- Replace random `sort(() => Math.random() - .5)` shuffles with Fisher-Yates helpers.
- Remove leftover debug logging from the practice-test page.

### Phase 4: Larger Refactors To Keep Deferred

Deferred intentionally:
- Extracting all shared rendering helpers across activities.
- Splitting the single HTML app into multiple source modules and building it back into one shareable file.
- Reworking the Spanish Class HW story audio into a dedicated `StoryPlayer` object.

Reason for deferral:
- These are worthwhile, but they touch many UI paths and carry more regression risk than the current branch needs.
- They should be done after the correctness/stability branch is verified in-browser.

## Findings

### 1. Avoid double-saving lesson progress

File: `learn-verb-activity.html`

Current issue:
- `saveDayProgress(stars)` is called in `renderBloom`.
- `commitDay(stars)` later calls `saveDayProgress(stars)` again.
- Completion state is mostly protected because completed days are keyed by day number.
- Some counters, especially Level 4 La Casa counters such as `sentenceCleanWin` and `listenCleanWin`, can still be incremented twice.

Recommended improvement:
- Make `saveDayProgress` fully idempotent.
- Only update one-time counters when the day was not previously completed.
- Keep star upgrades working, so replaying for a better star score still updates `st.stars[d]`.

Priority: High

## 2. Centralize shared scoring rules

Files:
- `learn-verb-activity.html`
- `regular-verb-practice-tests.html`
- `spanish-class-hw.html`

Current issue:
- Star thresholds now exist in multiple places.
- The intended shared rule is:
  - `<25%` correct -> `0★`, not complete
  - `25-50%` -> `1★`
  - `50-75%` -> `2★`
  - `75%+` -> `3★`

Recommended improvement:
- Create one helper in each file or a shared snippet:
  - `starsForScore(score, max)`
- Use it anywhere a score becomes stars.

Priority: High

## 3. Centralize two-attempt answer behavior

Files:
- `learn-verb-activity.html`
- `regular-verb-practice-tests.html`
- `spanish-class-hw.html`

Current issue:
- The two-attempt rule is implemented in several different styles.
- Future activities could accidentally reintroduce unlimited retries.

Recommended improvement:
- Standardize around a helper like:
  - `secondWrongAdvance(state, onAdvance)`
- For standalone pages, use the same naming and behavior:
  - first wrong: gentle retry
  - second wrong: mark wrong and advance

Priority: Medium-High

## 4. Centralize daily revive tracking

Files:
- `learn-verb-activity.html`
- `regular-verb-practice-tests.html`

Current issue:
- Daily revive logic is duplicated.
- The rule is: any 3 completed lessons/quizzes across 3 different levels revives all plants/saplings/trees for today.
- Duplicate implementations can drift over time.

Recommended improvement:
- Keep one canonical helper shape:
  - `markDailyLevelActivity(state, levelId, sourceKey)`
  - `reviveAllLevelsForToday(state)`
- Reuse the same logic in any standalone page that writes progress.

Priority: Medium

## 5. Clean up surprise quiz state logic in companion pages

Files:
- `regular-verb-practice-tests.html`
- `spanish-class-hw.html`

Current issue:
- Companion pages still contain surprise quiz pending logic.
- Main app has surprise quiz pop-up behavior disabled.
- This is not currently breaking functionality, but it is confusing and could cause future behavior drift.

Recommended improvement:
- Either fully remove surprise quiz trigger code from companion pages, or update it to match the main app's disabled behavior.
- Keep completion tracking only if still needed for parent dashboard/history.

Priority: Medium

## 6. Remove leftover debug logging

File: `regular-verb-practice-tests.html`

Current issue:
- A `console.log("Practice tests", ...)` remains at the bottom of the file.

Recommended improvement:
- Remove the debug log.

Priority: Low

## 7. Separate authored content from engine code

File:
- `learn-verb-activity.html`

Current issue:
- The main app is now more than 6,000 lines.
- Data, lesson plans, rendering, progress, trophies, and parent dashboard code all live in one file.

Recommended improvement:
- Keep the app shareable, but split internally by section more clearly.
- Possible later structure:
  - `data-levels.js`
  - `progress.js`
  - `activities.js`
  - `ui.js`
- If single-file sharing is still required, a simple build/pack script could combine these into one HTML file.

Priority: Medium-Low

## 8. Reduce repeated `innerHTML` rendering patterns

Files:
- `learn-verb-activity.html`
- `regular-verb-practice-tests.html`
- `spanish-class-hw.html`

Current issue:
- Many activities build large HTML strings inline.
- Content is authored locally, so this is acceptable, but repeated patterns make future mistakes easier.

Recommended improvement:
- Create small render helpers for common question panels, option buttons, hints, and action rows.
- Keep the visual output unchanged.

Priority: Low

## Suggested Safe Order

1. Make `saveDayProgress` idempotent.
2. Add `starsForScore(score, max)` and replace duplicated star calculations.
3. Normalize two-attempt helper usage across the three files.
4. Normalize daily revive helper usage across main and practice pages.
5. Remove stale surprise quiz trigger logic from companion pages.
6. Remove debug logging.
7. Later: consider separating data from engine code.

## Validation Checklist

After each change:

1. Run script syntax checks:
   ```bash
   node -e 'const fs=require("fs");for(const f of ["learn-verb-activity.html","regular-verb-practice-tests.html","spanish-class-hw.html"]){const h=fs.readFileSync(f,"utf8");const m=h.match(/<script>([\s\S]*)<\/script>/);fs.writeFileSync(`/tmp/${f}.js`,m[1]);}'
   node --check /tmp/learn-verb-activity.html.js
   node --check /tmp/regular-verb-practice-tests.html.js
   node --check /tmp/spanish-class-hw.html.js
   ```
2. Open the main app and confirm all level grids still render.
3. Complete one low-score attempt and confirm it stays not done.
4. Complete one passing attempt and confirm stars save.
5. Complete activities across 3 different levels and confirm all plants revive for today.
6. Confirm parent dashboard and trophy room still open.

---

# Detailed Review Addendum

This deeper pass found additional opportunities and a few subtle behavior risks. Items below are ranked by likely impact and how safely they can be improved.

## 9. Fix undefined callback in bonus paragraph fill

File: `learn-verb-activity.html`

Current issue:
- In `renderBonusReview()` -> `paragraphFill()`, the wrong-answer branch calls `secondWrongAdvance(wrongState, adv)`.
- That local scope does not define `adv`.
- Syntax checks pass because JavaScript does not resolve that identifier until the branch runs.
- Runtime impact: on a second wrong answer in the bonus paragraph fill activity, this can throw a `ReferenceError` and interrupt the lesson flow.

Recommended improvement:
- Replace the missing callback with the same paragraph advancement logic used after a correct answer:
  - if more blanks remain, move to the next blank and re-render
  - otherwise finish the paragraph phase and continue to redo/bloom

Priority: Highest

## 10. Make `saveDayProgress` one-shot for counters

File: `learn-verb-activity.html`

Current issue:
- `renderBloom()` calls `saveDayProgress(stars)` immediately.
- Clicking `Back to lessons` later calls `commitDay(stars)`, which calls `saveDayProgress(stars)` again.
- Completed flags and stars are guarded enough for basic completion.
- But Level 4 counters are incremented before checking whether the day was already completed:
  - `st.house.sentenceCleanWin += ...`
  - `st.house.listenCleanWin += ...`

Recommended improvement:
- Keep star upgrades allowed.
- Gate one-time counters behind `if (!wasCompleted)`.
- Alternatively split saving into:
  - `previewSaveDayProgress()` for early trophy checks
  - `commitDayProgress()` for final one-time effects

Priority: Highest

## 11. Prevent zero-verb levels from triggering "all verbs learned"

File: `learn-verb-activity.html`

Current issue:
- Trophy snapshot uses `if(collected>=lv.verbs.length) allVerbsLearned=true;`.
- For levels with no verb list, such as Everyday Basics or Verb Tenses, `0 >= 0` is true.
- Runtime impact: a zero-verb level can accidentally satisfy the generic "Collect all verbs in a level" trophy.

Recommended improvement:
- Require `lv.verbs.length > 0` before setting `allVerbsLearned`.
- Prefer dynamic counts for level-specific "all" trophies instead of hardcoded totals.

Priority: High

## 12. Replace hardcoded trophy thresholds with data-driven totals

File: `learn-verb-activity.html`

Current issue:
- Some trophy thresholds are hardcoded:
  - `regular-all` uses `41`
  - `irregular-all` uses `61`
- If verb lists change, trophies can become incorrect without any syntax failure.

Recommended improvement:
- Use `LEVEL1_VERBS.length`, `LEVEL2_VERBS.length`, and `LEVEL4_HOUSE_VOCAB.length`.
- Or expose these counts from `trophySnapshot()`.

Priority: High

## 13. Clean up unreachable surprise quiz code

File: `learn-verb-activity.html`

Current issue:
- `maybeShowSurpriseQuiz()` immediately returns after clearing `pending`.
- The original surprise quiz display code remains below that `return`, unreachable.

Recommended improvement:
- Either fully remove unreachable code, or preserve it behind a named feature flag:
  - `const SURPRISE_QUIZ_ENABLED = false;`
- If the feature might return later, feature flag is clearer than unreachable code.

Priority: Medium-High

## 14. Align companion-page surprise state behavior with the main app

Files:
- `regular-verb-practice-tests.html`
- `spanish-class-hw.html`

Current issue:
- Companion pages still set `surpriseQuiz.pending=true` after every fourth completion.
- Main app immediately clears `pending` and does not show the pop-up.
- This is harmless most of the time, but confusing and state-noisy.

Recommended improvement:
- Remove pending-trigger behavior from companion pages.
- Keep completion tracking if parent dashboard/history depends on it.

Priority: Medium-High

## 15. Clarify Level 4 lesson numbering source of truth

File: `learn-verb-activity.html`

Current issue:
- `LEVEL4_LESSONS` contains raw `d` and title numbers that are later overwritten by `.map((lesson, idx)=>...)`.
- Runtime is okay, but the source is confusing:
  - raw Day 4 appears twice
  - raw Day 5 appears twice
  - actual runtime days are only known after the map

Recommended improvement:
- Remove raw `d` values from the authored objects and generate them once.
- Or keep raw `d` values accurate and remove the reindexing map.

Priority: Medium

## 16. Make `learnedUpTo()` safer for future custom levels

File: `learn-verb-activity.html`

Current issue:
- `learnedUpTo(d)` returns all level verbs if no `newV` has been introduced yet.
- This works for current zero-verb custom levels, but it is risky for a future custom level with verbs and an early review/quiz day.
- That future level would accidentally unlock every verb before any learning lesson.

Recommended improvement:
- Only fall back to all verbs for explicitly review-only levels or when the level declares that behavior.
- Safer default:
  - return `[]` when no verbs have been introduced
  - let individual activities handle empty pools gracefully

Priority: Medium

## 17. Filter missing verb IDs before building lesson state

File: `learn-verb-activity.html`

Current issue:
- `openDay()` builds pools with `.map(byId)`.
- If content ever references a missing verb ID, later renderers may receive `undefined`.

Recommended improvement:
- Use `.map(byId).filter(Boolean)`.
- Add a development-only warning for missing IDs.

Priority: Medium

## 18. Guard `conjugate()` against bad verb metadata

File: `learn-verb-activity.html`

Current issue:
- `conjugate(v, p)` assumes `v`, `v.inf`, `ENDINGS[v.t]`, and `ENDINGS[v.t][p]` all exist.
- Current data is mostly valid, but this is a fragile extension point.

Recommended improvement:
- Add a small guard or a clear thrown error in development mode.
- This would make future level data mistakes easier to diagnose.

Priority: Medium

## 19. Do not let stale one-time migrations run forever

File: `learn-verb-activity.html`

Current issue:
- One-time functions such as `resetTenseLesson1Once()` and `resetHouseQuizAfterLesson3Once()` are permanent runtime code.
- Restoring an older backup without those marker flags will run those migrations again.

Recommended improvement:
- Move migrations into a versioned migration system:
  - `STATE.schemaVersion`
  - `migrations = [{version, run}]`
- Keep past migration behavior explicit and easier to retire later.

Priority: Medium

## 20. Fix stale storage comment

File: `learn-verb-activity.html`

Current issue:
- The storage header says "never uses localStorage".
- The implementation intentionally uses localStorage as fallback and persistent local-file storage.

Recommended improvement:
- Update the comment to match reality:
  - "Uses artifact storage when available, plus guarded localStorage fallback."

Priority: Low-Medium

## 21. Make story audio state easier to reason about

File: `spanish-class-hw.html`

Current issue:
- Story audio uses one shared `storyRun` object.
- Screen changes call `stopStoryAudio()`, which is good.
- Replay/seek/play behavior is spread across `setupStoryPlayer()`, `renderQuestion()`, `renderRedo()`, and `renderAudioStory()`.

Recommended improvement:
- Wrap story behavior into a small object:
  - `StoryPlayer.mount(story, options)`
  - `StoryPlayer.stop()`
  - `StoryPlayer.play(rate)`
- Keep the same UI and behavior.

Priority: Low-Medium

## 22. Reduce repeated question-rendering boilerplate

Files:
- `learn-verb-activity.html`
- `regular-verb-practice-tests.html`
- `spanish-class-hw.html`

Current issue:
- Many renderers repeat the same structure:
  - prompt panel
  - hint button
  - option buttons
  - wrong-attempt state
  - delayed advance

Recommended improvement:
- Introduce small helpers:
  - `renderQuestionShell({lead, sub, count, ask, hint})`
  - `renderOptions(opts, onPick)`
  - `advanceAfter(ms, callback)`
- This can be done gradually per activity type.

Priority: Low-Medium

## 23. Replace random `sort(()=>Math.random()-.5)` shuffles

Files:
- `regular-verb-practice-tests.html`
- `spanish-class-hw.html`

Current issue:
- Some standalone-page code uses `array.sort(()=>Math.random()-.5)`.
- The main app already has a Fisher-Yates `shuffle()`.

Recommended improvement:
- Use the same Fisher-Yates helper everywhere.

Priority: Low

## 24. Remove stale debug logging

File: `regular-verb-practice-tests.html`

Current issue:
- The file ends with `console.log("Practice tests", ...)`.

Recommended improvement:
- Remove it or guard it behind a `DEBUG` flag.

Priority: Low

## Updated Suggested Safe Order

1. Fix the undefined `adv` callback in bonus paragraph fill.
2. Make `saveDayProgress` idempotent for one-time counters.
3. Fix zero-verb "all verbs learned" trophy logic.
4. Replace hardcoded trophy counts with data-driven totals.
5. Clean up unreachable surprise quiz code and companion-page pending triggers.
6. Normalize shared star/two-attempt/daily-revive helpers.
7. Clean up Level 4 lesson numbering source of truth.
8. Add safer guards around future level data.
9. Move one-time reset functions into versioned migrations.
10. Remove debug logging and stale comments.

## Extra Validation Cases

Add these to the existing checklist:

1. Bonus Review paragraph fill: answer one blank wrong twice and confirm the app advances.
2. Trophy room: confirm "Word Wizard" does not unlock from zero-verb levels.
3. Level 4: complete a quiz once and verify La Casa clean-win counters increase only once.
4. Restore an older backup and confirm migrations do not unexpectedly clear newer progress.
5. Open `regular-verb-practice-tests.html`, complete a passing test, then open the main app and confirm surprise quiz pending state is not reintroduced.
6. Open a future custom level with no `newV` on day 1 and confirm it does not unlock every verb by accident.
