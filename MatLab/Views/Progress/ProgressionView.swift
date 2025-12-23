import SwiftUI
import SwiftData

struct ProgressionView: View {
    @Query private var videos: [Video]
    @Query(sort: \BJJCategory.sortOrder) private var categories: [BJJCategory]

    var stats: ProgressStats {
        ProgressStats(
            total: videos.count,
            notSeen: videos.filter { $0.progressStatus == .notSeen }.count,
            seen: videos.filter { $0.progressStatus == .seen }.count,
            inProgress: videos.filter { $0.progressStatus == .inProgress }.count,
            mastered: videos.filter { $0.progressStatus == .mastered }.count,
            toReview: videos.filter { $0.progressStatus == .toReview }.count
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Global Stats
                    VStack(spacing: 16) {
                        Text("Vue d'ensemble")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        OverallProgressCard(stats: stats)

                        StatsGrid(stats: stats)
                    }
                    .padding(.horizontal)

                    // Progress by Category
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progression par catégorie")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(categories.filter { $0.isRootCategory && $0.videoCount > 0 }) { category in
                            CategoryProgressRow(category: category)
                                .padding(.horizontal)
                        }
                    }

                    // In Progress Videos
                    if !stats.inProgressVideos.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("En cours de travail")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(stats.inProgressVideos.prefix(5)) { video in
                                VideoRow(video: video)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Progression")
            .background(Color.appGroupedBackground)
        }
    }
}

// MARK: - Progress Stats Model
struct ProgressStats {
    let total: Int
    let notSeen: Int
    let seen: Int
    let inProgress: Int
    let mastered: Int
    let toReview: Int

    var completionPercentage: Double {
        guard total > 0 else { return 0 }
        return Double(mastered) / Double(total) * 100
    }

    var inProgressVideos: [Video] {
        []
    }
}

// MARK: - Overall Progress Card
struct OverallProgressCard: View {
    let stats: ProgressStats

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: stats.completionPercentage / 100)
                    .stroke(
                        Color.appPrimary,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(Int(stats.completionPercentage))%")
                        .font(.system(size: 36, weight: .bold))
                    Text("Maîtrisé")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)

            HStack {
                VStack {
                    Text("\(stats.total)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)

                VStack {
                    Text("\(stats.mastered)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    Text("Maîtrisé")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cardCornerRadius)
                .fill(Color.appCardBackground)
        )
    }
}

// MARK: - Stats Grid
struct StatsGrid: View {
    let stats: ProgressStats

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Non vu", count: stats.notSeen, color: .gray, icon: "circle")
            StatCard(title: "Vu", count: stats.seen, color: .blue, icon: "eye.fill")
            StatCard(title: "En cours", count: stats.inProgress, color: .orange, icon: "arrow.triangle.2.circlepath")
            StatCard(title: "À revoir", count: stats.toReview, color: .purple, icon: "arrow.counterclockwise")
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .fill(Color.appCardBackground)
        )
    }
}

// MARK: - Category Progress Row
struct CategoryProgressRow: View {
    let category: BJJCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(Color.forCategory(category.colorName))

                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(Int(category.progressPercentage))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.forCategory(category.colorName))
                        .frame(width: geometry.size.width * (category.progressPercentage / 100))
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .fill(Color.appCardBackground)
        )
    }
}

#Preview {
    ProgressionView()
        .modelContainer(for: [Video.self, BJJCategory.self, Tag.self, VideoTimestamp.self])
}
