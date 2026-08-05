# Web + Mobile Interaction Plan

Branch: `codex/web-mobile-ux-flow-plan`

Goal: improve interaction flow, button placement, and visual hierarchy for both the browser version and the installed iPhone app without changing lesson/scoring/progress logic unless explicitly planned.

## Live Phase Status

Last updated: 2026-08-05 15:22 IST

| Phase | Branch | Status | Commit / push | QA / notes |
|---|---|---|---|---|
| Plan | `codex/web-mobile-ux-flow-plan` | Complete | `17bba81` committed | Iterated review complete. |
| 1 - Audit | `codex/mobile-ux-phase-1-audit` | Complete | `8fe1eb1` pushed; remote SHA verified | Source audit, syntax, bundle parity, signed iPhone install/launch complete; fresh visual screenshots deferred to Phase 9 because local `file://` automation was blocked. |
| 1a - iOS OTA sibling pages | `codex/mobile-ux-phase-1a-ios-sibling-pages` | Complete | `6cacb45` pushed; remote SHA verified | Signed physical-device build succeeded; all three bundle resources match the web files; the exact build installed and launched on the paired iPhone. CoreDevice process enumeration was unreliable after launch, so that secondary inspection remains deferred. |
| 2 - Sticky mobile action | `codex/mobile-ux-phase-2-sticky-action` | Complete | `Phase 2: sticky portrait lesson actions`; push and remote SHA verification are the final handoff step | Responsive browser QA, simulator build/install/launch, signed physical-iPhone install/launch, portrait-only plist verification, and exact before/after progress comparison passed. Work stops here before Phase 3. |
| 3-prereq - `lastLevelId` | `codex/mobile-ux-phase-3-prereq-last-level-id` | Complete | Ready to commit/push from exact Phase 2 commit `b8ba982` | Focused migration/persistence tests, all-script syntax, three-resource parity, and `git diff --check` passed; no scoring/content/progress fields changed. |
| 3 - Today card | Not created | Pending | - | - |
| 2b - Full-screen overlay | Not created | Pending | - | - |
| 4 - Button hierarchy | Not created | Pending | - | - |
| 5 - Level cards | Not created | Pending | - | - |
| 6a - Audio audit | Not created | Pending | - | - |
| 6b - Audio polish | Not created | Pending | - | Runs only if 6a confirms useful audio surfaces. |
| 7 - Celebration and trophies | Not created | Pending | - | - |
| 8 - Desktop and iPad | Not created | Pending | - | - |
| 9 - Final cross-device QA | Not created | Pending | - | Includes the deferred desktop/iPad/iPhone visual baselines. |

## Phase Execution Protocol

- Create a dedicated branch for every phase from the latest user-approved phase commit. Use `codex/mobile-ux-phase-<number>-<short-name>`; sub-phases such as `3-prereq`, `2b`, `6a`, and `6b` get separate branches and approvals because they have separate commits in the implementation order.
- Run every new phase in a separate Codex task, and title that task with the exact phase name shown in this document (for example, `Phase 2 - Sticky Mobile Action`). At phase completion, pass the plan path, pushed commit, QA state, device-authorization state, and next phase title into the newly named task.
- Work on one phase only. Do not begin, branch for, or mix in the next phase while the current phase is under implementation or review.
- For the current phase: implement its scoped changes, run its specific exit checks, review the diff with fresh eyes, fix every in-scope finding, and repeat review/testing until a full pass finds no new in-scope issue.
- Run pre-commit QA, create one `Phase N: ...` commit, push the phase branch, verify the pushed SHA, and run the phase's smoke QA against that committed tree.
- Report changed files, checks, residual risks, the exact `git revert <phaseCommit>` command, and the pushed branch in the working log. Then create the next phase branch from that verified commit and continue automatically.
- Do not merge a phase branch into the plan branch or `main` unless the user explicitly requests the merge.
- If a required exit check is blocked by the available tooling, use the safest available substitute, document the residual check for Phase 9, and continue when the user has explicitly instructed uninterrupted phase progression.

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
- Confirm the bundled iOS web resources are byte-identical to the web files (`learn-verb-activity.html`, `regular-verb-practice-tests.html`, `spanish-class-hw.html`). Only validate the installed iPhone app in Phase 1 if the user has explicitly asked for device QA.

**Phase QA / exit check:**

