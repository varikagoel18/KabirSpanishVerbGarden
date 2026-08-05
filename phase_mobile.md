# Web + Mobile Interaction Plan

Branch: `codex/web-mobile-ux-flow-plan`

Goal: improve interaction flow, button placement, and visual hierarchy for both the browser version and the installed iPhone app without changing lesson/scoring/progress logic unless explicitly planned.

## Phase 1 - Audit Current Flow

- Map the main user paths:
  - Home/dashboard
  - Level picker
  - Level grid
  - Lesson overlay
  - Quiz flow
  - Practice tests
  - Spanish class HW
  - Trophy room
  - Parents dashboard
  - Sync panel
- Review each path at desktop, iPad, and iPhone widths.
- Identify buttons that are:
  - Too far from thumb reach on iPhone
  - Competing visually with the primary action
  - Hidden below the fold
  - Repeated in confusing places
  - Smaller than the 44x44pt tap-target minimum for a child to tap reliably
- Confirm the installed iPhone app uses the same bundled HTML behavior as the web app (byte-identical `learn-verb-activity.html`, `regular-verb-practice-tests.html`, `spanish-class-hw.html`).

**Phase QA / exit check:**

- Produce a short audit note listing the top 5 web issues and top 5 iPhone issues before coding.
- Capture screenshots for desktop, iPad-width, and iPhone-width baseline states.
- Confirm `git status` is clean before Phase 2 begins.
- Confirm no app files changed during audit unless the user explicitly approves a doc-only update.

## Phase 2 - Mobile-First Lesson Shell

- On iPhone-sized screens, make lessons and quizzes feel like full-screen activities instead of desktop-style modal sheets.
- Keep the top area focused on:
  - Close/back button
  - Activity title
  - Progress indicator
- Add a sticky bottom action area for primary actions:
  - `Next`
  - `Check`
  - `Try again`
  - `Done`
  - `Continue`
- Keep secondary actions smaller and away from the primary button.
- Make answer choices full-row tappable.
- Preserve existing scoring behavior, including two-attempt rules and star thresholds.

**Implementation details (decide before coding):**

- **Safe area:** use `padding-bottom: calc(12px + env(safe-area-inset-bottom))` on the sticky bar so it clears the iPhone home indicator; also set `bottom: env(safe-area-inset-bottom)` when positioned fixed.
- **Height math:** switch overlay/stage from `100vh` to `100dvh` so the sticky bar sits above the visible viewport rather than under Safari's URL chrome / iOS keyboard.
- **DOM location:** the sticky bar is a **sibling of `.stage` inside the overlay panel**, not injected into the stage HTML. This way `renderStage()` can rewrite `.stage.innerHTML` without wiping the bar. Renderers push their primary action's `{label, onClick, disabled}` into a shared `stageBottom({...})` helper.
- **Keyboard handling:** on iOS the on-screen keyboard shifts the viewport; use `visualViewport` events to reposition the sticky bar when a text input is focused so it stays visible above the keyboard. Fall back to `window.innerHeight` polling on `focus`/`blur` when `window.visualViewport` is undefined (older Safari).

**Phase QA / exit check:**

- Run `node --check` against all three HTML scripts.
- Verify at least one lesson, one quiz, one fill/type activity, and one matching activity on iPhone-width.
- Verify sticky controls clear the home indicator and do not cover answer options.
- Verify keyboard-focused inputs keep the primary action visible or intentionally move it away.
- Verify desktop modal layout still works and does not inherit cramped mobile-only behavior.
- Verify scoring and two-attempt behavior are unchanged with a wrong-first-attempt test.
- Commit Phase 2 before starting Phase 3.

## Phase 3 - Home Screen Flow

- Add a clear "Today" path at the top of the home screen.
- The first visible action should answer: "What should Kabir do now?"
- Suggested top card:
  - `Today: Level X - Lesson/Quiz Y`
  - Short label for the subject
  - One strong `Play Now` button
- Keep the full level list below as secondary navigation.
- On iPhone, the existing collapse toggle (`+`/`-`) continues to hide the stats grid. This plan does **not** add a separate `Stats` button; it uses the toggle that already ships.
- On desktop/iPad, keep richer stats visible because there is room to scan.

**"Today" pick rule (concrete):**

