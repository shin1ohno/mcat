//
//  MarqueeTextTests.swift
//  MCatTests
//

import XCTest
@testable import MCat

final class MarqueeTextTests: XCTestCase {

    func testShortTextDoesNotNeedScroll() {
        let width = MarqueeText.textWidth("Hello")
        XCTAssertLessThanOrEqual(width, 190, "Short text should fit within threshold")
    }

    func testLongTextNeedsScroll() {
        let longText = "This is a very long message that should definitely scroll in the menu bar"
        let width = MarqueeText.textWidth(longText)
        XCTAssertGreaterThan(width, 190, "Long text should exceed threshold")
    }

    func testDefaultMessageFitsWithinThreshold() {
        let defaultMessage = "MCat running on ::0:9999"
        let width = MarqueeText.textWidth(defaultMessage)
        XCTAssertLessThanOrEqual(width, 190, "Default message (24 chars) should fit within 190pt")
    }
}
