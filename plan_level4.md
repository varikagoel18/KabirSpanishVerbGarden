# Level 4 Plan: La Casa Vocabulary

> **Review status:** all open issues from the first pass are now resolved below (see "Decisions" callouts inline). Ready to implement.

## Goal

Create a new level based on the PDF vocabulary for **Las Partes de la Casa**.

Level name:

**Level 4 · La Casa**

Level focus:

Rooms, house areas, house parts, furniture, and common objects.

## Vocabulary Scope

> **Decision — compound entries:** every slash-labelled entry (`la habitación / el dormitorio`, `la sala / el salón`) is **one item**. The primary Spanish form is used for display; the alternate is stored in an `accepted:[…]` array so typed-answer activities recognize both.
>
> **Decision — `belongsIn` tags on furniture:** every furniture / object item carries a `belongsIn:[…]` array listing which rooms it belongs to. Powers the "Which item belongs in the X?" activity. Ambiguous items like `la lámpara` get multiple rooms.
>
> **Total item count after de-duping compounds:** 16 rooms + 6 house parts + 10 furniture = **32 items**.

### Habitaciones / Areas

- `la casa` - house
- `la habitación / el dormitorio` - bedroom
- `la sala / el salón` - living room
- `el comedor` - dining room
- `la cocina` - kitchen
- `el baño` - bathroom
- `el garaje` - garage
- `el pasillo` - corridor
- `el estudio` - study
- `el sótano` - basement
- `el ático` - attic
- `el jardín` - garden
- `el patio` - patio
- `el balcón` - balcony
- `la terraza` - terrace
- `la entrada` - entrance

### House Parts

- `la puerta` - door
- `la ventana` - window
- `la pared` - wall
- `el techo` - roof / ceiling
- `el suelo` - floor
- `las escaleras` - stairs

### Muebles y Objetos

- `la cama` - bed
- `el sofá` - sofa
- `la mesa` - table
- `la silla` - chair
- `el armario` - wardrobe
- `la lámpara` - lamp
- `el escritorio` - desk
- `la estantería` - bookshelf
- `la televisión` - television
- `el espejo` - mirror

## Lesson Cadence

> **Decision — total lessons:** **40 lessons** total. Days 1–5 learning only, then Days 6–20 alternate `Quiz → Learn → Quiz → Learn …` starting with quiz. Days 21–40 add 10 more review lessons and 10 more quizzes, all randomly selected from already-covered La Casa words.
>
> **Decision — Bonus Review days:** **No 🌳 Bonus Review cells in Level 4.** Level 4 stays vocabulary-focused, matching Level 3's clean structure. Users who want cross-lesson quizzing get it from Day 8+ quiz cells.
>
> **Decision — sentence & paragraph uniqueness:** every fill-in sentence and every learning-day sentence is **unique across the whole level** (no repeats within a day or across days). Same rule Level 3 uses, enforced at content-authoring time.

### First 5 Days: Learning Only

The first 5 days should contain only learning lessons. The first quiz starts immediately after Lesson 5.

- Day 1: Rooms 1 - house, bedroom, living room, dining room
- Day 2: Rooms 2 - kitchen, bathroom, garage, corridor
- Day 3: Rooms 3 - study, basement, attic, garden
- Day 4: Outdoor / entry - patio, balcony, terrace, entrance
- Day 5: House parts - door, window, wall, ceiling, floor, stairs

### Starting Day 6: Alternate Quiz And Learning

From Day 6 onward, alternate quiz and learning activity days.

- Day 6: Quiz on Days 1-5 vocabulary
- Day 7: Furniture 1 - bed, sofa, table, chair
- Day 8: Quiz
- Day 9: Furniture 2 - wardrobe, lamp, desk, bookshelf, television, mirror
- Day 10: Quiz
- Day 11: Learning activity - Where is it in the house?
- Day 12: Quiz
- Day 13: Learning activity - sentence practice with `Hay...` and `Está en...`
- Day 14: Quiz
- Day 15: Learning activity - room/object matching
- Day 16: Quiz

