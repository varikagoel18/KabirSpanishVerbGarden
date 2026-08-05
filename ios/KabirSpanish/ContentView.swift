import SwiftUI

struct ContentView: View {
    @EnvironmentObject var server: SyncServer
    var body: some View {
        WebView(store: WebViewStore.shared)
            .ignoresSafeArea()
    }
}

struct SyncSheet: View {
    @EnvironmentObject var server: SyncServer
    @Environment(\.dismiss) private var dismiss
    @State private var statusMsg = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Label("Sync over Wi-Fi", systemImage: "wifi").font(.title2.bold())

                if let ip = server.currentIP {
                    Text("Your iPhone address").font(.headline)
                    Text("http://\(ip):\(server.port)")
                        .font(.body.monospaced())
                        .textSelection(.enabled)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(10)

                    Text("On your Mac, open the app in the browser, tap 🔄 Sync in the header, and paste the address above. Both sides must be on the same Wi-Fi.")
                        .font(.callout).foregroundStyle(.secondary)
                } else {
                    Text("Connect to Wi-Fi to enable syncing.").foregroundStyle(.secondary)
                }

                Divider()

                Button {
                    exportToClipboard()
                } label: {
                    Label("Copy my progress (JSON)", systemImage: "doc.on.doc")
                }.buttonStyle(.borderedProminent)

                if !statusMsg.isEmpty {
                    Text(statusMsg).font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func exportToClipboard() {
        WebViewStore.shared.getState { json in
            UIPasteboard.general.string = json ?? ""
            statusMsg = "Copied \(json?.count ?? 0) characters to clipboard."
        }
    }
}
