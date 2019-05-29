//
//  Copyright © 2018-present Amaris Technologies GmbH. All rights reserved.
//

import XCTest
@testable import SplashBuddy

class ToolsTests: XCTestCase {

    // MARK: - Tests

    func testShouldReturnBoolFromString() {
        XCTAssertTrue(Tools.getBool(from: "1")!)
        XCTAssertFalse(Tools.getBool(from: "0")!)
        XCTAssertFalse(Tools.getBool(from: "9")!)
    }

    func testShouldReturnBoolFromInt() {
        XCTAssertTrue(Tools.getBool(from: 1)!)
        XCTAssertFalse(Tools.getBool(from: 0)!)
        XCTAssertFalse(Tools.getBool(from: 9)!)
    }

    func testShouldReturnBoolFromBool() {
        XCTAssertTrue(Tools.getBool(from: true)!)
        XCTAssertFalse(Tools.getBool(from: false)!)
    }

    func testShouldReturnBoolFromAny() {
        XCTAssertNil(Tools.getBool(from: [:]))
        XCTAssertNil(Tools.getBool(from: []))
    }
}
