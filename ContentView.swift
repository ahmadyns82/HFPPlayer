import SwiftUI

struct ContentView: View {
    @EnvironmentObject var player:  PlayerViewModel
    @EnvironmentObject var library: MusicLibrary
    @State private var selectedTab  = 0
    @State private var showPlayer   = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                FolderBrowserView()
                    .tabItem {
                        Label("Folders", systemImage: "folder.fill")
                    }
                    .tag(0)

                SongsListView(songs: library.allSongs, title: "All Songs")
                    .tabItem {
                        Label("Songs", systemImage: "music.note.list")
                    }
                    .tag(1)

                PlayerView()
                    .tabItem {
                        Label("Player", systemImage: "play.circle.fill")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)
            }
            .tint(.blue)
            // Push tab bar up to make room for mini player
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if player.currentSong != nil {
                    MiniPlayerView(onTap: { selectedTab = 2 })
                        .background(.ultraThinMaterial)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
