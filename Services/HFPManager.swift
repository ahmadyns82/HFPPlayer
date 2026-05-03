import Foundation
import AVFoundation

final class HFPManager: ObservableObject {

    static let shared = HFPManager()

    @Published var isEnabled  = false
    @Published var routeInfo  = "Standard audio"

    private let audioSession  = AudioSessionManager.shared
    private var routeObserver: Any?

    private init() {
        routeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.updateRouteInfo()
        }
    }

    func enable(playerVM: PlayerViewModel) {
        isEnabled = true
        Task { @MainActor in
            let wasPlaying = playerVM.isPlaying
            if wasPlaying { playerVM.pause() }
            self.audioSession.configureForHFP()
            if wasPlaying {
                try? await Task.sleep(nanoseconds: 300_000_000)
                playerVM.resume()
            }
        }
        updateRouteInfo()
    }

    func disable(playerVM: PlayerViewModel) {
        isEnabled = false
        Task { @MainActor in
            let wasPlaying = playerVM.isPlaying
            if wasPlaying { playerVM.pause() }
            self.audioSession.configureForMusic()
            if wasPlaying {
                try? await Task.sleep(nanoseconds: 300_000_000)
                playerVM.resume()
            }
        }
        updateRouteInfo()
    }

    private func updateRouteInfo() {
        DispatchQueue.main.async { [weak self] in
            self?.routeInfo = self?.audioSession.currentRoute ?? "Unknown"
        }
    }

    deinit {
        if let obs = routeObserver { NotificationCenter.default.removeObserver(obs) }
    }
}
