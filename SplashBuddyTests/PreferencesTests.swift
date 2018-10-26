// SplashBuddy

/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest
@testable import SplashBuddy

class PreferencesTests: XCTestCase {

    var appDelegate: AppDelegate!
    var testUserDefaults: UserDefaults!
    var testPrefs: Preferences!
    var casperSplashController: MainWindowController!
    var casperSplashMainController: MainViewController!

    var assetPath = ""

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()

        // Global Default UserDefaults
        testUserDefaults = UserDefaults.init(suiteName: "testing")

        assetPath = Bundle(for: type(of: self)).bundlePath + "/Contents/Resources"
        testUserDefaults!.set(assetPath, forKey: "TSTAssetPath")

        let testJamfLog = Bundle(for: type(of: self)).path(forResource: "jamf_1", ofType: "txt")
        testUserDefaults!.set(testJamfLog, forKey: "TSTJamfLog")

        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
    }

    override func tearDown() {
        super.tearDown()

        testPrefs = nil
        testUserDefaults.removeSuite(named: "testing")
        testUserDefaults = nil
        SoftwareArray.sharedInstance.array.removeAll()
    }

    //-----------------------------------------------------------------------------------
    // MARK: - File Handle
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    // MARK: - Setup Done
    //-----------------------------------------------------------------------------------

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

    //-----------------------------------------------------------------------------------
    // MARK: - User Defaults
    //-----------------------------------------------------------------------------------

    func testUserDefaults_MalformedApplication() {
        let input = [true]
        testUserDefaults!.set(input, forKey: "applicationsArray")
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        XCTAssertThrowsError(try testPrefs.getPreferencesApplications(), "") { (error) in
            XCTAssertEqual(error as? Preferences.Errors, .malformedApplication)
        }
    }

    func testUserDefaults_NoApplicationsArray() {
        testUserDefaults.set(nil, forKey: "applicationsArray")
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        XCTAssertThrowsError(try testPrefs.getPreferencesApplications(), "") { (error) in
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
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)

        try! testPrefs.getPreferencesApplications()

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
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)

        try! testPrefs.getPreferencesApplications()

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
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)

        try! testPrefs.getPreferencesApplications()

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
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)

        // Disabling throwing ".noApplicationArray"
        _ = try? testPrefs.getPreferencesApplications()

        XCTAssertTrue(SoftwareArray.sharedInstance.array.isEmpty)
    }

    func test_extractSoftware() {
        let input: Dictionary = [
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
            ] as [String: Any]

        let nsDict = NSDictionary(dictionary: input)
        let result = testPrefs.extractSoftware(from: nsDict)!
        let testPath = "\(self.assetPath)/ec_32x32.png"

        XCTAssertEqual(result.packageName, "Enterprise Connect")
        XCTAssertNil(result.packageVersion)
        XCTAssertEqual(result.status, Software.SoftwareStatus.pending)
        XCTAssertEqual(result.icon!.tiffRepresentation, NSImage(byReferencingFile: testPath)!.tiffRepresentation)
        XCTAssertEqual(result.displayName, "Enterprise Connect")
        XCTAssertEqual(result.desc, "SSO")
        XCTAssertTrue(result.canContinue)
        XCTAssertTrue(result.displayToUser)
    }

    //-----------------------------------------------------------------------------------
    // MARK: - Extraxt Software
    //-----------------------------------------------------------------------------------

    func test_extractSoftware_no_displayName() {

        let input: Dictionary = [
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
            ] as [String: Any]

        let nsDict = NSDictionary(dictionary: input)
        let result = testPrefs.extractSoftware(from: nsDict)

        XCTAssertNil(result)
    }

    func test_extractSoftware_no_description() {
        let input: Dictionary = [
            "displayName": "Enterprise Connect",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
            ] as [String: Any]

        let nsDict = NSDictionary(dictionary: input)
        let result = testPrefs.extractSoftware(from: nsDict)

        XCTAssertNil(result)
    }

    func test_extractSoftware_no_packageName() {
        let input: Dictionary = [
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
            ] as [String: Any]

        let nsDict = NSDictionary(dictionary: input)
        let result = testPrefs.extractSoftware(from: nsDict)

        XCTAssertNil(result)
    }

    func test_extractSoftware_no_iconRelativePath() {

        let input: Dictionary = [
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "canContinue": 1
            ] as [String: Any]

        let nsDict = NSDictionary(dictionary: input)
        let result = testPrefs.extractSoftware(from: nsDict)

        XCTAssertNil(result)
    }

    func test_extractSoftware_no_canContinue() {
        let input: Dictionary = [
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png"
            ] as [String: Any]

        let nsDict = NSDictionary(dictionary: input)
        let result = testPrefs.extractSoftware(from: nsDict)

        XCTAssertNil(result)
    }

    //-----------------------------------------------------------------------------------
    // MARK: - Get Bool
    //-----------------------------------------------------------------------------------

    func test_getBool_String() {
        XCTAssertTrue(testPrefs.getBool(from: "1")!)
        XCTAssertFalse(testPrefs.getBool(from: "0")!)
        XCTAssertFalse(testPrefs.getBool(from: "9")!)
    }

    func test_getBool_Int() {
        XCTAssertTrue(testPrefs.getBool(from: 1)!)
        XCTAssertFalse(testPrefs.getBool(from: 0)!)
        XCTAssertFalse(testPrefs.getBool(from: 9)!)
    }

    func test_getBool_Bool() {
        XCTAssertTrue(testPrefs.getBool(from: true)!)
        XCTAssertFalse(testPrefs.getBool(from: false)!)
    }

    func test_getBool_Other() {
        XCTAssertNil(testPrefs.getBool(from: [:]))
        XCTAssertNil(testPrefs.getBool(from: []))
    }
}
