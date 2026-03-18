import SwiftUI
import StoreKit

struct ContentView: View {
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 44/255, green: 44/255, blue: 44/255), location: 0),
                    .init(color: Color(red: 22/255, green: 22/255, blue: 22/255), location: 0.5),
                    .init(color: Color(red: 12/255, green: 12/255, blue: 12/255), location: 0.75),
                    .init(color: Color(red: 1/255, green: 1/255, blue: 1/255), location: 1.0),
                ]),
                center: UnitPoint(x: 0.5, y: 0),
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height
            )
            .ignoresSafeArea()
            Image("bb")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                DefaultWelcomeView(deepLinkHandler: deepLinkHandler)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct DefaultWelcomeView: View {
    let deepLinkHandler: DeepLinkHandler
    @State private var overlayShown = false
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            HStack(spacing: -44) {
                Image(deepLinkHandler.deviceImageName.contains("core") ? "envoy_on_iphone_core" : "envoy_on_iphone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                    .offset(x: appeared ? 0 : -UIScreen.main.bounds.width)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8), value: appeared)
                Image(deepLinkHandler.deviceImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: deepLinkHandler.deviceImageName.contains("core") ? 110 : 160)
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                    .offset(x: appeared ? 0 : UIScreen.main.bounds.width)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8), value: appeared)
            }
            Spacer()
            VStack(spacing: 16){
                Text("Welcome to Passport")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Install Envoy to set up your \(deepLinkHandler.deviceSetupName).")
                    .font(.footnote)
            }
            Spacer()
            Spacer()

        }
        .modifier(
            RepeatingAppClipOverlayModifier(
                isPresented: $overlayShown,
                position: .bottom
            )
        )
        .onAppear {
            appeared = true
            overlayShown = true
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environmentObject(DeepLinkHandler())
}

struct RepeatingAppClipOverlayModifier: ViewModifier {
    @Binding var isPresented: Bool
    let position: SKOverlay.Position
    @State private var reshowTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .appStoreOverlay(isPresented: $isPresented) {
                SKOverlay.AppClipConfiguration(position: position)
            }
            .onChange(of: isPresented) { _, newValue in
                reshowTask?.cancel()

                guard !newValue else { return }

                reshowTask = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1))
                    guard !Task.isCancelled else { return }
                    isPresented = true
                }
            }
            .onDisappear {
                reshowTask?.cancel()
            }
    }
}
