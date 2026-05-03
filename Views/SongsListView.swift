import SwiftUI

struct SongsListView: View {
    @EnvironmentObject var player: PlayerViewModel
    let songs: [Song]
    let title: String
    @State private var searchText = ""

    var filtered: [Song] {
        searchText.isEmpty ? songs
            : songs.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.artist.localizedCaseInsensitiveContains(searchText)
              }
    }

    var body: some View {
        Group {
            if songs.isEmpty {
                EmptyStateView(icon: "music.note", title: "No Songs",
                               message: "This folder has no playable audio files.")
            } else {
                List {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { idx, song in
                        SongRow(song: song, index: idx + 1,
                                isCurrent: player.currentSong?.id == song.id,
                                isPlaying: player.isPlaying && player.currentSong?.id == song.id)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                player.setQueue(filtered, startAt: idx)
                            }
                            .listRowBackground(
                                player.currentSong?.id == song.id
                                    ? Color.blue.opacity(0.1)
                                    : Color(.secondarySystemBackground)
                            )
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText, prompt: "Search songs")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            let shuffled = songs.shuffled()
                            player.shuffle = true
                            player.setQueue(shuffled, startAt: 0)
                        } label: {
                            Image(systemName: "shuffle")
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SongRow: View {
    let song:      Song
    let index:     Int
    let isCurrent: Bool
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Track number / playing indicator
            ZStack {
                if isPlaying {
                    Image(systemName: "waveform")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .symbolEffect(.variableColor.iterative, isActive: true)
                } else if isCurrent {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                } else {
                    Text("\(index)")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 24)

            // Artwork or placeholder
            Group {
                if let art = song.artwork {
                    Image(uiImage: art)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 44, height: 44)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 6))

            // Title + artist
            VStack(alignment: .leading, spacing: 3) {
                Text(song.title)
                    .font(.system(size: 15, weight: isCurrent ? .semibold : .regular))
                    .foregroundColor(isCurrent ? .blue : .primary)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Duration
            Text(song.durationFormatted)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 3)
    }
}
