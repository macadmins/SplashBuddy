//
//  Copyright © 2018-present Amaris Technologies GmbH. All rights reserved.
//

import XCTest
@testable import SplashBuddy

class SoftwareTests: XCTestCase {

    // MARK: - Lifecycle

    var assetPathURL: URL?

    override func setUp() {
        super.setUp()

        assetPathURL = URL(string: Bundle(for: type(of: self)).bundlePath + "/Contents/Resources")
    }

    // MARK: - Tests

    func testShouldInstantiateFromDictionary() {
        let input: [String: Any] = [
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
        ]

        let result = Software(from: NSDictionary(dictionary: input), assetPath: assetPathURL!)!
        let testPath = "\(assetPathURL!.path)/ec_32x32.png"

        XCTAssertEqual(result.packageName, "Enterprise Connect")
        XCTAssertNil(result.packageVersion)
        XCTAssertEqual(result.status, Software.SoftwareStatus.pending)
        XCTAssertEqual(result.icon!.tiffRepresentation, NSImage(byReferencingFile: testPath)!.tiffRepresentation)
        XCTAssertEqual(result.displayName, "Enterprise Connect")
        XCTAssertEqual(result.desc, "SSO")
        XCTAssertTrue(result.canContinue)
        XCTAssertTrue(result.displayToUser)
    }

    func testShouldNotInstantiateWithoutDisplayName() {
        let input: [String: Any] = [
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
        ]

        let result = Software(from: NSDictionary(dictionary: input), assetPath: assetPathURL!)

        XCTAssertNil(result)
    }

    func testShouldNotInstantiateWithoutDescription() {
        let input: [String: Any] = [
            "displayName": "Enterprise Connect",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
        ]

        let result = Software(from: NSDictionary(dictionary: input), assetPath: assetPathURL!)

        XCTAssertNil(result)
    }

    func testShouldNotInstantiateWithoutPackageName() {
        let input: [String: Any] = [
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
        ]

        let result = Software(from:  NSDictionary(dictionary: input), assetPath: assetPathURL!)

        XCTAssertNil(result)
    }

    func testShouldNotInstantiateWithoutIconRelativePath() {

        let input: [String: Any] = [
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "canContinue": 1
        ]

        let result = Software(from: NSDictionary(dictionary: input), assetPath: assetPathURL!)

        XCTAssertNil(result)
    }

    func testShouldNotInstantiateWithoutCanContinue() {
        let input: [String: Any] = [
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png"
        ]

        let result = Software(from: NSDictionary(dictionary: input), assetPath: assetPathURL!)

        XCTAssertNil(result)
    }
}
