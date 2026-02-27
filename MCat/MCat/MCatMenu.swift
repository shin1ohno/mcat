//
//  MCatMenu.swift
//  MCat
//

import SwiftUI

struct MCatMenu: View {
    let server: NCServer
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Settings...") {
            NSApp.activate()
            openWindow(id: "settings")
        }
        .keyboardShortcut(",")

        Divider()

        Button("Quit") {
            server.stop()
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
