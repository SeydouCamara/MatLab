import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Video.title) private var videos: [Video]
    @Query(sort: \BJJCategory.name) private var categories: [BJJCategory]
    @State private var searchText = ""
    @State private var expandedCategories: Set<UUID> = []
    @State private var showAddVideo = false

    // Group videos by category, sorted alphabetically
    var groupedVideos: [(BJJCategory, [Video])] {
        let filtered = videos.filter { video in
            if searchText.isEmpty { return true }
            let matchTitle = video.title.localizedCaseInsensitiveContains(searchText)
            let matchInstructor = video.instructor?.localizedCaseInsensitiveContains(searchText) ?? false
            let matchCategory = video.category?.name.localizedCaseInsensitiveContains(searchText) ?? false
            return matchTitle || matchInstructor || matchCategory
        }

        let grouped = Dictionary(grouping: filtered) { $0.category }
        return categories
            .filter { grouped[$0] != nil && !grouped[$0]!.isEmpty }
            .sorted { $0.name < $1.name }
            .map { ($0, grouped[$0]!) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        if groupedVideos.isEmpty {
                            EmptyLibraryView()
                                .padding(.top, 60)
                        } else {
                            ForEach(groupedVideos, id: \.0.id) { category, videos in
                                CategorySection(
                                    category: category,
                                    videos: videos,
                                    isExpanded: expandedCategories.contains(category.id)
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        if expandedCategories.contains(category.id) {
                                            expandedCategories.remove(category.id)
                                        } else {
                                            expandedCategories.insert(category.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Bibliothèque")
            .searchable(text: $searchText, prompt: "Rechercher technique ou instructeur...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddVideo = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showAddVideo) {
                AddVideoView()
            }
            .onAppear {
                if categories.isEmpty {
                    createDefaultCategories()
                }
                if videos.isEmpty {
                    createSampleVideos()
                }
            }
        }
    }

    private func createDefaultCategories() {
        let defaultCategories = BJJCategory.createDefaultCategories()
        defaultCategories.forEach { modelContext.insert($0) }
        try? modelContext.save()
    }

    private func createSampleVideos() {
        let sampleData = [
            ("Ashi Garami Mastery", "Lachlan Giles", "Leg Locks"),
            ("The Saddle System", "Lachlan Giles", "Leg Locks"),
            ("Guard Retention Fundamentals", "Lachlan Giles", "Concepts"),
            ("Leg Lock Defense", "Craig Jones", "Leg Locks"),
            ("Z Guard System", "Craig Jones", "Half Guard"),
            ("Back Attack System", "John Danaher", "Back Control"),
            ("Kimura Trap System", "John Danaher", "Submissions"),
            ("Closed Guard Fundamentals", "Roger Gracie", "Garde Fermée"),
            ("X Guard Mastery", "Marcelo Garcia", "X-Guard"),
            ("Deep Half Guard", "Bernardo Faria", "Half Guard")
        ]

        for (title, instructor, categoryName) in sampleData {
            let category = categories.first { $0.name.contains(categoryName) }
            let video = Video(
                title: title,
                instructor: instructor,
                videoDescription: "Instructional complet sur \(title)",
                sourceType: .streaming,
                category: category
            )
            modelContext.insert(video)
        }
        try? modelContext.save()
    }
}

// MARK: - Category Section
struct CategorySection: View {
    let category: BJJCategory
    let videos: [Video]
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: category.icon)
                        .font(.title3)
                        .foregroundStyle(Color.forCategory(category.colorName))
                        .frame(width: 30)

                    Text(category.name)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    Text("\(videos.count)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding()
                .background(
                    GlassCard {
                        Rectangle()
                            .fill(Color.clear)
                    }
                )
            }

            // Expanded Videos
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(videos) { video in
                        VideoRowItem(video: video)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Video Row Item
struct VideoRowItem: View {
    let video: Video

    var body: some View {
        HStack(spacing: 12) {
            // Play Icon
            ZStack {
                Circle()
                    .fill(Color.glassBackground)
                    .frame(width: 40, height: 40)

                Image(systemName: "play.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                if let instructor = video.instructor {
                    Text(instructor)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()

            // Status Badge
            Image(systemName: video.progressStatus.icon)
                .font(.caption)
                .foregroundStyle(Color.forProgressStatus(video.progressStatus))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - Empty Library View
struct EmptyLibraryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.3))

            Text("Bibliothèque vide")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text("Ajoutez vos premiers instructionals")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Add Video View (Placeholder)
struct AddVideoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                Text("Ajouter une vidéo")
                    .foregroundStyle(.white)
            }
            .navigationTitle("Nouvelle vidéo")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    LibraryView()
        .modelContainer(for: [Video.self, BJJCategory.self, Tag.self, VideoTimestamp.self])
}
