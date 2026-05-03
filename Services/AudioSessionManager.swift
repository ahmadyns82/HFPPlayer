import AVFoundation
import Foundation

/// Manages AVAudioSession configuration for best audio quality.
/// Handles normal playback, HFP/SCO routing, and interruptions.
final class AudioSessionManager: ObservableObject {

    static let shared = AudioSessionManager()
    @Published var isHFPActive = false
    @Published var currentRoute = ""

    private let session = AVAudioSession.sharedInstance()
    private var routeObserver: Any?

    private init() {
        observeRouteChanges()
    }

    // MARK: - Normal high-quality playback
    /// Use .playback category for crystal-clear music through speaker/earphones.
    /// Supports background audio, locks screen controls.
    func configureForMusic() {
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.allowBluetooth, .allowBluetoothA2DP]
            )
            try session.setPreferredSampleRate(44100)
            try session.setPreferredIOBufferDuration(0.005) // 5ms low latency
            try session.setActive(true)
            isHFPActive = false
            updateRouteDescription()
        } catch {
            print("AudioSession music config error: \(error)")
        }
    }

    // MARK: - HFP / SCO routing for cars without A2DP
    /// Switches to .voiceChat mode which forces SCO/HFP routing.
    /// Audio quality drops to 8–16 kHz but reaches HFP-only car systems.
    func configureForHFP() {
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,           // forces HFP SCO path
                options: [.allowBluetooth,  // enables SCO
                          .defaultToSpeaker]
            )
            try session.setPreferredSampleRate(16000) // wideband HFP (mSBC)
            try session.setActive(true)

            // Override output to speaker in case earpiece is selected
            try session.overrideOutputAudioPort(.speaker)
            isHFPActive = true
            updateRouteDescription()
        } catch {
            print("AudioSession HFP config error: \(error)")
        }
    }

    func deactivate() {
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Route monitoring
    private func observeRouteChanges() {
        routeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.updateRouteDescription()
        }
    }

    private func updateRouteDescription() {
        let outputs = session.currentRoute.outputs
        currentRoute = outputs.map { $0.portName }.joined(separator: ", ")
    }

    var isBluetoothConnected: Bool {
        session.currentRoute.outputs.contains {
            [.bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains($0.portType)
        }
    }

    var bluetoothPortName: String? {
        session.currentRoute.outputs.first {
            [.bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains($0.portType)
        }?.portName
    }

    deinit {
        if let obs = routeObserver { NotificationCenter.default.removeObserver(obs) }
    }
}
