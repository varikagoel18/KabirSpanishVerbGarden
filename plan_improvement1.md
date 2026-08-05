# Improvement Plan v1 — Jardín español

**Consolidated improvement roadmap** covering everything discussed in this session — App Store readiness, mobile UX polish, memory-leak hardening, local-only data rule, minimum-friction personalization, and adoption strategy.

**Companion docs:** [plan_launch.md](plan_launch.md) (launch sequence) · [phase_4a_profile.md](phase_4a_profile.md) (name-only onboarding) · [phase_mobile.md](phase_mobile.md) (mobile UX phases) · [appstore_plan.md](appstore_plan.md) (original App Store gap analysis)

**Anchor branch:** `codex/post-phase-native-progress-continuity`

---

## North star (from user, in this session)

1. **Kid opens app → within 5s is playing.** Learning is the product. Everything else is secondary.
2. **All user data stays on-device.** No cloud, no accounts, no analytics vendor, no CDNs that observe the user.
3. **Adoption first, features second.** Watch stickiness before adding anything critical. Zero backend at launch.
4. **Keep it simple.** Ship the minimum, iterate on real signal.

Every improvement below is judged against these four.

---

## Part A · Pre-launch blockers (must fix before App Store submission)

Same 9 blockers from [appstore_plan.md](appstore_plan.md), now aligned with the "keep it simple / local-only / adoption first" philosophy.

| # | Item | New guidance |
|---|---|---|
| **A1** | Replace hard-coded "Kabir" with a runtime learner name | **Only ~10 user-visible strings**, not all 34. Comments and Spanish lesson content ("Un día con Kabir", "Kabir toca la puerta") stay — Kabir is a fine Spanish-language example name. Detail: [phase_4a_profile.md](phase_4a_profile.md). |
| **A2** | First-launch onboarding | **Simplified to ONE prompt:** "What should I call you?" — text + Skip. No parent info, no age, no grade, no school. Full spec: [phase_4a_profile.md](phase_4a_profile.md). |
| **A3** | Self-host Google Fonts | Blocker for Kids category. Bundle Baloo 2 + Nunito as WOFF2 in `ios/KabirSpanish/Resources/fonts/`, add `@font-face` with local paths. ~30 LOC + 2 files. |
| **A4** | Privacy policy URL | 1-page hosted doc. Content: "Everything stays on your device. No accounts, no analytics." GitHub Pages or Notion public link. Free. |
| **A5** | Age rating + category | **Age 4+**, primary **Education** (safer than Kids category — fewer legal hoops, still trustworthy). Kids category requires stricter privacy proofs and verifiable parental consent for any data collection, which we won't need anyway. |
| **A6** | Icon audit | Confirm existing 1024×1024 is opaque, no alpha, no rounded corners. Regenerate if needed. |
| **A7** | Launch screen | Green background + centered "Jardín español" in Baloo 2. ~15 LOC + 1 image. |
| **A8** | Wi-Fi sync in App Store build | Compile-flag `#if !APPSTORE` around `SyncServer.start()`. Keep sync for dev/TestFlight builds so we can still OTA-push during development. **Do not migrate to iCloud** — violates local-only rule. |
| **A9** | Restore-backup button | Replace console-only rescue with a real UI in Parents → "Restore last backup". Reads `learn_verb_activity_v2_backup`. |

---

## Part B · Mobile flow polish (deltas from current state to launchable)

Screen-by-screen, ordered by impact.

### B1 · First launch
Empty picker feels like a broken app. Fix via A2 (single name prompt).

