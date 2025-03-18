import Cocoa
import SwiftUI
import Combine
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var window: NSWindow?
    var popover: NSPopover?
    var viewModel: TimerViewModel!
    var cancellables: Set<AnyCancellable> = []

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
            .sink { [weak self] _ in
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
            // Right-click shows the quit menu
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
            statusItem?.menu = menu
            menu.popUp(positioning: nil, at: NSPoint(x: sender.frame.minX, y: sender.frame.minY), in: sender)
            // Remove the menu after it's shown to prevent it from appearing on left click
            DispatchQueue.main.async {
                self.statusItem?.menu = nil
            }
        }
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
