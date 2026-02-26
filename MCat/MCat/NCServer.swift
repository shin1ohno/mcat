//
//  NCServer.swift
//  MCat
//

import Foundation
import NIOCore
import NIOPosix
import os

enum ServerState: Sendable {
    case stopped
    case starting
    case running
    case error(String)
}

@MainActor
@Observable
final class NCServer {
    var message: String
    private(set) var serverState: ServerState = .stopped

    let host: String
    let port: Int
    private var serverChannel: Channel?

    private static let logger = Logger(subsystem: "be.ohno.MCat", category: "NCServer")

    init(host: String = "::0", port: Int = 9999) {
        (self.host, self.port) = (host, port)
        self.message = "MCat running on \(self.host):\(self.port)"
    }

    func start() async {
        self.serverState = .starting
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let bootstrap = self.makeBootstrap(group: group)

        do {
            let channel = try await bootstrap.bind(host: self.host, port: self.port).get()
            self.serverChannel = channel
            self.serverState = .running
            Self.logger.info("Server started on \(self.host):\(self.port)")
            try await channel.closeFuture.get()
        } catch {
            Self.logger.error("Server error: \(error)")
            self.serverState = .error(error.localizedDescription)
            self.message = "Error: \(error.localizedDescription)"
        }

        try? await group.shutdownGracefully()
        self.serverState = .stopped
    }

    func stop() {
        self.serverChannel?.close(promise: nil)
    }

    private func makeBootstrap(group: EventLoopGroup) -> ServerBootstrap {
        ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { [weak self] channel in
                channel.pipeline.addHandler(EchoHandler(onMessage: { [weak self] text in
                    Task { @MainActor in self?.message = text }
                }))
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
    }
}
