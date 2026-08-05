# Phase 6a - Audio Audit

Branch: `codex/mobile-ux-phase-6a-audio-audit`

## Inventory

### Main app

- `speak(text)` uses `SpeechSynthesisUtterance`, Spanish `es-ES`, and rate `0.85`; it cancels the previous utterance before speaking.
- `sayOops()` uses English speech synthesis for playful retry feedback.
- `SFX` creates short right/wrong/pop tones with `AudioContext` / `webkitAudioContext`; no audio assets are loaded.
- TTS is used for flashcards, matching selections, completed spellings, quiz answers, fill sentences, tense/HW/house prompts, trophy announcements, learned-word lists, and parent-panel sound buttons.
- Four render-time automatic TTS starts exist and must be removed in Phase 6b: main listen/spell and voice flows near lines 4422 and 4452, Level 0 listen/spell near 5493, and house listening near 5665.
- Existing explicit speaker controls are question-scoped and should remain near their prompts.

### Spanish Class HW

- Uses speech synthesis for Spanish prompts and a chunked story reader with Play/Stop controls.
- The story reader has a real utterance sequence but no seekable media timeline; it does not support a meaningful scrub bar.
- Speech is cancelled on Stop, question changes, and navigation paths already present in that page.

### Practice Tests and iOS shell

- Regular Practice Tests contain no TTS, `<audio>`, `new Audio`, or Web Audio usage.
- Swift files contain no native audio playback implementation.

## Decision for Phase 6b

- Proceed with Phase 6b because TTS-backed prompts benefit from explicit Play and Slow controls and lifecycle cancellation.
- Do not add a scrub/progress bar: no real audio timeline exists.
- Remove all four automatic TTS starts so reload/open never speaks before a user gesture.
- Add visibility/navigation cancellation and ensure a new clip cancels the previous one.
- Keep controls at least 44px and avoid duplicate control clusters on short screens.

## Audit Checks

- Every `speak()`, `SFX.right/wrong/pop`, `sayOops`, speech-synthesis, and audio-context call site was included in the grep inventory.
- Repository-wide checks found no `<audio>` element or `new Audio()` call.
- No application code changed in Phase 6a.

## Rollback

After commit creation: `git revert <phase-6a-commit>`.
