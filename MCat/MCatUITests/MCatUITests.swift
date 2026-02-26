//
//  MCatUITests.swift
//  MCatUITests
//
//  Created by Shinichi Ohno on 15/11/2021.
//

import XCTest

final class MCatUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
}
