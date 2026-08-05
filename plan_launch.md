# App Store Launch Plan — Jardín español

**Product philosophy:** kid taps the app → within 5 seconds is playing. Nothing else is critical for launch. See adoption first, add profile/backend/analytics only if the numbers justify it.

**Data rule (permanent for v1):** everything stays on the device. No accounts, no cloud, no CDNs, no analytics. Privacy declaration = *"Data Not Collected"*.

**Anchor branch:** `codex/post-phase-native-progress-continuity`
**Related plans:** [phase_mobile.md](phase_mobile.md) · [appstore_plan.md](appstore_plan.md) · [phase_4a_profile.md](phase_4a_profile.md)

---

## Current state (what's already shipped on device)

| Area | Status |
|---|---|
| Core gameplay loop | ✅ Levels 0-4 + Practice Tests + Spanish HW |
| Mid-lesson resume | ✅ intra-question for 6 renderers, stage-level everywhere |
| Progress durability | ✅ localStorage + iOS `ProgressPersistenceBridge` |
| Wi-Fi sync (dev tool) | ✅ works LAN-only |
| Mobile UX phases 1-9 | ✅ implemented (`phase_mobile.md`) |
| Tree/sapling icon system | ✅ shipped |
| Trophies | ✅ 143 defined |
| Reduced-motion / transparency / safe-area | ✅ shipped |

---

## Launch phases (in order)

### Phase L0 · Snapshot baseline (0.5 hour, doc-only)

- `git status` clean, tag current commit as `pre-launch-baseline`.
- Copy Kabir's `STATE` JSON to `scratchpad/kabir_baseline.json` so nothing he has can be lost during launch prep.
- Confirm all 3 bundled HTML resources match root.
- **Exit:** baseline committed and tagged.

---

### Phase L1 · Minimum-friction personalization (~135 LOC)

Full spec: [phase_4a_profile.md](phase_4a_profile.md).

- One prompt on first launch: *"What should I call you?"* — text + Skip.
- `STATE.profile = {version:1, childName, createdAt, updatedAt}`.
- `STATE.deviceId = crypto.randomUUID()` — set once, forward-compat with a future backend.
- Replace ~10 user-visible "Kabir" strings with `learnerName()`; fallback = *"amigo"*.
- Local-only adoption counters (`firstLaunchAt`, `totalLaunches`, `lastLaunchAt`) — no transmission.
- Feature flag `UX_FLAGS.nameOnboarding` (default on), URL rescue `?nameOnboarding=0`.
- **Exit:** fresh install shows prompt once; skip works; Kabir's device migrates cleanly.

---

### Phase L2 · Kids-category compliance (~2 hours, small code + assets)

Blockers that fail Apple review for a Kids-category app.

- **L2.1 · Self-host fonts** (~30 LOC + 2 WOFF2 files) — pull Baloo 2 + Nunito, bundle in `ios/KabirSpanish/Resources/fonts/`, add `@font-face` with local paths. Remove `fonts.googleapis.com` links.
- **L2.2 · Launch screen** (~15 LOC + 1 image) — green background + centered "Jardín español" in Baloo 2. Info.plist entry.
- **L2.3 · Icon audit** — confirm 1024×1024 opaque sRGB PNG in AppIcon.appiconset (already done). Verify no alpha, no transparency, no rounded corners.
- **L2.4 · Disable HTTP sync in App Store build** — compile flag `#if !APPSTORE` around `SyncServer.start()`. Keep it for personal builds so we can still OTA-push during dev.
- **L2.5 · Restore-backup button** (Parents section) — replaces the console-only rescue path with a real UI. Reads `learn_verb_activity_v2_backup` and restores.
- **Exit:** zero third-party network requests in DevTools Network tab; App Store build launches cleanly with launch screen.

---

### Phase L3 · Store metadata + assets (~2 hours, non-code)