**Prerequisite:** persist `STATE.lastLevelId` inside `openLevel(id)` (today only tracked in memory as `LVID`). Migrate missing key to `null` in `ensureExtraState`.

1. If the user has an active revival coupon showing, defer to that flow.
2. Otherwise pick the **next incomplete day in the level the user most recently opened** (`STATE.lastLevelId`).
3. If that level is fully done, fall back to the level with the fewest completed lessons that still has an unlocked day.
4. Never surface a locked day; if only bonus/finale days remain, surface those.
5. If no candidate exists (fresh install), point at Level 0 Day 1.

**Phase QA / exit check:**

- Test fresh state: Today card points to Level 0 Day 1.
- Test after opening each level: Today card follows `STATE.lastLevelId`.
- Test a fully completed level: Today card falls back to an unlocked incomplete level.
- Test locked future days: Today card never opens a locked tile.
- Test revival coupon state: coupon flow remains higher priority than Today card.
- Confirm backup/restore still preserves enough state for Today card behavior.
- Run `node --check`, `git diff --check`, and commit Phase 3 before starting Phase 4.

## Phase 4 - Button Hierarchy

- Use one clear primary action per screen or card.
- **Primary button** — high-contrast CTA:
  - Background: `linear-gradient(180deg, var(--berry) 0%, var(--berry-dark) 100%)`
  - Text: `#fff`, font-weight 800
  - Min height 48px, min width 140px (>= 44pt tap target)
  - Bottom aligned on mobile, right / bottom-right on desktop
- **Secondary button** — ghost / muted:
  - `background: transparent; border: 1.5px solid rgba(60,45,20,.16); color: var(--ink);`
  - Same 48px min height so pairs read as siblings
  - Grouped away from the primary action
- **Utility buttons (header `mini-action` — Parents / Trophies / Sync):**
  - Neither primary nor secondary; treat as a third bucket.
  - `background: rgba(255,255,255,.2); border: 1.5px solid rgba(255,255,255,.3); color: #fff;`
  - Height ~34px on desktop / 36px on mobile.
  - Never grow to primary-button size, and never appear inside a lesson activity's content area.
- **Danger / destructive button** (Reset, Discard) — pink outline, white fill; only used inside confirm dialogs.
- Status buttons should have distinct labels:
  - `Start`
  - `Continue`
  - `Retry`
  - `Locked`
  - `Done`
- Avoid putting critical actions only in the header on mobile.

**Phase QA / exit check:**

- Confirm every level card has one visually dominant action.
- Confirm Parents, Trophies, Sync remain utility controls and are not mistaken for primary lesson actions.
- Confirm destructive actions still require confirmation and are visually distinct.
- Check tap target size for primary, secondary, and utility buttons at iPhone width.
- Verify text does not overflow in long labels like `Practice Tests`, `Spanish Class HW`, and `Continue`.
- Run `node --check`, `git diff --check`, and commit Phase 4 before Phase 5.

## Phase 5 - Level Card Polish

- Keep lesson and quiz tile meanings consistent (match the code identifiers so grep works):
  - 🌱 **Sapling** = lesson day that's next up or in-progress
  - 🌸 **Flower** = lesson day that's completed (`flowerFor(p.d)` — pattern already in `renderDash`)
  - 🌳 **Tree** = quiz / bonus tile (`p.bonus || p.fiestaQuiz || p.pureQuiz || p.tense || p.game==="quiz"`); trees stay trees even after completion
  - 🥀 **`drought` state** (className in code) = day is completed but the level hasn't been played today
  - 🔒 **Lock** = unavailable
- Make level cards tighter on mobile:
  - One primary button
  - Compact progress line
  - Clear status text
- Keep desktop cards richer:
  - More stats
  - More spacing
  - Easier comparison between levels
- Avoid adding extra explanatory text inside the app unless it directly helps Kabir act.

**Phase QA / exit check:**

- Verify completed, locked, next, lesson, quiz, and drought tile states in each level type.
- Confirm sapling/tree icon mapping stays consistent across Levels 0-4, Practice Tests, and HW links where applicable.
- Confirm Level 1 and Level 2 daily revive/drought behavior is not changed by visual cleanup.
- Confirm Level 3 tense activities do not show dead plants if that exception still applies.
- Compare desktop and mobile screenshots to ensure mobile got tighter without removing desktop information.
- Run `node --check`, `git diff --check`, and commit Phase 5 before Phase 6.

