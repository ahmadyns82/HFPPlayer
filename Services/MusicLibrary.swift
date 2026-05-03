import Foundation
import MediaPlayer
import UIKit

/// Scans both the on-device MediaPlayer library and the Files app
/// (Documents + iCloud Drive) for playable audio files.
final class MusicLibrary: ObservableObject {

    @Published var folders: [MusicFolder] = []
    @Published var allSongs: [Song]       = []
    @Published var isLoading              = false
    @Published var authStatus: MPMediaLibraryAuthorizationStatus = .notDetermined

    static let shared = MusicLibrary()
    private init() {}

    // MARK: - Load
    func load() {
        isLoading = true
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            let songs = await self.scanAll()
            let grouped = self.groupByFolder(songs)
            await MainActor.run {
                self.allSongs = songs
                self.folders  = grouped
                self.isLoading = false
            }
        }
    }

    // MARK: - Scanning
    private func scanAll() async -> [Song] {
        var songs: [Song] = []

        // 1. Apple Music / iPod library (requires permission)
        let status = MPMediaLibrary.authorizationStatus()
        await MainActor.run { self.authStatus = status }
        if status == .authorized || status == .notDetermined {
            let granted = await requestLibraryAccess()
            if granted { songs += scanMediaLibrary() }
        }

        // 2. Files app — app Documents folder (no permission needed)
        songs += scanDirectory(url: documentsURL(), folderName: "Documents")

        // 3. Files app — iCloud Drive container (if available)
        if let icloud = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
                .appendingPathComponent("Documents") {
            songs += scanDirectory(url: icloud, folderName: "iCloud Drive")
        }

        // Deduplicate by URL
        var seen = Set<URL>()
        return songs.filter { seen.insert($0.url).inserted }
    }

    private func requestLibraryAccess() async -> Bool {
        await withCheckedContinuation { cont in
            MPMediaLibrary.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
    }

    private func scanMediaLibrary() -> [Song] {
        guard let collections = MPMediaQuery.songs().collections else { return [] }
        var songs: [Song] = []
        for collection in collections {
            for item in collection.items {
                guard let url = item.assetURL else { continue }
                let artwork = item.artwork?.image(at: CGSize(width: 300, height: 300))
                let folder  = item.albumTitle ?? item.artist ?? "Unknown"
                songs.append(Song(
                    title:      item.title ?? "Unknown Title",
                    artist:     item.artist ?? "Unknown Artist",
                    album:      item.albumTitle ?? "",
                    duration:   item.playbackDuration,
                    url:        url,
                    folderName: folder,
                    artwork:    artwork,
                    mediaItem:  item
                ))
            }
        }
        return songs
    }

    private func scanDirectory(url: URL, folderName: String) -> [Song] {
        var songs: [Song] = []
        guard let items = try? FileManager.default.contentsOfDirectory(
                at: url, includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles) else { return [] }

        for item in items {
            let isDir = (try? item.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            if isDir {
                // Recurse one level deep
                songs += scanDirectory(url: item, folderName: item.lastPathComponent)
            } else if isAudioFile(item) {
                let title    = item.deletingPathExtension().lastPathComponent
                let duration = audioDuration(url: item)
                songs.append(Song(
                    title:      title,
                    artist:     "Unknown Artist",
                    album:      "",
                    duration:   duration,
                    url:        item,
                    folderName: folderName
                ))
            }
        }
        return songs
    }

    private func isAudioFile(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["mp3","m4a","aac","wav","aiff","flac","ogg","opus","caf"].contains(ext)
    }

    private func audioDuration(url: URL) -> TimeInterval {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }

    private func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func groupByFolder(_ songs: [Song]) -> [MusicFolder] {
        var map: [String: [Song]] = [:]
        for song in songs {
            map[song.folderName, default: []].append(song)
        }
        return map.map { MusicFolder(name: $0.key, songs: $0.value) }
                  .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

// Needed for AVURLAsset duration
import AVFoundation
