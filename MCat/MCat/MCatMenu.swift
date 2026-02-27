//
//  MCatMenu.swift
//  MCat
//

import SwiftUI

struct MCatMenu: View {
    let server: NCServer

    var body: some View {
        Button("Settings...") {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
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
