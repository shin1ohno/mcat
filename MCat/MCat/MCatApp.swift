//
//  MCatApp.swift
//  MCat
//
//  Created by Shinichi Ohno on 15/11/2021.
//

import SwiftUI
import Combine

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
        var observation: AnyCancellable!

        func applicationWillFinishLaunching(_ notification: Notification) {
            self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            self.observation = self.ncServer.$message.receive(on: RunLoop.main).sink { [weak self] in
                self?.statusItem.button?.title = $0
            }
        }

        func applicationDidFinishLaunching(_ notification: Notification) {
            let server = self.ncServer
            Thread.detachNewThread {
                server.start()
            }
        }
    }
}
