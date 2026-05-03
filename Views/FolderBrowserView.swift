import SwiftUI

struct FolderBrowserView: View {
    @EnvironmentObject var library: MusicLibrary
    @EnvironmentObject var player:  PlayerViewModel
    @State private var searchText  = ""

    var filtered: [MusicFolder] {
        searchText.isEmpty ? library.folders
            : library.folders.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
              }
    }

    var body: some View {
        NavigationView {
            Group {
                if library.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)
                        Text("Scanning your music…")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))

                } else if library.folders.isEmpty {
                    EmptyStateView(
                        icon: "folder.badge.questionmark",
                        title: "No Music Found",
                        message: "Add MP3/M4A files via Files app into the app's Documents folder, or grant access to your Apple Music library."
                    )

                } else {
                    List(filtered) { folder in
                        NavigationLink(destination:
                            SongsListView(songs: folder.songs, title: folder.name)
                        ) {
                            FolderRow(folder: folder)
                        }
                        .listRowBackground(Color(.secondarySystemBackground))
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $searchText, prompt: "Search folders")
                    .refreshable { library.load() }
                }
            }
            .navigationTitle("Music Folders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { library.load() } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct FolderRow: View {
    let folder: MusicFolder

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: "folder.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(folder.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Text("\(folder.songCount) song\(folder.songCount == 1 ? "" : "s")")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.secondary.opacity(0.6))
            Text(title)
                .font(.title2.bold())
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
