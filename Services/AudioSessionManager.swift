import AVFoundation
import Foundation

final class AudioSessionManager: ObservableObject {

    static let shared = AudioSessionManager()
    @Published var isHFPActive = false
    @Published var currentRoute = ""

    private let session = AVAudioSession.sharedInstance()
    private var routeObserver: Any?

    private init() {
        observeRouteChanges()
    }

    func configureForMusic() {
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.allowBluetoothA2DP]
            )
            try session.setPreferredSampleRate(44100)
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
            isHFPActive = false
            updateRouteDescription()
        } catch {
            print("AudioSession music config error: \(error)")
        }
    }

    func configureForHFP() {
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetoothHFP, .defaultToSpeaker]
            )
            try session.setPreferredSampleRate(16000)
            try session.setActive(true)
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
