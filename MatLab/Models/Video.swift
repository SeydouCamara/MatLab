import Foundation
import SwiftData

@Model
final class Video {
    var id: UUID
    var title: String
    var instructor: String?
    var videoDescription: String?
    var sourceType: SourceType
    var sourceURL: String?
    var localPath: String?
    var thumbnailPath: String?
    var duration: TimeInterval?
    var category: BJJCategory?
    @Relationship(deleteRule: .nullify, inverse: \Tag.videos)
    var tags: [Tag]
    var progressStatus: ProgressStatus
    var isFavorite: Bool
    var notes: String?
    @Relationship(deleteRule: .cascade, inverse: \VideoTimestamp.video)
    var timestamps: [VideoTimestamp]
    var lastWatched: Date?
    var dateAdded: Date
    var giType: GiType
    var level: TechniqueLevel
    var videoType: VideoType

    init(
        id: UUID = UUID(),
        title: String,
        instructor: String? = nil,
        videoDescription: String? = nil,
        sourceType: SourceType = .streaming,
        sourceURL: String? = nil,
        localPath: String? = nil,
        thumbnailPath: String? = nil,
        duration: TimeInterval? = nil,
        category: BJJCategory? = nil,
        tags: [Tag] = [],
        progressStatus: ProgressStatus = .notSeen,
        isFavorite: Bool = false,
        notes: String? = nil,
        timestamps: [VideoTimestamp] = [],
        lastWatched: Date? = nil,
        dateAdded: Date = Date(),
        giType: GiType = .both,
        level: TechniqueLevel = .beginner,
        videoType: VideoType = .instructional
    ) {
        self.id = id
        self.title = title
        self.instructor = instructor
        self.videoDescription = videoDescription
        self.sourceType = sourceType
        self.sourceURL = sourceURL
        self.localPath = localPath
        self.thumbnailPath = thumbnailPath
        self.duration = duration
        self.category = category
        self.tags = tags
        self.progressStatus = progressStatus
        self.isFavorite = isFavorite
        self.notes = notes
        self.timestamps = timestamps
        self.lastWatched = lastWatched
        self.dateAdded = dateAdded
        self.giType = giType
        self.level = level
        self.videoType = videoType
    }
}

// MARK: - Computed Properties
extension Video {
    var isAvailableOffline: Bool {
        sourceType == .local || sourceType == .downloaded
    }

    var formattedDuration: String {
        guard let duration = duration else { return "--:--" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
