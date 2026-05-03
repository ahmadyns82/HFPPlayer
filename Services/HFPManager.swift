import Foundation
import AVFoundation

/// Manages optional Bluetooth HFP/SCO routing.
/// When enabled, audio is forced through the call channel so it
/// plays on car systems that only support HFP (no A2DP).
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
        ) { [weak self] notification in
            self?.handleRouteChange(notification)
        }
    }

    func enable(playerVM: PlayerViewModel) {
        isEnabled = true
        // Pause, reconfigure session for HFP, then resume
        let wasPlaying = playerVM.isPlaying
        if wasPlaying { playerVM.pause() }
        audioSession.configureForHFP()
        if wasPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                playerVM.resume()
            }
        }
        updateRouteInfo()
    }

    func disable(playerVM: PlayerViewModel) {
        isEnabled = false
        let wasPlaying = playerVM.isPlaying
        if wasPlaying { playerVM.pause() }
        audioSession.configureForMusic()
        if wasPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                playerVM.resume()
            }
        }
        updateRouteInfo()
    }

    private func handleRouteChange(_ notification: Notification) {
        updateRouteInfo()
        guard let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt else { return }
        let changeReason = AVAudioSession.RouteChangeReason(rawValue: reason) ?? .unknown
        switch changeReason {
        case .oldDeviceUnavailable:
            routeInfo = "Bluetooth disconnected"
        case .newDeviceAvailable:
            updateRouteInfo()
        default: break
        }
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
