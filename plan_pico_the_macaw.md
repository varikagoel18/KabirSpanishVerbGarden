# Plan · Pico the Macaw (fresh app, Education Universe · World 1)

**Status:** planning-only. **No code changes to Kabir's Verb Garden until this plan is fully detailed.** When ready, we'll create a fresh app scaffold and *selectively* port pieces from Verb Garden — not modify Verb Garden in place.

**Anchored in:**
- `Education_Universe_Master_Context_v1.docx` — the north-star vision
- `design_education_universe_world1.md` — the exploratory design that seeded this plan
- Family-project constraints saved in memory ([local-only data](../../.claude/projects/-Users-ashish-Library-CloudStorage-GoogleDrive-agoyal03-gmail-com-My-Drive/memory/feedback-spanish-app-local-only.md), [discuss before code](../../.claude/projects/-Users-ashish-Library-CloudStorage-GoogleDrive-agoyal03-gmail-com-My-Drive/memory/feedback-spanish-app-discuss-before-code.md), [commit authors](../../.claude/projects/-Users-ashish-Library-CloudStorage-GoogleDrive-agoyal03-gmail-com-My-Drive/memory/feedback-spanish-app-commit-authors.md))

---

## 0 · Ground rules

1. **Kabir's Verb Garden stays frozen.** No structural rewrites, no rename, no in-place migration. Verb Garden continues to be the "beta / personal" build. Pico the Macaw is a separate product that will grow into the public launch.
2. **Plan first, port second.** Every piece we take from Verb Garden gets copied deliberately, once we know exactly what shape it needs in Pico's World.
3. **Local-only data.** Same rule as Verb Garden — nothing leaves the device. No accounts, no cloud, no analytics vendor. See [Spanish app: local-only](../../.claude/projects/-Users-ashish-Library-CloudStorage-GoogleDrive-agoyal03-gmail-com-My-Drive/memory/feedback-spanish-app-local-only.md).
4. **No code until explicitly requested.** Discussion turns produce docs, not code. See [discuss before code](../../.claude/projects/-Users-ashish-Library-CloudStorage-GoogleDrive-agoyal03-gmail-com-My-Drive/memory/feedback-spanish-app-discuss-before-code.md).
5. **All commits use Varika + Kabir as `Co-Authored-By`.** See [commit authors](../../.claude/projects/-Users-ashish-Library-CloudStorage-GoogleDrive-agoyal03-gmail-com-My-Drive/memory/feedback-spanish-app-commit-authors.md).

---

## 1 · Product identity — locked

| Field | Value | Notes |
|---|---|---|
| **App name** | **Pico the Macaw** | Warm, kid-parseable, zero App Store name collision |
| **Tagline** | *Learn a language. Grow a living world.* | Working; can iterate |
| **Bundle ID** | `com.picothemacaw.app` (or `com.picomacaw.app` fallback) | Immutable once shipped — get right the first time |
| **Architecture** | **One app, many subjects** | Same profile, mascot, world, bond, achievements carry across every future subject |
| **First subject inside** | Spanish | Others (Math, English, Science, …) added later as content packs, not new App Store listings |
| **Category** | Education (primary) · Games/Family (secondary) | |
| **Age rating** | 4+ | |

**What "Pico the Macaw" is *not*:**
- Not renamed Verb Garden. Different app record, different bundle ID, different codebase (though borrowing lesson content).
- Not a per-subject brand (there is no "Pico the Macaw: Spanish" — Spanish is one adventure *inside* Pico the Macaw).

**Kabir attribution:**
- App is no longer named after him publicly.
- Inside the app: his name lives on the child profile, and we ship a subtle "Made with Kabir" credit visible on first launch. Specifics of *how we tell Kabir* deferred to a family conversation.

---

## 2 · Domains — to purchase

**Must-grab (~$50/yr):**
- `picothemacaw.com` — landing page, marketing, business card
- `picothemacaw.app` — Apple-native TLD, enables Universal Links
- `picomacaw.com` — defensive against short-branding squatters

**Nice-to-have (~$40/yr):**
- `picothemacaw.world` — thematic (Book of Living Worlds); good for future story/map subdomain
- `picothemacaw.kids` — kid-safe TLD, parent-trust signal

**Skip for now:** .io / .co / .org / .family / .dev / bookoflivingworlds.com — grab only if a specific plan needs them.

**Registrar:** Cloudflare Registrar or Porkbun (wholesale pricing, clean DNS, auto-TLS for .app).

---

## 3 · Pico — character bible v0