## Phase 6 - Audio + Listening Flow

**Split into two sub-phases because the app currently only has TTS via `speak()` — no story audio / slow / scrub bar exists yet.**

### 6a - Audio audit (do first)

- Grep every call site of `speak()` and any `<audio>` element.
- Confirm what audio actually plays today (verb TTS, celebration SFX) and what is aspirational.
- Decide per screen whether audio needs adding at all.
- Output: a written inventory before any UI is built.

**6a QA / exit check:**

- Save the inventory in the working notes or this plan before touching audio UI.
- Confirm all existing `speak()` call sites are accounted for.
- Confirm whether any real `<audio>` timeline exists; if none, do not build a scrub bar yet.
- Commit the audit/doc update before 6b if it changes files.

### 6b - Audio control polish (only for screens that have audio)

- Keep story/audio controls near the question.
- Always include:
  - Play
  - Slow (if the source supports rate control — TTS does via `SpeechSynthesisUtterance.rate`; note that iOS Safari clamps `rate` to a narrower range than Chrome, so the Slow effect is subtler on iPhone — test the actual audible delta on-device before shipping)
  - Scrub/progress bar (only where a real audio timeline exists — not for TTS)
- On long question screens, repeat compact audio controls near the sticky bottom action area.
- Stop audio automatically when:
  - Moving to a new question
  - Closing the lesson
  - Switching screens
  - Starting a different audio clip
- Keep audio controls large enough for mobile taps (44x44pt min).

**6b QA / exit check:**

- Verify Play and Slow work for TTS-backed prompts.
- Verify no scrub bar appears for TTS-only screens.
- Verify audio stops on next question, previous/close, screen change, and new audio start.
- Verify iPhone silent mode / autoplay limitations do not break the flow; controls should require a user tap when needed.
- Verify audio controls do not duplicate confusingly on short screens.
- Run `node --check`, `git diff --check`, and commit Phase 6 before Phase 7.

## Phase 7 - Celebration + Trophy Flow

- Make earned trophies feel special without blocking the next learning step for too long.
- Use celebration moments after:
  - New trophy
  - Lesson complete
  - Quiz complete
  - Surprise quiz unlocked
  - Meaningful small win
- **Respect `prefers-reduced-motion`:** when the user has requested reduced motion, drop confetti/pixie dust and replace with a static badge or a single fade-in. Applies to `confetti()`, `pixieConfetti()`, `trophyMegaBurst()`, and the `.trv2-card::before` idle shimmer.
- **Code hook:** at load, evaluate `const REDUCED_MOTION = matchMedia('(prefers-reduced-motion: reduce)').matches;` and short-circuit each animation function when true. Also add `@media (prefers-reduced-motion: reduce) { .trv2-card::before, .confetti { animation: none !important; } }` in the stylesheet so CSS-only animations don't need a JS gate.
- **Surprise quiz relocation is a logic change, not visual polish.** Today `maybeShowSurpriseQuiz()` fires at startup as an overlay. Moving it to a "post-completion event card" changes when/where it runs, so:
  - Track it under the plan's *"logic changes required"* section.
  - Keep the storage guard against re-triggering.
  - Add before/after QA that the surprise trophy still fires.
- On trophy page:
  - Keep distinct icons/badges
  - Show earned vs locked clearly
  - Keep the layout dense enough for scanning
  - Avoid excessive animation on page load (already scoped: `will-change` is now `:active`-only; keep it that way).

**Phase QA / exit check:**

- Test one newly earned trophy and confirm the celebration appears once.
- Test multiple newly earned trophies and confirm the queue advances cleanly.
- Test `prefers-reduced-motion: reduce`: no heavy confetti/pixie burst should run.
- Test trophy page opening on mobile and desktop; cards must not jump or overflow.
- Test surprise quiz trigger before and after any relocation; it must not retrigger repeatedly.
- Confirm surprise quiz completion still records progress/trophies correctly.
- Run `node --check`, `git diff --check`, and commit Phase 7 before Phase 8.

## Phase 8 - Desktop + iPad Refinement

