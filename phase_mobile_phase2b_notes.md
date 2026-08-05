# Phase 2b - Full-screen Overlay

Branch: `codex/mobile-ux-phase-2b-full-screen-overlay`

## Scope Delivered

- Converted lesson overlays at widths up to 640px from inset modal sheets to edge-to-edge activity shells.
- Uses the required `100vh` / `100dvh` fallback pair.
- Removed mobile lesson-sheet margins, rounded corners, shadow, and pop animation.
- Added safe-area-aware lesson-header padding.
- Preserved the scrollable stage and existing sticky action/footer behavior.
- Kept desktop lessons and every non-lesson overlay in their existing modal layout.
- Made no JavaScript, scoring, progress, content, storage, audio, coupon, or unlock changes.

## QA Completed

- At 390 x 844, the lesson overlay and sheet both measured exactly `(0, 0, 390, 844)`, with `border-radius: 0`, no margin, and no outer padding.
- The phone lesson header, activity content, and bottom action rendered without overlap.
- At 1024 x 800, the lesson remained a centered 560px modal with a 26px radius.
- At phone width, the Parents panel remained a padded, rounded non-lesson modal.
- With `?stickyBar=0`, the lesson remained full-screen while the action footer stayed visible in normal flow and the stage remained scrollable.
- Browser console checks reported no errors or warnings.
- All three HTML scripts pass `node --check`.
- Main, Practice Tests, and Spanish HW match their iOS source and built-app copies byte-for-byte.
- `git diff --check` passes.
- iPhone 17 Pro simulator build, install, and launch passed.
- The built app remains portrait-only and requires full-screen presentation.

## Progress Preservation

- Browser QA used an isolated localhost origin.
- No reset, restore, sync, seed, or real browser/iPhone state mutation was performed.
- No physical iPhone action was attempted.

## Rollback

After the Phase 2b commit is created, use `git revert <phase-2b-commit>`.
