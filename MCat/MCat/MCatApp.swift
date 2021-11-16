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
    
    class AppDelegate: NSObject, NSApplicationDelegate {
        var ncServer = NCServer()
        var statusItem: NSStatusItem!
        var sub: AnyCancellable!
        
        func applicationWillFinishLaunching(_ notification: Notification) {
            self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            self.sub = self.ncServer.$message.sink() {
                self.statusItem.button?.title = $0
            }
        }
        
        func applicationDidFinishLaunching(_ notification: Notification) {
            Thread.detachNewThread {
                self.ncServer.start()
            }
        }
    }
}
