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
            Label(server.message, systemImage: "network")
                .task { await server.start() }
        }
    }
}
