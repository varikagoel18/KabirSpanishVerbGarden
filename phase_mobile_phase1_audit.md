# Phase 1 - Web and Mobile UX Audit

Date: 2026-08-05  
Branch: `codex/mobile-ux-phase-1-audit`  
Plan baseline: `17bba81` (`Refine mobile UX plan through iterated review`)

## Scope

This phase is documentation-only. It maps the current interaction paths, records the most important web and iPhone issues, and verifies that the browser and bundled iOS resources match. It does not change lesson content, scoring, stars, unlock rules, progress state, HTML, CSS, JavaScript, or Swift.

## Current Path Map

| Path | Current entry and flow | Primary interaction observations |
|---|---|---|
| Home / level picker | Header stats and utilities, then every Level 0-4 card, Regular Verb Practice Tests, Spanish Class HW, and a coming-soon card | Every available card is visually prominent. There is no single recommendation for what Kabir should play next. |
| Level grid | Open a level card, use `All levels` to return, select the next unlocked day from a 6-column grid (5 columns at <=520px) | The whole tile is tappable. Tile meaning is carried mainly by the plant/tree/lock icon, day number, and legend. |
| Lesson overlay | Select a day, then move through dynamic stages inside the shared `#overlay > .sheet > #stage` shell | The close control stays in the header, but stage actions such as Next, Check, Skip, and Done scroll with the activity content. |
| Quiz flow | Tap an answer or submit typed input; most questions advance automatically after feedback; misses can enter the redo stage | Choice buttons are naturally full-row. Typed activities place Check/Submit and Skip inside the scrolling question body. |
| Practice Tests | Open the sibling `regular-verb-practice-tests.html`, choose one of 10 tests, answer 25 questions, redo misses, see result | Test runner has a top progress area and an `All tests` action after the options. It uses a separate page shell and button hierarchy. |
| Spanish Class HW | Open the sibling `spanish-class-hw.html`, choose a dated quiz, answer typed/MCQ/listening questions, redo misses, see result | Story controls, hints, Submit, and `All HW` are placed inside the scrolling panel. It also uses a separate page shell. |
| Trophy room | Header `Trophies` utility opens the shared overlay with progress ring, filters, categories, and trophy cards | Long content has a single close control at the top. Earned cards are also celebration triggers. |
| Parents dashboard | Header `Parents` utility opens metrics, focus verbs, wrong questions by day, and patterns in the shared overlay | Information is useful but vertically long; the only exit is the overlay's top close control. |
| Sync panel | Header `Sync` utility opens address, Test, Sync, Update app, and Revert controls in the shared overlay | Two action groups compete inside one panel. The Sync button is hidden in the iOS app, as intended. |
| Backup / restore / reset | Three text buttons in the page footer | Destructive Reset and safe backup actions share the same small link treatment. |

## Top 5 Web Issues

1. **No clear next action on the home screen.** All level cards plus Practice Tests and HW compete equally, so the page does not answer "What should Kabir do now?" This is the reason Phase 3 needs a Today card.
2. **Primary-action styling changes by surface.** Home card CTAs are berry, most lesson completion buttons are green, retry is orange, and the sibling pages use green as their default primary. The command may be clear locally, but the app has no stable cross-page hierarchy.
3. **Lesson navigation is tied to scrolling content.** `#stage` is replaced for every renderer, and Next/Check/Skip/Done are rendered inside it. Long questions, redo screens, and result screens can place the next action below the fold even on desktop-height windows.
4. **The level picker has a naming collision.** The Regular Verb Practice Test card shows badge `2`, while Level 2 is already Irregular Verbs. A child can read both as the same level even though one opens a separate page.
5. **Backup, Restore, and Reset have equal visual weight.** They are all 12px underlined footer controls with zero padding. Reset is destructive but does not look meaningfully different until its confirmation dialog appears.

## Top 5 iPhone Issues

1. **Several controls miss the 44x44pt minimum.** The header toggle is `32x32px`, the overlay close control is `38x38px`, the main `All levels` button uses only `6px 2px` padding, and header utility buttons, hint controls, and footer links have no 44px minimum.
2. **Lessons remain inset modal sheets.** The overlay keeps `14px` outer padding, a rounded `26px` sheet, and a desktop-style max width at phone sizes. This reduces usable space and makes the lesson feel layered over the app instead of being the active full-screen task.
3. **The primary action can disappear behind scrolling or the keyboard.** Typed activities focus the input automatically, but Check/Submit/Skip stay in the stage flow. There is no `visualViewport` keyboard adjustment and no sticky action sibling outside `#stage`.
4. **Critical utilities are hidden behind a very small collapsed-header toggle.** Mobile always starts with stats and Parents/Trophies actions collapsed. The only way back to those tools is the `32px` plus button in the top-right corner.
5. **An OTA main-page update can break Practice Test and HW navigation.** The bundled main page can resolve both sibling HTML files because all three are in the bundle directory. `saveUpdatedHTML` writes only `learn-verb-activity.html` to Documents, and `loadApp()` then grants read access to that Documents directory; the two sibling pages are not copied there. Relative navigation can therefore land on a missing file after an OTA update.