- Produce a short audit note listing the top 5 web issues and top 5 iPhone issues before coding.
- Capture screenshots for desktop, iPad-width, and iPhone-width baseline states.
- Confirm `git status` is clean before Phase 2 begins.
- Confirm no app HTML, CSS, JavaScript, Swift, or plist files changed during audit. Audit notes and baseline images are the only permitted Phase 1 file changes.
- Confirm iPhone sibling-page navigation works from both startup modes: bundled main HTML and a Documents-directory OTA main HTML. If the OTA path cannot resolve Practice Tests and Spanish HW, treat it as a blocking existing bug and fix it in a separately approved prerequisite phase before Phase 2.

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

- **Safe area:** default to **`bottom: 0` + `padding-bottom: calc(12px + env(safe-area-inset-bottom))`** — one offset, applied on the same element. Never combine `bottom: env(safe-area-inset-bottom)` *and* a safe-area padding on the same element or the footer floats too high.
- **Height math:** use a fallback pair: `height: 100vh; height: 100dvh;` so modern mobile browsers get the dynamic viewport while older browsers still render.
- **DOM location:** the sticky bar is a **sibling of `#stage` inside the overlay panel**, not injected into the stage HTML. This way `runStage()` (in the code) can rewrite `$("#stage").innerHTML` without wiping the bar. Renderers push their primary action's `{label, onClick, disabled}` into a shared `stageBottom({...})` helper.
- **Keyboard handling:** on iOS the on-screen keyboard shifts the viewport; use `visualViewport` events to reposition the sticky bar when a text input is focused so it stays visible above the keyboard. Fall back to `window.innerHeight` polling on `focus`/`blur` when `window.visualViewport` is undefined (older Safari).
- **Orientation:** the installed iOS app is portrait-only. Keep both iPhone and iPad supported-orientation declarations limited to `UIInterfaceOrientationPortrait`; landscape-specific lesson-shell support and QA are out of scope.
- **Reduce Transparency:** iOS "Settings > Accessibility > Display & Text Size > Reduce Transparency" disables `backdrop-filter`. The sticky bar and utility buttons must remain readable without blur — use a solid fallback color (`--leaf-dark` at 92% alpha) when `@media (prefers-reduced-transparency: reduce)` matches.
- **Dark Mode:** the app uses fixed light-cream backgrounds. Do not automatically flip to dark on iOS system dark mode; if we ever add dark support it should be an opt-in toggle in Parents. For now, force `color-scheme: light` in the root CSS so iOS doesn't invert form controls.

**Renderer matrix before implementation:**

| Renderer / activity | Footer handling |
|---|---|
| `intro`, `wordbuild`, `listenspell`, `voiceverb` | Footer owns the primary `Next` / `Continue` action. |
| `fillblank`, `para_fill`, `basics_section` (Level 0 sections A/B/C/D/G/H typed inputs) | Footer owns `Check` / `Next`; must respond to keyboard visibility. |
| `quiz`, `truefalse`, `conj`, `tense_quiz`, `house_quiz` | Answer options **are** the primary interaction. Footer is either absent or hosts only secondary/utility controls (`Skip`, `💡 Hint`, question counter). Never place a primary CTA that duplicates the answer tap. |
| `match`, `memory` | No primary footer CTA during play; completion can briefly show `Continue`. |
| `redo` | Footer follows the underlying replayed question type. |
| `bloom` | Footer owns `Back to lessons` / `Next activity`. |

Do not wire every renderer blindly into `stageBottom()`. Classify the renderer first so answer-choice games do not get duplicate primary controls.

**Phase QA / exit check:**

- Run `node --check` against all three HTML scripts.
- Verify at least one lesson, one quiz, one fill/type activity, and one matching activity on iPhone-width.
- Verify sticky controls clear the home indicator and do not cover answer options.
- Verify keyboard-focused inputs keep the primary action visible or intentionally move it away.
- Verify desktop modal layout still works and does not inherit cramped mobile-only behavior.
- Verify scoring and two-attempt behavior are unchanged with a wrong-first-attempt test.
- Verify the built iOS app advertises portrait as its only supported orientation.
- Commit Phase 2 before starting Phase 3.

## Phase 3 - Home Screen Flow

