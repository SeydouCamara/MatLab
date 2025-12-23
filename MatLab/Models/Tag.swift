import Foundation
import SwiftData

@Model
final class Tag {
    var id: UUID
    var name: String
    var colorName: String
    var videos: [Video]

    init(
        id: UUID = UUID(),
        name: String,
        colorName: String = "blue",
        videos: [Video] = []
    ) {
        self.id = id
        self.name = name
        self.colorName = colorName
        self.videos = videos
    }
}

// MARK: - Predefined Tags
extension Tag {
    static let predefinedInstructors = [
        "John Danaher",
        "Gordon Ryan",
        "Lachlan Giles",
        "Craig Jones",
        "Mikey Musumeci",
        "Marcelo Garcia",
        "Andre Galvao",
        "Keenan Cornelius",
        "Bernardo Faria",
        "Roger Gracie"
    ]
}
