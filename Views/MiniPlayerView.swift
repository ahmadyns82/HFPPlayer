import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var player: PlayerViewModel
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Thin progress line
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.blue)
                    .frame(
                        width: player.duration > 0
                            ? geo.size.width * CGFloat(player.currentTime / player.duration)
                            : 0
                    )
            }
            .frame(height: 2)
            .background(Color.white.opacity(0.1))

            HStack(spacing: 12) {
                // Artwork
                Group {
                    if let art = player.currentSong?.artwork {
                        Image(uiImage: art)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "music.note")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 40, height: 40)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 6))

                // Title + artist
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.currentSong?.title ?? "")
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    Text(player.currentSong?.artist ?? "")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Controls
                HStack(spacing: 20) {
                    Button { player.previous() } label: {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 20))
                    }
                    Button { player.togglePlayPause() } label: {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 22))
                    }
                    Button { player.next() } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20))
                    }
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}
