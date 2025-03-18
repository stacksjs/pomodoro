import Cocoa
import SwiftUI
import Combine
import AppKit
import Foundation

// Help window controller to manage window lifecycle
class HelpWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()

        // Enable key event handling for ESC key
        window?.makeKeyAndOrderFront(nil)
    }
}

// About window controller to manage window lifecycle
class AboutWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.makeKeyAndOrderFront(nil)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var helpWindowController: HelpWindowController?
    var aboutWindowController: AboutWindowController?
    var popover: NSPopover?
    var viewModel: TimerViewModel!
    var cancellables: Set<AnyCancellable> = []

    // MARK: - Window Delegate Methods

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the view model with a 25-minute duration
        viewModel = TimerViewModel(duration: 25)

        // Create the popover
        let contentView = ContentView(viewModel: viewModel)

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 260)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover

        // Create menu bar button
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem = statusItem

        // Configure the button to handle both left and right clicks
        if let statusButton = statusItem.button {
            statusButton.title = "⏱️"

            // Enable tracking different mouse events
            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
            statusButton.action = #selector(handleStatusItemClick)
            statusButton.target = self
        }

        // Observe the remaining time to update the status bar title
        viewModel.$remainingTime
            .receive(on: RunLoop.main)
            .sink { [weak self] (_: Int) in
                self?.updateStatusBarTitle()
            }
            .store(in: &cancellables)
    }

    // Create menu with all available options
    private func createMenu() -> NSMenu {
        let menu = NSMenu()

        // Get the current timer state as a string
        let timerStateString = String(describing: viewModel.timerState)

        // Add dynamic menu items based on timer state
        if timerStateString == "running" {
            // Timer is running - show Pause option
            menu.addItem(NSMenuItem(title: "Pause", action: #selector(toggleTimer), keyEquivalent: "p"))
        } else if timerStateString == "paused" {
            // Timer is paused - show Resume option
            menu.addItem(NSMenuItem(title: "Resume", action: #selector(toggleTimer), keyEquivalent: "r"))
            // Also add Reset option when paused
            menu.addItem(NSMenuItem(title: "Reset", action: #selector(resetTimer), keyEquivalent: "0"))
        } else {
            // Timer is stopped - show Start option
            menu.addItem(NSMenuItem(title: "Start", action: #selector(toggleTimer), keyEquivalent: "s"))
        }

        // Add separator before About and Help
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "a"))
        menu.addItem(NSMenuItem(title: "Help", action: #selector(showHelp), keyEquivalent: "h"))

        // Add Quit at the end
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        return menu
    }

    @objc func handleStatusItemClick(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .leftMouseUp {
            // Left-click shows the popover
            togglePopover(sender)
        } else if event.type == .rightMouseUp {
            // Right-click shows the menu
            let menu = createMenu()
            statusItem?.menu = menu
            menu.popUp(positioning: nil, at: NSPoint(x: sender.frame.minX, y: sender.frame.minY), in: sender)
            // Remove the menu after it's shown to prevent it from appearing on left click
            DispatchQueue.main.async {
                self.statusItem?.menu = nil
            }
        }
    }

    @objc func showAbout() {
        // Close any existing about window
        aboutWindowController?.close()

        // Create a custom about panel with additional information
        let aboutWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        aboutWindow.title = "About Pomodoro"
        aboutWindow.center()
        aboutWindow.isReleasedWhenClosed = true

        // Create a view controller for the about panel
        let viewController = NSViewController()
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))

        // Vertically center the content by shifting content down for better balance
        let verticalOffset = 15 // Positive value shifts content down

        // App icon
        let iconImageView = NSImageView(frame: NSRect(x: 150, y: 250 + verticalOffset, width: 100, height: 100))
        if let appIcon = NSImage(named: "AppIcon") {
            iconImageView.image = appIcon
        } else {
            iconImageView.image = NSImage(named: NSImage.applicationIconName)
        }
        view.addSubview(iconImageView)

        // App name in bold
        let appNameLabel = NSTextField(labelWithString: "Pomodoro Timer")
        appNameLabel.frame = NSRect(x: 0, y: 210 + verticalOffset, width: 400, height: 30)
        appNameLabel.alignment = .center
        appNameLabel.font = NSFont.boldSystemFont(ofSize: 18)
        view.addSubview(appNameLabel)

        // Add empty space label for line break effect
        let emptyLineLabel = NSTextField(labelWithString: "")
        emptyLineLabel.frame = NSRect(x: 0, y: 190 + verticalOffset, width: 400, height: 10)
        emptyLineLabel.isEditable = false
        emptyLineLabel.isBordered = false
        emptyLineLabel.drawsBackground = false
        view.addSubview(emptyLineLabel)

        // Version
        let versionLabel = NSTextField(labelWithString: "Version 1.0")
        versionLabel.frame = NSRect(x: 0, y: 175 + verticalOffset, width: 400, height: 20)
        versionLabel.alignment = .center
        versionLabel.font = NSFont.systemFont(ofSize: 12)
        view.addSubview(versionLabel)

        // Copyright
        let copyrightLabel = NSTextField(labelWithString: "Copyright © Stacks.js 2025")
        copyrightLabel.frame = NSRect(x: 0, y: 140 + verticalOffset, width: 400, height: 20)
        copyrightLabel.alignment = .center
        copyrightLabel.font = NSFont.systemFont(ofSize: 12)
        view.addSubview(copyrightLabel)

        // Credits
        let creditsLabel = NSTextField(labelWithString: "Thanks to Cloud & Chris Breuer")
        creditsLabel.frame = NSRect(x: 0, y: 110 + verticalOffset, width: 400, height: 20)
        creditsLabel.alignment = .center
        creditsLabel.font = NSFont.systemFont(ofSize: 12)
        view.addSubview(creditsLabel)

        // Description (italicized) with line break after "timer"
        let descriptionLabel = NSTextField(labelWithString: "A minimal, functional, yet simple Pomodoro timer\nto help you stay focused.")
        descriptionLabel.frame = NSRect(x: 20, y: 60 + verticalOffset, width: 360, height: 50)
        descriptionLabel.alignment = .center

        // Create an italicized font for the description
        let italicFont = NSFontManager.shared.convert(NSFont.systemFont(ofSize: 12), toHaveTrait: .italicFontMask)
        descriptionLabel.font = italicFont

        descriptionLabel.isEditable = false
        descriptionLabel.isBordered = false
        descriptionLabel.drawsBackground = false
        descriptionLabel.isSelectable = false
        descriptionLabel.lineBreakMode = .byWordWrapping
        view.addSubview(descriptionLabel)

        viewController.view = view
        aboutWindow.contentViewController = viewController

        // Create and set up the window controller
        let windowController = AboutWindowController(window: aboutWindow)
        aboutWindowController = windowController
        windowController.showWindow(nil)

        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func showHelp() {
        // Close any existing help window
        helpWindowController?.close()

        // Calculate a scaled size that maintains the 1280:1085 ratio
        let ratio = 1280.0 / 1085.0
        let height = 600.0 // scaled down height
        let width = height * ratio

        // Create a window to display help information
        let helpWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        helpWindow.title = "Help"
        helpWindow.center()
        helpWindow.isReleasedWhenClosed = true

        // Load the image from asset catalog
        if let helpImage = NSImage(named: "help") {
            // Create an image view sized to match the window
            let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: width, height: height))
            imageView.image = helpImage
            imageView.imageScaling = .scaleProportionallyDown
            imageView.imageAlignment = .alignCenter

            // Set the image view as the content view
            helpWindow.contentView = imageView
        }

        // Create and set up the window controller
        let windowController = HelpWindowController(window: helpWindow)
        helpWindowController = windowController
        windowController.showWindow(nil)

        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func togglePopover(_ sender: AnyObject) {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                if let statusBarButton = statusItem?.button {
                    popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: .minY)
                }
            }
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }

    @objc func toggleTimer() {
        viewModel.toggleTimer()
    }

    @objc func resetTimer() {
        viewModel.resetTimer()
    }

    func updateStatusBarTitle() {
        if let button = statusItem?.button {
            let minutes = viewModel.remainingTime / 60
            let seconds = viewModel.remainingTime % 60
            let title = String(format: "%02d:%02d", minutes, seconds)

            // Create an attributed string with monospace font
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            ]
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)

            button.attributedTitle = attributedTitle
        }
    }
}