- Preserve the richer dashboard feeling on larger screens.
- Keep stats visible where space allows.
- Use two-column or wider layouts only when they improve scanning.
- Keep lesson activities centered and readable.
- Avoid creating separate behavior paths unless mobile ergonomics require it.
- **Concrete rule:** never remove a stat tile / info section from the desktop layout just because it's hidden on mobile. Mobile can collapse; desktop should still show everything at once.
- **Flip side:** mobile is allowed to hide anything desktop shows, but **only via a collapse/toggle the user can reopen** (like the current header `+/-`). Never remove functionality entirely on mobile.

**Phase QA / exit check:**

- Compare desktop, iPad landscape, iPad portrait, iPhone portrait, and iPhone landscape.
- Confirm desktop still shows rich stats and level context.
- Confirm iPad layout does not feel like an over-stretched phone layout.
- Confirm no card-in-card visual nesting was introduced.
- Confirm all visible text fits without overlap at narrow and wide widths.
- Run `node --check`, `git diff --check`, and commit Phase 8 before Phase 9.

## Phase 9 - QA Checklist

- Validate desktop browser flow.
- Validate iPad-width browser flow.
- Validate iPhone-width browser flow.
- Validate installed iPhone app.
- Validate with `prefers-reduced-motion: reduce` in Safari / iOS Settings > Accessibility > Motion > Reduce Motion.
- Validate iPhone landscape orientation (currently allowed via Info.plist).
- Confirm:
  - No progress data loss
  - No scoring rule changes
  - No lesson unlock regressions
  - No repeated unexpected generic fills in Vocab Fiesta
  - Practice Test and Spanish HW links still open in iOS app
  - Audio stops on screen/question changes
  - Sticky mobile controls do not cover answer options and clear the home indicator via `env(safe-area-inset-bottom)`
  - Sticky bar stays above the on-screen keyboard when a text input is focused
  - Text fits inside buttons/cards
  - Main web HTML and bundled iOS HTML remain synchronized (`diff -q` on the two `learn-verb-activity.html` copies must return no output)
  - **Sync round-trip (measurable):** before sync, snapshot each side's `STATE.levels[N].completed` count, `STATE.levels[N].stars[d]` per day, and `Object.keys(STATE.trophies).length`. After running `Sync now` on the browser, both sides must satisfy: `count_completed >= max(browserBefore, phoneBefore)`, `stars[d] >= max(browserBefore[d], phoneBefore[d])` for every day, and `trophyCount >= max(browserBefore, phoneBefore)`. Then run sync a second time — nothing should change. **Fail if any counter decreases.**

## Implementation Order

Phases below map back to the sections above.

1. Phase 1 - Audit
2. Phase 2 - Sticky mobile bottom action structure
3. Phase 3 - "Today / Play Now" home path
4. Phase 2 (part 2) - Convert iPhone lesson overlay behavior toward full-screen
5. Phase 4 - Button hierarchy (colors, sizes, buckets) — must land before Phase 5
6. Phase 5 - Level card cleanup (uses Phase 4's color decisions)
7. Phase 6a - Audio audit
8. Phase 6b - Audio control placement (only if audit reveals real audio to polish)
9. Phase 7 - Trophy + celebration flow (including reduced-motion + surprise-quiz relocation)
10. Phase 8 - Desktop + iPad refinement
11. Phase 9 - Cross-device QA and adjust spacing

## Guardrails

- Do not change scoring, stars, unlock rules, or progress storage unless explicitly requested.
- Keep all `localStorage` access guarded (`try/catch` around every `getItem`/`setItem`).
- Keep `ios/build/` ignored.
- Keep the bundled iOS HTML copy in sync with `learn-verb-activity.html` (verified in Phase 9 QA).
- Prefer CSS/media-query/layout changes before restructuring logic.
- If logic has to move, keep it narrowly scoped and test the affected flow immediately.
- **No new network requests beyond the existing font links.** The app currently loads Baloo 2 / Nunito from `fonts.googleapis.com`; those are grandfathered in. Do not add any additional CDNs, telemetry pings, analytics, or fetches. Bundle any new fonts/images/audio locally.
- **All tap targets minimum 44x44pt.**
- **Never install / rebuild the iPhone app during implementation** unless the user explicitly asks; ship changes to disk, verify with `node --check` and the iOS Simulator, then wait for a `push to iPhone` instruction.

## Rollback Plan

Every phase must be reversible in under 30 seconds so a bad merge can't strand Kabir mid-lesson.

- **Per-phase git commit:** each phase lands in one commit with a `Phase N: ...` prefix. Never mix two phases in one commit — a bad Phase 4 button color must be revertable without losing Phase 2's sticky bar.
- **Feature flags for behavior-changing phases:** wrap Phase 2 (sticky bar), Phase 3 (Today card), and Phase 7 (surprise-quiz relocation) behind boolean toggles stored in `STATE.uxFlags = {phase2:true, phase3:true, phase7:true}` (default on). Expose a hidden "UX flags" section in the Parents panel that flips them off for quick rescue.
- **HTML backup on iPhone:** the existing `syncMergeIncoming` already snapshots to `learn_verb_activity_v2_backup` — do not remove that. If a pushed HTML breaks localStorage, users can restore via the browser console:
  `localStorage.setItem("learn_verb_activity_v2", localStorage.getItem("learn_verb_activity_v2_backup")); location.reload();`
- **Bundled HTML on iPhone:** the app's `WebViewStore.resetToBundledHTML()` reverts an OTA push. Keep that button reachable (via the browser sync panel's *"↩︎ Revert to shipped"*).
- **Git revert one-liner:** for each phase, the doc must include the exact revert command it would take. E.g. `git revert <phaseCommit>` plus a rebuild + reinstall step.

