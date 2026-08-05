# Phase 6b - Audio Control Polish

Branch: `codex/mobile-ux-phase-6b-audio-polish`

## Scope

- Added explicit Play and Slow controls to the four TTS-backed listening prompt surfaces identified in Phase 6a.
- Removed all four unattended TTS starts. Reloading or entering those activities is silent until a control is tapped.
- Added shared speech cancellation on question redraw, stage change, lesson close, level navigation, and document backgrounding.
- Kept TTS controls beside the prompt and above the answer interaction. No scrub/progress bar was added because TTS exposes no stable media timeline.
- Controls are at least 48 CSS pixels high and each audited short screen has one audio-control cluster.

## Preservation

- No lesson selection, scoring, retry, star, progress, unlock, content, storage, surprise-quiz, SFX, coupon, or sync behavior changed.
- `speak()` keeps its prior default rate and accepts an optional slower rate only for the new Slow control.

## QA

- JavaScript syntax passed for the main app, Practice Tests, and Spanish HW.
- Web/iOS parity passed for all three bundled HTML resources; the built simulator resource also matched.
- Responsive browser checks passed at 390x844, 844x390, and 1440x900. The listening screen showed exactly one control cluster, each control measured 96x48 CSS pixels, and there was no page-width overflow or console error.
- Play and Slow were both tapped successfully. Source checks confirmed no audited unattended TTS timeout remains and no scrub bar was introduced.
- Speech cancellation is present on stage/screen transitions, relevant question redraws, close, and `document.visibilitychange` backgrounding.
- Simulator build, in-place install, and launch passed.
- Signed physical-device build and in-place install passed. The exact saved-state SHA-256 and all progress counters matched before and after (`a299685c2a18f75c2486513ebd12eea4490de4b411c149477a0319265f680197`; completed 3/50/19/10/6, collected 8/41/36/0/12, 61 trophies).
- Physical launch was denied because the iPhone was locked. The silent-switch and audible normal-vs-Slow delta checks therefore remain explicitly deferred to Phase 9; no crash or state mutation occurred.

## Rollback

After commit, use `git revert <phase-6b-commit>` and rebuild/reinstall if reverting the device build.
