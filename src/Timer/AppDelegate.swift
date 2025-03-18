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

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var helpWindowController: HelpWindowController?
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

        // Create a separate menu for right-click
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "a"))
        menu.addItem(NSMenuItem(title: "Help", action: #selector(showHelp), keyEquivalent: "h"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

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

    @objc func handleStatusItemClick(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .leftMouseUp {
            // Left-click shows the popover
            togglePopover(sender)
        } else if event.type == .rightMouseUp {
            // Right-click shows the menu
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "a"))
            menu.addItem(NSMenuItem(title: "Help", action: #selector(showHelp), keyEquivalent: "h"))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
            statusItem?.menu = menu
            menu.popUp(positioning: nil, at: NSPoint(x: sender.frame.minX, y: sender.frame.minY), in: sender)
            // Remove the menu after it's shown to prevent it from appearing on left click
            DispatchQueue.main.async {
                self.statusItem?.menu = nil
            }
        }
    }

    @objc func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
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