| Field | Value |
|---|---|
| **Species** | Scarlet Macaw · **fixed universe-wide** — no color / species customization |
| **Name** | *Pico* · **fixed universe-wide** — child cannot rename |
| **Voice / tone** | Warm, curious, playful, cares about the forest · **fixed universe-wide** |
| **Role** | Friend on the same journey. **Not** a teacher. Never scolds. Never says "wrong." |
| **Speech pattern** | Short sentences (7-year-old readable). Uses *nosotros* ("let's plant this together"). Sprinkles one Spanish word per English sentence when appropriate. Curious first, celebratory second, comforting third. |

**Emotional states (5 sprites, reused everywhere):**
1. **Curious** — default (head tilted, feathers puffed)
2. **Cheering** — correct answer, lesson complete
3. **Thinking** — while kid types/chooses
4. **Comforting** — wrong answer
5. **Sleepy** — after 8pm local time

**v1 art constraint:** 5 emoji-scale SVG sprites embedded in HTML. Full illustrated character bible (~$500–2000 with a kid-lit illustrator) is a **v2 investment**, budgeted when we hit ~100 families.

**Cross-product intent:** Pico *will* appear outside the app someday — coloring pages, plush, YouTube, social. This is why the name/species/colors are fixed.

---

## 4 · Bond — the personal layer

Shared Pico, personal bond. Each child has:

- **Bond level 1–5**, visible only in Parents view (*"Pico has bonded with Kabir at level 3"*)
- **Pico uses the child's real name** in dialogue
- **Auto-picked nickname** for the child, sourced from Spanish vocabulary the child has *actually mastered*
- **Weekly private "Pico moment"** referencing something the child actually did

### Bond pacing — locked
**Medium** — Level 5 by ~8 weeks of active use. Slow enough to feel earned, fast enough that most kids see the top tier within one school term.

| Level | Approx. time | Unlock |
|---|---|---|
| 1 | Day 1 | Pico knows your name |
| 2 | ~week 2 | Pico can suggest a kindness mission |
| 3 | ~week 4 | Pico picks a warm nickname for you |
| 4 | ~week 6 | Pico shares an eco-fact he learned |
| 5 | ~week 8 | Pico shares a personal story from his home |

### Nickname mechanics — locked
**Auto-picked from mastered vocab**, with two guardrails:

- **Whitelist pool** of ~40 pre-vetted Spanish adjectives/nouns (*rojo, valiente, curioso, pequeño, estrella, luna, tigre, colibrí, …*). Words like *baño, hospital, calcetín* filtered out even if learned.
- **Refresh rule:** nickname re-picks every 2–3 weeks from newly-eligible mastered words. Pico announces the change (*"Now I want to call you pequeña estrella"*). Old nicknames retire into Parents view as memories.

### Multi-child on one device — deferred to v1.2+
v1 is one device, one Pico, one profile. Sibling separation via profile switcher deferred until real-world demand.

---

## 5 · The Book of Living Worlds — chapter structure

**One book. Ten chapters. Each a real ecosystem.**

| # | Chapter | Spanish name (on map) | What restores as the child learns |
|---|---|---|---|
| 1 | Home Tree | *El Árbol Hogar* | A single Ceiba, one leaf per verb learned |
| 2 | Rainforest Canopy | *La Selva* | Butterflies + more birds arrive |
| 3 | River | *El Río* | Cloudy water clears, fish return |
| 4 | Cloud Forest | *El Bosque Nuboso* | Fog lifts, orchids bloom |
| 5 | Andes | *Los Andes* | Snow line grows as tenses are mastered |
| 6 | Mangroves | *Los Manglares* | Roots + herons appear |
| 7 | Coral Reef | *El Arrecife* | Reef re-colors grey → full palette |
| 8 | Desert | *El Desierto* | Cacti bloom |
| 9 | Iberian Meadows | *España* | Wildflowers + a Iberian lynx sighting |
| 10 | Living Planet | *El Planeta Vivo* | Zoom-out — child sees the whole map they restored |

**Chapter boundaries are vocab-count based, not lesson-count based** — the story respects however the child learns.

### Chapter reveal — locked
**Silhouetted world map, ecosystem-shaped silhouettes.**

- Child sees a world map from day one, with all 10 chapters as **grey silhouettes** shaped like their ecosystem (mountain for Andes, wavy lines for Reef, coiled root for Mangroves, etc.)
- Restored chapters show their name (bilingual · *Spanish · English*) and color
- Unrestored chapters read as `???` or a fog-covered outline
- **Parents see chapter names** on their own version of the map — for guidance
- **Kids see silhouettes only** — for anticipation-without-spoilers

