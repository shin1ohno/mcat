//
//  NCServerE2ETests.swift
//  MCatTests
//
//  End-to-end tests: start a real TCP server, connect, and verify echo behavior.
//

import XCTest
import Darwin
@testable import MCat

private enum TCPError: Error {
    case socketCreationFailed
    case connectionFailed
    case sendFailed
    case receiveFailed
}

final class NCServerE2ETests: XCTestCase {

    private var server: NCServer!
    private var port: Int!

    override func setUp() {
        super.setUp()
        port = Int.random(in: 49152...65535)
        server = NCServer(host: "127.0.0.1", port: port)

        let s = server!
        Thread.detachNewThread {
            s.start()
        }

        waitForServerReady(port: port)
    }

    override func tearDown() {
        server.stop()
        Thread.sleep(forTimeInterval: 0.1)
        server = nil
        super.tearDown()
    }

    // MARK: - Echo Tests

    func testEchoSimpleString() throws {
        let response = try tcpSendReceive("Hello MCat")
        XCTAssertEqual(response, "Hello MCat\n")
    }

    func testEchoUnicode() throws {
        let response = try tcpSendReceive("日本語テスト")
        XCTAssertEqual(response, "日本語テスト\n")
    }

    func testEchoEmoji() throws {
        let response = try tcpSendReceive("🐱🎉")
        XCTAssertEqual(response, "🐱🎉\n")
    }

    func testEchoWhitespaceOnlyReturnsInvalid() throws {
        let response = try tcpSendReceive("   \n\t  ")
        XCTAssertEqual(response, "Invalid or empty\n")
    }

    func testEchoNewlineOnlyReturnsInvalid() throws {
        let response = try tcpSendReceive("\n")
        XCTAssertEqual(response, "Invalid or empty\n")
    }

    func testEchoStripsTrailingWhitespace() throws {
        let response = try tcpSendReceive("Hello\n")
        XCTAssertEqual(response, "Hello\n")
    }

    func testEchoLongString() throws {
        let longString = String(repeating: "A", count: 1000)
        let response = try tcpSendReceive(longString)
        XCTAssertEqual(response, longString + "\n")
    }

    // MARK: - Message Update Tests

    func testMessageUpdatedAfterEcho() throws {
        _ = try tcpSendReceive("Ping")

        // message is updated via DispatchQueue.main.async, pump the run loop
        let deadline = Date().addingTimeInterval(3)
        while server.message != "Ping" && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        XCTAssertEqual(server.message, "Ping")
    }

    // MARK: - Multiple Connections

    func testMultipleSequentialConnections() throws {
        let r1 = try tcpSendReceive("First")
        XCTAssertEqual(r1, "First\n")

        let r2 = try tcpSendReceive("Second")
        XCTAssertEqual(r2, "Second\n")

        let r3 = try tcpSendReceive("Third")
        XCTAssertEqual(r3, "Third\n")
    }

    // MARK: - Helpers

    private func waitForServerReady(port: Int, timeout: TimeInterval = 5) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let fd = socket(AF_INET, SOCK_STREAM, 0)
            guard fd >= 0 else {
                Thread.sleep(forTimeInterval: 0.05)
                continue
            }

            var addr = makeSockAddr(port: port)
            let result = withUnsafeMutablePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
            close(fd)

            if result == 0 { return }
            Thread.sleep(forTimeInterval: 0.05)
        }
        XCTFail("Server did not start within \(timeout) seconds")
    }

    private func tcpSendReceive(_ message: String) throws -> String {
        let fd = socket(AF_INET, SOCK_STREAM, 0)
        guard fd >= 0 else { throw TCPError.socketCreationFailed }
        defer { close(fd) }

        var addr = makeSockAddr(port: port)
        let connectResult = withUnsafeMutablePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        guard connectResult == 0 else { throw TCPError.connectionFailed }

        var messageBytes = Array(message.utf8)
        let sent = messageBytes.withUnsafeMutableBufferPointer { ptr in
            send(fd, ptr.baseAddress!, ptr.count, 0)
        }
        guard sent > 0 else { throw TCPError.sendFailed }

        var buf = [UInt8](repeating: 0, count: 8192)
        let received = recv(fd, &buf, buf.count, 0)
        guard received > 0 else { throw TCPError.receiveFailed }

        return String(bytes: buf[0..<received], encoding: .utf8) ?? ""
    }

    private func makeSockAddr(port: Int) -> sockaddr_in {
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = UInt16(port).bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")
        return addr
    }
}
