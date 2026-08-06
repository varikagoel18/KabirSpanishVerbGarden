# Plan · In-app bug report / feedback

**Purpose:** kid or parent can flag "this is broken" or "loved this part" without leaving the app. **Zero cloud** — same local-only rule as the rest of the app applies.

## User-facing shape

**Entry point:** small floating "💬 Feedback" chip pinned bottom-right of the picker (also reachable from Parents → *Send feedback*). Tap opens a compact overlay:

```
┌───────────────────────────────┐
│  💬  Send feedback         ✕ │
│      Tell us what happened    │
├───────────────────────────────┤
│  What is this?                │
│  [ 🐞 Bug ] [ 💡 Idea ] [ ❤️ Loved it ] │
│                                │
│  Where in the app?             │
│  (auto-filled with current      │
│  screen: "Level 0 · Quiz 3 ·    │
│  Warm-up")                      │
│                                │
│  Your note                     │
│  ┌───────────────────────────┐│
│  │ Type here...              ││
│  └───────────────────────────┘│
│                                │
│  ☐ Include a screenshot 📸     │
│  ☐ Include app state snapshot  │
│                                │
├───────────────────────────────┤
│  [ Send via Email ]  [ Copy ]  │
└───────────────────────────────┘
```

**Two send paths** (both offline, no server needed):
1. **Email (default).** Uses `mailto:` with the report packed into the body + a data-URI attachment for the screenshot. Opens Mail / Gmail / whatever the parent has configured. Parent hits Send.
2. **Copy.** Puts the whole report on the clipboard. Parent pastes into a Note / Slack / Messages.

Recipient email is set in Parents → *Feedback email* (defaults to blank — parent must enter once). No hardcoded destination.

## What a report contains

Everything the sender opts into, plus context we always know:

**Always included** (auto)
- App version + build number
- Current screen name (from a tiny `_lastScreen` ring buffer we already have via renderLevels/openDay hooks)
- Learner name (from STATE.profile, or "amigo")
- Device: userAgent, viewport, orientation, reduced-motion pref
- Last 20 UI events (screen enters, lesson starts, correct/wrong flag) — no PII
- Storage health: localStorage available? IDB available? size in KB

**Opt-in checkbox**
- **Screenshot** — use `html2canvas`-free approach: `SVGForeignObject` around the `#stage` and `#overlay`, render to canvas, export PNG data URI.
- **App state snapshot** — the `STATE` JSON (already local-only). Attached as `state.json` data URI.

**Never included**
- No email addresses other than the recipient the parent typed.
- No location / IP / device IDs (Kabir's `deviceId` is a random UUID — safe, but we still strip it before send since it's not useful for a bug).
- No third-party network call.

## Architecture (all local, all inside `learn-verb-activity.html`)

- New IIFE `BugReport` with `.open()`, `.record(event)`, `.snapshot()`, `.pack()`.
- Ring buffer (`BugReport._events`, cap 20) written from:
  - `openLevel`, `openDay`, `closeDay`, `nextStage`, `renderBloom`
  - `evaluateAnswer`-style hooks (correct / wrong) via one-line calls added inline
  - Any `throw` caught by `window.onerror` and `unhandledrejection` — captured and enqueued so the report also has recent JS errors.
- Recipient email stored in `STATE.feedbackEmail`.
- Feature flag `UX_FLAGS.bugReport` (default true), URL rescue `?bugReport=0`.

## Screenshot mechanics (no CDN)

`html2canvas` is 40KB — allowed since it's bundled, not fetched.  Alternative that avoids any lib: use the DOM's native `Element.getScreenshot()` isn't real; the practical native path is:

1. Serialize the current `#viewLevels` or `#overlay` to XML.
2. Wrap in an SVG `<foreignObject>` at the viewport size.
3. Convert SVG string to a Blob → object URL → draw onto canvas → `toDataURL('image/png')`.

Trade-off: `foreignObject` renders don't include images from cross-origin — fine here, everything is emoji + inline SVG. Level of fidelity is "screenshot of markup", which is exactly what a bug reporter needs.

## Bundle size budget

| Piece | Estimated LOC | Estimated bytes |
|---|---|---|
| BugReport IIFE + ring buffer | ~90 | ~3 KB |
| Overlay UI + CSS | ~110 | ~4 KB |
| Screenshot helper (SVG → canvas → PNG) | ~40 | ~1.2 KB |
| Parents section: email setting | ~25 | ~0.8 KB |
| **Total** | **~265** | **~9 KB** |

Fits under the App Store "one HTML file" ceiling. No new files.

## Flow: parent opens feedback for the first time

1. Tap 💬 chip → overlay opens, `Feedback email` field is empty.
2. Overlay shows a soft banner: *"First time? Add an email in Parents → Feedback so replies can reach you."* [Set email →]
3. On tapping the button, jumps to Parents → focus the email input, save on blur.
4. Return to the feedback overlay; email now prefilled. Type note, tap Send.

## Kid mode (safe UX)

If the current profile is a kid (i.e. name was set via onboarding), the overlay hides the "Copy" option (kid can't paste anywhere meaningful) and disables the email input; only "Loved it ❤️" and "Something is wrong 🐞" are one-tap buttons that queue the report to a **local outbox** (`STATE.feedbackOutbox`). Parent sees an outbox count on the Parents screen and reviews before sending.

## What NOT to build in v1

- No categorization / severity dropdowns (kids won't answer).
- No CAPTCHAs / consent gates (local-only, no server → nothing to protect).
- No file upload beyond screenshot + state JSON.
- No auto-send timer or "shake to report" gesture (feels magical, breaks accessibility).
- No analytics on how many reports were sent (defeats the local-only rule).

## Phased delivery

| Phase | Scope | Effort |
|---|---|---|
| BR1 | Ring buffer + `window.onerror` capture only; nothing user-visible | ~1h |
| BR2 | 💬 chip, overlay UI, mailto Send, clipboard Copy, Parents email setting | ~2h |
| BR3 | Screenshot capture, State-snapshot attachment | ~1.5h |
| BR4 | Kid-mode outbox with parent review | ~1h |

**Total:** ~5.5 hours of focused work.

## Open questions for you

1. **Recipient default.** Should the app ship with `varikagoel18@gmail.com` prefilled, or always blank until the parent enters it?
2. **Kid mode default.** Turn kid-mode outbox on automatically when `STATE.profile.childName` is set, or make it a parent toggle?
3. **Feedback email = same as sync-server label?** Reuse the Parents section, or new sub-section?
4. **On-device outbox retention** — auto-purge after N days, or keep forever?

Say the word on any of the above and I'll drop this into buckets and start BR1.
