import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    let video: Video
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView("Chargement...")
                    .tint(.white)
            }

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                    .padding()

                    Spacer()
                }

                Spacer()
            }
        }
        .onAppear {
            loadVideo()
        }
        .onDisappear {
            player?.pause()
        }
    }

    private func loadVideo() {
        guard let path = video.localPath else { return }
        let url = URL(fileURLWithPath: path)

        guard FileManager.default.fileExists(atPath: path) else {
            print("❌ Video file not found: \(path)")
            return
        }

        player = AVPlayer(url: url)
        player?.play()
    }
}
