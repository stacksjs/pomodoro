<p align="center"><img src=".github/art/cover.jpg" alt="Social Card of this repo"></p>

[![npm version][npm-version-src]][npm-version-href]
[![GitHub Actions][github-actions-src]][github-actions-href]
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)
<!-- [![npm downloads][npm-downloads-src]][npm-downloads-href] -->
<!-- [![Codecov][codecov-src]][codecov-href] -->

# Pomodoro.app

A minimal, functional, yet simple Pomodoro menubar app to help you stay focused. Built exclusively for macOS.

## Features

- 🍎 **macOS Native** - Built with SwiftUI for a seamless Mac experience
- 🔔 **Menu Bar App** - Always accessible from your menu bar
- ⏱️ **Customizable Timers** - Set your own work and break durations
- 🪟 **Detachable Timer Window** - Pop out the timer when you need it visible
- 🔊 **Audio Notifications** - Get alerted when your timer completes
- ⚙️ **Configurable Settings** - Customize to fit your workflow

## Getting Started

### Prerequisites

- macOS 11.0 (Big Sur) or later
- Xcode 13.0 or later
- [Bun](https://bun.sh/) for running build scripts (optional)

### Development Setup

1. **Clone the repository**

```bash
git clone https://github.com/stacksjs/pomodoro.git
cd pomodoro
```

2. **Open the project in Xcode**

```bash
open src/Timer.xcodeproj
```

3. **Build and run the app**

- Select the "Timer" scheme in Xcode
- Choose your Mac as the run destination
- Click the Run button (▶️) or press Cmd+R

### Building from Source

If you prefer to build from the command line:

```bash
# Build the app
bun run build

# cd src && xcodebuild -project Timer.xcodeproj -scheme Timer -configuration Release

# The built app will be in src/build/Release/Timer.app
```

### Installing the App

After building, you can install the app by:

1. Locating the built `Timer.app` in `src/build/Release/`
2. Dragging it to your Applications folder

## Usage

1. **Launch the app** - The timer will appear in your menu bar
2. **Click the menu bar icon** - Opens the timer interface
3. **Set your timer** - Use the slider or preset buttons (25, 5, or 10 minutes)
4. **Start the timer** - Click "Start" to begin your focus session
5. **Detach the timer** - Click "Detach Timer" to open a floating window
6. **Configure settings** - Click "Settings" to customize timer presets

## Development

This project uses:

- SwiftUI for the user interface
- Combine for reactive programming
- AVFoundation for audio playback
- AppKit for macOS-specific functionality

### Project Structure

- `TimerApp.swift` - Main app entry point
- `AppDelegate.swift` - Handles menu bar integration
- `ContentView.swift` - Main timer interface
- `TimerViewModel.swift` - Core timer logic
- `TimerState.swift` - Timer state management
- `settingsView.swift` - Settings interface
- `timerView.swift` - Detachable timer window

## Testing

```bash
bun test
```

## Changelog

Please see our [releases](https://github.com/stacksjs/pomodoro/releases) page for more information on what has changed recently.

## Contributing

Please see [CONTRIBUTING](.github/CONTRIBUTING.md) for details.

## Community

For help, discussion about best practices, or any other conversation that would benefit from being searchable:

[Discussions on GitHub](https://github.com/stacksjs/pomodoro/discussions)

For casual chit-chat with others using this package:

[Join the Stacks Discord Server](https://discord.gg/stacksjs)

## Postcardware

“Software that is free, but hopes for a postcard.” We love receiving postcards from around the world showing where `Pomodoro.app` is being used! We showcase them on our website too.

Our address: Stacks.js, 12665 Village Ln #2306, Playa Vista, CA 90094, United States 🌎

## Credits

- [@YYUUGGOO](https://github.com/YYUUGGOO) - for the original [Cloud](https://github.com/YYUUGGOO/Cloud) implementation

## Sponsors

We would like to extend our thanks to the following sponsors for funding Stacks development. If you are interested in becoming a sponsor, please reach out to us.

- [JetBrains](https://www.jetbrains.com/)
- [The Solana Foundation](https://solana.com/)

## License

The MIT License (MIT). Please see [LICENSE](LICENSE.md) for more information.

Made with 💙

<!-- Badges -->
[npm-version-src]: https://img.shields.io/npm/v/@stacksjs/pomodoro?style=flat-square
[npm-version-href]: https://npmjs.com/package/@stacksjs/pomodoro
[github-actions-src]: https://img.shields.io/github/actions/workflow/status/stacksjs/pomodoro/ci.yml?style=flat-square&branch=main
[github-actions-href]: https://github.com/stacksjs/pomodoro/actions?query=workflow%3Aci

<!-- [codecov-src]: https://img.shields.io/codecov/c/gh/stacksjs/ts-starter/main?style=flat-square
[codecov-href]: https://codecov.io/gh/stacksjs/ts-starter -->
