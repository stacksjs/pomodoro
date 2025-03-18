import SwiftUI
import AppKit
import Foundation
import Combine
import AVFoundation

// MARK: - Helper Views

struct TimerDisplayView: View {
    var remainingTime: Int

    var body: some View {
        Text(timeString(from: remainingTime))
            .font(.system(size: 60, weight: .medium, design: .monospaced))
            .foregroundColor(.primary)
            .padding(.top, 20) // Increased top padding
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ProgressSliderView: View {
    var remainingTime: Int
    var timerDuration: Double
    var timerColor: Color
    var onDragChanged: (Double) -> Void

    @State private var isDragging = false
    @State private var dragValue: Double?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 6)
                    .foregroundColor(Color(NSColor.systemGray))
                    .cornerRadius(3)

                Rectangle()
                    .frame(width: calculateProgressWidth(totalWidth: geometry.size.width), height: 6)
                    .foregroundColor(timerColor)
                    .cornerRadius(3)

                Circle()
                    .frame(width: 20, height: 20) // Increased size for better touch target
                    .foregroundColor(.white)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.15), radius: 2, x: 0, y: 1)
                    .offset(x: calculateProgressWidth(totalWidth: geometry.size.width) - 10)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDragging = true
                                let percentage = min(max(0, value.location.x / geometry.size.width), 1)
                                let newValue = percentage * timerDuration * 60
                                dragValue = Double(newValue)
                                onDragChanged(newValue)
                            }
                            .onEnded { _ in
                                isDragging = false
                                dragValue = nil
                            }
                    )
            }
            .contentShape(Rectangle()) // Makes the entire area tappable
            .onTapGesture { location in
                // Calculate the tap location relative to the view
                let percentage = min(max(0, location.x / geometry.size.width), 1)
                let newValue = percentage * timerDuration * 60
                onDragChanged(newValue)
            }
        }
        .frame(height: 30) // Increased height for better touch target
    }

    private func calculateProgressWidth(totalWidth: CGFloat) -> CGFloat {
        if isDragging, let value = dragValue {
            let progress = value / (timerDuration * 60)
            return min(max(0, CGFloat(progress) * totalWidth), totalWidth)
        } else {
            let progress = CGFloat(remainingTime) / CGFloat(timerDuration * 60)
            return min(max(0, progress * totalWidth), totalWidth)
        }
    }
}

struct ControlButtonsView: View {
    var timerState: TimerState
    var timerColor: Color
    var onToggle: () -> Void
    var onReset: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button(action: onToggle) {
                Text(buttonText(for: timerState))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(timerColor)
                    )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onReset) {
                Text("Reset")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(width: 80, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(NSColor.unemphasizedSelectedContentBackgroundColor))
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 5)
    }

    private func buttonText(for state: TimerState) -> String {
        switch state {
        case .running:
            return "Pause"
        case .paused:
            return "Resume"
        case .stopped:
            return "Start"
        }
    }
}

struct TimerPresetsView: View {
    var presets: [Int]
    var currentDuration: Double
    var timerColor: Color
    var onPresetSelected: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Reordered buttons: 5, 10, 25 min
            Button(action: { onPresetSelected(presets[1]) }) {
                Text("\(presets[1]) Min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(currentDuration == Double(presets[1]) ? .white : .primary)
                    .frame(height: 30)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(currentDuration == Double(presets[1]) ? timerColor : Color(NSColor.controlBackgroundColor))
                    )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { onPresetSelected(presets[2]) }) {
                Text("\(presets[2]) Min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(currentDuration == Double(presets[2]) ? .white : .primary)
                    .frame(height: 30)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(currentDuration == Double(presets[2]) ? timerColor : Color(NSColor.controlBackgroundColor))
                    )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { onPresetSelected(presets[0]) }) {
                Text("\(presets[0]) Min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(currentDuration == Double(presets[0]) ? .white : .primary)
                    .frame(height: 30)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(currentDuration == Double(presets[0]) ? timerColor : Color(NSColor.controlBackgroundColor))
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        // Removed bottom padding that was creating border appearance
    }
}

struct BottomNavigationView: View {
    var onQuit: () -> Void
    var onDetachTimer: () -> Void
    var onOpenSettings: () -> Void

