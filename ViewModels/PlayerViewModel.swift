import AVFoundation
import Combine
import MediaPlayer
import UIKit

@MainActor
final class PlayerViewModel: ObservableObject {

    // MARK: - Published state
    @Published var currentSong: Song?
    @Published var playlist:    [Song] = []
    @Published var currentIndex = -1
    @Published var isPlaying    = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration:    TimeInterval = 0
    @Published var shuffle      = false
    @Published var repeatMode:  RepeatMode   = .none
    @Published var volume: Float = 1.0 {
        didSet { player?.volume = volume }
    }

    enum RepeatMode { case none, one, all }

    // MARK: - Private
    private var player: AVAudioPlayer?
    private var progressTimer: Timer?
    private let audioSession = AudioSessionManager.shared

    // MARK: - Play queue
    func setQueue(_ songs: [Song], startAt index: Int) {
        playlist     = songs
        currentIndex = index
        playCurrent()
    }

    func playSong(_ song: Song) {
        if let idx = playlist.firstIndex(of: song) {
            currentIndex = idx
        } else {
            playlist     = [song]
            currentIndex = 0
        }
        playCurrent()
    }

    private func playCurrent() {
        guard currentIndex >= 0, currentIndex < playlist.count else { return }
        let song = playlist[currentIndex]
        play(song: song)
    }

    // MARK: - Core playback
    private func play(song: Song) {
        stopTimer()
        currentSong = song

        do {
            // Re-activate session each time to ensure clean routing
            try AVAudioSession.sharedInstance().setActive(true)

            let newPlayer = try AVAudioPlayer(contentsOf: song.url)
            newPlayer.delegate        = PlayerDelegate.shared
            newPlayer.enableRate      = true
            newPlayer.prepareToPlay()
            newPlayer.volume          = volume

            // High-quality settings
            newPlayer.numberOfLoops   = repeatMode == .one ? -1 : 0

            player   = newPlayer
            duration = newPlayer.duration

            newPlayer.play()
            isPlaying = true
            startTimer()
            updateNowPlayingInfo()

            // Register completion via delegate
            PlayerDelegate.shared.onFinish = { [weak self] in
                Task { @MainActor in self?.handleSongFinished() }
            }
        } catch {
            print("Playback error: \(error.localizedDescription)")
        }
    }

    func togglePlayPause() {
        if isPlaying { pause() } else { resume() }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
        updateNowPlayingInfo()
    }

    func resume() {
        player?.play()
        isPlaying = true
        startTimer()
        updateNowPlayingInfo()
    }

    func next() {
        guard !playlist.isEmpty else { return }
        if shuffle {
            currentIndex = Int.random(in: 0..<playlist.count)
        } else {
            currentIndex = (currentIndex + 1) % playlist.count
        }
        playCurrent()
    }

    func previous() {
        guard !playlist.isEmpty else { return }
        if currentTime > 3 {
            seek(to: 0); return
        }
        currentIndex = (currentIndex - 1 + playlist.count) % playlist.count
        playCurrent()
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
        updateNowPlayingInfo()
    }

    // MARK: - Song finish handler
    private func handleSongFinished() {
        switch repeatMode {
        case .one:  playCurrent()
        case .all:  next()
        case .none:
            if currentIndex < playlist.count - 1 { next() }
            else { isPlaying = false; stopTimer() }
        }
    }

    // MARK: - Progress timer
    private func startTimer() {
        stopTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self, let p = self.player else { return }
            Task { @MainActor in
                self.currentTime = p.currentTime
                self.updateNowPlayingInfo()
            }
        }
    }

    private func stopTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    // MARK: - Lock screen / Control Centre
    private func updateNowPlayingInfo() {
        guard let song = currentSong else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle:           song.title,
            MPMediaItemPropertyArtist:          song.artist,
            MPMediaItemPropertyAlbumTitle:      song.album,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]
        if let art = song.artwork {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                boundsSize: art.size) { _ in art }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func setupRemoteControls() {
        let rc = MPRemoteCommandCenter.shared()
        rc.playCommand.addTarget  { [weak self] _ in self?.resume(); return .success }
        rc.pauseCommand.addTarget { [weak self] _ in self?.pause(); return .success }
        rc.nextTrackCommand.addTarget  { [weak self] _ in self?.next(); return .success }
        rc.previousTrackCommand.addTarget { [weak self] _ in self?.previous(); return .success }
        rc.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let e = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(to: e.positionTime); return .success
        }
    }
}

// MARK: - AVAudioPlayerDelegate bridge
final class PlayerDelegate: NSObject, AVAudioPlayerDelegate {
    static let shared = PlayerDelegate()
    var onFinish: (() -> Void)?
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag { onFinish?() }
    }
}
