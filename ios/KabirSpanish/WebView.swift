import SwiftUI
import WebKit
import Speech
import AVFoundation

final class SpeechPracticeBridge: NSObject, WKScriptMessageHandler {
    private weak var webView: WKWebView?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var activeSessionID: String?
    private var hasInputTap = false
    private var priorAudioSession: (AVAudioSession.Category, AVAudioSession.Mode, AVAudioSession.CategoryOptions)?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(audioInterrupted), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(routeChanged), name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBackgrounded), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    func attach(_ webView: WKWebView) { self.webView = webView }
    var supportsOnDeviceRecognition: Bool { recognizer?.supportsOnDeviceRecognition == true }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.frameInfo.isMainFrame,
              message.webView?.url?.lastPathComponent == "learn-verb-activity.html",
              let body = message.body as? [String: Any],
              let action = body["action"] as? String,
              let sessionID = body["sessionId"] as? String else { return }
        if action == "stop" { stop(reason: "stopped", notify: false); return }
        guard action == "start" else { return }
        start(sessionID: sessionID)
    }

    private func start(sessionID: String) {
        stop(reason: "replaced", notify: false)
        activeSessionID = sessionID
        requestPermissions { [weak self] allowed, reason in
            DispatchQueue.main.async {
                guard let self, self.activeSessionID == sessionID else { return }
                guard allowed else { self.send(type: "unavailable", sessionID: sessionID, extra: ["reason": reason]); self.stop(reason: reason, notify: false); return }
                self.beginCapture(sessionID: sessionID)
            }
        }
    }

    private func requestPermissions(completion: @escaping (Bool, String) -> Void) {
        func requestMic(_ speechOK: Bool) {
            guard speechOK else { completion(false, "speech-permission"); return }
            let session = AVAudioSession.sharedInstance()
            switch session.recordPermission {
            case .granted: completion(true, "")
            case .denied: completion(false, "microphone-permission")
            case .undetermined: session.requestRecordPermission { completion($0, $0 ? "" : "microphone-permission") }
            @unknown default: completion(false, "microphone-restricted")
            }
        }
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized: requestMic(true)
        case .denied: completion(false, "speech-permission")
        case .restricted: completion(false, "speech-restricted")
        case .notDetermined: SFSpeechRecognizer.requestAuthorization { requestMic($0 == .authorized) }
        @unknown default: completion(false, "speech-restricted")
        }
    }

    private func beginCapture(sessionID: String) {
        guard let recognizer, recognizer.isAvailable else { send(type: "unavailable", sessionID: sessionID, extra: ["reason":"service-unavailable"]); stop(reason: "service-unavailable", notify: false); return }
        let audioSession = AVAudioSession.sharedInstance()
        priorAudioSession = (audioSession.category, audioSession.mode, audioSession.categoryOptions)
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let req = SFSpeechAudioBufferRecognitionRequest()
            req.shouldReportPartialResults = true
            if recognizer.supportsOnDeviceRecognition { req.requiresOnDeviceRecognition = true }
            request = req
            let input = audioEngine.inputNode
            if hasInputTap { input.removeTap(onBus: 0); hasInputTap = false }
            let format = input.outputFormat(forBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in req.append(buffer) }
            hasInputTap = true
            audioEngine.prepare(); try audioEngine.start()
            send(type: "listening", sessionID: sessionID, extra: ["onDevice":recognizer.supportsOnDeviceRecognition])
            task = recognizer.recognitionTask(with: req) { [weak self] result, error in
                guard let self, self.activeSessionID == sessionID else { return }
                if let result {
                    let alternatives = result.transcriptions.prefix(5).map(\.formattedString)
                    self.send(type: "result", sessionID: sessionID, extra: ["alternatives":alternatives,"final":result.isFinal])
                    if result.isFinal { self.stop(reason: "finished", notify: false) }
                } else if error != nil {
                    self.send(type: "unavailable", sessionID: sessionID, extra: ["reason":"recognition-error"])
                    self.stop(reason: "recognition-error", notify: false)
                }
            }
        } catch {
            send(type: "unavailable", sessionID: sessionID, extra: ["reason":"audio-error"])
            stop(reason: "audio-error", notify: false)
        }
    }

    func stop(reason: String, notify: Bool) {
        let sessionID = activeSessionID
        if audioEngine.isRunning { audioEngine.stop() }
        if hasInputTap { audioEngine.inputNode.removeTap(onBus: 0); hasInputTap = false }
        request?.endAudio(); task?.cancel(); request=nil; task=nil
        if let priorAudioSession {
            let session=AVAudioSession.sharedInstance()
            try? session.setCategory(priorAudioSession.0, mode: priorAudioSession.1, options: priorAudioSession.2)
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
        }
        priorAudioSession=nil; activeSessionID=nil
        if notify, let sessionID { send(type: "unavailable", sessionID: sessionID, extra: ["reason":reason]) }
    }

    private func send(type: String, sessionID: String, extra: [String: Any]) {
        guard let webView else { return }
        var payload=extra; payload["type"]=type; payload["sessionId"]=sessionID
        guard let data=try? JSONSerialization.data(withJSONObject: payload), let json=String(data:data,encoding:.utf8) else { return }
        DispatchQueue.main.async { webView.evaluateJavaScript("window.KABIR_SPEECH_RECEIVE&&window.KABIR_SPEECH_RECEIVE(\(json))") }
    }

    @objc private func audioInterrupted() { stop(reason: "interrupted", notify: true) }
    @objc private func routeChanged() { stop(reason: "route-changed", notify: true) }
    @objc private func appBackgrounded() { stop(reason: "backgrounded", notify: true) }
    deinit { NotificationCenter.default.removeObserver(self); stop(reason: "deallocated", notify: false) }
}