Continue this pattern through Day 20:

`Quiz (D6) → Learn (D7) → Quiz (D8) → Learn (D9) → … → Quiz (D20)`

Initial total through Day 20: 5 learning-only days + 8 quiz days + 7 learning days from D7–D19.

### Days 21-40: Random Covered-Word Review

Add 20 more Level 4 days after Day 20:

- 10 review learning lessons.
- 10 review quizzes.
- Alternate one learning lesson and one quiz:
  - Day 21: random review lesson
  - Day 22: random quiz
  - Day 23: random review lesson
  - Day 24: random quiz
  - Continue through Day 40.

These days should not introduce new vocabulary. They should randomly select from words already covered by completed Level 4 learning days.

Full total: **40 lessons**.

## Activity Types

### Learning Days

> **Decision — learning-day stage flow:** each learning day runs `intro → wordbuild → matching (today's words only) → listen&spell → sentence builder → redo → bloom`. Deliberately **skip** the standard `fillblank` / `truefalse` stages — those show up on quiz days.

Use kid-friendly interactive activities:

- Flashcards with Spanish, English, emoji/icon, and audio.
- Matching: Spanish word to English meaning.
- Listen and spell.
- Room/object grouping:
  - Which item belongs in the bedroom?
  - Which item belongs in the kitchen?
  - Which item belongs in the living room?
- Sentence builder:
  - `Hay una cama en la habitación.`
  - `La mesa está en el comedor.`
  - `La televisión está en la sala.`
  - `El espejo está en el baño.`

### Quiz Days

> **Decision — quiz composition:** **15 questions per quiz** = 5 MCQ ES→EN, 5 MCQ EN→ES, 3 sentence fill-in (`Hay una ___`, `Está en la ___`), 2 listening.
>
> Every quiz day also runs the standard `redo` stage before bloom to replay any first-try mistakes / hint-used questions.

Use regular app quiz format:

- Multiple choice: Spanish to English.
- Multiple choice: English to Spanish.
- Matching set.
- Fill-in sentence:
  - `La cama está en la ___.`
  - `Hay una ___ en la cocina.`
  - `La televisión está en la ___.`
- Listening question:
  - Play Spanish word.
  - Kid chooses the meaning or matching object.

## Implementation Approach

Add a new vocabulary data block. Every item has `group` (one of `"room" | "house_part" | "furniture"`), and every furniture item also has a `belongsIn` array of rooms it plausibly lives in:

```js
const LEVEL4_HOUSE_VOCAB = [
  {id:1,  es:"la casa",         en:"house",       em:"🏠", group:"room"},
  {id:2,  es:"la habitación",   en:"bedroom",     em:"🛏️", group:"room",       accepted:["el dormitorio"]},
  {id:3,  es:"la sala",         en:"living room", em:"🛋️", group:"room",       accepted:["el salón"]},
  // ...
  {id:23, es:"la cama",         en:"bed",         em:"🛏️", group:"furniture", belongsIn:["bedroom"]},
  {id:24, es:"el sofá",         en:"sofa",        em:"🛋️", group:"furniture", belongsIn:["living room"]},
  {id:26, es:"la lámpara",      en:"lamp",        em:"💡", group:"furniture", belongsIn:["bedroom","living room","study"]},
  // ...
];
```

Add custom lesson data:

```js
const HOUSE_LESSONS = [
  {title:"1 · Habitaciones 1", type:"learn", items:[...]},
  {title:"2 · Habitaciones 2", type:"learn", items:[...]},
  // ...
  {title:"8 · Quiz de la casa", type:"quiz", items:[...]}
];
```

Append a new level:

```js
{
  id:4,
  name:"Level 4 · La Casa",
  blurb:"Rooms, house parts, furniture and objects",
  verbs:[],
  fills:{},
  house:true,
  customPlan: HOUSE_LESSONS.map((q,i)=>({
    d:i+1,
    title:q.title,
    em:q.em,
    game:q.type === "quiz" ? "house_quiz" : "house_lesson",
    quizIdx:i,
    newV:[],
    house:true
  }))
}
```

