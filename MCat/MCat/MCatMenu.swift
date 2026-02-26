//
//  MCatMenu.swift
//  MCat
//

import SwiftUI

struct MCatMenu: View {
    let server: NCServer

    var body: some View {
        Button("Quit") {
            server.stop()
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
