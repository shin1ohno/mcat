//
//  MCatServer.swift
//  MCat
//
//  Created by Shinichi Ohno on 15/11/2021.
//

import Foundation
import NIOCore
import NIOPosix

final class NCServer {
    @Published var message:String = "MCat"
    
    var host:String = "::1"
    var port:Int = 9999
    
    func start() -> Void {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let bootstrap = self.bootstrap(group: group)
        
        defer {
            try! group.syncShutdownGracefully()
        }
        
        let channel = try! bootstrap.bind(host: self.host, port: self.port).wait()
        try! channel.closeFuture.wait()
    }
    
    private func bootstrap(group: EventLoopGroup) -> ServerBootstrap {
        return ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.addHandler(BackPressureHandler()).flatMap { v in
                    channel.pipeline.addHandler(EchoHandler(server: self))
                }
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
    }
}

final private class EchoHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    var server: NCServer
    
    init(server: NCServer) {
        self.server = server
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inBuff = self.unwrapInboundIn(data)
        let s = inBuff.getString(at: 0, length: inBuff.readableBytes) ?? "MCat"
        
        DispatchQueue.main.async {
            self.server.message = s.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        context.write(data, promise: nil)
    }
    
    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        context.close(promise: nil)
    }
}


