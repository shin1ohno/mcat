//
//  MCatServer.swift
//  MCat
//
//  Created by Shinichi Ohno on 15/11/2021.
//

import Foundation
import NIOCore
import NIOPosix

final class NCServer: @unchecked Sendable {
    @Published var message: String

    let host: String
    let port: Int
    private var serverChannel: Channel?

    init(host: String = "::0", port: Int = 9999) {
        (self.host, self.port) = (host, port)
        self.message = "MCat running on \(self.host):\(self.port)"
    }

    func start() {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let bootstrap = self.bootstrap(group: group)

        defer {
            try! group.syncShutdownGracefully()
        }

        let channel = try! bootstrap.bind(host: self.host, port: self.port).wait()
        self.serverChannel = channel
        try! channel.closeFuture.wait()
    }

    func stop() {
        self.serverChannel?.close(promise: nil)
    }

    private func bootstrap(group: EventLoopGroup) -> ServerBootstrap {
        return ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.addHandler(EchoHandler(server: self))
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
    }
}

private final class EchoHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    let server: NCServer

    init(server: NCServer) {
        self.server = server
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let s = dataToString(data: data)

        DispatchQueue.main.async { [server] in
            server.message = s
        }

        self.writeStringToContext(string: s, context: context)
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        context.close(promise: nil)
    }

    private func dataToString(data: NIOAny) -> String {
        let inBuff = self.unwrapInboundIn(data)
        var s = inBuff.getString(at: 0, length: inBuff.readableBytes)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if s == "" { s = "Invalid or empty" }
        return s
    }

    private func writeStringToContext(string: String, context: ChannelHandlerContext) -> Void {
        let res = "\(string)\n"
        var buf = context.channel.allocator.buffer(capacity: res.utf8.count)
        buf.writeString(res)
        context.write(self.wrapOutboundOut(buf), promise: nil)
    }
}
