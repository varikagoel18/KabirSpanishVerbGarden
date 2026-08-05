# App Store Publication Plan — Jardín español

Branch anchor: `codex/post-phase-native-progress-continuity`

Goal: turn the current in-family iOS app (WKWebView wrapping `learn-verb-activity.html`) into a submittable App Store product for the **Kids 6-8** or **Education** category, without regressing anything Kabir already relies on.

This document is scoped to what a **stranger's kid** needs the app to do — first-launch onboarding, no personalization dependency, no unresolved network dependencies, no console-only rescue paths, and clear parental context.

---

## Part A · Pre-flight blockers (must fix before submission)

These will get the app rejected or embarrassed on day one.

### A1 · Personalization coupling ("Kabir's Verb Garden")

- The app hard-codes Kabir as the user throughout the copy ("Kabir got it right!", "Great job, Kabir!", "Kabir's Verb Garden").
- **Fix:** rename the shipping brand to a neutral name (existing display name is already **Jardín español** — keep that). Replace `Kabir` with a first-run-entered name stored in `STATE.learnerName`. Fall back to *"you"* / *"amigo"* if empty.
- 34 occurrences of "Kabir" — one pass replaces them all with `${STATE.learnerName || "amigo"}`.
- **Est. LOC:** ~40 across the HTML.

### A2 · First-launch onboarding

- Today the app dumps a returning player onto the level picker with pre-loaded progress. A new user sees the same UI but with empty stats — confusing.
- **Fix:** add a 3-step onboarding shown only when `STATE.onboardingComplete !== true`:
  1. *"What's your name?"* — text field → `STATE.learnerName`.
  2. *"How much Spanish do you already know?"* → 3 buttons (*"None"*, *"A little"*, *"Some"*) — sets a `STATE.startingLevelId` (0 / 1 / 2).
  3. *"Ready?"* → auto-opens the chosen level's Day 1.
- Skippable with *"I'll set up later"*, but the app then routes to Level 0 by default.
- **Est. LOC:** ~200.

### A3 · Google Fonts CDN

- The HTML currently loads Baloo 2 + Nunito from `fonts.googleapis.com`.
- **Blocker for Kids Category** — Apple prohibits third-party analytics / advertising / data transmission for apps in the Kids category, and Google Fonts qualifies as third-party data transmission (referer + IP).
- **Fix:** self-host both fonts. Download WOFF2 files, put them in `ios/KabirSpanish/Resources/fonts/`, reference via `@font-face` with local paths. Also inline the `@font-face` declarations so the site works from `file://` without a font server.
- **Est. LOC:** ~30 CSS + 2 font files bundled.

### A4 · Privacy policy + Data collection declaration

- App Store Connect **requires** every submitted app to declare data collection categories.
- Current answer: *"Data Not Collected"* — the app is entirely local, no analytics, no fetches (once A3 is done). Sync is user-initiated over LAN.
- **Fix:** write a one-page privacy policy at a hosted URL (GitHub Pages / your domain). Content: *"This app stores learning progress locally on your device. It does not collect, transmit, or share any personal information. Wi-Fi sync is opt-in and stays on your local network."*
- Submit the URL in App Store Connect under App Privacy → Privacy Policy URL.

### A5 · Age rating fields

- Set: **Age 4+** (no violence, no gambling, no mature themes).
- Category: **Education** (primary) + **Games / Family** (secondary) if you want. If shipping to Kids category, use **Ages 6-8**.

### A6 · Icon polish + full icon set

- Current icon (green background, book stack, sprout, star) is fine but only a 1024x1024 exists.
- App Store rejects if any required size is missing. Modern Xcode 15+ accepts a single 1024x1024 in `AppIcon.appiconset`, but **marketing** still needs a 1024x1024 no-alpha PNG uploaded separately in App Store Connect.
- **Fix:** confirm the existing icon meets Apple's requirements (opaque, no rounded corners, no alpha channel, 1024x1024 sRGB). Regenerate if needed.

### A7 · Launch screen

- Info.plist currently has an empty `UILaunchScreen` dict. iOS accepts it (renders black) but reviewers may flag it as unpolished.
- **Fix:** add a simple launch screen: green background + centered "Jardín español" title in Baloo 2. Storyboard-free — just an image asset + Info.plist entry.
- **Est. LOC:** ~15 Info.plist + 1 image asset.