### Cross-subject reuse — future-proofing
Chapters are geography-shaped, **not subject-shaped**. Future Math or Science lessons wake up the **same** Rainforest. This is what makes it feel like one universe rather than multiple apps sharing a mascot.

---

## 6 · Rewards — life, not points

Coins / gems / star counters are **retired as primary progress**. Stars remain internal quality signals only (small subtle display).

Every action falls into exactly one reward, and every reward is *a living thing appearing*:

| Action | Reward |
|---|---|
| Learn a new word | 🌱 seed sprouts in current chapter |
| 3★ a lesson | 🌸 flower blooms |
| 3★ a chapter's final quiz | 🦋 butterfly hatches |
| Finish a chapter | 🌳 tree matures; new species arrives; short cutscene |
| First lesson of the day | 💧 fresh rain across the chapter |
| Sync devices | ☀️ sunlight (visual only — acknowledges parent's care) |
| Report a bug | 🌿 a small "you helped Pico grow this app" moment |

**No numbers going up. No hoarded counts.** Totals available in Parents view. Child's view is a living scene.

---

## 7 · Language adaptation — Pico speaks

**Adaptive by kid's level — locked.**

- Pico narrates in **English by default**, always includes the Spanish word for anything nameable
- Once a Spanish word has been correctly answered **5+ times** in lessons, Pico **drops the English gloss** for that word
- Pico occasionally speaks a **full Spanish sentence** using only words the child has mastered
- No word the child hasn't learned is ever presented in Spanish without English

**Sub-rules:**
- **Map / signage:** bilingual side-by-side (*Bosque Nuboso · Cloud Forest*) — the map is a mental model, needs to feel intentional
- **UI buttons:** English only (*"Start today's quest"*, *"Next lesson"*) — zero comprehension risk, UI shouldn't be a language lesson
- **Every Spanish sentence Pico speaks:** tappable 🔊 for read-aloud (reuses existing `speak()`)

**What this creates emotionally:** the child sees Pico "graduate" a word from bilingual → Spanish-only. That IS the reward loop — a much better one than confetti.

---

## 8 · Delight loop — discovery & surprise

None of these unlock content. They just make the world feel alive.

- **Hidden animals** — every ~7th lesson, 1-in-3 chance of a wildlife visitor (jaguar walks through, quetzal lands). Cosmetic surprise.
- **Random discoveries** — kid taps a random spot in the scene, sometimes something bloomed overnight
- **Kindness missions** — soft banner ~once a week
- **Eco facts** — after chapter completion, one *did you know?* card under 20 words
- **Seasonal events** — Día de Muertos marigolds (Nov 1), farolitos (Dec), Carnaval butterfly flock (Feb), etc.
- **Festivals lens** — every Spanish-speaking country's holidays briefly

### Kindness missions — locked
**10 hand-written for v1, in-app only, schema flexible to grow to 30 later.**

**Author constraint (bakes consistency into content):**
> 1 sentence of setup + 1 concrete Spanish action (3 reps max) + 1 sentence of warm payoff.

**Two example missions:**
1. *"A little jaguar cub is lost in the Rainforest. Ask Pico for the word for* mother *(*madre*). Say it 3 times — Pico will call her home."*
2. *"The birds have no color today because they forgot their words. Say* rojo, azul, verde *— one for each bird."*

**External-world missions ("hug someone in Spanish today")** — deferred until we see how in-app missions land with parents. Not v1.

---

## 9 · Parent Promise view — reframed

Current Verb Garden dashboard shows lessons/stars/session-minutes. New view balances Learning + Character + Cultural exposure. Answers Master Context's *"is my kid becoming curious / kind / capable?"*

```
Parents · How <name> is growing

Learning
  23 verbs · 4 chapters restored
  Streak: 7 days (paused Wednesday)

Character
  🌍 Explored 3 cultures
  💛 Helped 5 kindness missions
  🔎 Asked 12 curious questions (words tapped for pronunciation)
  🦜 Bonded with Pico — level 2

Cultural exposure
  Mexico · Peru · Spain

This week's win
  "Finished the Rainforest chapter — every bird now has a name."

[ Print week summary ]
```

**Deliberately absent:** raw quiz percentages, comparative rankings, session-time-as-goal, streak-shame framing.

---

## 10 · Storage schema (all local, all subject-agnostic where possible)

```js
STATE.universe = {
  version: 1,
  mascot:      {name:"Pico", species:"scarletMacaw", bondLevel:1, bondXP:0},
  book: {
    currentChapter: 1,               // 1..10
    chapterProgress: {               // per chapter
      "1": {seeds:0, flowers:0, butterflies:0, trees:0,
            wildlifeSeen:[], factSeen:[], events:[]},
      // ...
    },
  },
  child: {
    displayName: "Kabir",            // what Pico calls them (from onboarding)
    nickname:    "",                  // auto-picked from mastered vocab
    nicknameHistory: [],              // retired nicknames — Parents view "memories"
  },
  discoveries: [],                    // hidden animals encountered
  kindness:    { missionsDone:0, log:[] },
  curiosity:   { wordsTapped:0, factsRead:0 },
  cultures:    { visited:[] },        // ISO country codes
  trophies:    {},                    // moved from per-subject to universe-level
};

STATE.spanish = {
  // Verb Garden's existing per-subject state moves under here, unchanged shape
  levels: {...}, streak: 0, verbStats: {...}, ...
};

// Future subjects: STATE.math = {...}, STATE.english = {...}, etc.
```

**Migration from Verb Garden:** on first launch of Pico the Macaw, if we detect an exported Verb Garden state (via manual paste-restore — no auto-detection since it's a different app), we compute `book.currentChapter` and `chapterProgress` from completed lessons, so Kabir's transition feels continuous.

---

## 11 · What to port from Verb Garden (and what to build fresh)

Explicitly deciding piece by piece so we don't accidentally copy things that don't fit.

**Port as-is:**
- All Spanish lesson content: verbs, vocab, fills, HW quizzes, tense lessons, La Casa vocab
- Renderer functions: `renderIntro`, `renderQuiz`, `renderTF`, `renderConj`, `renderFill`, `renderHWQuiz`, `renderTenseQuiz` — proven and durable
- Mid-lesson resume machinery (`saveResume` / `readResume` / `cur._startAt`)
- IndexedDB + localStorage persistence layer (lsSet, idbSet, `_compactState`, `syncStoreSet`)
- Wi-Fi sync server (SyncServer.swift) + ProgressPersistenceBridge
- Speech recognition bridge (`window.KABIR_NATIVE_CAPABILITIES` → renamed `PICO_NATIVE_CAPABILITIES`)
- `stageBottom()` sticky action pattern, safe-area handling, prefers-reduced-motion respect

**Port with rework:**
- Level picker → becomes the world map + chapter view + subject picker (Spanish is one card for now)
- Bloom screen → life-reward animation (seed / flower / butterfly / tree) instead of star-count
- Trophy system → moved under `STATE.universe.trophies`, tagged with `subject:"spanish"`
- Overlay system → keep, but re-skin per new visual system
- Copy / titles → all Pico-voiced, adaptive-language rules applied

**Build fresh:**
- Pico character sprites (5 SVGs) + rendering rules
- World map with silhouetted chapters + ecosystem shapes
- Chapter scene renderer (the "living scene" for each chapter)
- Bond level engine + weekly Pico moment scheduler
- Kindness missions engine (author 10, publish weekly)
- Adaptive language layer (`shouldTranslate(word)` based on mastery count)
- Nickname auto-pick + refresh engine + whitelist pool
- Reframed Parents view (Learning + Character + Cultural exposure)
- New landing screen ("Hi Kabir! Pico is waiting at the Home Tree")
- Seasonal event scheduler
- Discovery / hidden-animal engine

**Do NOT port:**
- "Verb Garden" copy anywhere
- Tree/sapling icon system as the primary reward vocabulary (it's still there conceptually inside the chapter scenes, but not the top-level metaphor)
- "Kabir" hardcoded strings (already migrated in Verb Garden — port the `learnerName()` pattern, not any leftover names)
- Any references to Verb Garden trophies numbered against the old system

---

## 12 · Delivery phases

| Phase | Scope | Effort |
|---|---|---|
| **P0 · Scaffold** | New repo (or subfolder), new bundle ID, new App Icon draft, empty HTML shell with the Pico visual language | ~3h |
| **P1 · Meet Pico** | 5 Pico sprites, name onboarding as a Pico greeting, `STATE.universe` schema | ~4h |
| **P2 · Port Spanish content** | All Verb Garden lesson data + renderers ported under `STATE.spanish` | ~6h |
| **P3 · World map + chapters** | Silhouetted map, chapter shapes, bilingual signage, restoration bar | ~5h |
| **P4 · Life-based rewards** | Bloom screen replaced with seed/flower/butterfly/tree, per-chapter scene | ~5h |
| **P5 · Adaptive language layer** | Word-mastery tracking, English-gloss dropping, tappable 🔊 on Spanish sentences | ~3h |
| **P6 · Bond + nickname engine** | Level 1–5, XP thresholds, nickname whitelist, refresh scheduler | ~3h |
| **P7 · Kindness missions v1** | Engine + 10 hand-written missions + weekly rotation | ~3h |
| **P8 · Discovery loop** | Hidden animals, random discoveries, first eco-fact, seasonal event scaffold | ~4h |
| **P9 · Parent Promise view** | New Parents dashboard organizing Learning / Character / Cultural exposure | ~3h |
| **P10 · Migration from Verb Garden** | Paste-in restore that computes `book.currentChapter` from Verb Garden state | ~2h |
| **P11 · Polish + App Store prep** | Self-host fonts, launch screen, privacy declaration ("Data Not Collected"), screenshots, description, keywords | ~5h |

**Total:** ~46 hours of focused work.

**Suggested slicing:** P0 + P1 + P2 alone (~13h) delivers a "Pico opens the app, greets you, and hands you a Spanish lesson identical to Verb Garden" milestone. That's a real product on day 1. Everything else layers on.

---

## 13 · What we deliberately do NOT build for v1

- No 3D world map. Ecosystems are emoji + CSS scenes.
- No character voice acting. Pico speaks in text; TTS reuses `speak()`.
- No cutscenes longer than 3 seconds.
- No cross-device shared state (local-only continues). No accounts.
- No unlocking of content via non-learning actions.
- No time pressure of any kind.
- No push notifications (App Store friction + Master Context is "growth over pressure").
- No leaderboards, no competitive score.
- No custom Pico (no rename, no recolor, no re-species).
- No external-world kindness missions.
- No profile switcher / sibling separation.
- No AI-generated content.
- No timed quizzes.

---

## 14 · Success signals we watch post-launch

Qualitative, not KPI-driven.

- Does a kid greet Pico unprompted?
- Does a parent describe the app using the words *nature* or *kind*?
- Does the kid choose to explore the Book before starting a lesson?
- Does the kid come back tomorrow for a reason **other than** streak preservation?
- Does the parent notice a Spanish word being used in real life?

Two "yes" out of five = reframe is working. Zero out of five after 4 weeks = we're missing something and revisit.

---

## 15 · Immediate next steps (before any code is written)

1. **Grab the three must-have domains** (picothemacaw.com, .app, picomacaw.com) — ~$50/yr, blocks squatters
2. **Decide "when do we tell Kabir"** — family conversation; app credit design ("Made with Kabir") can be sketched separately
3. **Author 10 kindness missions** — a weekend of writing to the shape constraint in §8; can happen before any code
4. **Sketch the 5 Pico sprites** — either commissioned quick or hand-drawn placeholder; needed before P1
5. **Decide the scaffolding location** — new repo (`picothemacaw`), sibling folder to Verb Garden, or subfolder? Recommend **new repo** so Verb Garden's git history stays clean and Pico the Macaw starts fresh
6. **Decide when to start P0** — after domain + Pico art placeholders exist, we're unblocked

---

## 16 · Open questions still to close

Held for later discussion — none block this plan:

1. **Kabir conversation** — how and when to tell him the app has a new name. Family-side decision, not a product decision.
2. **App Store submission timing** — do we launch on the Pico the Macaw scaffold, or ship Verb Garden first (with Kabir-specific branding) as a limited "personal beta" while Pico the Macaw is built? Latter is what Master Context implies but adds an extra App Store cycle.
3. **Bond level pacing tuning** — the 8-week target is a guess. Real usage will show if it's too slow/fast.
4. **Content pack format** — when we add Math later, do subjects load from a JSON manifest bundled in the app, or from a folder of separate JS modules? Solve at P6/P11.
5. **Illustrated Pico timing** — when do we invest the $500–2000 in a real illustrator? Recommend: after 100 organic families.

---

## 17 · Cross-reference

- Vision source: `Education_Universe_Master_Context_v1.docx` (in `~/Downloads/`)
- Earlier design exploration: [design_education_universe_world1.md](design_education_universe_world1.md)
- App Store launch plan (Verb Garden context): [plan_launch.md](plan_launch.md)
- Improvement plan (Verb Garden context): [plan_improvement1.md](plan_improvement1.md)
- Popup / copy review (Verb Garden context): [popup_review.md](popup_review.md)
- Bug report feature plan (portable to Pico): [plan_bug_report.md](plan_bug_report.md)
- Mobile UX phase notes (patterns to port): [phase_mobile.md](phase_mobile.md)
