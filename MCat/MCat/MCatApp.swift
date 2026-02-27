//
//  MCatApp.swift
//  MCat
//

import SwiftUI

@main
struct MCatApp: App {
    @State private var server = NCServer()
    @State private var ticker = MarqueeTicker()

    var body: some Scene {
        MenuBarExtra {
            MCatMenu(server: server)
        } label: {
            HStack(spacing: 4) {
                if server.message == "MCat running on \(server.host):\(server.port)" {
                    Image(systemName: "network")
                }
                MarqueeText(text: server.message, tick: ticker.value)
            }
            .task {
                ticker.start()
                await server.start()
            }
        }

        Window("MCat Settings", id: "settings") {
            SettingsView(server: server)
        }
        .windowResizability(.contentSize)
    }
}