- Add a clear "Today" path at the top of the home screen.
- The first visible action should answer: "What should Kabir do now?"
- Suggested top card:
  - **Title:** `Today: Level X - <plan[d].title>` (e.g. *"Level 4 - Habitaciones 1"*, *"Level 1 - Big finish"*, *"Level 0 - Colores · Quiz 1"*) — always use the plan entry's `title` so it works for lessons, quizzes, bonus tiles, and finales without special-casing.
  - **Subtitle:** the current level's `.blurb` (e.g. *"Rooms, house parts, furniture & objects"*) — read from `LEVELS.find(...)`.
  - **Action:** one strong `Play Now` button that calls `openDay(d)` on the picked day.
- Keep the full level list below as secondary navigation.
- On iPhone, the existing collapse toggle (`+`/`-`) continues to hide the stats grid. This plan does **not** add a separate `Stats` button; it uses the toggle that already ships.
- On desktop/iPad, keep richer stats visible because there is room to scan.

**"Today" pick rule (concrete):**

**Prerequisite:** persist `STATE.lastLevelId` inside `openLevel(id)` (today only tracked in memory as `LVID`). Migrate missing key to `null` in `ensureExtraState`.

1. If the user has an active revival coupon showing, defer to that flow.
2. Otherwise pick the **next incomplete day in the level the user most recently opened** (`STATE.lastLevelId`).
3. If that level is fully done, fall back to the level with the fewest completed lessons that still has an unlocked day.
4. Never surface a locked day. If the only remaining unlocked days are bonus/finale tiles, surface one of them — they're valid Today candidates (they're unlocked, just quiz-flavored).
5. If no candidate exists (fresh install), point at Level 0 Day 1.

**Phase QA / exit check:**

