# Popup + copy review · mobile-first pass

## 1 · Popup titles/subtext — before → after

| # | Where | Current | Suggested |
|---|---|---|---|
| 1 | Lesson header (`openDay`) | Title: **"Lesson 5"** · Sub: **"Regular -AR verbs"** | Title: **"Lesson 5"** · Sub: **"-AR verbs"** *(trim redundant word)* |
| 2 | Trophy queue | Title: **"New trophy earned!"** · Sub: trophy name | Title: **"Trophy!"** · Sub: trophy name |
| 3 | Trophy chain | Title: **"New trophy!"** · Sub: trophy name | Title: **"¡Trofeo!"** · Sub: trophy name |
| 4 | Revival coupon | Title: **"Revive-your-Garden Coupon"** · Sub: **"Because you were away for 3 days · one-time offer"** | Title: **"Grow it back 🌱"** · Sub: **"Finish 1 lesson in each level"** |
| 5 | Name onboarding | Title: **"¡Hola!"** · Sub: **"What should I call you?"** | Keep — already tight |
| 6 | Learned-verbs list | Title: **"Regular verbs learned"** · Sub: **"12 verbs so far — tap any to hear it!"** | Title: **"Regular verbs"** · Sub: **"12 learned · tap to hear"** |
| 7 | Surprise quiz | Title: **"Surprise quiz!"** · Sub: **"Every 4 completions unlocks a quick review · 20 learned verbs"** | Title: **"Quick review 🎁"** · Sub: **"20 verbs · 5 quick questions"** |
| 8 | Parent dashboard | Title: **"Parent dashboard"** · Sub: **"A quick coaching snapshot"** | Title: **"Parents"** · Sub: **"How it's going"** |
| 9 | Wi-Fi sync | Title: **"Wi-Fi Sync"** · Sub: **"Merge progress with the iPhone app"** | Title: **"Sync"** · Sub: **"Merge devices on your Wi-Fi"** |
| 10 | Trophies room | Title: **"Trophies"** · Sub: **"12 of 143 collected"** | Keep — good |
| 11 | Streak explainer | Title: **"Day streak"** · Sub: **"How it works"** | Keep — good |

**Rule I applied:** first line ≤ 20 chars, second line ≤ 40 chars. Emoji leads when it aids the mood.

## 2 · Layout patterns for popups on mobile (native-app feel)

Consistent frame — every overlay should follow it:

```
┌─────────────────────────────────┐
│ 🏠  Emoji  Title (18px bold)  ✕│  ← 56px header, sticky
│              Subtitle (13px)    │
├─────────────────────────────────┤
│                                 │
│         Body scrolls            │
│                                 │
├─────────────────────────────────┤
│      [ Primary ]  [ Ghost ]     │  ← sticky bottom, safe-area padded
└─────────────────────────────────┘
```

Concrete fixes to apply (small CSS pass):
- Cap popup width at 480px and center on tablets so it doesn't stretch edge-to-edge.
- Add `env(safe-area-inset-top)` to overlay header padding so it clears the notch.
- Move all buttons into `stage-bottom` sticky container so the thumb reach stays constant.
- Increase tap targets to min 44×44pt everywhere (some current pill chips are 34px tall).
- Add a soft slide-up transition (150ms) when overlay opens — feels more native than a flash.

## 3 · Level order — easy → hard for kids

Current order: **0 Fiesta · 1 Regular verbs · 2 Irregular · 3 Tenses · 4 La Casa**

Suggested reorder (cognitive load, not calendar order):

| New # | Level | Why here |
|---|---|---|
| 1 | Vocab Fiesta | Nouns + adjectives, easiest — no conjugation |
| 2 | La Casa | Also nouns, familiar objects, image-anchored |
| 3 | Regular verbs (-AR/-ER/-IR) | Predictable rules — the "learnable" first verb tier |
| 4 | Irregular verbs | Requires memorization on top of the pattern brain from L3 |
| 5 | Tenses (futuro cercano) | Combines a verb + pattern from L3–L4 |

**Note:** re-numbering the constant IDs would break saved progress. Better to add a `displayOrder` field per level and render in that order — internal IDs stay `0..4` for storage compatibility. Tiny change: 1 property + a `.sort()` in `renderLevels`.

## 4 · Engagement ideas for daily use (kids-first, no cloud, no cost)

Sorted by build effort:

**Tiny (< 1 hour each)**
1. **Daily coin.** First lesson of the calendar day earns a "coin of the day" 🪙. Purely cosmetic; adds up on the picker header. Kids love counters.
2. **"Word of the day."** On app open, one random already-learned word floats in with pronunciation. 3 seconds of Spanish before the picker.
3. **Streak-save token.** After 5 streak days, grant 1 "save" that auto-covers a missed day. Removes the punishment feeling.
4. **Level-up sting.** When a level's progress crosses 25/50/75/100%, brief tree-grow burst + a distinct sound.

**Small (1–3 hours each)**
5. **Character companion.** Pick a garden buddy 🐣🐢🦋 on first launch (extends name onboarding). Buddy cheers, waves, sleeps between sessions.
6. **Mini game every 5 lessons.** Word-tap race, flashcard flip, or drag-to-match — same words but zero new vocabulary, pure fluency reps.
7. **"Say it back."** After correct-answer for a new word, a 1-tap "🎤 Say it" that scores based on Web Speech recognition (already prototyped). Optional, celebratory only.
8. **Progress screenshot for parents.** "Send today's win 📸" — makes a shareable card. No cloud; uses Web Share API to hand off to Messages.

**Bigger (half-day each)**
9. **Skill tree view.** Alternate to the picker: nodes chained visually so kids see the path. Great screenshot moment for parents.
10. **Story mode.** 3–5 lessons chained into a short paragraph story kids re-read at the end ("Un día en la escuela"). Anchors vocab in narrative.
11. **Family mode toggle.** Multiple named avatars on one device (siblings). Zero backend — just an array under STATE.

**Do NOT build for launch**
- Push notifications (needs UNUserNotificationCenter + parental consent copy).
- Any leaderboard / competitive score.
- Content-generated-by-AI screens.
- Timed quizzes for young kids — pressure hurts more than it helps.

## 5 · Next concrete implementation slice I recommend

If you say go, I'll ship this as one commit ("Popup + copy polish"):

- All 11 title/sub trims from §1
- 480px max-width + safe-area top padding + 150ms slide-up transition
- Sticky bottom-button frame applied everywhere
- Word-of-the-day (tiny) + Coin-of-the-day (tiny)

Not in that slice unless you also want it: level reorder, character companion, skill-tree view.
