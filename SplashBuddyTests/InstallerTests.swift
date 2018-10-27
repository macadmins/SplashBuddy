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

class InstallerTests: XCTestCase {
    
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
    func testStatusWhenInstallationStart() throws {
        let input = "2018-09-25 23:17:53+02 MacBook-Pro installd[479]: PackageKit: Extracting file://localhost/Library/Managed%20Installs/Cache/msoutlook2016-16.16.18091001.pkg#Microsoft_Outlook.pkg (destination=/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/C/PKInstallSandboxManager/C0E37156-FA33-4FEB-AB9F-EBA0588BBC32.activeSandbox/Root/Applications, uid=0)"
        let output = Software.SoftwareStatus.installing
        
        XCTAssertEqual(try InstallerInsider.InstallerLineChecker().check(line: input), output)
    }
    
    // Packages Successfully Installed
    func testStatusWhenInstallationSucceed() throws {
        let input = "2018-09-25 23:18:35+02 MacBook-Pro installd[479]: Installed \"Microsoft Outlook for Mac\" ()"
        let output = Software.SoftwareStatus.success
        
        XCTAssertEqual(try InstallerInsider.InstallerLineChecker().check(line: input), output)
    }
    
    // Failed Packages
    func testStatusWhenInstallationFailed() throws {
        let input = "2018-10-27 10:39:06+02 MacBook-Pro-4 installd[1850]: PackageKit: Install Failed: Error Domain=PKInstallErrorDomain Code=112 \"Une erreur s’est produite pendant l’exécution des scripts du paquet « Fail pre install script.pkg ».\" UserInfo={NSFilePath=./preinstall, NSURL=file://localhost/Users/ygi/Desktop/FailPreInstall/build/Fail%20pre%20install%20script.pkg, PKInstallPackageIdentifier=com.abelionni.pkg.failpreinstall, NSLocalizedDescription=Une erreur s’est produite pendant l’exécution des scripts du paquet « Fail pre install script.pkg ».} {"
        let output = Software.SoftwareStatus.failed
        
        XCTAssertEqual(try InstallerInsider.InstallerLineChecker().check(line: input), output)
    }
}
