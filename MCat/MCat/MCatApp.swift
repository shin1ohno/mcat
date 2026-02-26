//
//  MCatApp.swift
//  MCat
//

import SwiftUI

@main
struct MCatApp: App {
    @State private var server = NCServer()

    var body: some Scene {
        MenuBarExtra {
            MCatMenu(server: server)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "network")
                MarqueeText(text: server.message)
            }
            .task { await server.start() }
        }
    }
}
