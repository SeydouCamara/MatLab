import Foundation
import SwiftData

@Model
final class BJJCategory {
    var id: UUID
    var name: String
    var icon: String
    var colorName: String
    var parentCategory: BJJCategory?
    @Relationship(deleteRule: .cascade, inverse: \BJJCategory.parentCategory)
    var subcategories: [BJJCategory]
    @Relationship(deleteRule: .nullify, inverse: \Video.category)
    var videos: [Video]
    var sortOrder: Int
    var categoryType: String? // Pour les catégories prédéfinies

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "folder.fill",
        colorName: String = "blue",
        parentCategory: BJJCategory? = nil,
        subcategories: [BJJCategory] = [],
        videos: [Video] = [],
        sortOrder: Int = 0,
        categoryType: String? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorName = colorName
        self.parentCategory = parentCategory
        self.subcategories = subcategories
        self.videos = videos
        self.sortOrder = sortOrder
        self.categoryType = categoryType
    }
}

// MARK: - Computed Properties
extension BJJCategory {
    var videoCount: Int {
        videos.count + subcategories.reduce(0) { $0 + $1.videoCount }
    }

    var progressPercentage: Double {
        let total = videoCount
        guard total > 0 else { return 0 }

        let mastered = videos.filter { $0.progressStatus == .mastered }.count +
                       subcategories.reduce(0) { $0 + $1.videos.filter { $0.progressStatus == .mastered }.count }

        return Double(mastered) / Double(total) * 100
    }

    var isRootCategory: Bool {
        parentCategory == nil
    }
}

// MARK: - Static Factory
extension BJJCategory {
    static func createDefaultCategories() -> [BJJCategory] {
        BJJCategoryType.allCases.enumerated().map { index, type in
            BJJCategory(
                name: type.rawValue,
                icon: type.icon,
                colorName: type.color,
                sortOrder: index,
                categoryType: type.rawValue
            )
        }
    }
}
