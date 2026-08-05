# Phase 4 - Button Hierarchy

Branch: `codex/mobile-ux-phase-4-button-hierarchy`

## Scope Delivered

- Standardized primary actions on the planned berry gradient with white text and a 48px x 140px minimum target.
- Added explicit `btn-primary` and `btn-secondary` classes and wired the shared lesson footer to them.
- Styled secondary actions as transparent, bordered controls with equal prominence sizing but no primary fill.
- Kept Parents, Trophies, and Sync as header utilities at 34px desktop / 36px mobile height.
- Marked the footer Reset action in warning red while retaining its native confirmation gate.
- Normalized level-card status labels to Start, Continue, Locked, and Done; changed the lesson replay label to Retry.
- Kept question-scoped speaker, hint, and undo controls out of the primary/secondary palette.
- Made no scoring, retry-count, stars, progress, unlock, storage, content, audio, coupon, or surprise-quiz logic changes.

## QA Completed

- At 390px width, level CTAs measured 140 x 48px; the Today CTA measured 322 x 48px.
- Header utilities measured 36px high on mobile and 34px on desktop.
- The shared lesson primary action measured 354 x 48px and used the required gradient.
- Sync primary/secondary pairs rendered distinctly; long labels did not overflow.
- Practice Test, Spanish Class HW, all level cards, and Continue/Locked labels had no horizontal overflow.
- Desktop and mobile pages had no horizontal page overflow.
- Reset remains behind `confirm("Reset all progress? ...")` and is visually distinct from everyday primary actions.
- Browser console checks reported no errors or warnings.
- Source invariants, all three `node --check` runs, `git diff --check`, and all web/iOS parity checks passed.
- Simulator build, in-place install, and launch passed; built HTML resources match all three web sources.
- The simulator and physical builds remain portrait-only and require full-screen presentation.

## Physical iPhone QA

The user authorized physical-iPhone use for two hours during this phase. A signed Debug build was installed in place and launched on the paired iPhone 15 Pro. No uninstall, reset, restore, sync, seed, or OTA update was used.

The exact progress fingerprint matched before and after installation:

- SHA-256: `467f66a5ae51bba1cb76eb992ef89e6023d56a92d179d2341ecaac23bbe09e0e`
- Completed lessons: Level 0 = 3, Level 1 = 50, Level 2 = 19, Level 3 = 10, Level 4 = 6
- Collected items: Level 0 = 8, Level 1 = 41, Level 2 = 36, Level 3 = 0, Level 4 = 12
- Trophies: 61

The comparison included every completed-day ID, every per-day star value, every collected item, and every trophy ID.

## Rollback

After the Phase 4 commit is created, use `git revert <phase-4-commit>`.
