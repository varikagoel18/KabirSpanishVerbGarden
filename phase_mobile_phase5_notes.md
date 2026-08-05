# Phase 5 - Level Card Polish

Branch: `codex/mobile-ux-phase-5-level-card-polish`

## Delivered

- Locked days now always show 🔒, including locked quiz-flavored days.
- Quiz/tree detection uses the exact planned predicate: bonus, house quiz, Fiesta quiz, pure quiz, tense, finale, or `game === "quiz"`.
- Completed quiz tiles remain 🌳; completed learning tiles use flowers or 🥀 drought state; next learning tiles use 🌱.
- Level 3 tense tiles remain trees and continue to bypass drought behavior.
- Mobile level cards retain title, compact progress, status, and one CTA while hiding verbose blurbs; desktop cards retain all information.
- No progress, scoring, unlock, drought, content, storage, or activity logic changed.

## QA

- Mapping invariants passed for completed, locked, next, lesson, quiz, drought, and Level 3 tense states.
- Mobile cards measured approximately 72–102px tall with no overflow; desktop cards remained approximately 110px with blurbs visible.
- Practice Tests and Spanish Class HW cards remained intact without adopting lesson-grid icon semantics.
- Responsive browser console had no errors or warnings.
- All three scripts pass `node --check`; all three web/iOS resource pairs match; `git diff --check` passes.
- Simulator build, install, and launch passed.
- Physical iPhone was not updated for this CSS/mapping phase; the last exact device fingerprint remains recorded in Phase 4.

## Rollback

After commit creation: `git revert <phase-5-commit>`.
