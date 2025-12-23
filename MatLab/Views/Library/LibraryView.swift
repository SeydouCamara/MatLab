import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BJJCategory.sortOrder) private var categories: [BJJCategory]
    @State private var showingAddVideo = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.UI.spacing) {
                    // Quick Access Section
                    if !categories.isEmpty {
                        VStack(alignment: .leading, spacing: AppConstants.UI.smallSpacing) {
                            Text("Accès rapide")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    QuickAccessCard(
                                        title: "Continuer",
                                        icon: "play.circle.fill",
                                        color: .orange
                                    )

                                    QuickAccessCard(
                                        title: "Récentes",
                                        icon: "clock.fill",
                                        color: .blue
                                    )

                                    QuickAccessCard(
                                        title: "Favoris",
                                        icon: "star.fill",
                                        color: .yellow
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Categories Grid
                    VStack(alignment: .leading, spacing: AppConstants.UI.smallSpacing) {
                        Text("Catégories")
                            .font(.headline)
                            .padding(.horizontal)

                        if categories.isEmpty {
                            EmptyLibraryView()
                        } else {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ],
                                spacing: 12
                            ) {
                                ForEach(categories.filter { $0.isRootCategory }) { category in
                                    CategoryCard(category: category)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Bibliothèque")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddVideo = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddVideo) {
                Text("Add Video Form")
            }
            .onAppear {
                if categories.isEmpty {
                    createDefaultCategories()
                }
            }
        }
    }

    private func createDefaultCategories() {
        let defaultCategories = BJJCategory.createDefaultCategories()
        defaultCategories.forEach { modelContext.insert($0) }
        try? modelContext.save()
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: BJJCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(category.videoCount)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Text(category.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(2)

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.3))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white)
                        .frame(width: geometry.size.width * (category.progressPercentage / 100), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding()
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cardCornerRadius)
                .fill(Color.forCategory(category.colorName).gradient)
        )
    }
}

// MARK: - Quick Access Card
struct QuickAccessCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
        }
        .frame(width: 100, height: 80)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .fill(color.gradient)
        )
    }
}

// MARK: - Empty Library View
struct EmptyLibraryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundStyle(.gray)

            Text("Bibliothèque vide")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Ajoutez vos premières vidéos BJJ")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    LibraryView()
        .modelContainer(for: [Video.self, BJJCategory.self, Tag.self, VideoTimestamp.self])
}
