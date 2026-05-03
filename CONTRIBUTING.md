# Contributing to HFP Player

## Getting Started

1. Fork the repo and clone your fork
2. Open `HFPPlayer.xcodeproj` in Xcode 15+
3. Set your Team under **Signing & Capabilities**
4. Run on a real iPhone (Simulator won't test Bluetooth)

## Branch Naming

| Type       | Pattern               | Example                    |
|------------|-----------------------|----------------------------|
| Feature    | `feature/description` | `feature/equalizer`        |
| Bug fix    | `fix/description`     | `fix/seek-bar-crash`       |
| Chore      | `chore/description`   | `chore/update-gitignore`   |

## Pull Request Checklist

- [ ] Code builds without warnings
- [ ] SwiftLint passes (`swiftlint lint`)
- [ ] Tested on real device (iOS 15+)
- [ ] README updated if behaviour changed
- [ ] CHANGELOG entry added under `[Unreleased]`

## Code Style

- Swift 5.9, SwiftUI, MVVM
- `@MainActor` on all ViewModels
- No force-unwrap (`!`) except in tests
- `final class` for services and ViewModels
