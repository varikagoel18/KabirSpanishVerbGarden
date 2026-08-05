# Phase 2 - Sticky Mobile Action

Branch: `codex/mobile-ux-phase-2-sticky-action`

## Scope Delivered

- Added a persistent lesson action footer as a sibling of `#stage` so stage renders cannot erase it.
- Added mobile portrait flex/scroll behavior, safe-area padding, keyboard viewport handling, light color-scheme enforcement, and a reduced-transparency fallback.
- Moved renderer-owned actions for intro, typed fill, voice practice, La Casa intro/safety, and bloom into the shared footer.
- Kept answer-option, matching, memory, spelling, and listening activities free of duplicate primary actions.
- Added the `?stickyBar=0` rescue flag; its footer remains usable in normal document flow.
- Prevented a closed timed quiz from advancing a newly opened lesson by binding countdown callbacks to their owning lesson session.
- Locked the installed iOS app to portrait and required full-screen presentation so the orientation declaration is valid on iPad as well as iPhone.

## Behavior Preserved

- No scoring, star thresholds, unlock rules, lesson content, or storage schema changed.
- First wrong attempts still allow a retry; a second wrong answer advances once.
- Existing completed lessons and all saved progress remain untouched.

## QA Completed

- Main, Practice Test, and Spanish HW scripts pass `node --check`.
- Web and bundled iOS copies of all three HTML resources match exactly.
- `git diff --check` and `plutil -lint` pass.
- Responsive browser checks passed at 390 x 844 and desktop 1024 x 800.
- Lesson intro, matching in either selection order, typed fill, and quiz activity were exercised at phone width.
- Typed input and footer do not overlap; quiz/matching/spelling screens do not gain duplicate actions.
- A live quiz confirmed first-wrong retry and second-wrong advance behavior.
- Closing and reopening a timed quiz produced one active countdown and advanced only one question at expiry.
- iPhone 17 Pro simulator build, install, launch, and portrait screenshot passed.
- The signed physical-device build succeeded without orientation warnings and launched on the paired iPhone 15 Pro.
- The built app declares only `UIInterfaceOrientationPortrait` and `UIRequiresFullScreen = true`.

## Progress Preservation

The physical iPhone app was updated in place. A read-only WebKit storage snapshot was taken before and after installation. Every completed day, per-day star value, collected item, and trophy ID matched exactly.

Completed counts remained Level 0: 3, Level 1: 50, Level 2: 19, Level 3: 10, and Level 4: 6. Trophy count remained 61. No uninstall, reset, restore, or sync operation was used.

## Handoff

Phase 2 is complete. Per the user's instruction, do not create or begin Phase 3 in this task.