- **L3.1 · Privacy policy** — 1-page hosted URL. Content: *"This app stores learning progress locally on your device. It does not collect, transmit, or share any personal information. There are no accounts. Wi-Fi sync (dev builds only) never leaves your network."* GitHub Pages or Notion public link — free.
- **L3.2 · Support URL** — 1-page contact form / email link. Required by App Store.
- **L3.3 · Screenshots** — 6 per size (6.7" 6.5" 5.5"): level picker, lesson in progress, quiz question, bloom celebration, trophy page, parent dashboard. Use iOS Simulator to capture at correct dimensions.
- **L3.4 · Description copy** (~4000 chars max):
  > *Learn Spanish through games designed by a dad for kids. 5 levels, 200+ words, 143 trophies. No ads, no in-app purchases, no accounts. Everything stays on your device.*
- **L3.5 · Keywords** (100 chars max): `spanish, kids, learn, verbs, vocabulary, children, education, game, elementary, español`
- **L3.6 · Age rating** — Age 4+; primary category **Education**; secondary **Games / Family**.
- **L3.7 · App preview video** (optional, 15-30s): lesson start → correct answer → bloom celebration.
- **Exit:** all fields populated in App Store Connect; screenshots uploaded; description approved on read-back.

---

### Phase L4 · Pre-submission QA (~2 hours, doc + testing)

Run [phase_mobile.md § Phase 9](phase_mobile.md) top to bottom on the release build:

- Desktop / iPad-width / iPhone-width browser flow.
- Installed iPhone app.
- `prefers-reduced-motion: reduce`.
- Landscape orientation.
- Offline on iPhone (airplane mode) + on desktop (DevTools Offline).
- No progress data loss.
- No scoring rule changes.
- Practice Test + Spanish HW links open in iOS app.
- Audio stops on screen/question changes.
- Sticky mobile controls clear home indicator + keyboard.
- Bundle parity: `diff -q` on the 3 HTML pairs — zero output.
- Sync round-trip merges without losing counters.
- Zero outgoing network requests (Instruments → Network profile).
- Cold-start < 2s on iPhone 13+.
- **Exit:** every checkbox passes; screenshots re-captured if any visual regressed.

---

### Phase L5 · App Store submission (30 min + 24-48h wait)

- Version 1.0.0, build 1.
- Ensure signing identity + provisioning profile ready in Xcode.
- Archive → Distribute → App Store Connect.
- Fill privacy declaration: **Data Not Collected** ✓.
- Submit for review.
- Reply to Apple within 24h if they ask questions.

---

## Post-launch adoption watch (weeks 1-8)

**Manual inspection only** — no analytics vendor. On your own device (and Kabir's):

- Parents → Profile shows: total launches, first launch date, last launch date, sessions per day.
- After every few weeks, compare against a rough gut check: *"Does the number look like real use, or just my testing?"*
- Ask 2-3 friends with kids to try it; note qualitative feedback (verbal or DM).

**Adoption trigger points** for future work:

| Signal | Consider adding |
|---|---|
| ≥ 100 organic installs & interest in cross-device sync | Phase 4B backend |
| A parent requests a "how is my kid doing" view they can access remotely | Phase 4B + parent portal |
| A school asks for classroom rosters | Phase 4B + classroom mode |
| A grant / study opportunity comes up | Formal COPPA/GDPR consent + data pipeline |

Until then, keep it local.

---

## v1.1 backlog (post-launch, only if adoption justifies)

**Do NOT build these before launch.** Log ideas here for later:

- Push notifications (daily reminder — needs UNUserNotificationCenter).
- Dark mode (proper design pass; not auto-flipped).
- More levels (Level 5 · Preterite, Level 6 · Adjetivos avanzados, etc.).
- Multi-user profiles (Kabir + sibling on same device).
- iCloud sync (breaks local-only rule — requires reopening that conversation).
- App-preview video.
- Localization to Hindi / other languages in the UI (learning content stays Spanish).
- Optional voice practice — already prototyped, needs polish.

---

## Rough timeline

| Phase | Effort | Wall time |
|---|---|---|
| L0 baseline | 0.5h | Same day |
| L1 name-only onboarding | 2h | Same day |
| L2 kids-category compliance | 3h | 1 day |
| L3 store metadata + assets | 2h | 1 day (screenshots take real time) |
| L4 pre-submission QA | 2h | 1 day |
| L5 submission | 0.5h + wait | Submit day 4, live day 5-7 |

**Total effort:** ~10 hours of focused work.
**Wall time from start to live in App Store:** ~1 week including Apple review.

---

## Guardrails

- Data stays local (`spanish-app-local-only` memory rule).
- No auto app updates to Kabir's device unless explicitly asked (`feedback-no-auto-app-updates` memory rule).
- iOS Simulator use OK anytime; physical-device install requires explicit user consent per turn.
- Every phase = one commit, `Launch Ln: <title>` prefix, revertable via `git revert <sha>`.
- No merging launch branches into `main` unless user requests.
- No OTA HTML pushes during Apple review window (reviewer sees the bundled HTML).
- All storage writes guarded (`try/catch`).
- All new features behind a `UX_FLAGS` toggle for local rescue.

---

## Success criteria for v1

- App accepted by Apple on first review submission.
- Cold-start < 2s on iPhone 13+ (baseline).
- Zero third-party network requests in Instruments trace.
- Kabir's progress on his device survives every phase intact.
- At least 3 friends can install and their kids can complete Level 0 Day 1 without help.

---

## Not a success criterion (deliberately)

- Number of installs. **Don't measure it. Don't chase it.** If the app is good for Kabir and 3 friends' kids, that's success for v1. Adoption thinking begins post-launch when real signal exists.
