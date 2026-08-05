import SwiftUI

@main
struct KabirSpanishApp: App {
    @StateObject private var server = SyncServer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(server)
                .task {
                    // Trigger local-network permission prompt on first launch.
                    // (iOS shows the prompt once the app opens a listener/connection.)
                    server.start()
                }
        }
    }
}