/// Keeps progress independent of WKWebView's opaque `file://` storage origin.
/// A cold `loadFileURL` can receive a new origin after an app/HTML update, so
/// localStorage alone is not a safe source of truth for installed iOS builds.
final class ProgressPersistenceBridge: NSObject, WKScriptMessageHandler {
    static let stateKey = "learn_verb_activity_v2"
    static let fileName = "learn_verb_activity_v2.json"

    static var stateURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    static func savedState() -> String? {
        guard let data = try? Data(contentsOf: stateURL),
              let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String: Any],
              dictionary["levels"] is [String: Any] else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.frameInfo.isMainFrame,
              message.webView?.url?.lastPathComponent == "learn-verb-activity.html",
              let raw = message.body as? String,
              let data = raw.data(using: .utf8),
              data.count < 4_000_000,
              let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String: Any],
              dictionary["levels"] is [String: Any] else { return }
        try? data.write(to: Self.stateURL, options: .atomic)
    }
}

final class WebViewStore: NSObject, ObservableObject, WKNavigationDelegate {
    static let shared = WebViewStore()
    let webView: WKWebView
    private let speechBridge: SpeechPracticeBridge
    private let progressBridge: ProgressPersistenceBridge
    // Release gate: enable only after the physical-device 8/10 accept and 8/10 reject check passes.
    private let speechPracticeEnabled = false

    private let mainHTMLName = "learn-verb-activity"
    private let siblingHTMLNames = [
        "regular-verb-practice-tests",
        "spanish-class-hw"
    ]

    private var documentsDirectoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Where over-the-air HTML updates are stored. If present, we boot from
    /// here instead of the bundled copy — so a Wi-Fi push is picked up on
    /// the next launch (and immediately after write via `loadApp()`).
    private var documentsHTMLURL: URL {
        documentsDirectoryURL.appendingPathComponent("\(mainHTMLName).html")
    }

    /// Relative links resolve within the directory of the loaded main page.
    /// When an OTA main page lives in Documents, stage the bundled sibling
    /// pages there too so Practice Tests and Spanish Class HW still open.
    private func stageBundledSiblingHTML() throws {
        for name in siblingHTMLNames {
            guard let bundledURL = Bundle.main.url(forResource: name, withExtension: "html") else {
                throw CocoaError(.fileNoSuchFile)
            }
            let data = try Data(contentsOf: bundledURL)
            let destination = documentsDirectoryURL.appendingPathComponent("\(name).html")
            try data.write(to: destination, options: .atomic)
        }
    }