- Test fresh state: Today card points to Level 0 Day 1.
- Test after opening each level: Today card follows `STATE.lastLevelId`.
- Test a fully completed level: Today card falls back to an unlocked incomplete level.
- Test locked future days: Today card never opens a locked tile.
- Test near-completion: on a level where only bonus/finale days remain unfinished, Today card surfaces one of those (rule #4) instead of falling back to a different level.
- Test migration: restore a pre-`STATE.lastLevelId` backup (from before this branch) and confirm `ensureExtraState` writes `null` for the missing key without crashing, and Today card falls to rule #5 (Level 0 Day 1).
- Test revival coupon state: coupon flow remains higher priority than Today card.
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
- **Danger / destructive button** (Reset, Discard) — **must not** reuse the primary CTA pink. Use a distinct red-orange band or a bordered warning style (`border: 2px solid #C2333A; color: #C2333A; background: #fff;`) so users can't confuse it with the everyday primary action. Only used inside confirm dialogs.
- Status buttons should have distinct labels:
  - `Start`
  - `Continue`
  - `Retry`
  - `Locked`
  - `Done`
- **`Skip`** (Level 0 typed sections, timer expiry) is always a **secondary** button — ghost style, sits next to the primary `Check` action, never overtakes it visually.
- Avoid putting critical actions only in the header on mobile.
- **Inline controls** (`🔊` speaker, `💡 hint` inside a question, per-blank feedback icons): neither utility nor secondary — they're question-scoped inline controls. Style with the existing per-renderer conventions, keep tap target >= 44pt, do not force them into the primary/secondary color palette.

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
  - 🌳 **Tree** = quiz / bonus tile (`p.bonus || (p.house && p.houseType==="quiz") || p.fiestaQuiz || p.pureQuiz || p.tense || p.finale || p.game==="quiz"`); trees stay trees even after completion
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
- Confirm sapling/tree/flower/drought/lock icon mapping stays consistent across Levels 0-4 grids. Practice Tests and Spanish HW are separate sibling pages with their own visual language — verify their level-picker *cards* still render correctly, but do not force the sapling/tree convention onto their internal grids.
- Confirm Level 1 and Level 2 daily revive/drought behavior is not changed by visual cleanup.
- Confirm Level 3 tense activities render as trees (per Phase 5's tree condition `p.tense` → 🌳) and do not accidentally get a drought overlay applied — Level 3 has no drought behavior today, and the cleanup must not introduce one.
- Compare desktop and mobile screenshots to ensure mobile got tighter without removing desktop information.
- Run `node --check`, `git diff --check`, and commit Phase 5 before Phase 6.

## Phase 6 - Audio + Listening Flow

**Split into two sub-phases because the app currently only has TTS via `speak()` — no story audio / slow / scrub bar exists yet.**

### 6a - Audio audit (do first)

- Grep every call site of `speak()`, `SFX.*()` (`SFX.right`, `SFX.wrong`, `SFX.pop`, `sayOops`), any `<audio>` element, any `new Audio(...)`, and any `AudioContext` / `webkitAudioContext` use.
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
  - The tab backgrounds or the phone screen locks (listen on `document.visibilitychange` and call `speechSynthesis.cancel()` when `document.hidden`)
- Keep audio controls large enough for mobile taps (44x44pt min).

**6b QA / exit check:**

- Verify Play and Slow work for TTS-backed prompts.
- Verify no scrub bar appears for TTS-only screens.
- Verify audio stops on next question, previous/close, screen change, and new audio start.
- Silent-mode test: flip the iPhone's ringer/silent switch to silent, launch a lesson, tap `🔊`. Document actual behavior (Web Speech API historically ignores the ringer switch, but any future non-TTS `<audio>` will be muted). Flow must never crash or hang on either outcome.
- Autoplay test: reload mid-lesson — audio must never play until the user taps a control (WKWebView blocks unattended autoplay).
- Verify audio controls do not duplicate on short screens: at viewport height < 500 px (landscape iPhone), only one audio control cluster is visible at a time (either the near-question one *or* the sticky-bar one, not both).
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
- **Code hook:** add a guarded helper like `prefersReducedMotion()` that checks `window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches` at call time, then short-circuit each animation function when true. Also add `@media (prefers-reduced-motion: reduce) { .trv2-card::before, .confetti { animation: none !important; } }` in the stylesheet so CSS-only animations don't need a JS gate. Prefer a helper over a one-time constant so changes to the system setting are respected after reload.
- **Surprise quiz relocation is a logic change, not visual polish.** Today `maybeShowSurpriseQuiz()` fires at startup as an overlay. Moving it to a "post-completion event card" means:
  - **When:** fires exactly once after `commitDay(stars)` completes and the trophy chain (if any) has finished — before `renderDash` re-renders the level grid.
  - **Where:** appears as a dismissible event card injected above the level grid — new element `#eventCard` prepended to `#viewLevel` before `#grid` — not as a full-screen overlay. `renderDash` skips it; a dedicated **new function `renderEventCard()`** (doesn't exist yet — create in Phase 7) owns its lifecycle.
  - **Guard:** introduces a new flag `STATE.surpriseQuiz.pendingCard = true` (pre-authorized under Guardrails); cleared on tap or dismiss. Never re-triggers within the same session or same day. The pre-existing `STATE.surpriseQuiz.lastFinishedAt` remains authoritative for trophy tracking.
  - Track it under the plan's *"logic changes required"* section (see Phase 9 QA line).
  - Add before/after QA that the surprise trophy still fires and that `commitDay` still runs its normal side-effects (star save, trophy check, streak update).
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
- Test surprise quiz twice: once with `?surpriseEventCard=1` (new event-card path) and once with `?surpriseEventCard=0` (rescue back to the legacy startup overlay). Both paths must fire once, not retrigger within the same session/day, and record the same trophy state.
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
- Confirm no *new* card-in-card visual nesting was introduced. Existing patterns (trophy grid inside category section inside modal) are grandfathered; the rule only blocks new nested wrappers that weren't there before this branch.
- Confirm all visible text fits without overlap at narrow and wide widths.
- Run `node --check`, `git diff --check`, and commit Phase 8 before Phase 9.

## Phase 9 - QA Checklist

- Validate desktop browser flow.
- Validate iPad-width browser flow.
- Validate iPhone-width browser flow.
- Validate installed iPhone app.
- Validate with `prefers-reduced-motion: reduce` in Safari / iOS Settings > Accessibility > Motion > Reduce Motion.
- Validate iPhone landscape orientation (currently allowed via Info.plist).
- **Validate offline:** put the iPhone in airplane mode with the app open. Confirm: (a) lessons and progress continue to work (all state is local), (b) the Sync panel surfaces a clear "no Wi-Fi" or "iPhone unreachable" message within 6 s instead of hanging, (c) Google Fonts fallback to system fonts without layout collapse.
- **Validate offline on desktop browser:** DevTools > Network > Offline, reload the page. App must continue to serve locally, never make an outgoing network request (check the Network tab shows 0 pending requests), and font fallback should render text with the browser's default sans-serif without breaking button/card widths.
- Confirm:
  - No progress data loss
  - No scoring rule changes
  - No lesson unlock regressions
  - **Regression guard:** no repeated generic "Me gusta ___" fills leak into Vocab Fiesta lessons (this was a shipped bug earlier — Level 0 must continue to skip `fillblank`/`truefalse`/`para_fill` since it has no per-verb fill sentences).
  - Practice Test and Spanish HW cards, when tapped in the installed iOS app, navigate to the sibling HTML file inside the bundle (`regular-verb-practice-tests.html`, `spanish-class-hw.html`) without a "file not found" page — verified visually on device.
  - Audio stops on screen/question changes
  - Sticky mobile controls do not cover answer options and clear the home indicator via `env(safe-area-inset-bottom)`
  - Sticky bar stays above the on-screen keyboard when a text input is focused
  - Text fits inside buttons/cards
  - Main web HTML and bundled iOS HTML remain synchronized for all bundled web resources:
    - `diff -q learn-verb-activity.html ios/KabirSpanish/Resources/learn-verb-activity.html`
    - `diff -q regular-verb-practice-tests.html ios/KabirSpanish/Resources/regular-verb-practice-tests.html`
    - `diff -q spanish-class-hw.html ios/KabirSpanish/Resources/spanish-class-hw.html`
  - **Sync round-trip (measurable):** before sync, snapshot each side's `STATE.levels[N].completed` count, `STATE.levels[N].stars[d]` per day, `Object.keys(STATE.trophies).length`, and per-level collected count `STATE.levels[N].collected.length`. After running `Sync now` on the browser, both sides must satisfy: `count_completed >= max(browserBefore, phoneBefore)`, `stars[d] >= max(browserBefore[d], phoneBefore[d])` for every day, `trophyCount >= max(browserBefore, phoneBefore)`, and `collected.length >= max(browserBefore, phoneBefore)` for every level. Then run sync a second time — nothing should change. **Fail if any counter decreases.**

## Implementation Order

Phases below map back to the sections above.

1. Phase 1 - Audit
2. Phase 2 - Sticky mobile bottom action structure
3. **Phase 3 prerequisite:** persist `STATE.lastLevelId` in `openLevel(id)` + migrate missing key in `ensureExtraState`. Land in its own tiny commit so the Today card in the next step has data to read.
4. Phase 3 - "Today / Play Now" home path
5. Phase 2b - Convert iPhone lesson overlay from modal sheet to full-screen shell (the sticky-bar structure from step 2 stays; this step swaps the overlay's `max-width` + rounded panel styling for edge-to-edge on iPhone widths only)
6. Phase 4 - Button hierarchy (colors, sizes, buckets) — must land before Phase 5
7. Phase 5 - Level card cleanup (uses Phase 4's color decisions)
8. Phase 6a - Audio audit
9. Phase 6b - Audio control placement (only if audit reveals real audio to polish)
10. Phase 7 - Trophy + celebration flow (including reduced-motion + surprise-quiz relocation)
11. Phase 8 - Desktop + iPad refinement
12. Phase 9 - Cross-device QA and adjust spacing

## Guardrails

- Do not change scoring, stars, unlock rules, or progress storage unless explicitly requested. Two pre-authorized exceptions defined in this plan: (a) Phase 3-prereq adds `STATE.lastLevelId`; (b) Phase 7 relocates `maybeShowSurpriseQuiz()` and adds `STATE.surpriseQuiz.pendingCard`. Everything else is off-limits.
- **Progress preservation is a release invariant for every phase.** Run browser QA on an isolated localhost origin or temporary profile; never reset, restore, overwrite, or sync into Kabir's real browser/iPhone state. Before any physical-iPhone install or real sync, record a read-only progress fingerprint containing each level's completed count, stars by day, and collected count plus the total trophy count. Update the app in place (never uninstall it or clear its data), then verify every value is unchanged or greater after launch. A decrease blocks the phase commit/push and requires restoring the saved backup before further work.
- Keep all app-code `localStorage` access guarded (`try/catch` around every `getItem`/`setItem`). Console-only QA or emergency restore snippets are allowed but should be labeled as manual rescue steps.
- Keep `ios/build/` ignored (prevents committing ~90 MB of Xcode-generated derived data).
- Keep all bundled iOS web resources in sync with their web originals: `learn-verb-activity.html`, `regular-verb-practice-tests.html`, and `spanish-class-hw.html` (verified in Phase 9 QA).
- Prefer CSS/media-query/layout changes before restructuring logic.
- If logic has to move, keep it narrowly scoped and test the affected flow immediately.
- **No new network requests beyond the existing font links.** The app currently loads Baloo 2 / Nunito from `fonts.googleapis.com`; those are grandfathered in. Do not add any additional CDNs, telemetry pings, analytics, or fetches. Bundle any new fonts/images/audio locally.
- **All tap targets minimum 44x44pt.**
- **iOS device policy:** building for and driving the **iOS Simulator** is allowed anytime — it runs locally, doesn't touch any physical device, and is the fastest layout QA loop. **Physical-iPhone install** (via `xcrun devicectl`, Xcode Run, or the browser's OTA HTML push) always requires explicit user consent in the current turn — no automatic reinstalls, no OTA pushes without an explicit *"push to iPhone"* / *"update the app"* / *"install"* instruction.

## Rollback Plan

Target: each phase locally reversible in under 30 seconds (single-commit revert) so a bad merge can't strand Kabir mid-lesson. Multi-phase chain reverts (see isolation caveat below) may take longer, and device rollback (reinstall or OTA reset) longer still — target still applies to the git operation itself, not the device round-trip.

**Isolation caveat:** later phases sometimes depend on earlier phases' structure — e.g. Phase 3's Today card assumes Phase 2's sticky-bar footer exists in the stage DOM, and Phase 5's level cards read Phase 4's button classes. When that's the case, rolling back a single phase in isolation may leave the app in a half-migrated state. Rule: if a mid-chain phase must be reverted, revert **the whole chain forward from that phase** in a single commit and re-apply later phases on top.

- **Per-phase git commit:** each phase lands in one commit with a `Phase N: ...` prefix (e.g. `Phase 2: sticky bottom action`, `Phase 3-prereq: persist STATE.lastLevelId`, `Phase 3: Today card`). Never mix two phases in one commit — a bad Phase 4 button color must be revertable without losing Phase 2's sticky bar.
- **Feature flags for behavior-changing phases:** start with code-level constants or URL/debug flags only, e.g. `const UX_FLAGS = {stickyBar:true, todayCard:true, surpriseEventCard:true}`. URL rescue must use the **same key names** — `?stickyBar=0`, `?todayCard=0`, `?surpriseEventCard=0` — parsed once at boot from `new URLSearchParams(location.search)`; any parse failure defaults to `true` (flag stays enabled). URL rescue in the iOS app requires reaching the WebView with a query string, which `loadFileURL` doesn't support directly — for iOS-only rescue add a hard-coded `SyncServer` endpoint (e.g. `POST /flags` writing to localStorage) **only if a real iOS-only breakage happens**; do not create the endpoint speculatively. Do not add persistent `STATE.uxFlags` or hidden Parents-panel controls unless the user explicitly asks for persistent toggles.
- **HTML backup on iPhone:** the existing `syncMergeIncoming` already snapshots to `learn_verb_activity_v2_backup` — do not remove that. If a pushed HTML breaks localStorage, users can restore via the browser console:
  `localStorage.setItem("learn_verb_activity_v2", localStorage.getItem("learn_verb_activity_v2_backup")); location.reload();`
- **Bundled HTML on iPhone:** the app's `WebViewStore.resetToBundledHTML()` reverts an OTA push. Keep that button reachable (via the browser sync panel's *"↩︎ Revert to shipped"*).
- **Git revert one-liner:** every phase PR description must include its own revert command in the form `git revert <phaseCommit>`. Add rebuild/reinstall notes only for release/device rollback phases. (This plan does not pre-list per-phase SHAs — they only exist after the commit lands.)

## Test Session Script

Run the local script at the end of every phase before merging. Run the device script only before release, before iPhone install, or when the user explicitly asks for device QA.

### Repeatable QA state

Do not run phase QA against Kabir's real progress without first making a backup.

1. Use the app footer's `Backup code`, or copy `localStorage.getItem("learn_verb_activity_v2")` into a scratch note.
2. Use a temporary browser profile or restore a known QA backup before testing.
3. If a phase requires Day 1 / new trophy behavior, use the QA state, not live progress.
4. Restore the original backup after the test session if the regular browser profile was used.

**One-time QA seed setup** (do this once, reuse across phases):

1. Open a fresh browser profile at `learn-verb-activity.html`.
2. Play through Level 0 Day 1, Level 1 Day 1, Level 4 Day 1 (or an equivalent minimum spread).
3. Earn at least one trophy so the trophy-chain path can be exercised.
4. In DevTools console: `copy(localStorage.getItem("learn_verb_activity_v2"))`.
5. Save the clipboard contents to `scratchpad/qa_seed_state.json` in the repo (the `scratchpad/` folder is git-ignored per the repo's `.gitignore`; if it isn't yet, add `scratchpad/` before running this step).
6. To restore before any phase QA: `localStorage.setItem("learn_verb_activity_v2", <paste JSON>); location.reload();`.

### Required local script

1. **Restore the QA seed** (per the *Repeatable QA state* block above), then **open a fresh browser tab** at `learn-verb-activity.html`; expect the level picker to render with the header collapsed by default (mobile-width) or fully expanded (desktop-width).
2. **Open Level 1** — the level card should highlight the current next day.
3. **Play the next available QA lesson** through to bloom. During the lesson:
   - Enter one wrong answer, one hint, one right answer.
   - Verify the two-attempt rule fires on the second wrong.
   - Starting with Phase 2, verify the sticky primary action stays visible when text input is focused. Before Phase 2, record the current scrolling-action behavior as the baseline instead.
4. **Trigger a trophy if the QA state is set up for one.** Verify the trophy chain shows once and animates cleanly, or is subdued under `prefers-reduced-motion`.
5. **Open Trophies** — scan for layout jump; verify progress bars fill smoothly.
6. **Open Sync panel** — verify the panel renders and no `SecurityError`, `QuotaExceededError`, `TypeError`, or `ReferenceError` appears in the browser console. Do not require iPhone ping in per-phase local QA. **Close the panel** before continuing so the header isn't occluded by the overlay in the next step.
7. **Collapse the header** with `+/-`; confirm the level list scrolls without jitter.
8. **Close the browser tab.** Reopen — confirm the level picker renders with all prior progress intact and no console errors appear. Starting with Phase 3, also confirm the Today card points at the same recommendation as before.

### Device / release script

1. Build and install on iPhone only when the user asks or before release sign-off.
2. Confirm Practice Tests and Spanish Class HW open from the installed app.
3. Test connection to the iPhone from the web Sync panel; confirm ping succeeds within 6s.
4. Run Sync progress and confirm both sides reload with merged state and the round-trip counter assertion from Phase 9 passes.
5. If an OTA HTML override is active, use `Revert to shipped` before validating the bundled install.

Any failure = rollback the current phase and file an issue before continuing.

## Change Budget Per Phase

Rough size limit per phase — a PR bigger than this signals scope creep and should be split.

| Phase | Est. LOC added/changed | Notes |
|---|---|---|
| 1 (Audit) | 0 code, doc-only | Screenshots + notes, no app HTML/Swift diffs |
| 2 (Sticky shell) | ~120 lines | HTML wrapper + CSS + `stageBottom()` helper + priority renderer wiring; matrix decides which renderers get footer actions |
| 2b (Full-screen overlay) | ~30 lines | Media-query CSS + edge-to-edge iPhone-only override; no JS logic |
| 3-prereq (`STATE.lastLevelId`) | ~20 lines | Persist in `openLevel(id)`, migrate in `ensureExtraState`; own commit |
| 3 (Today card) | ~80 lines | `pickTodayCard()` function + rendering + Today-card UI |
| 4 (Buttons) | ~60 lines | Mostly CSS replacements + one shared `.btn-primary`, `.btn-secondary`, `.btn-utility` cleanup |
| 5 (Level cards) | ~40 lines | CSS-only for icons, spacing, status text |
| 6a (Audio audit) | 0 code, doc-only | Grep output pasted into an "Audio inventory" section |
| 6b (Audio polish) | ~60 lines *if* real audio exists; else 0 | Skipped entirely if 6a shows nothing to polish |
| 7 (Celebration) | ~60 lines | `prefersReducedMotion()` gate + surprise-quiz relocation + CSS media query |
| 8 (Desktop/iPad refinement) | ~40 lines | Media-query tweaks only; no logic |
| 9 (QA) | 0 code, doc-only | Checklist run, screenshots, sign-off |

**Total budget:** ~510 lines across all coding phases (20 lines for the 3-prereq split-out + 30 for the Phase 2b overlay conversion). If Phase 6a's audit shows no audio worth polishing, subtract Phase 6b's ~60 → **~450 lines**. If cumulative diff exceeds 700 lines by Phase 7, stop and re-plan.
