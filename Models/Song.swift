import Foundation
import UIKit
import MediaPlayer

// MARK: - Song Model
struct Song: Identifiable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval
    let url: URL
    let folderName: String
    var artwork: UIImage?
    let mediaItem: MPMediaItem?

    init(title: String, artist: String, album: String,
         duration: TimeInterval, url: URL, folderName: String,
         artwork: UIImage? = nil, mediaItem: MPMediaItem? = nil) {
        self.id = UUID(); self.title = title; self.artist = artist
        self.album = album; self.duration = duration; self.url = url
        self.folderName = folderName; self.artwork = artwork
        self.mediaItem = mediaItem
    }

    var durationFormatted: String {
        let m = Int(duration) / 60; let s = Int(duration) % 60
        return String(format: "%d:%02d", m, s)
    }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Song, rhs: Song) -> Bool { lhs.id == rhs.id }
}

struct MusicFolder: Identifiable {
    let id = UUID()
    let name: String
    var songs: [Song]
    var songCount: Int { songs.count }
}
