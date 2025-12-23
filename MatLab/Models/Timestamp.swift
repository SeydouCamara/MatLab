import Foundation
import SwiftData

@Model
final class VideoTimestamp {
    var id: UUID
    var time: TimeInterval
    var label: String
    var video: Video?

    init(
        id: UUID = UUID(),
        time: TimeInterval,
        label: String,
        video: Video? = nil
    ) {
        self.id = id
        self.time = time
        self.label = label
        self.video = video
    }
}

// MARK: - Computed Properties
extension VideoTimestamp {
    var formattedTime: String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
