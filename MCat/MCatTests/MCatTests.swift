//
//  MCatTests.swift
//  MCatTests
//
//  Created by Shinichi Ohno on 15/11/2021.
//

import XCTest
@testable import MCat

final class NCServerInitTests: XCTestCase {

    func testDefaultInit() {
        let server = NCServer()
        XCTAssertEqual(server.host, "::0")
        XCTAssertEqual(server.port, 9999)
        XCTAssertEqual(server.message, "MCat running on ::0:9999")
    }

    func testCustomInit() {
        let server = NCServer(host: "127.0.0.1", port: 8080)
        XCTAssertEqual(server.host, "127.0.0.1")
        XCTAssertEqual(server.port, 8080)
        XCTAssertEqual(server.message, "MCat running on 127.0.0.1:8080")
    }

    func testCustomHostOnly() {
        let server = NCServer(host: "localhost")
        XCTAssertEqual(server.host, "localhost")
        XCTAssertEqual(server.port, 9999)
    }

    func testCustomPortOnly() {
        let server = NCServer(port: 12345)
        XCTAssertEqual(server.host, "::0")
        XCTAssertEqual(server.port, 12345)
    }

    func testMessageUpdate() {
        let server = NCServer()
        server.message = "Updated"
        XCTAssertEqual(server.message, "Updated")
    }

    func testStopBeforeStartDoesNotCrash() {
        let server = NCServer()
        server.stop()
    }
}
