# Phase 8 - Desktop and iPad Portrait Refinement

Branch: `codex/mobile-ux-phase-8-desktop-ipad`

## Scope

- Expanded the large-screen dashboard canvas to 1040px at widths of 900px and above.
- Added a two-column level-picker layout for desktop while retaining the single-column iPad/iPhone portrait layouts. Landscape is not a required acceptance target for either device by user direction.
- Increased the large-screen lesson grid from six to eight columns and kept lesson sheets centered/readable.
- Did not remove or collapse any desktop stat, context, or action, and introduced no new card-in-card wrapper or behavior path.

## Responsive QA

- 1440x900: 1040px canvas, two 489px card columns, all header stats present.
- 768x1024 iPad portrait: one 728px card column inside the existing 760px canvas.
- 390x844 iPhone portrait: existing compact one-column layout and portrait-only iOS orientation preserved.
- No document-level horizontal overflow at any tested size; level/Today cards fit their containers.

## Final QA

- JavaScript syntax passed for the main app, Practice Tests, and Spanish HW.
- All three web/iOS HTML pairs match byte-for-byte; built simulator resources match source.
- Simulator build, in-place install, and launch passed.
- `git diff --check` passed. Browser QA used an isolated localhost origin and did not touch real browser/iPhone progress.

## Rollback

After commit, use `git revert <phase-8-commit>` and rebuild/reinstall if reverting a device build.