### A8 · Sync feature review risk

- **Hard project rule: all user data stays on-device.** No iCloud, no cloud accounts, no telemetry. Only the current user's LAN is allowed. (See memory `feedback-spanish-app-local-only`.)
- The in-app Wi-Fi sync (HTTP server on port 8181) can be flagged during App Review as "unsecured network endpoint" or "unclear purpose".
- **Fix:**
  - **Ship-default:** disable the HTTP sync server for App Store builds via a compile flag (e.g. `#if !APPSTORE`). Keep it only for personal / TestFlight builds so we can still push OTA updates during development.
  - **User-visible replacement in the App Store build:** a **Backup / Restore** pair in Parents that exports/imports state as a JSON file via the iOS share sheet (AirDrop, Files, Messages — user's choice, on-device or user-to-user only, no server involved). **Est. LOC:** ~80 Swift + ~40 JS.
  - Document the review answer clearly: *"App uses local file storage only. No accounts, no cloud, no analytics. The optional Backup exports a file the user chooses where to send."*

### A9 · Console-only rescue paths

- The recent doc references localStorage restore snippets like `localStorage.setItem("learn_verb_activity_v2", localStorage.getItem("learn_verb_activity_v2_backup"))`. These are fine for us but reviewers won't test them — they aren't a real feature.
- **Fix:** add an in-app "Restore last backup" button under Parents → Backup. One tap, no console needed.

---

## Part B · Mobile flow audit (screen-by-screen)

Each row lists **what's currently there → what needs to change for public release.**

### B1 · First launch (new user)

- **Today:** empty level picker, header stats at 0, no onboarding.
- **Target:** onboarding flow (A2) → first lesson auto-loaded → confetti on Day 1 completion.

### B2 · Level picker (home)

- **Today:** collapsed header + list of 5 levels + Practice Tests + Spanish HW cards.
- **Fix:**
  - Add the **Today card** from `phase_mobile.md` Phase 3 (it's spec'd, land it).
  - Reduce Practice Tests / HW to a single "Extras" section on mobile — currently they dominate the fold.
  - Move the reset/backup section behind Parents → Danger zone.
  - Add a persistent **level badge** that shows a small icon of what Kabir just earned last (mini trophy carousel).

### B3 · Level grid (day tiles)

- **Today:** grid of day tiles (sapling / tree / flower / lock / drought). Solid.
- **Fix:**
  - Add a subtle **"you are here" pulse** on the next-up tile so it draws the eye.
  - Fix tap target: locked tiles are visually smaller — bring them to full size with a lock overlay so the grid feels uniform.
  - Add long-press → "About this activity" preview sheet (accessibility win).

### B4 · Lesson overlay (all activity types)

- **Today:** modal sheet, sticky bottom action (Phase 2 landed), full-screen on iPhone (Phase 2b).
- **Fix:**
  - **Progress bar animation** — the top step pips update instantly; add a 200ms slide so kids see the movement.
  - **Streak toast** already exists (combo counter). Make sure it doesn't fire during onboarding — dampen for the first 3 questions of every fresh install.
  - **Skip button** placement — on Level 0 typed sections, it's next to Check. Consider hiding Skip for first-time users so they don't accidentally skip everything.
  - **Wrong-answer feedback** — currently a red border + toast. Add a soft haptic (`window.navigator.vibrate?.(50)`) on wrong; check WKWebView support.
  - **Close-button confirmation** — Kabir tapping X mid-lesson loses in-question progress (though stage resume works). Add a mini confirm: *"Take a break? You'll come back to question N."*

### B5 · Bloom / lesson complete

- **Today:** confetti, star count, "Back to lessons" button.
- **Fix:**
  - Add a **"Next lesson"** primary button alongside "Back to lessons" — keeps the momentum on mobile.
  - Show the newly-earned trophy inline (currently deferred to trophy chain).
  - Streak counter mini-animation.

### B6 · Trophies panel

- **Today:** modal, categorized, filter chips, per-trophy progress bars.
- **Fix:**
  - **Locked trophies show generic emoji** — good obfuscation for a personal app, but for the App Store, showing "???" everywhere feels stingy. Show the actual emoji + name; keep the description hidden until earned.
  - Add **"Almost there"** section — trophies within 20% of target, sorted by proximity. Kids will chase these.
  - Add **share button** (react to trophy → save PNG). Requires html2canvas or SwiftUI ShareLink. Optional.

### B7 · Parents dashboard

- **Today:** session minutes, streak, focus verbs, wrong questions by day.
- **Fix:**
  - Add **weekly summary** (7-day rollup graph).
  - Add **"Reset day"** button (removes today's completions if a parent wants to redo).
  - Rename **"Parents"** → **"Grown-ups"** for warmth.
  - **Backup / restore** UI (see A9).

### B8 · Sync panel

- **Today:** Wi-Fi HTTP sync, works but review-risky (A8).
- **Fix:** replace with iCloud sync (A8) OR gate behind an "Advanced" toggle in Parents that's off by default.

### B9 · Practice Tests + Spanish HW pages

- **Today:** separate HTML pages, bundled in iOS.
- **Fix:**
  - Unify their header styles with the main app (currently look like a different app).
  - Add a "Back to home" button at the top (currently only via browser back).
  - Verify they respect safe-area insets on iPhone (they may not).

---

## Part C · UI polish (design pass)

### C1 · Type scale

- Currently: big/small font sizes are ad-hoc across renderers. Standardize into 5 sizes: `--fs-xxl 28px`, `--fs-xl 22px`, `--fs-l 18px`, `--fs-m 16px`, `--fs-s 13px`. Apply via existing CSS vars.

### C2 · Color palette normalization

- The Phase 4 button spec is landed. Extend the same treatment to the celebration screens and Sync panel status colors so nothing feels off-brand.

### C3 · Iconography

- Emoji use is charming but inconsistent (some cards have leading emoji, some don't). Decide a rule: level cards always emoji-first; utility rows never.

### C4 · Empty states

- Every list needs a friendly empty state. Currently:
  - Trophies: empty state exists ✓
  - Focus verbs: empty state exists ✓
  - Wrong questions by day: empty state exists ✓
  - **Missing:** Today card when no candidate (Phase 3 rule #5) — needs "🌱 Let's start" prompt.

### C5 · Animation restraint

- Reduce-motion is respected (Phase 7). But even in normal motion mode, some animations chain (trophy chain → confetti → bloom → toast). Cap total celebration time to 4 seconds so kids can't get stuck.

### C6 · Dark mode decision

- `phase_mobile.md` says do not auto-flip. For App Store, iOS users increasingly expect dark support. Decision needed: opt-in Parents toggle, or add a proper dark theme?
- **Recommend:** ship v1 light-only with `color-scheme: light` forced; add dark mode in v1.1.

---

## Part D · Onboarding + retention

### D1 · Empty-state hook

- First 10 seconds decide retention. After onboarding, the first lesson must be **guaranteed** to end in success. Force it to be a 3-item lesson at max, with all correct answers on first try feeling achievable.

### D2 · Streak system communication

- The streak counter exists but no one knows what it means. Add a 1-tap explainer on the streak stat: *"Play any lesson today to keep your streak alive!"*

### D3 · Daily reminder push notifications

- App Store apps rarely reject push notifications, but Kids-category apps have strict rules: must be opt-in during onboarding, must be for the app's own content, no marketing.
- **Fix (v1.1, not v1):** UNUserNotificationCenter, local notification only. "Ready for today's Spanish?" at a user-picked time. Requires ~150 lines Swift + persistence for the schedule.

### D4 · Session length caps

- Kids-category best practice: nudge a break after 20 min. Show a soft "Take a break?" card after `STATE.sessionMinutes[today] >= 20`, dismissible.

---

## Part E · Accessibility (App Store requirement)

### E1 · VoiceOver

- WKWebView content is accessible if the HTML is. Currently: many buttons have no `aria-label`. Audit:
  - Trophy cards: add `aria-label="Trophy: Colors Champion, unlocked"`.
  - Level day tiles: add `aria-label="Level 1 Day 5, next up, 0 stars"`.
  - Utility buttons: labels present, good.
- **Est. LOC:** ~60.

### E2 · Dynamic Type

- Not respected currently — CSS uses fixed px. For Kids category this is less critical (kids don't change type size), but for Education it matters.
- **Fix:** use `rem` for text where feasible, honor `-webkit-text-size-adjust`. **Est. LOC:** ~40.

### E3 · Color contrast

- Green header on cream background = fine. Pink primary button on gold earned trophy card = borderline WCAG AA. Audit with a contrast tool; darken pink or add a border.

### E4 · Reduced Motion / Reduced Transparency

- Both spec'd in `phase_mobile.md`. Verify implementation lands before submission.

---

## Part F · Performance for App Store review

### F1 · Cold-start time

- Target: < 2 seconds from tap to interactive on iPhone 13+.
- Current bundle is ~400 KB HTML + ~500 KB icon + 2 sibling HTML files. Should be well under target. Verify.

### F2 · Memory

- Trophy page shimmer animation + confetti during celebration → potential mid-lesson memory spike. Verify no OOM on older devices.

### F3 · Load speed on cellular

- N/A — app is offline-only. Confirm no accidental network requests in Instruments → Network profile.

---

## Part G · Store listing prep

### G1 · Screenshots

- Required sizes: 6.7" (iPhone 16 Pro Max), 6.5" (iPhone 11 Pro Max), 5.5" (iPhone 8 Plus).
- Prepare 6 screenshots: level picker, lesson in progress, quiz question, bloom celebration, trophy page, parent dashboard.
- Use the iOS Simulator (already running) to capture at correct dimensions.

### G2 · App preview video (optional)

- 15-30 second video showing a lesson start → correct answer → bloom.
- Recommended but not required. Adds ~10% install conversion in App Store data.

### G3 · Description copy

- 4000 chars max. Focus on:
  - "Learn Spanish through games designed by a dad for kids"
  - "5 levels, 200+ words, 100+ trophies"
  - "No ads, no in-app purchases, no data collection"
  - Age range 6-8 recommended.

### G4 · Keywords

- 100 chars total. Suggested: `spanish, kids, learn, verbs, vocabulary, children, education, game, elementary, español`

### G5 · Support URL

- Required. Set up a simple contact page (GitHub Pages or Notion public link).

---

## Suggested execution order

1. **A3 (self-host fonts)** — 30 min, unblocks Kids-category eligibility.
2. **A1 (rename Kabir → learnerName)** — 1 hour.
3. **A2 (onboarding)** — 3 hours.
4. **A8 (sync decision)** — 30 min if we just gate it; 4 hours if we do iCloud.
5. **A7 (launch screen)** — 30 min.
6. **A4 (privacy policy page)** — 30 min.
7. **A6 (icon audit)** — 15 min.
8. **B2 (Today card)** — already spec'd in phase_mobile.md Phase 3; land it.
9. **B4 close-confirmation, next-lesson button** — 45 min.
10. **E1 (VoiceOver labels)** — 1 hour.
11. **C4 empty states + C5 celebration cap** — 30 min.
12. **G1 screenshots + G3 description** — 2 hours.
13. **Final QA pass** — full `phase_mobile.md` Phase 9 checklist + App Store submission.

**Rough total effort:** 15-20 hours of focused work to get from current state to first submission. Add 1-2 review cycles with Apple (each takes 24-48 hours).

---

## Guardrails during App Store prep

- **Do not remove any of Kabir's progress** — the app on his phone is the source of truth. Any refactor must preserve `STATE.levels[N]` schema.
- **Feature-flag new UX** so a bad reviewer build can be rolled back without changing the version on Kabir's phone.
- **Keep the "iOS Simulator anytime, physical iPhone install only on explicit ask" rule** from `phase_mobile.md`.
- **Do not push OTA HTML updates during Apple review** — the reviewer will see the *bundled* HTML, not the OTA-pushed one. Ship the same bundled HTML they'll be reviewing.
- **All storage writes stay guarded** (`try/catch` around `localStorage`).

---

## Out of scope for v1

- Multi-user profiles (Kabir + siblings).
- Multiple languages beyond Spanish.
- Server-backed accounts / cross-device sync via cloud.
- IAP / subscriptions.
- Push notifications (defer to v1.1).
- iPad-optimized layouts beyond the current responsive treatment.
- Dark mode (defer to v1.1).

---

**Reviewer's blunt take:** the app is functionally solid — the core loop works, progress is durable, and the visual identity is already there. The submission gap is 90% about **defaults for a stranger's kid** (onboarding, no personal names, self-hosted assets, privacy policy) and 10% about polish (Today card, close-confirmation, VoiceOver, screenshots). If you focus on Part A + B2 + E1 + G, you'll pass review on the first try.
