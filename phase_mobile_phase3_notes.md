# Phase 3 - Today Card

Branch: `codex/mobile-ux-phase-3-today-card`

## Scope Delivered

- Added the home-screen Today card above the full level list.
- Uses `Today: Level X - <plan title>`, the level blurb, and one `Play Now` action.
- Added `pickTodayCard()` with the plan's recent-level, fewest-completed fallback, unlocked-day, bonus/finale, fresh-install, and revival-coupon rules.
- Added the `?todayCard=0` rescue flag without adding persistent feature-flag state.
- Kept the existing mobile header collapse toggle and desktop/iPad stats behavior unchanged.

## Prerequisite

The separate prerequisite branch `codex/mobile-ux-phase-3-prereq-last-level-id` was created from exact Phase 2 commit `b8ba982d0dcfbe664e7c54c648b502b0feacf459`. Commit `f1a213f2fbef44973afaf4794c5753e5f1b592b8` adds only the missing-key migration to `null` and persistence in `openLevel(id)`. It was pushed and its remote SHA was verified before this branch was created.

## QA Completed

- Focused selection tests passed for fresh state, every most-recent level, a fully completed recent level, fewest-completed fallback, sparse completion with locked future days, bonus-only and finale-only near-completion, revival-coupon priority, and the rescue flag.
- The selection test verifies that choosing a recommendation does not mutate state.
- A pre-`lastLevelId` migration and `openLevel` persistence test passed in the prerequisite phase.
- Responsive isolated-localhost QA passed at 390 x 844 and 1024 x 800.
- `Play Now` opened Level 0 Day 1 from fresh state; `?todayCard=0` hid the card and preserved the level list.
- The browser console reported no errors or warnings.
- All three HTML scripts pass `node --check`.
- Main, Practice Tests, and Spanish HW match their iOS bundled source copies byte-for-byte.
- The built simulator app contains byte-identical copies of all three web resources.
- `git diff --check` passes.
- Simulator build, install, and launch passed on iPhone 17 Pro; the app remains portrait-only.

## Simulator Note

The existing iPhone 17 Pro simulator retained a Documents-directory OTA HTML override, so its successful app launch was not used for visual sign-off of the new bundled page. A fresh iPhone 17e simulator booted, but CoreSimulator became unresponsive while installing/launching. Responsive visual sign-off therefore comes from the exact web source on an isolated localhost origin; built-resource byte parity independently confirms that the simulator bundle contains that same source.

## Progress Preservation

- Browser QA used an isolated localhost origin and did not reset, restore, seed, or sync Kabir's real browser state.
- No physical iPhone build, install, launch, OTA push, sync, or state access was attempted.
- No lesson, scoring, retry, stars, progress, unlock, content, surprise-quiz, audio, or coupon logic changed.

## Rollback

After the Phase 3 commit is created, use `git revert <phase-3-commit>` to remove the Today card while retaining the prerequisite commit.
