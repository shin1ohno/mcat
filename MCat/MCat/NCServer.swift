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
    @Published var message:String
    
    var host:String
    var port:Int
    
    init(host:String = "::0", port:Int = 9999) {
        (self.host, self.port) = (host, port)
        self.message = "MCat runnig on \(self.host):\(self.port)"
    }
    
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
        let s = dataToString(data: data)
        
        DispatchQueue.main.async { //This causes UI text change so it should be done in the main thread
            self.server.message = s
        }

        self.writeStringToContext(string: s, context: context)
    }
    
    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        context.close(promise: nil)
    }
    
    private func dataToString(data: NIOAny) -> String {
        let inBuff = self.unwrapInboundIn(data)
        var s = inBuff.getString(at: 0, length: inBuff.readableBytes)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if (s == "") {s = "🤯Invalid? 😳empty?"}
        return s
    }
    
    private func writeStringToContext(string: String, context: ChannelHandlerContext) -> Void {
        let res = "\(string)\n"
        var buf = context.channel.allocator.buffer(capacity: res.utf8.count)
        buf.writeString(res)
        context.write(self.wrapOutboundOut(buf), promise: nil)
    }
}


