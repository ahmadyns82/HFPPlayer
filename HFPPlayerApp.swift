import SwiftUI
import AVFoundation

@main
struct HFPPlayerApp: App {

    @StateObject private var player  = PlayerViewModel()
    @StateObject private var library = MusicLibrary.shared
    @StateObject private var hfp     = HFPManager.shared
    @StateObject private var audio   = AudioSessionManager.shared

    init() {
        // Configure for high quality music playback at launch
        AudioSessionManager.shared.configureForMusic()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(player)
                .environmentObject(library)
                .environmentObject(hfp)
                .environmentObject(audio)
                .onAppear {
                    player.setupRemoteControls()
                    library.load()
                }
        }
    }
}
