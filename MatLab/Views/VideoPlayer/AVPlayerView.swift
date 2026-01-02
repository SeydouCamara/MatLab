import SwiftUI
import AVKit

/// Vue wrapper pour AVPlayer
struct AVPlayerView: UIViewControllerRepresentable {
    let url: URL
    @Binding var isPlaying: Bool
    @Binding var currentTime: Double
    @Binding var duration: Double
    @Binding var playbackSpeed: Float
    @Binding var seekTime: Double?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect

        context.coordinator.player = player
        context.coordinator.setupObservers()

        // Démarrer la lecture
        player.play()

        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        guard let player = context.coordinator.player else { return }

        // Gérer play/pause
        if isPlaying && player.timeControlStatus != .playing {
            player.play()
        } else if !isPlaying && player.timeControlStatus == .playing {
            player.pause()
        }

        // Gérer la vitesse de lecture
        if player.rate != 0 && player.rate != playbackSpeed {
            player.rate = playbackSpeed
        }

        // Gérer le seek
        if let seekTarget = seekTime {
            let time = CMTime(seconds: seekTarget, preferredTimescale: 600)
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            DispatchQueue.main.async {
                self.seekTime = nil
            }
        }
    }

    static func dismantleUIViewController(_ controller: AVPlayerViewController, coordinator: Coordinator) {
        coordinator.cleanup()
    }

    class Coordinator: NSObject {
        var parent: AVPlayerView
        var player: AVPlayer?
        var timeObserver: Any?
        var statusObserver: NSKeyValueObservation?

        init(_ parent: AVPlayerView) {
            self.parent = parent
            super.init()
        }

        func setupObservers() {
            guard let player = player else { return }

            // Observer pour le temps actuel
            let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard let self = self else { return }

                // Ne pas mettre à jour si on est en train de seek
                if self.parent.seekTime != nil { return }

                self.parent.currentTime = time.seconds
                self.parent.isPlaying = player.timeControlStatus == .playing
            }

            // Observer pour la durée
            statusObserver = player.currentItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
                guard let self = self, item.status == .readyToPlay else { return }
                DispatchQueue.main.async {
                    self.parent.duration = item.duration.seconds
                }
            }
        }

        func cleanup() {
            if let observer = timeObserver {
                player?.removeTimeObserver(observer)
            }
            statusObserver?.invalidate()
            player?.pause()
            player = nil
        }
    }
}

/// Contrôleur de lecture avec interface personnalisée
struct VideoPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    let video: Video

    @State private var isPlaying = true
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var playbackSpeed: Float = 1.0
    @State private var seekTime: Double? = nil
    @State private var showControls = true
    @State private var hideControlsTask: Task<Void, Never>?
    @State private var isSeeking = false

    private let speeds: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let url = videoURL {
                AVPlayerView(
                    url: url,
                    isPlaying: $isPlaying,
                    currentTime: $currentTime,
                    duration: $duration,
                    playbackSpeed: $playbackSpeed,
                    seekTime: $seekTime
                )
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showControls.toggle()
                    }
                    scheduleHideControls()
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.orange)
                    Text("Vidéo introuvable")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }

            // Overlay des contrôles
            if showControls {
                controlsOverlay
            }
        }
        .onAppear {
            scheduleHideControls()
        }
        .onDisappear {
            hideControlsTask?.cancel()
        }
        .statusBarHidden(true)
    }

    private var videoURL: URL? {
        // Priorité: streaming URL, sinon fichier local
        if let sourceURL = video.sourceURL, !sourceURL.isEmpty {
            return URL(string: sourceURL)
        } else if let localPath = video.localPath {
            let url = URL(fileURLWithPath: localPath)
            if FileManager.default.fileExists(atPath: localPath) {
                return url
            }
        }
        return nil
    }

    private var controlsOverlay: some View {
        VStack {
            // Header avec bouton fermer et titre
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }

                Spacer()

                Text(video.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .shadow(radius: 4)

                Spacer()

                // Menu vitesse
                Menu {
                    ForEach(speeds, id: \.self) { speed in
                        Button {
                            playbackSpeed = speed
                        } label: {
                            HStack {
                                Text(speedLabel(speed))
                                if playbackSpeed == speed {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Text(speedLabel(playbackSpeed))
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
            .padding()

            Spacer()

            // Contrôles de lecture centraux
            HStack(spacing: 50) {
                // Reculer 10s
                Button {
                    seekRelative(-10)
                } label: {
                    Image(systemName: "gobackward.10")
                        .font(.system(size: 35))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }

                // Play/Pause
                Button {
                    isPlaying.toggle()
                    scheduleHideControls()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }

                // Avancer 10s
                Button {
                    seekRelative(10)
                } label: {
                    Image(systemName: "goforward.10")
                        .font(.system(size: 35))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }
            }

            Spacer()

            // Barre de progression
            VStack(spacing: 8) {
                // Slider avec gestion du drag
                Slider(
                    value: Binding(
                        get: { isSeeking ? (seekTime ?? currentTime) : currentTime },
                        set: { newValue in
                            isSeeking = true
                            seekTime = newValue
                        }
                    ),
                    in: 0...max(duration, 1),
                    onEditingChanged: { editing in
                        if !editing {
                            // Quand on relâche le slider
                            isSeeking = false
                        }
                    }
                )
                .tint(.white)

                // Temps
                HStack {
                    Text(formatTime(isSeeking ? (seekTime ?? currentTime) : currentTime))
                        .font(.caption)
                        .foregroundStyle(.white)
                        .monospacedDigit()

                    Spacer()

                    Text(formatTime(duration))
                        .font(.caption)
                        .foregroundStyle(.white)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(
            LinearGradient(
                colors: [.black.opacity(0.7), .clear, .clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func speedLabel(_ speed: Float) -> String {
        if speed == 1.0 {
            return "1x"
        } else if speed == floor(speed) {
            return "\(Int(speed))x"
        } else {
            return String(format: "%.2gx", speed)
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && !seconds.isNaN else { return "00:00" }

        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }

    private func seekRelative(_ seconds: Double) {
        let newTime = max(0, min(duration, currentTime + seconds))
        seekTime = newTime
    }

    private func scheduleHideControls() {
        hideControlsTask?.cancel()
        hideControlsTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 secondes
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showControls = false
                    }
                }
            }
        }
    }
}
