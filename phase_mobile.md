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
- **Keyboard handling:** on iOS the on-screen keyboard shifts the viewport; use `visualViewport` events to reposition the sticky bar when a text input is focused so it stays visible above the keyboard.

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

1. If the user has an active revival coupon showing, defer to that flow.
2. Otherwise pick the **next incomplete day in the level the user most recently opened** (`STATE.lastLevelId`).
3. If that level is fully done, fall back to the level with the fewest completed lessons that still has an unlocked day.
4. Never surface a locked day; if only bonus/finale days remain, surface those.
5. If no candidate exists (fresh install), point at Level 0 Day 1.

## Phase 4 - Button Hierarchy

- Use one clear primary action per screen or card.
- **Primary button:**
  - Pink/action color (`--berry`)
  - Large
  - Bottom aligned on mobile
  - Right aligned or bottom-right on desktop
- **Secondary buttons:**
  - Ghost or muted style
  - Smaller
  - Grouped away from the primary action
- **Utility buttons (header `mini-action` — Parents / Trophies / Sync):**
  - Neither primary nor secondary; treat as a third bucket.
  - Small, translucent-white pill on the green header.
  - Never grow to primary-button size, and never appear inside a lesson activity's content area.
- Status buttons should have distinct labels:
  - `Start`
  - `Continue`
  - `Retry`
  - `Locked`
  - `Done`
- Avoid putting critical actions only in the header on mobile.

## Phase 5 - Level Card Polish

- Keep lesson and quiz tile meanings consistent (match the code identifiers so grep works):
  - **Sapling** = lesson (unstarted or in-progress)
  - **Tree** = quiz / bonus tile (`p.bonus || p.fiestaQuiz || p.pureQuiz`, etc.)
  - **Lock** = unavailable
  - **`drought` state** (className used in code) = "needs today's activity for that level"
- Make level cards tighter on mobile:
  - One primary button
  - Compact progress line
  - Clear status text
- Keep desktop cards richer:
  - More stats
  - More spacing
  - Easier comparison between levels
- Avoid adding extra explanatory text inside the app unless it directly helps Kabir act.

## Phase 6 - Audio + Listening Flow

**Split into two sub-phases because the app currently only has TTS via `speak()` — no story audio / slow / scrub bar exists yet.**

### 6a - Audio audit (do first)

- Grep every call site of `speak()` and any `<audio>` element.
- Confirm what audio actually plays today (verb TTS, celebration SFX) and what is aspirational.
- Decide per screen whether audio needs adding at all.
- Output: a written inventory before any UI is built.

### 6b - Audio control polish (only for screens that have audio)

- Keep story/audio controls near the question.
- Always include:
  - Play
  - Slow (if the source supports rate control — TTS does via `SpeechSynthesisUtterance.rate`)
  - Scrub/progress bar (only where a real audio timeline exists — not for TTS)
- On long question screens, repeat compact audio controls near the sticky bottom action area.
- Stop audio automatically when:
  - Moving to a new question
  - Closing the lesson
  - Switching screens
  - Starting a different audio clip
- Keep audio controls large enough for mobile taps (44x44pt min).

## Phase 7 - Celebration + Trophy Flow

- Make earned trophies feel special without blocking the next learning step for too long.
- Use celebration moments after:
  - New trophy
  - Lesson complete
  - Quiz complete
  - Surprise quiz unlocked
  - Meaningful small win
- **Respect `prefers-reduced-motion`:** when the user has requested reduced motion, drop confetti/pixie dust and replace with a static badge or a single fade-in. Applies to `confetti()`, `pixieConfetti()`, `trophyMegaBurst()`, and the trophy card idle shimmer.
- **Surprise quiz relocation is a logic change, not visual polish.** Today `maybeShowSurpriseQuiz()` fires at startup as an overlay. Moving it to a "post-completion event card" changes when/where it runs, so:
  - Track it under the plan's *"logic changes required"* section.
  - Keep the storage guard against re-triggering.
  - Add before/after QA that the surprise trophy still fires.
- On trophy page:
  - Keep distinct icons/badges
  - Show earned vs locked clearly
  - Keep the layout dense enough for scanning
  - Avoid excessive animation on page load (already scoped: `will-change` is now `:active`-only; keep it that way).

## Phase 8 - Desktop + iPad Refinement

- Preserve the richer dashboard feeling on larger screens.
- Keep stats visible where space allows.
- Use two-column or wider layouts only when they improve scanning.
- Keep lesson activities centered and readable.
- Avoid creating separate behavior paths unless mobile ergonomics require it.
- **Concrete rule:** never remove a stat tile / info section from the desktop layout just because it's hidden on mobile. Mobile can collapse; desktop should still show everything at once.

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
  - **Sync round-trip:** with progress on both browser and iPhone, run `Sync now` and confirm both sides end with union of completed lessons, max of stars, union of trophies. Run the reverse direction. Neither side may lose data.

## Implementation Order

Phases below map back to the sections above.

1. Phase 1 - Audit
2. Phase 2 - Sticky mobile bottom action structure
3. Phase 3 - "Today / Play Now" home path
4. Phase 2 (part 2) - Convert iPhone lesson overlay behavior toward full-screen
5. Phase 4 & Phase 5 - Button hierarchy + level-card cleanup
6. Phase 6a - Audio audit
7. Phase 6b - Audio control placement (only if audit reveals real audio to polish)
8. Phase 7 - Trophy + celebration flow (including reduced-motion + surprise-quiz relocation)
9. Phase 8 - Desktop + iPad refinement
10. Phase 9 - Cross-device QA and adjust spacing

## Guardrails

- Do not change scoring, stars, unlock rules, or progress storage unless explicitly requested.
- Keep all `localStorage` access guarded (`try/catch` around every `getItem`/`setItem`).
- Keep `ios/build/` ignored.
- Keep the bundled iOS HTML copy in sync with `learn-verb-activity.html` (verified in Phase 9 QA).
- Prefer CSS/media-query/layout changes before restructuring logic.
- If logic has to move, keep it narrowly scoped and test the affected flow immediately.
- **No new network requests.** The app must keep working offline. Bundle any new fonts/images/audio; do not add third-party CDN references.
- **All tap targets minimum 44x44pt.**
- **Never install / rebuild the iPhone app during implementation** unless the user explicitly asks; ship changes to disk, verify with `node --check` and the iOS Simulator, then wait for a `push to iPhone` instruction.
