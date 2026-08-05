import SwiftUI
import WebKit

final class WebViewStore: NSObject, ObservableObject {
    static let shared = WebViewStore()
    let webView: WKWebView

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
        loadApp()
    }

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
