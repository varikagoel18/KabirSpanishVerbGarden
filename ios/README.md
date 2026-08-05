# Kabir's Verb Garden — iOS App

Native SwiftUI wrapper around `learn-verb-activity.html` (WKWebView) plus a
tiny Wi-Fi HTTP server so progress can be merged with the web version.

## What this gives you

- The exact same app on iPhone/iPad — all gameplay, trophies, and animations.
- Progress persists in the app's own `localStorage` (survives closes and
  reboots; WKWebView uses `WKWebsiteDataStore.default`).
- **Wi-Fi sync**: from the browser tap 🔄 Sync → enter your iPhone's address
  → the two devices merge their state and end up identical.

## One-time Xcode setup (~5 minutes)

1. **Create the project**
   - Open Xcode → File → New → Project… → **iOS App**.
   - Product Name: `KabirSpanish`
   - Interface: `SwiftUI` · Language: `Swift` · Storage: `None`
   - Save it inside this `ios/` folder (or wherever you like).

2. **Replace the auto-generated Swift files**
   In the new Xcode project delete `KabirSpanishApp.swift` and
   `ContentView.swift` that Xcode created, then drag these four files
   from Finder into the Xcode project navigator (check *Copy items if
   needed*, add to target `KabirSpanish`):
   - `KabirSpanishApp.swift`
   - `ContentView.swift`
   - `WebView.swift`
   - `SyncServer.swift`

3. **Add the web app to the bundle**
   Drag `../learn-verb-activity.html` into the Xcode project navigator.
   In the "Add" sheet check *Copy items if needed* and *Add to targets:
   KabirSpanish*.

   (Optional) if you want the Level 0 PDFs bundled too, drag them in the
   same way.

4. **Info.plist keys for local networking**
   Select the project → target `KabirSpanish` → **Info** tab → add two
   entries:

   | Key | Type | Value |
   |---|---|---|
   | `NSLocalNetworkUsageDescription` | String | `Sync your progress with the web version over Wi-Fi.` |
   | `NSBonjourServices` | Array of Strings | one entry: `_kabirspanish._tcp` |

   (The Bonjour entry isn't strictly required today — we bind a fixed
   port — but iOS caches the local-network permission per service and
   listing one avoids permission prompts on iPad Sidecar setups.)

5. **Build & run on your iPhone**
   Plug the iPhone in, pick it in the device selector, ▶︎ Run.
   First launch iOS will ask *"Allow KabirSpanish to find devices on
   your local network?"* — tap **Allow**.

## Using Wi-Fi sync

1. Make sure the Mac and iPhone are on the **same Wi-Fi**.
2. On the iPhone, tap the 🌐 icon in the top-right → the sheet shows
   an address like `http://192.168.1.24:8181`.
3. On the Mac, open the app in the browser and tap **🔄 Sync** in the
   header. Paste the address, then hit **📡 Test connection**. On
   success, hit **🔄 Sync now**.
4. Both devices merge their progress and reload with the result. The
   URL is remembered for next time.

### Merge rules (JS `syncMergeState`)

- `levels[N].completed[d]` — OR (either device completed = completed)
- `levels[N].stars[d]` — max
- `levels[N].collected` — union
- `levels[N].basics.answers[d]` — newest `savedAt` wins per day
- `levels[N].house` counters — max / union
- `trophies[id]` — earliest `earnedAt` wins
- `streak` — max; `lastDate` — later
- `verbStats` — max attempts + max correct per verb
- `practiceRegular`, `spanishHW` — OR completed / max stars
- `sessionMinutes[d]` — max per date
- `missHistory[d]` — union

After a sync the two devices hold **byte-identical** state (we push the
merged blob to the iPhone right after saving locally).

## File layout

```
ios/
  README.md            ← this file
  KabirSpanish/
    KabirSpanishApp.swift   ← @main entry, starts SyncServer on launch
    ContentView.swift       ← root view (WebView + sync sheet)
    WebView.swift           ← WKWebView store, get/set localStorage bridge
    SyncServer.swift        ← HTTP server on TCP 8181 (/state, /ping)
```

## Common issues

- **"No response" on Test connection** → iPhone not on the same Wi-Fi,
  address wrong, or you tapped "Don't allow" on the local-network
  prompt. Delete the app and reinstall to see the prompt again.
- **Server never starts (logs `bind: address in use`)** → port 8181
  taken by something else; change `port` in `SyncServer.swift` to
  something else (also update the address on the Mac side).
- **The web app loads blank in WKWebView** → check that
  `learn-verb-activity.html` shows up under *Build Phases → Copy
  Bundle Resources* for the app target.
- **iOS "Web Content Process crashed"** → usually a Base64 encoding
  issue in `setState`. Confirm the sync push is valid JSON before
  posting.

## Wi-Fi HTML update (no Xcode rebuild)

The iPhone app can pull the exact HTML the browser is showing —
you don't have to open Xcode every time you tweak
`learn-verb-activity.html`.

**Endpoints on the iPhone (SyncServer):**
- `POST /html` — body is `text/html`; iPhone writes it to
  `Documents/learn-verb-activity.html` and reloads the WKWebView.
- `POST /html/reset` — deletes the pushed HTML and reboots into the
  version bundled with the app.

**On boot (`WebViewStore.loadApp`):**
if `Documents/learn-verb-activity.html` exists, it loads *that*.
Otherwise it falls back to the bundled copy.

**From the web app:**
open **🔄 Sync**, paste the iPhone URL, then hit **📱 Update iPhone
app**. It reads the current HTML via `fetch(location.href)` and POSTs
it. **↩︎ Revert to shipped** wipes the override so the phone goes back
to the bundled build.

Progress in `localStorage` is untouched by an HTML push — the WebView
keeps the same `WKWebsiteDataStore` regardless of which HTML file
loaded. If you also want to move progress, hit **🔄 Sync progress**.

## Not included (yet)

- No Bonjour auto-discovery yet (you paste the address manually).
- No conflict resolution UI — the merge is deterministic and additive,
  so it can't lose stars, but if you want per-day picking add it later.
- No signing / App Store setup — build is local only.
- OTA HTML pushes replace the whole file (no delta); a 700 KB HTML
  push over Wi-Fi is < 1 second on the LAN.
