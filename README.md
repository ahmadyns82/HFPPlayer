# HFP Player 🎵

![Build](https://github.com/YOUR_USERNAME/HFPPlayer/actions/workflows/build.yml/badge.svg)
![iOS](https://img.shields.io/badge/iOS-15%2B-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![License](https://img.shields.io/badge/license-MIT-green)

A clean SwiftUI music player for iPhone (iOS 15+) that plays local audio with **optional Bluetooth HFP routing** — useful for cars that only support HFP hands-free calls and not A2DP music streaming (e.g. older Mercedes-Benz GLK 350).

---

## Screenshots

> Run on device and add screenshots here.

---

## Features

| | Feature |
|---|---|
| 📁 | **Folder Browser** — browse music by folder, pull to refresh |
| 🎵 | **Song List** — searchable, artwork, artist, duration |
| ▶️ | **Full Player** — seek bar, shuffle, repeat, volume |
| 🎧 | **Mini Player** — persistent bar visible from all tabs |
| 🔒 | **Lock Screen Controls** — play/pause/skip from anywhere |
| 🔵 | **HFP Mode** — toggle in Settings to route via Bluetooth SCO |
| 📱 | **Background Playback** — keeps playing when screen is off |

---

## Requirements

| | Minimum |
|---|---|
| iOS | 15.0 |
| Xcode | 15.0 |
| Swift | 5.9 |
| Device | Real iPhone (Bluetooth won't work in Simulator) |

---

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/HFPPlayer.git
cd HFPPlayer
open HFPPlayer.xcodeproj
```

1. In Xcode: **HFPPlayer target → Signing & Capabilities → set your Team**
2. Change Bundle ID: `com.yourname.hfpplayer`
3. Select your iPhone → **▶ Run**

---

## Adding Music to the App

**Via Files App** *(recommended)*
1. Open **Files** → On My iPhone → **HFP Player** → Documents
2. Copy `.mp3` / `.m4a` / `.wav` files there
3. In the app → Settings → **Rescan Library**

**Via iTunes / Finder File Sharing**
1. Connect iPhone → open Finder → select iPhone → **Files** → HFP Player
2. Drag audio files in

**Via Apple Music Library**
Grant permission at first launch — your full Music library appears automatically.

---

## HFP Mode (For Cars Without A2DP)

1. Pair iPhone with car via Bluetooth (verify calls work)
2. Open **Settings** tab in the app
3. Toggle **Bluetooth HFP Mode** ON
4. Press Play — audio routes through the HFP/SCO call channel

> ⚠️ Audio quality in HFP mode is reduced (~16 kHz) because SCO is a voice-optimised protocol. This is a hardware/protocol limitation, not a software bug.

| Mode | Sample Rate | Quality |
|------|-------------|---------|
| Normal (Speaker / AirPods / A2DP) | 44.1 kHz | ⭐⭐⭐⭐⭐ Full |
| HFP Wideband (mSBC) | 16 kHz | ⭐⭐⭐ Voice |
| HFP Narrowband (CVSD) | 8 kHz | ⭐⭐ Phone |

---

## Project Structure

```
HFPPlayer/
├── .github/
│   ├── workflows/build.yml          # CI: builds on push + PR
│   ├── ISSUE_TEMPLATE/              # Bug + feature templates
│   └── pull_request_template.md
│
├── HFPPlayer.xcodeproj/
│   └── xcshareddata/xcschemes/      # Shared scheme for CI
│
├── HFPPlayer/
│   ├── HFPPlayerApp.swift           # @main entry, environment setup
│   ├── ContentView.swift            # TabView + MiniPlayer
│   ├── Info.plist                   # Permissions, background modes
│   │
│   ├── Models/
│   │   └── Song.swift               # Song, MusicFolder models
│   │
│   ├── ViewModels/
│   │   └── PlayerViewModel.swift    # AVAudioPlayer, queue, lock screen
│   │
│   ├── Services/
│   │   ├── AudioSessionManager.swift  # AVAudioSession config
│   │   ├── MusicLibrary.swift         # MediaPlayer + Files scanner
│   │   └── HFPManager.swift           # HFP/SCO routing toggle
│   │
│   └── Views/
│       ├── FolderBrowserView.swift
│       ├── SongsListView.swift
│       ├── PlayerView.swift
│       ├── MiniPlayerView.swift
│       └── SettingsView.swift
│
├── .gitignore
├── .swiftlint.yml
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

---

## CI / CD

GitHub Actions runs on every push to `main` / `develop` and every PR:
- Builds with `xcodebuild` on `macos-14` (Xcode 15.4)
- Runs SwiftLint if installed

See [`.github/workflows/build.yml`](.github/workflows/build.yml).

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). PRs welcome!

---

## License

[MIT](LICENSE) © 2026 HFP Player Contributors
