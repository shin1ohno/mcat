//
//  MCatApp.swift
//  MCat
//

import SwiftUI

@main
struct MCatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ZStack {
                EmptyView()
            }
            .hidden()
        }
    }

    @MainActor
    class AppDelegate: NSObject, NSApplicationDelegate {
        let ncServer = NCServer()
        var statusItem: NSStatusItem!

        func applicationWillFinishLaunching(_ notification: Notification) {
            self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            self.observeMessage()
        }

        func applicationDidFinishLaunching(_ notification: Notification) {
            Task { await self.ncServer.start() }
        }

        private func observeMessage() {
            withObservationTracking {
                _ = self.ncServer.message
            } onChange: { [weak self] in
                Task { @MainActor in
                    self?.statusItem.button?.title = self?.ncServer.message ?? ""
                    self?.observeMessage()
                }
            }
            self.statusItem.button?.title = self.ncServer.message
        }
    }
}