Add renderers:

- `renderHouseLesson()`
- `renderHouseQuiz()`

Wire them into `openDay()` and the stage map:

```js
house_lesson: renderHouseLesson,
house_quiz: renderHouseQuiz
```

Reuse existing app systems:

- Overlay UI
- Score and stars
- Redo queue
- Confetti
- Bloom completion screen
- Saved progress
- Parent dashboard
- Trophies

## Trophy Celebration Requirement

> **Decision — build a shared trophy-celebration popup used by every level.** Today's app shows a toast for new trophies; this changes it to a proper modal. Put the popup in the existing overlay container so it works from any lesson end.

Whenever Kabir earns a new trophy:

- Show a trophy popup in the overlay.
- Play confetti burst.
- Show trophy icon, name, and short reason ("You earned this by …").
- Include a `Continue` button that closes the popup and returns to the level grid.
- Save trophy immediately after `checkTrophies()` so it does not repeat on refresh.
- Queue popups when multiple trophies are earned at once (show one at a time).

## Add 10 New La Casa Trophies

1. **Casa Explorer**
   - Finish the first La Casa lesson.

2. **Room Finder**
   - Learn all 16 room / area words. "Learned" means the lesson day that introduced them was **completed** (bloom reached), not just viewed.

3. **Furniture Collector**
   - Learn all 10 furniture / object words. Same "learned = day completed" rule as above.

4. **House Builder**
   - Learn all La Casa vocabulary.

5. **Perfect Room Quiz**
   - Get 3 stars on any La Casa quiz.

6. **Quiz Architect**
   - Get 3 stars on 5 La Casa quizzes.

7. **Listening Builder**
   - Answer 10 La Casa listening questions correctly.

8. **Sentence Maker**
   - Answer 10 `Hay...` / `Está en...` sentence questions correctly on the **first attempt** (no wrong tap before correct). Practice-round wins do NOT tick this counter — same rule as star scoring.

9. **No-Hint Home Hero**
   - Finish a La Casa quiz with 3 stars *and* zero hint taps that lesson. Requires new tracking: add `cur.hintUsedInLesson = false` on lesson open and flip it true whenever any `hint-btn` is tapped. Snapshot it into per-day stats so trophy check can look back.

10. **La Casa Champion**
    - Complete the full La Casa level.

## Trophy Snapshot Fields

Extend `trophySnapshot()` with Level 4 counters (all lifetime, never reset):

- `houseLessonsDone` — number of Level 4 lessons finished
- `houseQuizzesDone` — number of Level 4 quiz days finished (added)
- `houseWordsLearned` — unique La Casa vocab items whose introducing day was completed
- `houseRoomsLearned` — count of `group:"room"` items learned (target: 16)
- `houseFurnitureLearned` — count of `group:"furniture"` items learned (target: 10)
- `housePartsLearned` — count of `group:"house_part"` items learned (target: 6) *(added — useful for the parent dashboard even if no trophy uses it)*
- `houseThreeStarQuizzes` — Level 4 quiz days with 3 stars
- `houseListeningCorrect` — first-try correct answers on listening questions
- `houseSentenceCorrect` — first-try correct answers on `Hay/Está en` sentence questions
- `houseNoHintQuiz` — has any Level 4 quiz been finished 3-star with zero hints used
- `houseLevelComplete` — all 40 Level 4 lessons complete

## Validation Plan

After implementation:

1. Run `node --check` on the extracted script from `learn-verb-activity.html`.
2. Open the app in the browser.
3. Confirm Level 4 appears on the level picker.
4. Confirm Days 1-5 are learning only.
5. Confirm Day 6 onward alternates quiz / learning / quiz.
6. Confirm Days 21-40 add 10 random review lessons and 10 random quizzes.
7. Complete one learning day and verify progress saves.
8. Complete one quiz day and verify stars save.
9. Trigger a new trophy and verify the trophy celebration popup appears.
10. Confirm parent dashboard and trophy room still work.