    var body: some View {
        HStack {
            Button(action: onQuit) {
                Label("Quit", systemImage: "xmark.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Button(action: onDetachTimer) {
                Label("Detach Timer", systemImage: "arrow.up.right.square")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onOpenSettings) {
                Label("Settings", systemImage: "gearshape")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

// MARK: - Main ContentView

struct ContentView: View {
    @ObservedObject var viewModel: TimerViewModel
    @AppStorage("standardTimer") private var standardTimer = 25
    @AppStorage("shortBreak") private var shortBreak = 5
    @AppStorage("longBreak") private var longBreak = 10
    @State private var sliderValue: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            // Timer display
            TimerDisplayView(remainingTime: viewModel.remainingTime)

            // Progress slider
            ProgressSliderView(
                remainingTime: viewModel.remainingTime,
                timerDuration: viewModel.timerDuration,
                timerColor: timerColor(),
                onDragChanged: { newValue in
                    viewModel.timerDuration = newValue / 60
                    viewModel.updateRemainingTime()
                }
            )
            .padding(.horizontal)

            // Control buttons
            ControlButtonsView(
                timerState: viewModel.timerState,
                timerColor: timerColor(),
                onToggle: viewModel.toggleTimer,
                onReset: viewModel.resetTimer
            )

            // Timer presets
            TimerPresetsView(
                presets: [standardTimer, shortBreak, longBreak],
                currentDuration: viewModel.timerDuration,
                timerColor: timerColor(),
                onPresetSelected: { viewModel.setPresetTimer(minutes: $0) }
            )

            Divider()
                .padding(.horizontal)

            // Bottom navigation
            BottomNavigationView(
                onQuit: { NSApplication.shared.terminate(nil) },
                onDetachTimer: openTimerWindow,
                onOpenSettings: openSettings
            )
        }
        .padding(.top)
        .frame(width: 300, height: 260)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            sliderValue = viewModel.timerDuration
        }
    }

    private func timerColor() -> Color {
        if viewModel.timerDuration > 15 {
            return Color.red.opacity(0.8) // Pomodoro
        } else if viewModel.timerDuration > 8 {
            return Color.blue.opacity(0.8) // Long break
        } else {
            return Color.green.opacity(0.8) // Short break
        }
    }

    func openTimerWindow() {
        let screen = NSScreen.main
        let screenRect = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)

        let windowWidth: CGFloat = 200
        let windowHeight: CGFloat = 200

        let windowX = screenRect.midX - (windowWidth / 2)
        let windowY = screenRect.midY - (windowHeight / 2)

        let newWindow = NSWindow(
            contentRect: NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false)
        newWindow.center()
        newWindow.setFrameAutosaveName("TimerWindow")
        newWindow.isReleasedWhenClosed = false
        newWindow.level = .floating
        newWindow.contentView = NSHostingView(rootView: timerView(viewModel: viewModel))
        newWindow.makeKeyAndOrderFront(nil)
    }

    func openSettings() {
        let screen = NSScreen.main
        let screenRect = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let windowWidth: CGFloat = 400
        let windowHeight: CGFloat = 300
        let windowX = screenRect.midX - (windowWidth / 2)
        let windowY = screenRect.midY - (windowHeight / 2)

        let newWindow = NSWindow(
            contentRect: NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false)
        newWindow.center()
        newWindow.setFrameAutosaveName("SettingsWindow")
        newWindow.isReleasedWhenClosed = false
        newWindow.level = .floating
        newWindow.contentView = NSHostingView(rootView: settingsView(standardTimer: $standardTimer, shortBreak: $shortBreak, longBreak: $longBreak))
        newWindow.makeKeyAndOrderFront(nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: TimerViewModel(duration: 25))
    }
}
