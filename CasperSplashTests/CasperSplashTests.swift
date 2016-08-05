//
//  CasperSplashTests.swift
//  CasperSplashTests
//
//  Created by testpilotfinal on 02/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import XCTest
@testable import CasperSplash



class CasperSplashTests: XCTestCase {
    
    var appDelegate: AppDelegate!
    var testUserDefaults: NSUserDefaults!
    var testPrefs: Preferences!
    var casperSplashController: CasperSplashController!
    var softwareArray = [Software]()
    //var testPrefs = Preferences!(nil)
    
    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
        
        // Global Default UserDefaults
        testUserDefaults = NSUserDefaults.init(suiteName: "testing")
        
        let path = NSBundle(forClass: self.dynamicType).bundlePath + "/Contents/Resources"
        testUserDefaults!.setObject(path, forKey: "assetPath")
        
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        
        testUserDefaults.removeSuiteNamed("testing")
        testUserDefaults = nil
        
    }
    
    
    
    // Packages Installing
    func testRegexInstallingPackage_Name() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installing EnterpriseConnect-1.5.3.pkg..."
        let output = "EnterpriseConnect"
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.packageName, output)
    }
    
    func testRegexInstallingPackage_Version() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installing EnterpriseConnect-1.5.3.pkg..."
        let output = "1.5.3"
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.packageVersion, output)
    }
    
    func testRegexInstallingPackage_Status() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installing EnterpriseConnect-1.5.3.pkg..."
        let output = Software.SoftwareStatus.Installing.rawValue
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.status.rawValue, output)
    }
    
    
    
    
    // Packages Successfully Installed
    func testRegexSuccessfullyInstalledPackage_Name() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Successfully installed EnterpriseConnect-1.5.3.pkg."
        let output = "EnterpriseConnect"
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.packageName, output)
    }
    
    func testRegexSuccessfullyInstalledPackage_Version() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Successfully installed EnterpriseConnect-1.5.3.pkg."
        let output = "1.5.3"
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.packageVersion, output)
    }
    
    func testRegexSuccessfullyInstalledPackage_Status() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Successfully installed EnterpriseConnect-1.5.3.pkg."
        let output = Software.SoftwareStatus.Success.rawValue
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.status.rawValue, output)
    }
    
    
    
    
    // Failed Packages
    func testRegexFailedInstall_Name() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installation failed. The installer reported: installer: Package name is EnterpriseConnect-1.5.3"
        let output = "EnterpriseConnect"
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.packageName, output)
    }
    
    func testRegexFailedInstall_Version() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installation failed. The installer reported: installer: Package name is EnterpriseConnect-1.5.3"
        let output = "1.5.3"
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.packageVersion, output)
    }

    func testRegexFailedInstall_Status() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installation failed. The installer reported: installer: Package name is EnterpriseConnect-1.5.3"
        let output = Software.SoftwareStatus.Failed.rawValue
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.status.rawValue, output)
    }
    
    
    
    func testReadFromFile_CanReadFile() {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("jamf_1", ofType: "txt")
        let output = [
        "Wed Mar 16 13:31:11 François's Mac mini jamf[2874]: Installing Success021-0.21.pkg...",
        "Wed Mar 16 13:31:14 François's Mac mini jamf[2874]: Successfully installed Success021-0.21.pkg.",
        "Wed Mar 16 13:31:15 François's Mac mini jamf[2874]: Installing Failed153-1.5.3.pkg...",
        "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installation failed. The installer reported: installer: Package name is Failed153-1.5.3",
        "Wed Mar 16 13:31:11 François's Mac mini jamf[2874]: Installing Installing022-0.22.pkg...",
        ]

        let fileHandle = NSFileHandle(forReadingAtPath: path!)
        XCTAssertEqual(readLinesFromFile(fileHandle!)!, output)
    }
    
    func testReadFromFile_CanParseSoftwareFromFile() {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("jamf_1", ofType: "txt")
        
        struct software {
            let name: String
            let version: String
            let status: Software.SoftwareStatus
            
        }
        let output = [
            software.init(name: "Success021", version: "0.21", status: .Success),
            software.init(name: "Failed153", version: "1.5.3", status: .Failed),
            software.init(name: "Installing022", version: "0.22", status: .Installing)
        ]
        let fileHandle = NSFileHandle(forReadingAtPath: path!)
        let results = fileToSoftware(fileHandle!)

        for (index, item) in output.enumerate() {
            XCTAssertEqual(results[index].packageName, item.name)
            XCTAssertEqual(results[index].packageVersion, item.version)
            XCTAssertEqual(results[index].status, item.status)
            XCTAssertEqual(results[index].icon, NSImage(imageLiteral: NSImageNameFolder))
            XCTAssertNil(results[index].displayName)
            XCTAssertNil(results[index].desc)
            XCTAssertEqual(results[index].canContinue, true)
        }

    }
    
    func testReadFromFile_NonExistentFile() {
        let path = "/nonexistent"
        let fileHandle = NSFileHandle(forReadingAtPath: path)
        XCTAssertNil(readLinesFromFile(fileHandle))
    }
    
    func testAddIcon_CheckIfNSImage() {
        let path = NSBundle(forClass: self.dynamicType).pathForImageResource("ec_32x32")

        XCTAssert(Software(name: "EC", version: "1.6.2", status: .Installing, iconPath: path).icon!.dynamicType == NSImage().dynamicType)
    }
    
    func testAddIcon_WithIncorrectResource() {
        let path = NSBundle(forClass: self.dynamicType).pathForImageResource("nonexistent")
        
        XCTAssertEqual(Software(name: "EC", version: "1.6.2", status: .Installing, iconPath: path).icon, NSImage(imageLiteral: NSImageNameFolder))
    }
    
    func testUserDefaults_assetPath() {
        
        let output = NSBundle(forClass: self.dynamicType).bundlePath + "/Contents/Resources"
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        XCTAssertEqual(testPrefs.assetPath, output)
    }
    
    func testUserDefaults_assetPathEmptyUserDefaults() {
        
        let testNoneUserDefaults = NSUserDefaults.init(suiteName: "none")
        let testNonePrefs = Preferences(nsUserDefaults: testNoneUserDefaults!)
        
        XCTAssertNil(testNonePrefs.assetPath)
    }
    
    func testUserDefaults_Application() {
        
        let input = [[
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": "1"
            ]]
        // Setup user defaults
        
        testUserDefaults!.setObject(input, forKey: "applicationsArray")
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        testPrefs.getPreferencesApplications(&softwareArray)
        
        XCTAssertEqual(self.softwareArray.first!.packageName, "Enterprise Connect")
        XCTAssertEqual(self.softwareArray.first!.status, Software.SoftwareStatus.Pending)
        XCTAssert(self.softwareArray.first!.icon?.dynamicType == NSImage().dynamicType)
        XCTAssertEqual(self.softwareArray.first!.displayName, "Enterprise Connect")
        XCTAssertEqual(self.softwareArray.first!.desc, "SSO")
        XCTAssertEqual(self.softwareArray.first!.canContinue, true)
        XCTAssertEqual(self.softwareArray.first!.displayToUser, true)
        
        testUserDefaults.removeObjectForKey("applicationsArray")
        XCTAssertNil(testUserDefaults.objectForKey("applicationsArray"))
    }

    func testUserDefaults_ApplicationMultiple() {
        
        let input = [[
                "displayName": "Enterprise Connect",
                "description": "SSO",
                "packageName": "Enterprise Connect",
                "iconRelativePath": "ec_32x32.png",
                "canContinue": "1"
            ],[
                "displayName": "Druva",
                "description": "Backup",
                "packageName": "DruvaEndPoint",
                "iconRelativePath": "ec_32x32.png",
                "canContinue": "1"
            ]
                     ]
        // Setup user defaults
        
        testUserDefaults!.setObject(input, forKey: "applicationsArray")
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        testPrefs.getPreferencesApplications(&softwareArray)
        
        XCTAssertEqual(self.softwareArray.first!.packageName, "Enterprise Connect")
        XCTAssertEqual(self.softwareArray.first!.status, Software.SoftwareStatus.Pending)
        XCTAssert(self.softwareArray.first!.icon?.dynamicType == NSImage().dynamicType)
        XCTAssertEqual(self.softwareArray.first!.displayName, "Enterprise Connect")
        XCTAssertEqual(self.softwareArray.first!.desc, "SSO")
        XCTAssertEqual(self.softwareArray.first!.canContinue, true)
        XCTAssertEqual(self.softwareArray.first!.displayToUser, true)
        
        XCTAssertEqual(self.softwareArray.last!.displayName, "Druva")
        XCTAssertEqual(self.softwareArray.last!.desc, "Backup")
        XCTAssertEqual(self.softwareArray.last!.packageName, "DruvaEndPoint")
        XCTAssert(self.softwareArray.last!.icon?.dynamicType == NSImage().dynamicType)
        XCTAssertEqual(self.softwareArray.last!.canContinue, true)
        XCTAssertEqual(self.softwareArray.last!.status, Software.SoftwareStatus.Pending)
        XCTAssertEqual(self.softwareArray.last!.displayToUser, true)
        
        testUserDefaults.removeObjectForKey("applicationsArray")
        XCTAssertNil(testUserDefaults.objectForKey("applicationsArray"))
    }
    
    func testUserDefaults_ApplicationEmptyUserDefaults() {
        
        testUserDefaults = NSUserDefaults.init(suiteName: "none")
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        testPrefs.getPreferencesApplications(&softwareArray)
        
        XCTAssertTrue(self.softwareArray.isEmpty)
    }
    
    func testUserDefaults_CanParseSoftwareFromFile() {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("jamf_1", ofType: "txt")
        
        let input = [[
            "displayName": "Suceeded",
            "description": "test",
            "packageName": "Success021",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": "1"
            ]]
        // Setup user defaults
        
        testUserDefaults!.setObject(input, forKey: "applicationsArray")
        
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        testPrefs.getPreferencesApplications(&softwareArray)
        
        let fileHandle = NSFileHandle(forReadingAtPath: path!)
        modifySoftwareArrayFromFile(fileHandle, softwareArray: &self.softwareArray)
        
        XCTAssertEqual(self.softwareArray.first!.packageName, "Success021")
        XCTAssertEqual(self.softwareArray.first!.packageVersion, "0.21")
        XCTAssertEqual(self.softwareArray.first!.status, Software.SoftwareStatus.Success)
        XCTAssert(self.softwareArray.first!.icon?.dynamicType == NSImage().dynamicType)
        XCTAssertEqual(self.softwareArray.first!.displayName, "Suceeded")
        XCTAssertEqual(self.softwareArray.first!.desc, "test")
        XCTAssertEqual(self.softwareArray.first!.canContinue, true)
        XCTAssertEqual(self.softwareArray.first!.displayToUser, true)
        
        testUserDefaults.removeObjectForKey("applicationsArray")
        XCTAssertNil(testUserDefaults.objectForKey("applicationsArray"))
    }
    
    func testUserDefaults_PostInstallScriptFullPath() {
        
        let input = "test_postinstall_successful.sh"
        testUserDefaults.setObject(input, forKey: "postInstallAssetPath")
        let output = NSBundle(forClass: self.dynamicType).bundlePath + "/Contents/Resources/" + input
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        XCTAssertEqual(testPrefs.postInstallScript?.absolutePath, output)
        
        testUserDefaults.removeObjectForKey("postInstallAssetPath")
        XCTAssertNil(testUserDefaults.objectForKey("postInstallAssetPath"))
    }
    
    func testUserDefaults_PostInstallScriptFullPathEmpty() {
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        XCTAssertNil(testUserDefaults.objectForKey("postInstallAssetPath"))
        XCTAssertNil(testPrefs.postInstallScript?.absolutePath, "")
    }
    
    func testUserDefaults_PostInstallSuccessful() {
        
        let input = "test_postinstall_successful.sh"
        testUserDefaults.setObject(input, forKey: "postInstallAssetPath")
        
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        let script = Script(absolutePath: testPrefs.postInstallScript!.absolutePath)
        
        script.execute { (isSuccessful) in
            XCTAssertTrue(isSuccessful)
        }
        
        testUserDefaults.removeObjectForKey("postInstallAssetPath")
        XCTAssertNil(testUserDefaults.objectForKey("postInstallAssetPath"))
    }
    
    func testUserDefaults_PostInstallFailed() {
        
        let input = "test_postinstall_failed.sh"
        testUserDefaults.setObject(input, forKey: "postInstallAssetPath")
        
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        let script = Script(absolutePath: testPrefs.postInstallScript!.absolutePath)
        script.execute { (isSuccessful) in
            XCTAssertFalse(isSuccessful)
        }
        
        testUserDefaults.removeObjectForKey("postInstallAssetPath")
        XCTAssertNil(testUserDefaults.objectForKey("postInstallAssetPath"))
    }
    
    
    func testUserDefaults_HTMLFullPath() {
        
        let input = "index.html"
        testUserDefaults.setObject(input, forKey: "htmlPath")
        let output = NSBundle(forClass: self.dynamicType).bundlePath + "/Contents/Resources/" + input
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        XCTAssertEqual(testPrefs.htmlAbsolutePath!, output)
        
        testUserDefaults.removeObjectForKey("postInstallAssetPath")
        XCTAssertNil(testUserDefaults.objectForKey("postInstallAssetPath"))
    }
    
    func testUserDefaults_HTMLFullPathEmpty() {
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        let output = NSBundle(forClass: self.dynamicType).bundlePath + "/Contents/Resources/index.html"
        
        XCTAssertEqual(testPrefs.htmlAbsolutePath!, output)
    }


}
