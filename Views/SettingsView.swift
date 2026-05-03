import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var player:  PlayerViewModel
    @EnvironmentObject var hfp:     HFPManager
    @EnvironmentObject var audio:   AudioSessionManager
    @EnvironmentObject var library: MusicLibrary

    var body: some View {
        NavigationView {
            List {

                // ── Audio Routing ────────────────────────────────────────────
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bluetooth HFP Mode")
                                .font(.system(size: 16, weight: .medium))
                            Text("Route audio via call channel (SCO)\nFor cars without A2DP support")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { hfp.isEnabled },
                            set: { on in
                                if on { hfp.enable(playerVM: player) }
                                else  { hfp.disable(playerVM: player) }
                            }
                        ))
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Image(systemName: "hifispeaker.fill")
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        Text("Current Output")
                        Spacer()
                        Text(audio.currentRoute.isEmpty ? "Unknown" : audio.currentRoute)
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }

                    HStack {
                        Image(systemName: "bluetooth")
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        Text("Bluetooth")
                        Spacer()
                        Text(audio.isBluetoothConnected ? (audio.bluetoothPortName ?? "Connected") : "Not connected")
                            .foregroundColor(audio.isBluetoothConnected ? .green : .secondary)
                            .font(.system(size: 14))
                    }

                } header: {
                    Text("Audio Routing")
                } footer: {
                    Text("HFP mode uses the Bluetooth call channel (SCO). Audio quality will be lower but works with car systems that only support phone calls, not music streaming.")
                }

                // ── Playback ─────────────────────────────────────────────────
                Section("Playback") {
                    HStack {
                        Image(systemName: "shuffle")
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        Toggle("Shuffle", isOn: $player.shuffle)
                    }

                    HStack {
                        Image(systemName: "repeat")
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        Picker("Repeat", selection: $player.repeatMode) {
                            Text("Off").tag(PlayerViewModel.RepeatMode.none)
                            Text("All").tag(PlayerViewModel.RepeatMode.all)
                            Text("One").tag(PlayerViewModel.RepeatMode.one)
                        }
                        .pickerStyle(.menu)
                    }
                }

                // ── Library ───────────────────────────────────────────────────
                Section("Library") {
                    HStack {
                        Image(systemName: "music.note.list")
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        Text("Total Songs")
                        Spacer()
                        Text("\(library.allSongs.count)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        Text("Folders")
                        Spacer()
                        Text("\(library.folders.count)")
                            .foregroundColor(.secondary)
                    }
                    Button {
                        library.load()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                                .frame(width: 28)
                            Text("Rescan Library")
                        }
                    }
                }

                // ── Add Music ─────────────────────────────────────────────────
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("How to add music", systemImage: "info.circle")
                            .font(.system(size: 15, weight: .medium))
                        Text("1. Open the **Files** app\n2. Navigate to **HFP Player** → Documents\n3. Copy your MP3 / M4A files there\n4. Tap **Rescan Library** above")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Adding Music")
                }

                // ── About ────────────────────────────────────────────────────
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("iOS")
                        Spacer()
                        Text("15.0+").foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
    }
}
