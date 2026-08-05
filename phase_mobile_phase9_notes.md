# Phase 9 - Final Cross-Device QA

Branch: `codex/mobile-ux-phase-9-cross-device-qa`

## Device scope

- Desktop browser
- iPad portrait
- iPhone portrait
- iPhone/iPad landscape is intentionally unsupported and out of scope by user direction.

## Phase 8b contingency

The native Listen & Speak implementation remains capability-disabled because the locked physical iPhone prevented the mandatory quiet-room 8/10 acceptance and 8/10 deliberate-rejection gate. Phase 9 verifies that no speech stage is exposed while that gate remains incomplete.

## QA log

- Responsive browser matrix passed for the main app, Practice Tests, and Spanish HW at 1440x900 desktop, 768x1024 iPad portrait, and 390x844 iPhone portrait. Every page loaded with expected content, no horizontal overflow, no native capability, and no speech UI.
- Corrected the reported cramped two-line `Skip ⏭` footer control to the compact text-only `Skip` label and enforced `white-space: nowrap` for shared secondary footer controls. Checks at 320, 375, 390, the 482px screenshot width, and 1440px confirmed the nowrap rule and no page overflow; the existing 48px footer-button target and primary `Check` hierarchy are unchanged.
- The final Swift tree built successfully. The final capability-disabled app installed and launched on iPhone and iPad portrait simulators.
- JavaScript syntax passed for all three HTML apps. Source and built-product parity passed for all three resources; plist validation and `git diff --check` passed. The plist contains portrait as the sole supported orientation for both device families.
- Phase 8b matcher vectors and prompt-bank audit remain green. Its disabled-capability contingency was confirmed on web and in source; no speech stage is exposed.
- The signed final build—including the Phase 9 Skip-footer correction—was installed in place on the real iPhone without uninstall/reset/restore/sync/OTA. All three built HTML resources matched source. Exact progress remained unchanged after installation: canonical SHA-256 `c9d9a8ae6bcd61fecd00c555797dbb5ee34ccf7a8e31f81a51a235b7961e9a75`; completed `3/50/19/10/6`, collected `8/41/36/0/12`, trophies `61`.
- Physical-device launch/audio/speech/offline interaction remains blocked because the iPhone is locked. The speech capability remains false, so the uncompleted 8/10 acceptance and 8/10 rejection quality gate cannot expose pass/fail recognition.

## Result

Automated, responsive, parity, build, simulator, signing, in-place install, orientation, and progress-preservation checks pass. The only Phase 9 app-code adjustment is the narrow shared Skip-footer presentation fix; skip behavior, scoring, attempts, and progress logic are unchanged. Phase 9 closes with the explicitly documented physical-interaction residual above.

## Post-phase progress-continuity correction

A later cold-launch check exposed that `WKWebView.loadFileURL` can assign a new opaque `file://` storage origin after an installed-app/OTA HTML update. The original progress was recovered exactly from the mandatory pre-install backup. Native iOS now keeps an atomic Documents copy of `learn_verb_activity_v2`, seeds a newly assigned origin at document start before app initialization, and mirrors subsequent state writes back to that native file. This changes no progress values or merge/scoring rules; it makes the existing state survive origin rotation. Recovery/cold-relaunch QA requires the canonical fingerprint `c9d9a8ae6bcd61fecd00c555797dbb5ee34ccf7a8e31f81a51a235b7961e9a75`, completed `3/50/19/10/6`, collected `8/41/36/0/12`, and `61` trophies.