    override init() {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.suppressesIncrementalRendering = false
        // Keep localStorage persistent across launches.
        config.websiteDataStore = .default()

        let bridge = SpeechPracticeBridge()
        speechBridge = bridge
        let progress = ProgressPersistenceBridge()
        progressBridge = progress
        let savedProgress = ProgressPersistenceBridge.savedState()
        let savedProgressB64 = savedProgress.map { Data($0.utf8).base64EncodedString() } ?? ""
        let progressScript = """
        if(decodeURIComponent(location.pathname).endsWith('/learn-verb-activity.html')){
          const key='\(ProgressPersistenceBridge.stateKey)';
          try{
            if(!localStorage.getItem(key)&&'\(savedProgressB64)'){
              const bytes=Uint8Array.from(atob('\(savedProgressB64)'),c=>c.charCodeAt(0));
              localStorage.setItem(key,new TextDecoder().decode(bytes));
            }
            const nativeSetItem=Storage.prototype.setItem;
            Storage.prototype.setItem=function(k,v){
              nativeSetItem.call(this,k,v);
              if(this===localStorage&&k===key){
                try{webkit.messageHandlers.progressPersistence.postMessage(String(v));}catch(e){}
              }
            };
          }catch(e){}
        }
        """
        config.userContentController.addUserScript(WKUserScript(source: progressScript, injectionTime: .atDocumentStart, forMainFrameOnly: true, in: .page))
        config.userContentController.add(progress, name: "progressPersistence")
        let speechScript = """
        if(decodeURIComponent(location.pathname).endsWith('/learn-verb-activity.html')){
          const sid=(crypto.randomUUID?crypto.randomUUID():String(Date.now())+Math.random());
          window.KABIR_NATIVE_CAPABILITIES=Object.freeze({speechPractice:\(speechPracticeEnabled),speechSessionId:sid,onDeviceRecognition:\(bridge.supportsOnDeviceRecognition)});
          window.KABIR_SPEECH_BRIDGE=Object.freeze({start:()=>webkit.messageHandlers.speechPractice.postMessage({action:'start',sessionId:sid}),stop:()=>webkit.messageHandlers.speechPractice.postMessage({action:'stop',sessionId:sid})});
        }
        """
        config.userContentController.addUserScript(WKUserScript(source: speechScript, injectionTime: .atDocumentStart, forMainFrameOnly: true, in: .page))
        config.userContentController.add(bridge, name: "speechPractice")

        webView = WKWebView(frame: .zero, configuration: config)

        // --- Mobile smoothness ---
        webView.scrollView.bounces = false                           // no rubber-band
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never   // safe-area handled via CSS env()
        webView.scrollView.decelerationRate = .normal                 // native-feel fling
        webView.allowsBackForwardNavigationGestures = false           // avoid accidental swipe-back
        webView.isOpaque = false
        webView.backgroundColor = .clear                              // matches the app's cream page
        webView.scrollView.backgroundColor = .clear

        super.init()
        bridge.attach(webView)
        webView.navigationDelegate = self
        loadApp()
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { speechBridge.stop(reason: "navigation", notify: false) }

    /// Prefer a wifi-pushed HTML from Documents. Fall back to the bundled copy.
    func loadApp() {
        let updated = documentsHTMLURL
        if FileManager.default.fileExists(atPath: updated.path) {
            do {
                try stageBundledSiblingHTML()
                print("[WebView] loading updated HTML from \(updated.path)")
                webView.loadFileURL(updated, allowingReadAccessTo: documentsDirectoryURL)
                return
            } catch {
                print("[WebView] OTA support-page staging failed; using bundled app: \(error)")
            }
        }
        guard let url = Bundle.main.url(forResource: mainHTMLName, withExtension: "html") else {
            print("[KabirSpanish] learn-verb-activity.html not in bundle — add it to the Xcode target.")
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    func reload() { webView.reload() }

    /// Read the app's persisted state from the WKWebView's localStorage.
    @MainActor
    func getState(completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("localStorage.getItem('learn_verb_activity_v2')") { result, _ in
            completion(result as? String)
        }
    }

    /// Merge the incoming state INTO the current local state (never blindly
    /// overwrites), then reload so the UI shows the merged result.
    /// If `syncMergeIncoming` isn't loaded (older HTML), falls back to a plain
    /// write so old builds still function.
    @MainActor
    func setState(_ rawJson: String, completion: @escaping (Bool) -> Void) {
        // Base64 the incoming JSON so we don't have to escape anything.
        let b64 = Data(rawJson.utf8).base64EncodedString()
        let js = """
        (function(){
          try{
            var s = atob('\(b64)');
            if(typeof window.syncMergeIncoming === 'function'){
              var ok = window.syncMergeIncoming(s);
              if(ok){ location.reload(); return true; }
              return false;
            }
            // Fallback for older bundled HTML that doesn't expose the merger.
            localStorage.setItem('learn_verb_activity_v2', s);
            location.reload();
            return true;
          }catch(e){ return false; }
        })()
        """
        webView.evaluateJavaScript(js) { result, _ in
            completion((result as? Bool) ?? false)
        }
    }

    /// Save a new HTML build shipped over Wi-Fi from the Mac, then reload.
    @MainActor
    func saveUpdatedHTML(_ data: Data, completion: @escaping (Bool, Int) -> Void) {
        do {
            try data.write(to: documentsHTMLURL, options: .atomic)
            try stageBundledSiblingHTML()
            loadApp()
            completion(true, data.count)
        } catch {
            print("[WebView] failed to write updated HTML: \(error)")
            completion(false, 0)
        }
    }

    /// Discard any pushed HTML and revert to the version bundled with the app.
    @MainActor
    func resetToBundledHTML() {
        try? FileManager.default.removeItem(at: documentsHTMLURL)
        for name in siblingHTMLNames {
            let url = documentsDirectoryURL.appendingPathComponent("\(name).html")
            try? FileManager.default.removeItem(at: url)
        }
        loadApp()
    }
}

struct WebView: UIViewRepresentable {
    let store: WebViewStore
    func makeUIView(context: Context) -> WKWebView { store.webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
