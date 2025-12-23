import SwiftUI
import SwiftData

struct DownloadsView: View {
    @Query private var allVideos: [Video]

    private var downloadedVideos: [Video] {
        allVideos.filter { $0.sourceType == .downloaded || $0.sourceType == .local }
    }

    var totalSize: String {
        "2.4 GB"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Storage Info
                StorageInfoCard(totalSize: totalSize, videoCount: downloadedVideos.count)
                    .padding()
                    .background(Color.appGroupedBackground)

                // Downloaded Videos
                if downloadedVideos.isEmpty {
                    EmptyDownloadsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(downloadedVideos) { video in
                                DownloadedVideoRow(video: video)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Téléchargements")
            .toolbar {
                if !downloadedVideos.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                // Delete all
                            } label: {
                                Label("Tout supprimer", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Storage Info Card
struct StorageInfoCard: View {
    let totalSize: String
    let videoCount: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "internaldrive.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Stockage utilisé")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(totalSize)
                        .font(.title3)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(videoCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    Text("vidéos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Storage bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue.gradient)
                        .frame(width: geometry.size.width * 0.35)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cardCornerRadius)
                .fill(Color.appCardBackground)
        )
    }
}

// MARK: - Downloaded Video Row
struct DownloadedVideoRow: View {
    let video: Video

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 68)
                .overlay {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
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
                    Image(systemName: video.sourceType.icon)
                    Text(video.sourceType.rawValue)
                    Text("•")
                    Text("156 MB")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                // Delete
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .fill(Color.appCardBackground)
        )
    }
}

// MARK: - Empty Downloads View
struct EmptyDownloadsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 60))
                .foregroundStyle(.gray)

            Text("Aucun téléchargement")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Téléchargez des vidéos pour les regarder hors ligne")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    DownloadsView()
        .modelContainer(for: [Video.self, BJJCategory.self, Tag.self, VideoTimestamp.self])
}
