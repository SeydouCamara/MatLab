import Foundation
import SwiftData

@Observable
class VideoScannerService {
    static let shared = VideoScannerService()

    private init() {}

    // MARK: - Videos Directory
    var videosDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videosPath = documentsPath.appendingPathComponent("MatLab/Videos", isDirectory: true)

        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: videosPath.path) {
            try? FileManager.default.createDirectory(at: videosPath, withIntermediateDirectories: true)
        }

        return videosPath
    }

    // MARK: - Scan Videos
    func scanVideos(modelContext: ModelContext) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: videosDirectory, includingPropertiesForKeys: [.isRegularFileKey])

        let videoExtensions = ["mp4", "mov", "avi", "mkv", "m4v"]
        let videoFiles = contents.filter { url in
            videoExtensions.contains(url.pathExtension.lowercased())
        }

        print("📁 Found \(videoFiles.count) video files in \(videosDirectory.path)")

        for videoURL in videoFiles {
            processVideoFile(url: videoURL, modelContext: modelContext)
        }

        try modelContext.save()
    }

    // MARK: - Parse Video Filename
    private func processVideoFile(url: URL, modelContext: ModelContext) {
        let fileName = url.deletingPathExtension().lastPathComponent

        // Parse format: "Category - Title - Creator"
        let components = fileName.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }

        guard components.count >= 3 else {
            print("⚠️ Skipping invalid filename format: \(fileName)")
            return
        }

        let categoryName = components[0]
        let titleComponents = components[1..<(components.count - 1)]
        let title = titleComponents.joined(separator: " - ")
        let creator = components.last ?? ""

        // Find or create category
        let category = findOrCreateCategory(name: categoryName, modelContext: modelContext)

        // Check if video already exists
        let existingVideos = try? modelContext.fetch(FetchDescriptor<Video>(
            predicate: #Predicate { video in
                video.title == title && video.instructor == creator
            }
        ))

        if existingVideos?.isEmpty == false {
            print("⏭️ Video already exists: \(title)")
            return
        }

        // Create video
        let video = Video(
            title: title,
            instructor: creator,
            sourceType: .local,
            localPath: url.path,
            category: category
        )

        modelContext.insert(video)
        print("✅ Added: \(categoryName) - \(title) - \(creator)")
    }

    // MARK: - Find or Create Category
    private func findOrCreateCategory(name: String, modelContext: ModelContext) -> BJJCategory? {
        // Try to find existing category (case-insensitive)
        let fetchDescriptor = FetchDescriptor<BJJCategory>(
            predicate: #Predicate { category in
                category.name.localizedStandardContains(name)
            }
        )

        if let existingCategory = try? modelContext.fetch(fetchDescriptor).first {
            return existingCategory
        }

        // Create new category
        let newCategory = BJJCategory(
            name: name,
            icon: "folder.fill",
            colorName: "blue",
            sortOrder: 999
        )
        modelContext.insert(newCategory)
        print("🆕 Created new category: \(name)")

        return newCategory
    }

    // MARK: - Get Video File Size
    func getFileSize(for video: Video) -> String? {
        guard let path = video.localPath else { return nil }
        let url = URL(fileURLWithPath: path)

        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int64 else {
            return nil
        }

        return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}
