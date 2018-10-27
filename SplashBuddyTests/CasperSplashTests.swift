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

class CasperSplashTests: XCTestCase {

    var appDelegate: AppDelegate!
    var testUserDefaults: UserDefaults!
    var testPrefs: Preferences!
    var casperSplashController: MainWindowController!
    var casperSplashMainController: MainViewController!

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()

        // Global Default UserDefaults
        testUserDefaults = UserDefaults.init(suiteName: "testing")

        let path = Bundle(for: type(of: self)).bundlePath + "/Contents/Resources"
        testUserDefaults!.set(path, forKey: "assetPath")
    }

    override func tearDown() {
        super.tearDown()

        testUserDefaults.removeSuite(named: "testing")
        testUserDefaults = nil
        SoftwareArray.sharedInstance.array.removeAll()
    }

    // Packages Installing
    func testRegexInstallingPackage_Status() throws {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installing EnterpriseConnect-1.5.3.pkg..."
        let output = Software.SoftwareStatus.installing

        XCTAssertEqual(try JAMFInsider.JAMFLineChecker().check(line: input), output)
    }

    // Packages Successfully Installed
    func testRegexSuccessfullyInstalledPackage_Status() throws {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Successfully installed EnterpriseConnect-1.5.3.pkg."
        let output = Software.SoftwareStatus.success

        XCTAssertEqual(try JAMFInsider.JAMFLineChecker().check(line: input), output)
    }

    // Failed Packages
    func testRegexFailedInstall_Status() throws {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installation failed. The installer reported: installer: Package name is EnterpriseConnect-1.5.3"
        let output = Software.SoftwareStatus.failed

        XCTAssertEqual(try JAMFInsider.JAMFLineChecker().check(line: input), output)
    }

    func testReadFromFile_NonExistentFile() {
        let path = "/nonexistent"
        let fileHandle = FileHandle(forReadingAtPath: path)

        XCTAssertNil(fileHandle)
    }

    func testAddIcon_CheckIfNSImage()  {
        let path = Bundle(for: type(of: self)).pathForImageResource(NSImage.Name(rawValue: "ec_32x32.png"))
        let icon = Software(packageName: "EC", status: .installing, iconPath: path).icon
        XCTAssert(type(of: icon!) == type(of: NSImage()))
    }

    func testAddIcon_WithIncorrectResource() {
        let path = Bundle(for: type(of: self)).pathForImageResource(NSImage.Name(rawValue: "nonexistent"))

        XCTAssertEqual(Software(packageName: "EC", status: .installing, iconPath: path).icon, NSImage(named: NSImage.Name.folder))
    }

    func testCanContinue_yes() {
        Preferences.sharedInstance.doneParsingPlist = true

        casperSplashMainController = MainViewController()
        let input: [Software] = [
            Software(packageName: "test1", status: .success, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true),
            Software(packageName: "test2", status: .success, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true)
        ]
        XCTAssertTrue(SoftwareArray.sharedInstance.canContinue(input))
    }

    func testCanContinue_yesNoCritical() {
        Preferences.sharedInstance.doneParsingPlist = true

        casperSplashMainController = MainViewController()
        let input: [Software] = [
            Software(packageName: "test1", status: .failed, iconPath: nil, displayName: nil, description: nil, canContinue: true, displayToUser: true),
            Software(packageName: "test2", status: .failed, iconPath: nil, displayName: nil, description: nil, canContinue: true, displayToUser: true)
        ]
        XCTAssertTrue(SoftwareArray.sharedInstance.canContinue(input))
    }

    func testCanContinue_no() {
        Preferences.sharedInstance.doneParsingPlist = true

        casperSplashMainController = MainViewController()
        let input = [
            Software(packageName: "test1", status: .pending, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true),
            Software(packageName: "test2", status: .success, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true)
        ]
        XCTAssertFalse(SoftwareArray.sharedInstance.canContinue(input))
    }
}
