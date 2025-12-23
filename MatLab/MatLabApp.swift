import SwiftUI
import SwiftData

@main
struct MatLabApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Video.self, BJJCategory.self, Tag.self, VideoTimestamp.self])
    }
}
