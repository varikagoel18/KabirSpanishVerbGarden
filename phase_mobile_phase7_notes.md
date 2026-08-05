# Phase 7 - Celebration and Trophy Flow

Branch: `codex/mobile-ux-phase-7-celebration-trophies`

## Scope

- Added live `prefers-reduced-motion` gates to confetti, pixie dust, and trophy mega-bursts, plus CSS suppression for confetti and trophy-card shimmer.
- Restored the existing every-four-global-completions surprise-review trigger and moved the default presentation to a dismissible event card above the level grid.
- Added the `?surpriseEventCard=0` legacy-overlay rescue path.
- The event card clears `STATE.surpriseQuiz.pendingCard` on start/dismiss; dismiss also clears the pending quiz. Surprise completion remains authoritative through `lastFinishedAt` and now immediately checks/queues its trophy.
- Practice Tests and Spanish HW update the same pending fields, while their own UI and scoring remain unchanged.

## Preservation

- No lesson answer, retry, score, star threshold, unlock, collected-word, coupon, content, or sync-merge rule changed.
- The only storage addition is the plan-authorized `STATE.surpriseQuiz.pendingCard` boolean.
- The plan-only Phase 8b specification was added/refined as Pending; no Phase 8b feature code, bridge, capability, permission, prompt-bank, or plist change was made in this phase.

## QA

- Focused state tests cover fourth-completion unlock, duplicate suppression, same-day post-finish suppression, event-card start/dismiss lifecycle, and reduced-motion preference detection.
- Responsive trophy-room checks passed at 390x844 and 1440x900 with no horizontal overflow.
- JavaScript syntax passed for all three web apps; all three web/iOS resource pairs match byte-for-byte.
- Simulator build, in-place install, and launch passed; the built resources match the source resources.
- `git diff --check` passed. Browser QA used an isolated localhost origin and did not touch real browser or iPhone progress.

## Rollback

After commit, use `git revert <phase-7-commit>` and rebuild/reinstall if reverting a device build.
