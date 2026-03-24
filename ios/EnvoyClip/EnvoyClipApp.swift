import SwiftUI

@main
struct EnvoyClipApp: App {
    @StateObject private var deepLinkHandler = DeepLinkHandler()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deepLinkHandler)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
                .onOpenURL { url in
                    deepLinkHandler.handleURL(url)
                }
        }
    }

    private func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else { return }
        deepLinkHandler.handleURL(url)
    }
}
