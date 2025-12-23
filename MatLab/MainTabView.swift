import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryView()
                .tabItem {
                    Label("Bibliothèque", systemImage: "books.vertical.fill")
                }
                .tag(0)

            SearchView()
                .tabItem {
                    Label("Recherche", systemImage: "magnifyingglass")
                }
                .tag(1)

            ProgressionView()
                .tabItem {
                    Label("Progression", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            DownloadsView()
                .tabItem {
                    Label("Téléchargements", systemImage: "arrow.down.circle.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Réglages", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(.appPrimary)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Video.self, BJJCategory.self, Tag.self, VideoTimestamp.self])
}
