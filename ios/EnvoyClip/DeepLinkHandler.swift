import Foundation
import SwiftUI

class DeepLinkHandler: ObservableObject {
    @Published var originalURL: URL?
    @Published var isCoreOnboarding = false
    @Published var colorway: Int = 1

    private let appGroupID = "group.com.foundationdevices.envoy"

    func handleURL(_ url: URL) {
        originalURL = url

        // Parse parameters locally for UI display only
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            let params = Dictionary(
                uniqueKeysWithValues: components.queryItems?.map { ($0.name, $0.value ?? "") } ?? []
            )
            isCoreOnboarding = params["t"] != nil
            colorway = Int(params["c"] ?? "1") ?? 1
        }

        // Save URL to shared UserDefaults for handoff to full app
        saveStateForFullApp()
    }

    var deviceImageName: String {
        if isCoreOnboarding {
            return "core_dark"
        }

        return colorway == 1 ? "prime_light" : "prime_dark"
    }

    var deviceSetupName: String {
        isCoreOnboarding ? "Passport Core" : "Passport Prime"
    }

    /// Save the URL to App Groups shared UserDefaults for handoff to full app
    func saveStateForFullApp() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        print("saving to shared UserDefaults \(originalURL?.absoluteString ?? "nil")")
              
        defaults.set(originalURL?.absoluteString, forKey: "appClip_deepLinkURL")
        defaults.set(Date(), forKey: "appClip_timestamp")
        defaults.synchronize()
    }
}
