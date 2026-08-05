# Phase 1a - iOS OTA Sibling Pages

Date: 2026-08-05  
Branch: `codex/mobile-ux-phase-1a-ios-sibling-pages`  
Parent phase: `8fe1eb1` (`Phase 1: audit web and mobile UX`)

## Problem

The iOS app normally loads all three HTML files from the bundle, so relative links to Regular Verb Practice Tests and Spanish Class HW work. After an OTA update, only `learn-verb-activity.html` existed in Documents. WKWebView then resolved both relative links against Documents, where the sibling files were missing.

## Fix

- Keep the OTA main page in Documents.
- Before loading it, atomically copy both bundled sibling HTML files into the same Documents directory.
- Repeat the staging whenever a new OTA main page is saved, so the files stay aligned with the installed app build.
- If staging fails, load the bundled main page instead of presenting a partially usable OTA build.
- `resetToBundledHTML()` now removes the main OTA file and both staged sibling files.

## Guardrails

- No HTML, lesson, scoring, star, unlock, trophy, or progress-state logic changes.
- Filenames are fixed constants; no user-controlled path is written.
- Existing localStorage and WKWebView data-store behavior is unchanged.
- The OTA endpoint remains backward-compatible and still accepts the main HTML body used by existing browser builds.

## QA

- Signed physical-iPhone build succeeded with the Apple Development identity and the `com.ashish.KabirSpanish` provisioning profile.
- The built app contains all three HTML resources, and each one is byte-identical to both the web source and its `ios/KabirSpanish/Resources` copy.
- The exact signed build installed and launched successfully on the paired iPhone 15 Pro running iOS 26.5.2.
- CoreDevice's process-list service timed out twice and later returned no process rows, so child-process inspection could not be used as a reliable secondary signal. The successful `devicectl` launch is the recorded device smoke result; visual/device-flow coverage remains part of Phase 9.
- All three HTML script blocks pass `node --check`.
- `git diff --check` passes, and the only app source change is `ios/KabirSpanish/WebView.swift`.

## Fresh-Eyes Review

- No lesson, scoring, progress, sync-state, or web-page behavior changed.
- OTA startup now either has all required sibling pages or falls back to the complete bundled app.
- Partial sibling staging cannot expose a partially usable OTA app because the OTA main page is loaded only after the full staging loop succeeds.
- The sibling copies intentionally come from the installed app bundle. A main-only OTA push therefore keeps navigation working but does not update Practice Tests or Spanish Class HW content independently; a future multi-file OTA protocol would be a separate feature.
