import SwiftUI

// MARK: - App Colors
extension Color {
    // Primary BJJ Green
    static let appPrimary = Color(red: 0.18, green: 0.49, blue: 0.196)

    // Secondary Blue (like blue belt)
    static let appSecondary = Color(red: 0.086, green: 0.396, blue: 0.753)

    // Accent Purple (like purple belt)
    static let appAccent = Color(red: 0.482, green: 0.122, blue: 0.635)

    // Warning Orange
    static let appWarning = Color(red: 0.902, green: 0.318, blue: 0)

    // Success Green
    static let appSuccess = Color(red: 0.18, green: 0.49, blue: 0.196)

    // Error Red
    static let appError = Color(red: 0.863, green: 0.078, blue: 0.235)

    // Backgrounds
    static let appBackground = Color(UIColor.systemBackground)
    static let appGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let appCardBackground = Color(UIColor.secondarySystemGroupedBackground)

    // Belt Colors
    static let beltWhite = Color.white
    static let beltBlue = Color(red: 0.086, green: 0.396, blue: 0.753)
    static let beltPurple = Color(red: 0.482, green: 0.122, blue: 0.635)
    static let beltBrown = Color(red: 0.549, green: 0.337, blue: 0.169)
    static let beltBlack = Color.black
}

// MARK: - App Constants
enum AppConstants {
    static let appName = "MatLab"
    static let version = "1.0"

    // Video Player
    enum Player {
        static let skipForwardSeconds: Double = 10
        static let skipBackwardSeconds: Double = 10
        static let playbackSpeeds: [Float] = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    }

    // Storage
    enum Storage {
        static let videosDirectory = "Videos"
        static let thumbnailsDirectory = "Thumbnails"
    }

    // UI
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let cardCornerRadius: CGFloat = 16
        static let spacing: CGFloat = 16
        static let smallSpacing: CGFloat = 8
    }
}

// MARK: - Category Colors Helper
extension Color {
    static func forCategory(_ colorName: String) -> Color {
        switch colorName {
        case "orange": return .orange
        case "blue": return .appSecondary
        case "green": return .appPrimary
        case "red": return .red
        case "purple": return .appAccent
        case "brown": return .brown
        case "teal": return .teal
        case "indigo": return .indigo
        case "gray": return .gray
        default: return .appPrimary
        }
    }
}

// MARK: - Progress Status Color
extension Color {
    static func forProgressStatus(_ status: ProgressStatus) -> Color {
        switch status {
        case .notSeen: return .gray
        case .seen: return .blue
        case .inProgress: return .orange
        case .mastered: return .green
        case .toReview: return .purple
        }
    }
}
