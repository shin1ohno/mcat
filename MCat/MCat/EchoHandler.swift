//
//  EchoHandler.swift
//  MCat
//

import NIOCore
import os

final class EchoHandler: ChannelInboundHandler, Sendable {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    private static let logger = Logger(subsystem: "be.ohno.MCat", category: "EchoHandler")
    let onMessage: @Sendable (String) -> Void

    init(onMessage: @Sendable @escaping (String) -> Void) {
        self.onMessage = onMessage
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let s = self.dataToString(data: data)
        self.onMessage(s)
        self.writeStringToContext(string: s, context: context)
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        Self.logger.error("Channel error: \(error)")
        context.close(promise: nil)
    }

    private func dataToString(data: NIOAny) -> String {
        let inBuff = self.unwrapInboundIn(data)
        let s = inBuff.getString(at: 0, length: inBuff.readableBytes)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return s.isEmpty ? "Invalid or empty" : s
    }

    private func writeStringToContext(string: String, context: ChannelHandlerContext) {
        let res = "\(string)\n"
        var buf = context.channel.allocator.buffer(capacity: res.utf8.count)
        buf.writeString(res)
        context.write(self.wrapOutboundOut(buf), promise: nil)
    }
}