## Test Session Script

Run this canonical script at the end of every phase before merging. Should take ~5 minutes.

1. **Open a fresh browser tab** at `learn-verb-activity.html`; expect the level picker to render with the header collapsed by default (mobile-width) or fully expanded (desktop-width).
2. **Open Level 1** — the level card should highlight the current next day.
3. **Play Level 1 Day 1** through to bloom. During the lesson:
   - Enter one wrong answer, one hint, one right answer.
   - Verify the two-attempt rule fires on the second wrong.
   - Verify the sticky primary action stays visible when text input is focused.
4. **Trigger a trophy** by finishing to 3 stars if possible. Verify the trophy chain shows once and animates cleanly (or is subdued under `prefers-reduced-motion`).
5. **Open Trophies** — scan for layout jump; verify progress bars fill smoothly.
6. **Open Sync panel** — Test connection to the iPhone; confirm ping succeeds within 6s.
7. **Run Sync progress** — confirm both sides reload with merged state and the round-trip counter assertion (Phase 9) passes.
8. **Collapse the header** with `+/-`; confirm the level list scrolls without jitter.
9. **Close the browser tab.** Reopen — confirm the app resumes at the same level with progress intact and no console errors.

Any failure = rollback the current phase and file an issue before continuing.

## Change Budget Per Phase

Rough size limit per phase — a PR bigger than this signals scope creep and should be split.

| Phase | Est. LOC added/changed | Notes |
|---|---|---|
| 1 (Audit) | 0 code, doc-only | Screenshots + notes, no `learn-verb-activity.html` diff |
| 2 (Sticky shell) | ~120 lines | HTML wrapper + CSS + `stageBottom()` helper + wiring in ~5 renderers |
| 3 (Today card) | ~80 lines | `pickTodayCard()` function + rendering + `STATE.lastLevelId` persistence |
| 4 (Buttons) | ~60 lines | Mostly CSS replacements + one shared `.btn-primary`, `.btn-secondary`, `.btn-utility` cleanup |
| 5 (Level cards) | ~40 lines | CSS-only for icons, spacing, status text |
| 6a (Audio audit) | 0 code, doc-only | Grep output pasted into an "Audio inventory" section |
| 6b (Audio polish) | ~60 lines *if* real audio exists; else 0 | Skipped entirely if 6a shows nothing to polish |
| 7 (Celebration) | ~60 lines | `REDUCED_MOTION` gate + surprise-quiz relocation + CSS media query |
| 8 (Desktop/iPad refinement) | ~40 lines | Media-query tweaks only; no logic |
| 9 (QA) | 0 code, doc-only | Checklist run, screenshots, sign-off |

**Total budget:** ~460 lines across all coding phases. If cumulative diff exceeds 700 lines by Phase 7, stop and re-plan.
