# Design · World 1 of the Education Universe

**Anchored in:** *Education_Universe_Master_Context_v1.docx* — Pico the Scarlet Macaw, Book of Living Worlds, ecosystems restored through learning, life-based rewards, one persistent universe across subjects. This document translates that vision into a concrete design for the **current Spanish app** so it becomes the first world children ever enter.

**Non-negotiables carried over from Master Context:**
- Not an app — a universe. Same profile, mascot, world, achievements survive across every future subject.
- No coins, no gems, no leaderboards. Rewards are life: seeds → leaves → flowers → butterflies → trees → wildlife → clean rivers.
- Hope over fear. Wonder over guilt. Growth over competition.
- Free. Local-only. No addiction mechanics. No manipulative streaks.

**Non-negotiables from the current build (do not break):**
- Data stays on device (see [feedback-spanish-app-local-only](../feedback-spanish-app-local-only.md)).
- Kabir's existing progress migrates without loss.
- No rebuild/install unless explicitly asked.
- App Store review can happen on this same codebase.

---

## 1 · The reframe in one screen

**Today:** *Jardín español · a Spanish learning app for kids*
**After:** *The Book of Living Worlds · Pico's Home Tree · Spanish*

Same underlying lessons. Same durations. Same trophies underneath. What changes is the **frame** the child sees every time they open the app.

```
┌───────────────────────────────────────┐
│  🦜  Hi Kabir!                        │
│      Pico is waiting at the Home Tree │
│                                       │
│  📖  Book of Living Worlds            │
│      Chapter 1 · Home Tree            │
│      🌱🌱🌱🌱🌸🌸🌸🌳       ← restoration bar │
│                                       │
│  Today's quest:                        │
│  "Help Pico teach 3 new colors to     │
│   the parrots in the canopy."          │
│                                       │
│  [ Start today's quest ▶ ]            │
│                                       │
│  ─── Explore ─────────────────────    │
│  🎉 Vocab Fiesta   ●●●●●○○           │
│  🏠 La Casa        ●●○○○              │
│  🌷 Regular Verbs  ●○○○○              │
│  ⚡ Irregular      ○○○○○              │
│  ⏭  Tenses         ○○○○○              │
└───────────────────────────────────────┘
```

The picker doesn't disappear — it becomes the "Explore" section beneath a single daily quest that Pico narrates.

---

## 2 · Pico — the character bible v0

**Species:** young Scarlet Macaw. Not a teacher. A **friend on the same journey**.

**Voice rules:**
- Never scolds. Never says "wrong." Says "let's try together" or "close — hear it again."
- Speaks in short sentences a 7-year-old can read.
- Uses *nosotros*, not *tú*, when suggesting things ("Let's plant this word together").
- Mixes one Spanish word into every English sentence (`¡Mira!` `¡Vamos!` `¡Increíble!`) so Spanish feels ambient.
- Curious first, celebratory second, comforting third — in that order.

**Emotional states** (5 total — one sprite each, reused everywhere):
1. **Curious** — head tilted, feathers puffed slightly. Default.
2. **Cheering** — wings up, feathers spread. Fires on correct answer / lesson done.
3. **Thinking** — beak resting on foot. Fires while kid is typing / choosing.
4. **Comforting** — one wing extended toward the kid. Fires on wrong answer.
5. **Sleepy** — eyes closed, head tucked. Fires if app opened after 8pm local time.

**Art constraint for v1:** we can't afford full character animation. Use 5 emoji-scale SVG sprites embedded in the HTML. Everything else is text + subtle CSS transforms. Full illustration is a v2 investment.

**Storage:** `STATE.universe.mascot = {name:"Pico", species:"scarletMacaw"}` — future-proofs for kids who name their own mascot in later versions.

---

## 3 · The Book of Living Worlds — structure

**One book. Many chapters. Each chapter is an ecosystem.**

| # | Chapter | What restores when the child learns |
|---|---|---|
| 1 | **Home Tree** | A single Ceiba tree in a bare clearing, one leaf per verb learned |
| 2 | **Rainforest canopy** | Butterflies + more birds arrive as vocabulary grows |
| 3 | **River** | Cloudy water clears; fish return |
| 4 | **Cloud Forest** | Fog lifts; orchids bloom |
| 5 | **Andes** | Snow line shows as tenses are mastered |
| 6 | **Mangroves** | Roots + herons appear as verbs conjugate correctly |
| 7 | **Coral Reef** | Reef re-colors from grey to full palette |
| 8 | **Desert** | Cacti bloom |
| 9 | **Spain (Iberian meadows)** | Wildflowers + a Iberian lynx sighting |
| 10 | **Living Planet** | Everything zooms out — the child sees the whole map they restored |

