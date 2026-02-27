//
//  SettingsView.swift
//  MCat
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("listenHost") private var listenHost = "::0"
    @AppStorage("listenPort") private var listenPort = 9999

    var server: NCServer

    @State private var draftHost = "::0"
    @State private var draftPort = "9999"

    var body: some View {
        Form {
            Picker("Host:", selection: $draftHost) {
                Text("All interfaces (::0)").tag("::0")
                Text("Localhost only (127.0.0.1)").tag("127.0.0.1")
            }
            .pickerStyle(.radioGroup)

            TextField("Port:", text: $draftPort)
                .frame(width: 280)

            HStack {
                Spacer()
                Button("Apply") {
                    applySettings()
                }
                .disabled(!hasChanges)
            }
        }
        .padding(20)
        .frame(width: 320)
        .onAppear {
            draftHost = listenHost
            draftPort = String(listenPort)
        }
    }

    private var hasChanges: Bool {
        let portValue = Int(draftPort) ?? listenPort
        return draftHost != listenHost || portValue != listenPort
    }

    private func applySettings() {
        let portValue = Int(draftPort) ?? 9999
        guard (1...65535).contains(portValue) else { return }

        listenHost = draftHost
        listenPort = portValue
        server.restart(host: draftHost, port: portValue)
    }
}
