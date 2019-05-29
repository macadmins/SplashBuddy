//
//  Copyright © 2018-present Amaris Technologies GmbH. All rights reserved.
//

import XCTest
@testable import SplashBuddy

class PreferencesTests: XCTestCase {

    // MARK: - Properties

    var appDelegate: AppDelegate!
    var testUserDefaults: UserDefaults!
    var testPrefs: Preferences!
    var casperSplashController: MainWindowController!
    var casperSplashMainController: MainViewController!
    var assetPath = ""

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()

        // Global Default UserDefaults
        testUserDefaults = UserDefaults.init(suiteName: "testing")

        assetPath = Bundle(for: type(of: self)).bundlePath + "/Contents/Resources"
        testUserDefaults!.set(assetPath, forKey: "TSTAssetPath")

        let testJamfLog = Bundle(for: type(of: self)).path(forResource: "jamf_1", ofType: "txt")
        testUserDefaults!.set(testJamfLog, forKey: "TSTJamfLog")

        testPrefs = Preferences(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        super.tearDown()

        testPrefs = nil
        testUserDefaults.removeSuite(named: "testing")
        testUserDefaults = nil
        SoftwareArray.sharedInstance.array.removeAll()
    }

    // MARK: - Tests

    func testSetSetupDone() {
        Preferences.sharedInstance.setupDone = true
        debugPrint(FileManager.default.currentDirectoryPath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: "Library/.SplashBuddyDone"))
    }

    func testUnsetSetupDone() {
        Preferences.sharedInstance.setupDone = false
        XCTAssertFalse(FileManager.default.fileExists(atPath: "Library/.SplashBuddyDone"))
    }

    func testSetupDoneSet() {
        FileManager.default.createFile(atPath: "Library/.SplashBuddyDone", contents: nil, attributes: nil)
        XCTAssertTrue(Preferences.sharedInstance.setupDone)
    }

    func testSetupDoneNotSet() {
        _ = try? FileManager.default.removeItem(atPath: "Library/.SplashBuddyDone")
        XCTAssertFalse(Preferences.sharedInstance.setupDone)
    }

    func testUserDefaults_MalformedApplication() {
        let input = [true]
        testUserDefaults!.set(input, forKey: "applicationsArray")
        testPrefs = Preferences(userDefaults: testUserDefaults)
        XCTAssertThrowsError(try testPrefs.getApplicationsFromPreferences(), "") { (error) in
            XCTAssertEqual(error as? Preferences.Errors, .malformedApplication)
        }
    }

    func testUserDefaults_NoApplicationsArray() {
        testUserDefaults.set(nil, forKey: "applicationsArray")
        testPrefs = Preferences(userDefaults: testUserDefaults)
        XCTAssertThrowsError(try testPrefs.getApplicationsFromPreferences(), "") { (error) in
            XCTAssertEqual(error as? Preferences.Errors, .noApplicationArray)
        }
    }

    func testUserDefaults_Application() {
        let input = [[
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
            ]]
        // Setup user defaults

        testUserDefaults!.set(input, forKey: "applicationsArray")
        testPrefs = Preferences(userDefaults: testUserDefaults)

        try! testPrefs.getApplicationsFromPreferences()

        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.packageName, "Enterprise Connect")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.status, Software.SoftwareStatus.pending)
        XCTAssert(type(of: SoftwareArray.sharedInstance.array.first!.icon!) == type(of: NSImage()))
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.displayName, "Enterprise Connect")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.desc, "SSO")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.canContinue, true)
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.displayToUser, true)

        testUserDefaults.removeObject(forKey: "applicationsArray")
        XCTAssertNil(testUserDefaults.object(forKey: "applicationsArray"))
    }

    func testUserDefaults_ApplicationCanContinueAsString() {

        let input = [[
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": "1"
            ]]

        // Setup user defaults
        testUserDefaults!.set(input, forKey: "applicationsArray")
        testPrefs = Preferences(userDefaults: testUserDefaults)

        try! testPrefs.getApplicationsFromPreferences()

        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.packageName, "Enterprise Connect")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.status, Software.SoftwareStatus.pending)
        XCTAssert(type(of: SoftwareArray.sharedInstance.array.first!.icon!) == type(of: NSImage()))
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.displayName, "Enterprise Connect")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.desc, "SSO")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.canContinue, true)
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.displayToUser, true)

        testUserDefaults.removeObject(forKey: "applicationsArray")
        XCTAssertNil(testUserDefaults.object(forKey: "applicationsArray"))
    }

    func testUserDefaults_ApplicationMultiple() {
        let input = [[
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
            ], [
                "displayName": "Druva",
                "description": "Backup",
                "packageName": "DruvaEndPoint",
                "iconRelativePath": "ec_32x32.png",
                "canContinue": 1
            ]
        ]

        // Setup user defaults
        testUserDefaults!.set(input, forKey: "applicationsArray")
        testPrefs = Preferences(userDefaults: testUserDefaults)

        try! testPrefs.getApplicationsFromPreferences()

        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.packageName, "Enterprise Connect")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.status, Software.SoftwareStatus.pending)
        XCTAssert(type(of: SoftwareArray.sharedInstance.array.first!.icon!) == type(of: NSImage()))
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.displayName, "Enterprise Connect")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.desc, "SSO")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.canContinue, true)
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.displayToUser, true)

        XCTAssertEqual(SoftwareArray.sharedInstance.array.last!.displayName, "Druva")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.last!.desc, "Backup")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.last!.packageName, "DruvaEndPoint")
        XCTAssert(type(of: SoftwareArray.sharedInstance.array.last!.icon!) == type(of: NSImage()))
        XCTAssertEqual(SoftwareArray.sharedInstance.array.last!.canContinue, true)
        XCTAssertEqual(SoftwareArray.sharedInstance.array.last!.status, Software.SoftwareStatus.pending)
        XCTAssertEqual(SoftwareArray.sharedInstance.array.last!.displayToUser, true)

        testUserDefaults.removeObject(forKey: "applicationsArray")
        XCTAssertNil(testUserDefaults.object(forKey: "applicationsArray"))
    }

    func testUserDefaults_ApplicationEmptyUserDefaults() {
        testUserDefaults = UserDefaults.init(suiteName: "none")
        testPrefs = Preferences(userDefaults: testUserDefaults)

        // Disabling throwing ".noApplicationArray"
        _ = try? testPrefs.getApplicationsFromPreferences()

        XCTAssertTrue(SoftwareArray.sharedInstance.array.isEmpty)
    }
}
