# Phase 8b - Mobile Listen-and-Speak Practice

Branch: `codex/mobile-ux-phase-8b-listen-speak`

## Scope

- Added an installed-iOS-only speech capability injected by Swift at document start and restricted to the main-frame `learn-verb-activity.html` page.
- Replaced the old browser `voiceverb` composition with one unscored native Listen & Speak stage for eligible pending lessons/quizzes. Web, Practice Tests, Spanish HW, completed replay, parent, trophy, surprise-quiz, and sync flows remain excluded.
- Added reviewed prompts, deterministic selection, exact word matching, token-level sentence matching, two-attempt/fallback UX, 6-second word and 10-second sentence timers, Stop, and Play/Slow controls.
- Added microphone and speech-recognition usage descriptions plus idempotent native cancellation for navigation, backgrounding, interruption, route change, and teardown.
- Preserved portrait-only support for both iPhone and iPad. Landscape support/QA is intentionally out of scope.

## Invariants

- Speech practice is formative and never changes score, stars, completion, unlocks, retries, or saved progress.
- Audio and transcripts are ephemeral and are not stored, synced, exported, or shown to parents.
- `?speechPractice=0` is a non-persistent QA rescue. With the native capability absent/false, no speech stage is composed.
- Main web/iOS HTML resource parity remains exact; sibling web/iOS resources remain unchanged and exact.

## QA log

- Focused matcher vectors passed for exact text, accents/punctuation, one approved function-word difference, wrong word order, missing content, exact `ir`, and the `ir`/`vivir` rejection guard. The reviewed-bank structural audit passed with stable unique IDs/targets and 3-8-word sentences.
- Desktop, iPad portrait, and iPhone portrait browser checks confirmed no native capability, no speech UI, and no horizontal overflow. All three scripts passed `node --check`; plist validation, web/iOS/built-resource parity, and `git diff --check` passed.
- The Swift app built successfully for simulator and signed physical device. iPhone and iPad portrait simulator install/launch checks completed.
- The signed physical-iPhone app installed in place. The exact canonical progress fingerprint matched before/after: `c9d9a8ae6bcd61fecd00c555797dbb5ee34ccf7a8e31f81a51a235b7961e9a75`; completed `3/50/19/10/6`, collected `8/41/36/0/12`, trophies `61`.
- Physical launch was blocked because the iPhone was locked. The mandatory 8/10 spoken-acceptance and 8/10 deliberate-rejection quality gate therefore could not be run. In accordance with the exit gate, `speechPracticeEnabled` remains `false`; the native activity is hidden and no unverified pass/fail recognition ships. Phase 9 must retain this contingency until a quiet-room physical gate is completed.
