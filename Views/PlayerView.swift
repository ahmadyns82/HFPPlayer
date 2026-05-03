import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var player: PlayerViewModel
    @State private var isDragging = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer(minLength: 20)

                // ── Album Art ───────────────────────────────────────────────
                artworkView
                    .padding(.horizontal, 32)
                    .scaleEffect(player.isPlaying ? 1.0 : 0.92)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: player.isPlaying)

                Spacer(minLength: 28)

                // ── Song Info ────────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text(player.currentSong?.title ?? "Nothing playing")
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 24)

                    Text(player.currentSong?.artist ?? "Pick a song from Folders")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 24)

                // ── Seek Bar ─────────────────────────────────────────────────
                seekBarView
                    .padding(.horizontal, 24)

                Spacer(minLength: 24)

                // ── Controls ─────────────────────────────────────────────────
                controlsView
                    .padding(.horizontal, 32)

                Spacer(minLength: 20)

                // ── Volume ──────────────────────────────────────────────────
                volumeView
                    .padding(.horizontal, 32)

                Spacer(minLength: 32)
            }
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Artwork
    private var artworkView: some View {
        ZStack {
            if let art = player.currentSong?.artwork {
                Image(uiImage: art)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 15)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 72, weight: .ultraLight))
                            .foregroundColor(.white.opacity(0.5))
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Seek bar
    private var seekBarView: some View {
        VStack(spacing: 6) {
            Slider(
                value: Binding(
                    get: { player.duration > 0 ? player.currentTime / player.duration : 0 },
                    set: { player.seek(to: $0 * player.duration) }
                )
            )
            .tint(.white)

            HStack {
                Text(formatTime(player.currentTime))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatTime(player.duration))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Controls
    private var controlsView: some View {
        HStack(spacing: 0) {
            // Shuffle
            Button {
                player.shuffle.toggle()
            } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 18))
                    .foregroundColor(player.shuffle ? .blue : .secondary)
            }

            Spacer()

            // Previous
            Button { player.previous() } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.primary)
            }

            Spacer()

            // Play / Pause — main button
            Button { player.togglePlayPause() } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 72, height: 72)
                        .shadow(color: .black.opacity(0.2), radius: 8)
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .offset(x: player.isPlaying ? 0 : 2)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Next
            Button { player.next() } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.primary)
            }

            Spacer()

            // Repeat
            Button {
                switch player.repeatMode {
                case .none: player.repeatMode = .all
                case .all:  player.repeatMode = .one
                case .one:  player.repeatMode = .none
                }
            } label: {
                Image(systemName: repeatIcon)
                    .font(.system(size: 18))
                    .foregroundColor(player.repeatMode == .none ? .secondary : .blue)
            }
        }
    }

    private var repeatIcon: String {
        switch player.repeatMode {
        case .none: return "repeat"
        case .all:  return "repeat"
        case .one:  return "repeat.1"
        }
    }

    // MARK: - Volume
    private var volumeView: some View {
        HStack(spacing: 10) {
            Image(systemName: "speaker.fill")
                .foregroundColor(.secondary)
                .font(.system(size: 13))
            Slider(value: $player.volume)
                .tint(.secondary)
            Image(systemName: "speaker.wave.3.fill")
                .foregroundColor(.secondary)
                .font(.system(size: 13))
        }
    }

    private func formatTime(_ t: TimeInterval) -> String {
        guard t.isFinite && !t.isNaN else { return "0:00" }
        let m = Int(t) / 60; let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}