## Tap-Target Evidence

| Control | Current rule | Audit result |
|---|---|---|
| Mobile header collapse | `width:32px; height:32px` | Fails 44pt minimum. |
| Overlay close | `width:38px; height:38px` | Fails 44pt minimum. |
| Header utility (`mini-action`) | `padding:9px 12px; font-size:12.5px` | Approximately 34-36px high; no minimum height. |
| Learned-word stat buttons | `padding:8px 12px` inherited from `.stat` | No minimum height; likely below 44px. |
| Main `All levels` | `padding:6px 2px; font-size:15px` | Clearly below 44px high. |
| Hint controls | `padding:6px 12px; font-size:13px` | Clearly below 44px high in the main app and HW page. |
| Footer backup/restore/reset | `font-size:12px; padding:0` | Clearly below 44px in both dimensions. |
| Speaker control | `46x46px` | Passes. |
| Choice rows (`.opt`) | `padding:14px; font-size:18px` | Passes in normal layouts. |
| Standard `.btn` | `padding:14px 22px; font-size:17px` in main app | Passes in normal layouts. |

## Verification Completed

- `learn-verb-activity.html` and `ios/KabirSpanish/Resources/learn-verb-activity.html` are byte-identical (SHA-256 `1158cb7aa6c2bdb5a188dee589133ba5ffe00ae3641725ca51e88b36971e9065`).
- `regular-verb-practice-tests.html` and its bundled iOS copy are byte-identical (SHA-256 `0ccb80c9fe7a8ea33c97ef53f81cd1ee9e762dcafb9a7a4bad3fa01e6fd6d02f`).
- `spanish-class-hw.html` and its bundled iOS copy are byte-identical (SHA-256 `6ea90c4d7efe2a8ad5d71ba2856f20a2f478d90f258dd94f4c237a611f3f8bae`).
- All three browser HTML files contain one inline script and pass JavaScript syntax compilation.
- All three HTML files are present in the Xcode Resources build phase.
- In bundled startup mode, `WebView.swift` loads the main HTML with read access to its bundle directory, which permits navigation to the two bundled sibling pages.
- Fresh-eyes review found that the same guarantee does not hold after an OTA main-HTML update because only the main file is written to Documents. This is a blocking existing iPhone issue for a separately approved prerequisite phase; it is not fixed during this documentation-only audit.
- The signed Debug iPhone build embedded the same three verified HTML hashes, was installed on the paired iPhone 15 Pro, and launched successfully at 12:47 IST. Device process inspection confirmed `KabirSpanish` and its WebKit processes were running.
- No app HTML or Swift file was changed by this audit.

## Plan Corrections Made During Review

- Added the required one-branch-per-phase, review/fix/retest, commit, push, QA, and user-approval protocol to `phase_mobile.md`.
- Made sticky-footer QA conditional on Phase 2 being implemented; earlier phases now record the scrolling-action baseline.
- Made Today-card persistence QA conditional on Phase 3 being implemented.
- Added bundled-versus-OTA sibling-page navigation to the Phase 1 exit criteria.

## Responsive Baseline Status

The in-app browser rejected automation of the local `file://` page under its URL security policy, and the browser session did not expose the user's already-open local tab for read-only claiming. The connected iPhone was available for install and launch, but this Mac had no application registered for CoreDevice's screen-viewing URL, so it could not provide an automated device screenshot. No alternate browser route was used.

Fresh visual baselines remain required in Phase 9 at approximately:

- Desktop: 1440x1000
- iPad portrait: 820x1180
- iPhone portrait: 390x844

The screenshots should use the same progress state and show the full home header plus the first level cards. For Phase 1, the source-level responsive audit, exact CSS measurements, bundle hashes, signed-build verification, physical-device install, launch, and process check are the accepted substitute. The user explicitly instructed uninterrupted phase progression, so the visual evidence is carried to Phase 9 instead of blocking implementation.

## Phase 1 Exit Status

- Path map: complete.
- Top five web findings: complete.
- Top five iPhone findings: complete.
- Tap-target audit: complete.
- HTML syntax and iOS bundle parity: complete.
- Fresh responsive screenshots: deferred to Phase 9 with the source/device substitute documented above.
- Commit and push: ready after the final clean-diff check.
- Next phase: starts automatically from the verified pushed Phase 1 commit.
