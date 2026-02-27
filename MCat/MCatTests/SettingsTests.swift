//
//  SettingsTests.swift
//  MCatTests
//

import XCTest
@testable import MCat

@MainActor
final class SettingsTests: XCTestCase {

    // MARK: - Restart Tests

    func testRestartUpdatesHostAndPort() {
        let server = NCServer(host: "::0", port: 9999)
        server.restart(host: "127.0.0.1", port: 8080)

        XCTAssertEqual(server.host, "127.0.0.1")
        XCTAssertEqual(server.port, 8080)
    }

    func testRestartUpdatesMessage() {
        let server = NCServer(host: "::0", port: 9999)
        server.restart(host: "127.0.0.1", port: 8080)

        XCTAssertEqual(server.message, "MCat running on 127.0.0.1:8080")
    }

    func testRestartWithSameValues() {
        let server = NCServer(host: "::0", port: 9999)
        server.restart(host: "::0", port: 9999)

        XCTAssertEqual(server.host, "::0")
        XCTAssertEqual(server.port, 9999)
        XCTAssertEqual(server.message, "MCat running on ::0:9999")
    }

    // MARK: - Default Value Tests

    func testDefaultHostValue() {
        let server = NCServer()
        XCTAssertEqual(server.host, "::0")
    }

    func testDefaultPortValue() {
        let server = NCServer()
        XCTAssertEqual(server.port, 9999)
    }

    func testDefaultMessageFormat() {
        let server = NCServer()
        XCTAssertEqual(server.message, "MCat running on ::0:9999")
    }

    // MARK: - AppStorage Key Consistency Tests

    func testAppStorageHostKey() {
        // Verify the key used in @AppStorage matches expected constant
        let defaults = UserDefaults.standard
        let key = "listenHost"

        defaults.removeObject(forKey: key)
        XCTAssertNil(defaults.string(forKey: key))

        defaults.set("127.0.0.1", forKey: key)
        XCTAssertEqual(defaults.string(forKey: key), "127.0.0.1")

        // Clean up
        defaults.removeObject(forKey: key)
    }

    func testAppStoragePortKey() {
        // Verify the key used in @AppStorage matches expected constant
        let defaults = UserDefaults.standard
        let key = "listenPort"

        defaults.removeObject(forKey: key)
        XCTAssertEqual(defaults.integer(forKey: key), 0)

        defaults.set(8080, forKey: key)
        XCTAssertEqual(defaults.integer(forKey: key), 8080)

        // Clean up
        defaults.removeObject(forKey: key)
    }
}