**Mapping to today's lessons (no data migration needed):**
- Chapter 1 (Home Tree) = the current Vocab Fiesta lessons 1–15 approx
- Chapter 2 (Rainforest) = the rest of Vocab Fiesta + first Regular Verb lessons
- Chapter 3 (River) = mid Regular Verbs
- …
- The chapter boundary is a fixed vocab count, not a fixed lesson count, so the story respects however the child learns.

**What the child sees on the picker header:**
```
📖 Chapter 2 · Rainforest canopy      🦜
   ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░  63%
   3 more words wake the toucans up
```

**What the child sees at bloom time** (replaces the current "You grew a sapling"):
```
    🌿🦋🌿
   You woke up 4 butterflies!
   They're helping Pico teach
   these words to the canopy.
   ¡Muy bien, Kabir!
```

---

## 4 · Rewards — from stars to life

**Retire (visually):** coins, gems, star counters as primary progress. **Keep** stars as an internal quality signal only; display them as "how deeply Pico understood you" in a small subtle place.

**New reward taxonomy** (all local; every action falls into exactly one):

| Action | Reward |
|---|---|
| Learn a new word | 🌱 a seed sprouts in the current chapter |
| 3★ a lesson | 🌸 a flower blooms |
| 3★ a chapter's final quiz | 🦋 a butterfly hatches |
| Finish a chapter | 🌳 a tree matures; new species arrives; short cutscene |
| First lesson of the day | 💧 fresh rain across the chapter |
| Sync devices | ☀️ sunlight (visual only — recognizes the parent's care) |
| Report a bug | 🌿 a small "you helped Pico grow this app" acknowledgement |

**Rule:** every reward is a *living thing appearing*. No numbers going up. No hoarded counts. If the child wants to see totals, Parents view shows them; the child's view shows a **living scene**.

---

## 5 · Surprise & discovery — the delight loop

Woven throughout, not scheduled:

- **Hidden animals.** Every ~7th lesson has a 1-in-3 chance of a wildlife visitor (jaguar walks through, quetzal lands on the tree). Pure cosmetic surprise; not tracked as an achievement.
- **Random discoveries.** Kid taps a random spot in the scene — sometimes something bloomed there overnight.
- **Kindness mini-missions.** Once per week: "Someone in the Rainforest is thirsty. Say *agua* to Pico three times." Fires as a soft banner, never blocks lessons.
- **Eco facts.** After chapter completion, a *did you know?* card ("Real ceiba trees can live 500 years"). Under 20 words. No exam on it.
- **Seasonal events.** Around November 1st, marigolds bloom for Día de Muertos with a short Spanish greeting. December: farolitos. February: a Carnaval butterfly flock.
- **Festivals lens.** Every real Spanish-speaking country's holiday shows briefly.

**Design rule:** none of these unlock more content. They just make the world feel alive.

---

## 6 · Parent Promise view — reframed

Current Parents dashboard shows lessons/stars/session-minutes. New view balances **learning progress** with **character milestones**.

```
┌──────────────────────────────────────┐
│  Parents · How Kabir is growing      │
├──────────────────────────────────────┤
│  Learning                              │
│    23 verbs · 4 chapters restored     │
│    Streak: 7 days (paused Wednesday)  │
│                                        │
│  Character                             │
│    🌍 Explored 3 cultures              │
│    💛 Helped 5 kindness missions       │
│    🔎 Asked 12 curious questions       │
│      (words tapped for pronunciation)  │
│    🦜 Bonded with Pico — level 2       │
│                                        │
│  Cultural exposure                     │
│    Mexico · Peru · Spain               │
│                                        │
│  This week's win                       │
│    "Finished the Rainforest chapter   │
│     — every bird now has a name."     │
│                                        │
│  [ Print week summary ]                │
└──────────────────────────────────────┘
```

**Key idea:** every metric answers *"is my kid becoming curious / kind / capable?"* — matches Master Context's parent promise. Nothing shows raw quiz percentages or comparative rankings.

---

## 7 · Storage schema addition (local-only)

Adds to existing `STATE`, does not rename anything old:

```js
STATE.universe = {
  version: 1,
  mascot: {name:"Pico", species:"scarletMacaw", bondLevel:1},
  book: {
    currentChapter: 1,               // 1..10
    chapterProgress: {               // per chapter, tracks life placed
      "1": {seeds:0, flowers:0, butterflies:0, trees:0,
            wildlifeSeen:[], factSeen:[], events:[]},
      // ...
    },
  },
  discoveries: [],                    // hidden animals encountered
  kindness:    { missionsDone:0, log:[] },
  curiosity:   { wordsTapped:0, factsRead:0 },
  cultures:    { visited:[] },        // ISO country codes
};
```

Backwards compat: on first load with the reframe, we **compute** initial `book.currentChapter` and `chapterProgress` from existing `STATE.levels` completions. Kabir opens the app and it looks like he was always exploring the Book of Living Worlds.

`deviceId` and `profile` from the current build carry over unchanged — the mascot / book are additive.

---

## 8 · Preparing for the multi-subject universe

Choices we make now that pay off when Math / Science / etc. arrive:

- **`STATE.universe`** is subject-agnostic. Spanish adds `STATE.spanish.*`; future Math adds `STATE.math.*`; the mascot, chapters, discoveries, kindness log are shared.
- **Chapters** are geography-shaped, not subject-shaped. Math lessons in the future *also* wake the Rainforest — a math problem restores as much of the same forest as a Spanish one. This is the whole point of "one universe."
- **Trophies** move under `STATE.universe.trophies`. Spanish-specific ones tag `{subject:"spanish"}`.
- **Content packs** — every subject ships as a JSON pack loaded from the same HTML. The reframe scaffolds that boundary now, so adding English or Math is a data-shape change, not a rewrite.

---

## 9 · What we do NOT build in this reframe

Ruthlessly kept out of scope so it's shippable:

- No 3D world map. Ecosystems are stylized scenes made from emoji + CSS.
- No character voice acting. Pico speaks in text; TTS is the existing `speak()`.
- No cutscenes longer than 3 seconds.
- No cross-device shared state (still local-only). No accounts.
- No unlocking of content via non-learning actions (kindness missions don't unlock lessons).
- No time pressure of any kind. Ever.
- No push notifications. (App Store friction, and Master Context is "growth over pressure".)

---

## 10 · Phased delivery

| Phase | Scope | Effort |
|---|---|---|
| **U1 · Meet Pico** | Add mascot sprite, name onboarding routed through Pico's greeting, `STATE.universe` schema, migration of existing progress into `book.currentChapter` | ~3h |
| **U2 · Living rewards** | Replace the coin/star-only bloom with life-based visuals (seed / flower / butterfly / tree). Keep stars internal. | ~4h |
| **U3 · Book chapters** | Picker header shows Chapter N + restoration bar + "today's quest." Explore section beneath. | ~3h |
| **U4 · Discovery loop** | Hidden animals, random discoveries, first eco-fact, seasonal event scaffolding. | ~4h |
| **U5 · Parent promise** | New Parents view organizing metrics into Learning / Character / Cultural exposure. | ~2h |
| **U6 · Universe seams** | `STATE.universe` moved to top-level, subject-agnostic; trophies re-anchored; content-pack scaffold for next subject. | ~3h |

**Total:** ~19 hours of focused work. Optional to ship pre-launch — U1 + U2 alone (~7h) already delivers the emotional reframe.

---

## 11 · Success signals we should watch for post-launch

Non-quantitative — we're not building for KPIs. These are qualitative signals:

- Does a kid **greet Pico** unprompted when they open the app?
- Does a parent describe the app to a friend using the words *"nature"* or *"kind"*?
- Does the kid **choose to explore** the Book (Chapter view) before starting a lesson?
- Does the kid come back the next day for a reason **other than** streak preservation?
- Does the parent notice a **word from Spanish being used in real life**?

If yes to any two, the reframe is working. If no to all after 4 weeks, we're missing something and we revisit.

---

## 12 · Open questions

1. **Pico or "Pico ⋅ Kabir's macaw"?** Do we let the child rename Pico, or is Pico a shared universe character across all users (like Duo)? Master Context implies shared identity — recommend **shared name, personal bond level**.
2. **Chapter reveal** — do we show all 10 chapter names upfront (map view) or reveal them as the child restores them? Recommend **reveal, with silhouettes visible** so anticipation exists.
3. **Kindness missions authoring** — hand-write ~30 for v1, or leave the feature dormant and add later? Recommend **~10 hand-written, rotate weekly**.
4. **Story tone in Spanish or English?** Pico speaks English with Spanish sprinkled — but should chapter names be Spanish (*El Bosque Nuboso*) or English (*Cloud Forest*)? Recommend **both — Spanish primary, English translation on hover/second line**.
5. **Where does the current "Kabir Spanish Verb Garden" name land?** Master Context implies it becomes something like *"Pico's Book of Living Worlds — Spanish"*. Renaming needs App Store consideration.

Say the word on any of these and I'll start converting this into build tickets.
