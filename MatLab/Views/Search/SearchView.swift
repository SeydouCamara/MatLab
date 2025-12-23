import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var videos: [Video]
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all

    enum FilterOption: String, CaseIterable {
        case all = "Tout"
        case favorites = "Favoris"
        case notSeen = "Non vu"
        case inProgress = "En cours"
        case mastered = "Maîtrisé"
    }

    var filteredVideos: [Video] {
        var result = videos

        // Text search
        if !searchText.isEmpty {
            result = result.filter { video in
                video.title.localizedCaseInsensitiveContains(searchText) ||
                video.instructor?.localizedCaseInsensitiveContains(searchText) == true ||
                video.category?.name.localizedCaseInsensitiveContains(searchText) == true
            }
        }

        // Status filter
        switch selectedFilter {
        case .all:
            break
        case .favorites:
            result = result.filter { $0.isFavorite }
        case .notSeen:
            result = result.filter { $0.progressStatus == .notSeen }
        case .inProgress:
            result = result.filter { $0.progressStatus == .inProgress }
        case .mastered:
            result = result.filter { $0.progressStatus == .mastered }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FilterOption.allCases, id: \.self) { filter in
                            FilterChip(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color.appGroupedBackground)

                // Results
                if filteredVideos.isEmpty {
                    EmptySearchView(searchText: searchText)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredVideos) { video in
                                VideoRow(video: video)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Recherche")
            .searchable(text: $searchText, prompt: "Rechercher une technique...")
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.appPrimary : Color.appCardBackground)
                )
        }
    }
}

// MARK: - Video Row
struct VideoRow: View {
    let video: Video

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 68)
                .overlay {
                    Image(systemName: "play.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.8))
                }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                if let instructor = video.instructor {
                    Text(instructor)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Image(systemName: video.progressStatus.icon)
                        .font(.caption2)
                    Text(video.progressStatus.rawValue)
                        .font(.caption2)
                }
                .foregroundStyle(Color.forProgressStatus(video.progressStatus))
            }

            Spacer()

            // Favorite
            if video.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .fill(Color.appCardBackground)
        )
    }
}

// MARK: - Empty Search View
struct EmptySearchView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.gray)

            Text(searchText.isEmpty ? "Recherchez une technique" : "Aucun résultat")
                .font(.title3)
                .fontWeight(.semibold)

            if !searchText.isEmpty {
                Text("Essayez un autre terme de recherche")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [Video.self, BJJCategory.self, Tag.self, VideoTimestamp.self])
}
