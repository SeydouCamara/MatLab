import SwiftUI

struct SettingsView: View {
    @State private var defaultPlaybackSpeed: Float = 1.0
    @State private var autoDownloadQuality = "720p"
    @State private var enableNotifications = true

    var body: some View {
        NavigationStack {
            List {
                // App Info
                Section {
                    HStack {
                        Image(systemName: "app.fill")
                            .font(.title)
                            .foregroundStyle(Color.appPrimary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(AppConstants.appName)
                                .font(.headline)
                            Text("Version \(AppConstants.version)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Playback
                Section("Lecture") {
                    Picker("Vitesse par défaut", selection: $defaultPlaybackSpeed) {
                        ForEach(AppConstants.Player.playbackSpeeds, id: \.self) { speed in
                            Text("\(String(format: "%.2f", speed))x")
                                .tag(speed)
                        }
                    }

                    Toggle("Lecture automatique", isOn: .constant(false))
                }

                // Downloads
                Section("Téléchargements") {
                    Picker("Qualité par défaut", selection: $autoDownloadQuality) {
                        Text("720p").tag("720p")
                        Text("1080p").tag("1080p")
                    }

                    NavigationLink {
                        Text("Manage Storage")
                    } label: {
                        HStack {
                            Text("Gérer le stockage")
                            Spacer()
                            Text("2.4 GB")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Notifications
                Section("Notifications") {
                    Toggle("Activer les notifications", isOn: $enableNotifications)

                    if enableNotifications {
                        Toggle("Rappels d'entraînement", isOn: .constant(true))
                        Toggle("Nouvelles vidéos", isOn: .constant(false))
                    }
                }

                // Categories
                Section("Bibliothèque") {
                    NavigationLink("Gérer les catégories") {
                        Text("Categories Management")
                    }

                    NavigationLink("Gérer les tags") {
                        Text("Tags Management")
                    }

                    Button("Scanner le dossier Vidéos") {
                        // Trigger scan
                    }

                    HStack {
                        Text("Dossier Vidéos")
                        Spacer()
                        Text(VideoScannerService.shared.videosDirectory.lastPathComponent)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }

                // Data
                Section("Données") {
                    Button("Exporter la bibliothèque") {
                        // Export
                    }

                    Button("Importer la bibliothèque") {
                        // Import
                    }

                    Button(role: .destructive) {
                        // Reset
                    } label: {
                        Text("Réinitialiser l'app")
                    }
                }

                // About
                Section("À propos") {
                    Link(destination: URL(string: "https://github.com/SeydouCamara")!) {
                        HStack {
                            Text("Site web")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    NavigationLink("Licences open source") {
                        Text("Licenses")
                    }
                }
            }
            .navigationTitle("Réglages")
        }
    }
}

#Preview {
    SettingsView()
}
