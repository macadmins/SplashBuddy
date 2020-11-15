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

class GeneralTests: XCTestCase {
    
    var appDelegate: AppDelegate!
    var testUserDefaults: UserDefaults!
    var testPrefs: Preferences!
    
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
    
    func testReadingAnImpossiblePath() {
        let path = "/nonexistent"
        let fileHandle = FileHandle(forReadingAtPath: path)
        
        XCTAssertNil(fileHandle)
    }
    
    func testLoadingValidIcon()  {
        let path = Bundle(for: type(of: self)).pathForImageResource("ec_32x32.png")
        let icon = Software(packageName: "EC", status: .installing, iconPath: path).icon
        XCTAssert(type(of: icon!) == type(of: NSImage()))
    }
    
    func testLoadingInvalidIcon() {
        let path = Bundle(for: type(of: self)).pathForImageResource("nonexistent")
        
        XCTAssertEqual(Software(packageName: "EC", status: .installing, iconPath: path).icon, NSImage(named: NSImage.folderName))
    }
    
    func testToContinueWithMandatorySoftwareCorrectlyInstalled() {
        Preferences.sharedInstance.doneParsingPlist = true
        
        let input: [Software] = [
            Software(packageName: "test1", status: .success, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true),
            Software(packageName: "test2", status: .success, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true)
        ]
        XCTAssertTrue(SoftwareArray.sharedInstance.canContinue(input))
    }
    
    func testToContinueWithOptionalSoftwareIncorrectlyInstalled() {
        Preferences.sharedInstance.doneParsingPlist = true
        
        let input: [Software] = [
            Software(packageName: "test1", status: .failed, iconPath: nil, displayName: nil, description: nil, canContinue: true, displayToUser: true),
            Software(packageName: "test2", status: .failed, iconPath: nil, displayName: nil, description: nil, canContinue: true, displayToUser: true)
        ]
        XCTAssertTrue(SoftwareArray.sharedInstance.canContinue(input))
    }
    
    func testToContinueWithMandatorySoftwareStillInstalling() {
        Preferences.sharedInstance.doneParsingPlist = true
        
        let input = [
            Software(packageName: "test1", status: .pending, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true),
            Software(packageName: "test2", status: .success, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true)
        ]
        XCTAssertFalse(SoftwareArray.sharedInstance.canContinue(input))
    }
}
