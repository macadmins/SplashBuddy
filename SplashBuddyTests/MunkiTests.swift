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

class MunkiTests: XCTestCase {
    
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
    
//    // Packages Installing
//    func testStatusWhenInstallationStart() throws {
//        let input = "Oct 27 2018 00:57:20 +0200 Installing Oracle Java 8 from oraclejava8-1.8.181.13.pkg"
//        let output = Software.SoftwareStatus.installing
//        
//        XCTAssertEqual(try MunkiInsider.MunkiLineChecker().check(line: input), output)
//    }
//    
//    // Packages Successfully Installed
//    func testStatusWhenInstallationSucceed() throws {
//        let input = "Oct 27 2018 00:57:27 +0200 Install of oraclejava8-1.8.181.13.pkg was successful."
//        let output = Software.SoftwareStatus.success
//        
//        XCTAssertEqual(try MunkiInsider.MunkiLineChecker().check(line: input), output)
//    }
//    
//    // Failed Packages
//    func testStatusWhenInstallationFailed() throws {
//        let input = "Oct 28 2018 09:45:56 +0100  The install failed (The Installer encountered an error that caused the installation to fail. Contact the software manufacturer for assistance.)"
//        let output = Software.SoftwareStatus.failed
//        
//        XCTAssertEqual(try MunkiInsider.MunkiLineChecker().check(line: input), output)
//    }
}
