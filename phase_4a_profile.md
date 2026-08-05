# Phase 4A · Minimum-friction launch

Branch: `codex/phase-4a-name-only`

**North star:** kid opens the app → within 5 seconds is playing. Everything else is secondary.

Goal: ship the smallest possible change that (a) removes the hard-coded "Kabir" so the app doesn't feel personal to one household, and (b) leaves the door open for a bigger profile/backend later if adoption justifies it. **No parent info, no phone, no school, no grade, no age gates. Not now.**

Anchor: honors the `spanish-app-local-only` memory rule; nothing leaves the device. Fits the "adoption first — see if kids stick" launch philosophy.

---

## What ships in Phase 4A

**Exactly one thing:** first-launch asks for the kid's name (or nickname). One text field. One button. Skippable.

```
┌──────────────────────────────┐
│  🌱 ¡Hola!                   │
│                              │
│  What should I call you?     │
│                              │
│  ┌────────────────────────┐  │
│  │ e.g. Kabir             │  │
│  └────────────────────────┘  │
│                              │
│  [ ¡Vamos! ▶ ]  [ Skip ]     │
└──────────────────────────────┘
```

That's it. On tap of "¡Vamos!" or "Skip" the app opens Level 0 Day 1.

## What we do NOT ship in 4A

Deferred entirely — bring back only if adoption signal justifies:

- ~~Parent name + phone~~
- ~~School name~~
- ~~Age~~
- ~~Grade~~
- ~~Multi-step onboarding~~
- ~~Parents → Profile section~~
- ~~Any consent / privacy flow (still "Data Not Collected")~~
- ~~Any backend or sync of the name~~

---

## Data schema (deliberately tiny)

```js
STATE.profile = {
  version:   1,
  childName: "",              // string, trimmed, 0-40 chars
  createdAt: "",              // ISO on first write
  updatedAt: ""               // ISO on every write
};

STATE.deviceId = STATE.deviceId || crypto.randomUUID();  // set once, never rewritten
STATE.onboarding = { seen: true, completedAt: "..." };
```

`deviceId` costs zero LOC to include and unlocks a clean future backend flip. Everything else stays out.

All writes go through:
```js
function setChildName(name){
  STATE.profile = Object.assign({}, STATE.profile||{version:1},
    {childName:(name||"").trim().slice(0,40), updatedAt:new Date().toISOString()});
  if(!STATE.profile.createdAt) STATE.profile.createdAt = STATE.profile.updatedAt;
  Store.save();
}
```

## Copy replacement

Every hard-coded "Kabir" (34 occurrences) becomes:
```js
const learnerName = () => (STATE.profile && STATE.profile.childName) || "amigo";
```

Falls back to *"amigo"* if the kid skipped the name prompt. Celebrations, streak toasts, bloom messages, trophy chain — all read from the getter.

---

## UI details

- Overlay uses the existing sticky-bottom action shell (Phase 2).
- Text input is `type="text" autocapitalize="words" spellcheck="false" maxlength="40"`.
- Enter key submits.
- Nothing else on the screen (no other fields, no fine print).
- "Skip" is a `secondary` button per the button-hierarchy spec.
- The prompt shows once. Reopening the app never re-shows it (guarded by `STATE.onboarding.seen`).
- No Parents → Profile section in 4A. If a kid enters the wrong name, the existing "Reset all progress" button also clears it. Good enough for launch.

## What kids see if they skip

Everywhere the copy would have said their name, it says *"amigo"* (warm, generic, works in both languages). Zero broken screens.

---

## Adoption-signal instrumentation (STILL local-only)

Add three tiny local counters so **when you review adoption yourself on the device**, you can see whether it's sticking. **No transmission.**

```js
STATE.adoption = {
  firstLaunchAt: "",      // ISO, set once
  totalLaunches: 0,       // ++ on each app foreground
  totalLessonsDone: 0,    // already tracked in trophy snapshot, don't duplicate
  lastLaunchAt: ""        // ISO
};
```

That's it — you can read these off the Parents dashboard or via console during your own usage checks. No analytics vendor, no ping, no server.

If you ever want *cross-installation* adoption data later, that's Phase 4B territory and needs the full consent conversation.

---

## Phase QA / exit check

- Fresh install: name prompt shows exactly once.
- Type "Ana", tap ¡Vamos!: `STATE.profile.childName === "Ana"`, celebration text says "¡Muy bien, Ana!".
- Skip button: `onboarding.seen = true`, `childName = ""`, celebration says "¡Muy bien, amigo!".
- Reload tab: prompt does not re-show, name persists.
- Existing progress on Kabir's device is untouched (his `childName` gets a default backfill from any pre-existing STATE, or shows the prompt once and he types "Kabir").
- `node --check` on all three HTML scripts.
- Three bundled iOS resources match root files.
- App Store privacy declaration stays **"Data Not Collected"**.
- Zero new network requests.
- `git diff --check`; commit as `Phase 4A: minimum-friction launch (child name only)`.
- Do NOT push to iPhone unless the user explicitly asks.

---

## Rollback

- Overlay behind `UX_FLAGS.nameOnboarding` (default true). URL rescue: `?nameOnboarding=0`.
- `git revert <phaseCommit>` cleanly removes everything.
- Existing `childName` in localStorage remains on rollback — no data loss.

---

## Change budget

| Item | Est. LOC |
|---|---|
| Data schema + `setChildName()` + `deviceId` init in `ensureExtraState` | ~20 |
| Name-only onboarding overlay | ~60 |
| Copy replacement (34 "Kabir" → `learnerName()`) | ~40 |
| Adoption counters | ~15 |
| **Total** | **~135 lines** |

Roughly **⅓ the size** of the earlier version of this phase, because we cut everything that wasn't needed for launch.

---

## When to reconsider Phase 4B

**Don't touch the backend question again until at least one of these is true:**

1. You have ≥ 100 organic installs and want to know who's using it.
2. A parent asks for an account they can log into on multiple devices.
3. A school asks for classroom rosters.
4. You want to run a real study of learning outcomes.

Until then, every hour spent on backend/auth/consent is an hour not spent on kids sticking with the app.

---

## Guardrails (project-wide, unchanged)

- No network requests introduced.
- All storage access guarded (`try/catch`).
- No changes to lesson/scoring/progress logic.
- Physical-iPhone install only on explicit user consent.
- Memory rule `spanish-app-local-only` continues to apply.
