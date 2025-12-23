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

        // Get course folders (Category - Title - Creator)
        let courseFolders = try fileManager.contentsOfDirectory(
            at: videosDirectory,
            includingPropertiesForKeys: [.isDirectoryKey]
        ).filter { url in
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
            return isDirectory.boolValue && !url.lastPathComponent.hasPrefix(".")
        }

        print("📁 Found \(courseFolders.count) course folders in \(videosDirectory.path)")

        for courseFolder in courseFolders {
            scanCourseFolder(url: courseFolder, modelContext: modelContext)
        }

        try modelContext.save()
    }

    // MARK: - Scan Course Folder
    private func scanCourseFolder(url: URL, modelContext: ModelContext) {
        let fileManager = FileManager.default
        let videoExtensions = ["mp4", "mov", "avi", "mkv", "m4v"]

        // Parse folder name: "Category - Title - Creator"
        let folderName = url.lastPathComponent
        let components = folderName.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }

        guard components.count >= 3 else {
            print("⚠️ Skipping invalid folder format: \(folderName)")
            return
        }

        let categoryName = components[0]
        let titleComponents = components[1..<(components.count - 1)]
        let courseTitle = titleComponents.joined(separator: " - ")
        let creator = components.last ?? ""

        print("📂 Scanning: \(categoryName) - \(courseTitle) - \(creator)")

        // Find or create category
        let category = findOrCreateCategory(name: categoryName, modelContext: modelContext)

        // Recursively find all video files in subfolders
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return
        }

        var videoCount = 0
        for case let fileURL as URL in enumerator {
            guard videoExtensions.contains(fileURL.pathExtension.lowercased()) else {
                continue
            }

            // Get relative path from course folder for video title
            let relativePath = fileURL.path.replacingOccurrences(of: url.path + "/", with: "")
            let videoTitle = "\(courseTitle) - " + relativePath
                .replacingOccurrences(of: ".mp4", with: "")
                .replacingOccurrences(of: ".mov", with: "")
                .replacingOccurrences(of: ".avi", with: "")
                .replacingOccurrences(of: ".mkv", with: "")
                .replacingOccurrences(of: ".m4v", with: "")

            // Check if video already exists by local path
            let filePath = fileURL.path
            let descriptor = FetchDescriptor<Video>(
                predicate: #Predicate<Video> { video in
                    video.localPath == filePath
                }
            )
            let existingVideos = try? modelContext.fetch(descriptor)

            if existingVideos?.isEmpty == false {
                continue
            }

            // Create video
            let video = Video(
                title: videoTitle,
                instructor: creator,
                sourceType: .local,
                localPath: fileURL.path,
                category: category
            )

            modelContext.insert(video)
            videoCount += 1
        }

        print("✅ Added \(videoCount) videos from \(courseTitle)")
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
