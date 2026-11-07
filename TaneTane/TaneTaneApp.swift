import SwiftUI

@main
struct TaneTaneApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(Color.tane)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        if store.s.onboarded {
            TabView {
                HomeView()
                    .tabItem { Label("Bugün", systemImage: "sun.max") }
                PathView()
                    .tabItem { Label("Seviyeler", systemImage: "stairs") }
                MeView()
                    .tabItem { Label("İlerleme", systemImage: "chart.bar") }
            }
        } else {
            OnboardingView()
        }
    }
}