### B2 · Level picker (home)
- Land the **Today card** from [phase_mobile.md](phase_mobile.md) Phase 3 (already spec'd, not yet built).
- Reduce Practice Tests + Spanish HW to a smaller "Extras" section on mobile — they currently dominate the fold.
- Move Reset/Backup behind Parents → Danger zone.

### B3 · Level grid
- "You are here" pulse on the next-up tile.
- Bring locked tiles to full size with a lock overlay so the grid reads uniformly.
- Long-press → "About this activity" preview (accessibility).

### B4 · Lesson overlay
- Progress-bar pip animation (200ms slide instead of instant snap).
- Suppress the streak toast in the first 3 questions of a fresh install.
- Hide Skip for the first-time user in Level 0 typed sections.
- Haptic feedback on wrong (`navigator.vibrate?.(50)`, WKWebView-permitting).
- Close-button confirmation: *"Take a break? You'll come back to question N."*

### B5 · Bloom / lesson complete
- Add **"Next lesson"** primary alongside "Back to lessons" — keeps momentum on mobile.
- Show newly-earned trophy inline (defer trophy chain).
- Streak counter mini-animation.

### B6 · Trophies panel
- Show real emoji + name for locked trophies; hide only the description.
- **"Almost there"** section — trophies within 20% of target.
- Skip share button for v1 (post-launch idea).

### B7 · Parents dashboard
- Rename **Parents** → **Grown-ups** for warmth.
- Weekly rollup graph.
- Reset-today button.
- Backup/restore UI (A9).
- **New:** local adoption counters (`totalLaunches`, `firstLaunchAt`, `lastLaunchAt`) — display only, no transmission.

### B8 · Sync panel
- Hidden in App Store build (A8).

### B9 · Practice Tests + Spanish HW pages
- Unify header styles with main app.
- "Back to home" button up top.
- Respect safe-area insets on iPhone.

---

## Part C · UI polish (design pass)

- **C1 · Type scale** — standardize into 5 CSS var sizes (`--fs-xxl` 28px → `--fs-s` 13px). Apply across renderers.
- **C2 · Palette normalization** — extend Phase 4 button spec to celebration screens + Sync panel.
- **C3 · Iconography rule** — level cards always emoji-first; utility rows never.
- **C4 · Empty states** — audit remaining ones (Today card fresh-install fallback especially).
- **C5 · Animation cap** — total celebration time ≤ 4 seconds so kids can't get stuck in a chain.
- **C6 · Dark mode** — defer to v1.1. Force `color-scheme: light` in root CSS for now.

---

## Part D · Onboarding + retention

- **D1 · First-lesson success** — force the first 10 seconds to feel like a win. Cap first lesson to 3 items, high-recall.
- **D2 · Streak explainer** — 1-tap "?" on the streak stat: *"Play any lesson today to keep your streak alive!"*
- **D3 · Push notifications** — defer to v1.1 (requires Info.plist + UNUserNotificationCenter). Nice retention lever, not launch-critical.
- **D4 · Session cap nudge** — soft "Take a break?" card after 20 min of session time. Dismissible.

---

## Part E · Accessibility (App Store expectation)

- **E1 · VoiceOver labels** — audit every button. Trophy cards, level day tiles especially. ~60 LOC.
- **E2 · Dynamic Type** — use `rem` for text; honor `-webkit-text-size-adjust`. ~40 LOC. Less critical for Kids but still good.
- **E3 · Contrast** — audit pink primary on gold trophy card (borderline WCAG AA).
- **E4 · Reduced-motion / reduced-transparency** — spec'd in phase_mobile.md; verify implementation.

---

## Part F · Performance

- **F1 · Cold-start** — target < 2s on iPhone 13+.
- **F2 · Memory** — trophy shimmer + confetti during celebration → verify no OOM spike on older devices.
- **F3 · Cellular** — N/A (offline-only). Verify zero outgoing requests in Instruments.
- **F4 · Memory-leak hardening** — 3 easy wins from static audit:
  1. Guard `visualViewport` listener registration with a flag (prevents duplicates if re-init happens).
  2. Move `cur._startAt = 0` from renderers into `runStage()` (uniform treatment).
  3. Cap `cur.redoQueue` at ~50 items (drop oldest on push).

---

## Part G · Store listing prep (non-code)

- **G1 · Screenshots** — 6 per size (6.7", 6.5", 5.5"): level picker, lesson in progress, quiz question, bloom celebration, trophy page, parent dashboard. Capture via iOS Simulator.
- **G2 · App preview video** — optional 15-30s of lesson start → correct answer → bloom. +10% install conversion per Apple data.
- **G3 · Description copy** — 4000 chars max:
  > *Learn Spanish through games designed by a dad for kids. 5 levels, 200+ words, 143 trophies. No ads, no in-app purchases, no accounts. Everything stays on your device.*
- **G4 · Keywords** (100 chars): `spanish, kids, learn, verbs, vocabulary, children, education, game, elementary, español`
- **G5 · Support URL** — required. Free hosted contact page.
- **G6 · Privacy policy URL** — see A4.

---

## Part H · Data & storage architecture (permanent rules)

Codified from the `spanish-app-local-only` memory rule.

- All user data — name, progress, stars, trophies, streaks, session times, wrong-answer history, anything typed — lives in `localStorage` on the browser and `ProgressPersistenceBridge` on iOS. Both on-device.
- **No iCloud, no CloudKit, no Firebase, no Supabase, no Sentry, no analytics vendor.**
- **No third-party CDNs** that observe the user. Self-host fonts before submission.
- Adoption inspection is **manual** — read counters on your own device. No cross-install aggregation.
- Wi-Fi sync (dev-only after A8) stays LAN-only; packets never leave the local network.
- Every new field goes into the same on-device buckets — never a new cloud service.

---

## Part I · Forward-compat for a possible Phase 4B (backend) later

Cheap now, big payoff if a backend is ever added post-launch. All three land in Phase L1 (`phase_4a_profile.md`):

1. **Versioned profile bucket** — `STATE.profile = {version:1, childName, createdAt, updatedAt}`. One place, not scattered.
2. **Stable device ID** — `STATE.deviceId = crypto.randomUUID()`. Set once, primary key for a future server row.
3. **`updatedAt` on every profile write** — enables future last-write-wins sync without a schema rewrite.

Phase 4B (if it ever ships) is then a weekend of work: server + POST endpoint + one opt-in card + privacy policy rewrite.

**Trigger points for reopening Phase 4B:**
- ≥ 100 organic installs and interest in cross-device sync.
- A parent asks for a "how is my kid doing" view they can access remotely.
- A school asks for classroom rosters.
- A grant / study opportunity comes up.

Until at least one of those, backend stays off the table.

---

## Part J · What NOT to do

Explicit anti-goals so we don't drift:

- ❌ **Don't add analytics.** Not even "just" Firebase, PostHog, Plausible, or a self-hosted equivalent. Adoption is inspected manually.
- ❌ **Don't add accounts.** No login, no email verification, no OAuth.
- ❌ **Don't add multi-user profiles** — one kid per device install for v1. Multi-user is v1.1+ if requested.
- ❌ **Don't add IAP** — free forever, no subscription, no paid levels.
- ❌ **Don't add dark mode** — v1.1 if requested. Force `color-scheme: light` for now.
- ❌ **Don't chase install count** as a v1 success metric — 3 friends' kids playing happily = v1 success.
- ❌ **Don't auto-push OTA HTML** to Kabir's device unless explicitly asked.
- ❌ **Don't change scoring / progress storage / unlock rules** during launch prep — every touch risks a regression on Kabir's device.

---

## Execution order (13 steps to first submission)

Optimized for "fewest hops between blocker and unblock":

1. **L0 · Baseline** — tag `pre-launch-baseline`, snapshot Kabir's state.
2. **A3 · Self-host fonts** — 30 min, unblocks Kids-category eligibility (still worth doing for Education).
3. **A1 + A2 → Phase L1** — name-only onboarding (~135 LOC). Full spec: [phase_4a_profile.md](phase_4a_profile.md).
4. **A7 · Launch screen** — 30 min.
5. **A8 · Sync compile flag** — 30 min.
6. **A9 · Restore backup button** — 30 min.
7. **A4 · Privacy policy page** — 30 min (hosted).
8. **A6 · Icon audit** — 15 min.
9. **B2 · Today card** — land the pre-spec'd `phase_mobile.md` Phase 3 (~80 LOC).
10. **B4 · Close-confirmation + Next-lesson button** — 45 min.
11. **E1 · VoiceOver labels** — 60 min (~60 LOC).
12. **C4 + C5 · Empty states + celebration cap** — 30 min.
13. **G1 + G3 · Screenshots + description** — 2h (screenshots take real time).
14. **F4 · Memory-leak hardening** — 15 min (3 tweaks, ~15 LOC).
15. **L4 · Pre-submission QA** — 2h ([phase_mobile.md](phase_mobile.md) Phase 9 checklist).
16. **L5 · Submit** — 30 min + 24-48h Apple wait.

**Rough total effort:** ~15-18 hours of focused work.
**Wall time:** ~1 week end-to-end including Apple review.

---

## Success criteria for v1

- ✅ App accepted by Apple on first review submission.
- ✅ Cold-start < 2s on iPhone 13+.
- ✅ Zero third-party network requests (Instruments-verified).
- ✅ Kabir's progress on his device survives every phase intact.
- ✅ At least 3 friends install and their kids complete Level 0 Day 1 without help.

## Not a success criterion (deliberately)

- ❌ Install count.
- ❌ Retention percentage.
- ❌ Session length.
- ❌ Anything that requires collecting data to measure.

If it's good for Kabir and 3 friends' kids, v1 shipped successfully. Adoption thinking begins post-launch when real signal exists — inspected manually, no vendor.

---

## Guardrails (all phases)

- Local-only data (H).
- No auto app updates to Kabir's device unless explicitly asked in the current turn.
- iOS Simulator OK anytime; physical-device install requires explicit user consent.
- Every phase = one commit with `Launch Ln: ...` or `Phase X: ...` prefix.
- All storage writes guarded (`try/catch`).
- All new UX behind a `UX_FLAGS` toggle for local rescue.
- No merges into `main` unless user requests.
- No OTA HTML pushes during Apple review window.

---

## Post-launch backlog (do NOT build before launch)

Ideas to log for later, unblocked only by real adoption signal:

- Push notifications (local, no server) — daily reminder.
- Dark mode.
- More levels (Preterite, Adjetivos avanzados, Comida, Vestir).
- Multi-user profiles.
- iCloud sync (breaks local-only — requires reopening that conversation).
- App-preview video.
- UI localization (Hindi, other languages; learning content stays Spanish).
- Voice practice polish (Swift bridge already prototyped in `WebView.swift`).
- Phase 4B backend + parent portal (only if a real trigger from Part I fires).

---

**Bottom line for the reviewer:** 90% of the improvement work is preparing the app for a stranger's kid (name prompt, self-hosted assets, privacy policy, launch screen, review-safe sync). 10% is polish (Today card, VoiceOver, close-confirmation). Do Part A + B2 + E1 + G and the app passes review on the first try.

Ready to begin when you say **"start L0"** (or specific item like **"start A3"**).
