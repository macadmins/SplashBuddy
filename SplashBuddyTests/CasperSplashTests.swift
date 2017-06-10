//
//  CasperSplashTests.swift
//  CasperSplashTests
//
//  Created by ftiff on 02/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

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
    func testRegexInstallingPackage_Name() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installing EnterpriseConnect-1.5.3.pkg..."
        let output = "EnterpriseConnect"
        
        XCTAssertEqual(Software(from: input)!.packageName, output)
    }
    
    func testRegexInstallingPackage_Version() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installing EnterpriseConnect-1.5.3.pkg..."
        let output = "1.5.3"
        
        XCTAssertEqual(Software(from: input)!.packageVersion, output)
    }
    
    func testRegexInstallingPackage_Status() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installing EnterpriseConnect-1.5.3.pkg..."
        let output = Software.SoftwareStatus.installing.rawValue
        
        XCTAssertEqual(Software(from: input)!.status.rawValue, output)
    }
    
    
    
    
    // Packages Successfully Installed
    func testRegexSuccessfullyInstalledPackage_Name() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Successfully installed EnterpriseConnect-1.5.3.pkg."
        let output = "EnterpriseConnect"
        
        XCTAssertEqual(Software(from: input)!.packageName, output)
    }
    
    func testRegexSuccessfullyInstalledPackage_Version() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Successfully installed EnterpriseConnect-1.5.3.pkg."
        let output = "1.5.3"
        
        XCTAssertEqual(Software(from: input)!.packageVersion, output)
    }
    
    func testRegexSuccessfullyInstalledPackage_Status() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Successfully installed EnterpriseConnect-1.5.3.pkg."
        let output = Software.SoftwareStatus.success.rawValue
        
        XCTAssertEqual(Software(from: input)!.status.rawValue, output)
    }
    
    
    
    
    // Failed Packages
    func testRegexFailedInstall_Name() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installation failed. The installer reported: installer: Package name is EnterpriseConnect-1.5.3"
        let output = "EnterpriseConnect"
        
        XCTAssertEqual(Software(from: input)!.packageName, output)
    }
    
    func testRegexFailedInstall_Version() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installation failed. The installer reported: installer: Package name is EnterpriseConnect-1.5.3"
        let output = "1.5.3"
        
        XCTAssertEqual(Software(from: input)!.packageVersion, output)
    }

    func testRegexFailedInstall_Status() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installation failed. The installer reported: installer: Package name is EnterpriseConnect-1.5.3"
        let output = Software.SoftwareStatus.failed.rawValue
        
        XCTAssertEqual(Software(from: input)!.status.rawValue, output)
    }
    
    
    
    func testReadFromFile_CanReadFile() {
        let path = Bundle(for: type(of: self)).path(forResource: "jamf_1", ofType: "txt")
        let output = [
        "Wed Mar 16 13:31:11 François's Mac mini jamf[2874]: Installing Success021-0.21.pkg...",
        "Wed Mar 16 13:31:14 François's Mac mini jamf[2874]: Successfully installed Success021-0.21.pkg.",
        "Wed Mar 16 13:31:15 François's Mac mini jamf[2874]: Installing Failed153-1.5.3.pkg...",
        "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installation failed. The installer reported: installer: Package name is Failed153-1.5.3",
        "Wed Mar 16 13:31:11 François's Mac mini jamf[2874]: Installing Installing022-0.22.pkg...",
        ]

        let fileHandle = FileHandle(forReadingAtPath: path!)
        XCTAssertEqual((fileHandle?.readLines()!)!, output)
    }
    
//    func testReadFromFile_CanParseSoftwareFromFile() {
//        let path = Bundle(for: type(of: self)).path(forResource: "jamf_1", ofType: "txt")
//        
//        struct software {
//            let name: String
//            let version: String
//            let status: Software.SoftwareStatus
//            
//        }
//        let output = [
//            software.init(name: "Success021", version: "0.21", status: .success),
//            software.init(name: "Failed153", version: "1.5.3", status: .failed),
//            software.init(name: "Installing022", version: "0.22", status: .installing)
//        ]
//        let fileHandle = FileHandle(forReadingAtPath: path!)
//        let results = fileToSoftware(fileHandle!)
//
//        for (index, item) in output.enumerated() {
//            XCTAssertEqual(results[index].packageName, item.name)
//            XCTAssertEqual(results[index].packageVersion, item.version)
//            XCTAssertEqual(results[index].status, item.status)
//            XCTAssertEqual(results[index].icon, NSImage(named: NSImageNameFolder))
//            XCTAssertNil(results[index].displayName)
//            XCTAssertNil(results[index].desc)
//            XCTAssertEqual(results[index].canContinue, true)
//        }
//
//    }
    
    func testReadFromFile_NonExistentFile() {
        let path = "/nonexistent"
        let fileHandle = FileHandle(forReadingAtPath: path)
        
        XCTAssertNil(fileHandle)
    }
    
    func testAddIcon_CheckIfNSImage() {
        let path = Bundle(for: type(of: self)).pathForImageResource(NSImage.Name(rawValue: "ec_32x32.png"))
        let icon = Software(packageName: "EC", version: "1.6.2", status: .installing, iconPath: path).icon
        XCTAssert(type(of: icon!) == type(of: NSImage()))
    }
    
    func testAddIcon_WithIncorrectResource() {
        let path = Bundle(for: type(of: self)).pathForImageResource(NSImage.Name(rawValue: "nonexistent"))
        
        XCTAssertEqual(Software(packageName: "EC", version: "1.6.2", status: .installing, iconPath: path).icon, NSImage(named: NSImage.Name.folder))
    }
    
    
    func testCanContinue_yes() {
        
        Preferences.sharedInstance.doneParsingPlist = true

        casperSplashMainController = MainViewController()
        let input: [Software] = [
            Software(packageName: "test1", version: nil, status: .success, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true),
            Software(packageName: "test2", version: nil, status: .success, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true)
        ]
        XCTAssertTrue(SoftwareArray.sharedInstance.canContinue(input))
    }
    
    func testCanContinue_yesNoCritical() {
        
        Preferences.sharedInstance.doneParsingPlist = true

        casperSplashMainController = MainViewController()
        let input: [Software] = [
            Software(packageName: "test1", version: nil, status: .failed, iconPath: nil, displayName: nil, description: nil, canContinue: true, displayToUser: true),
            Software(packageName: "test2", version: nil, status: .failed, iconPath: nil, displayName: nil, description: nil, canContinue: true, displayToUser: true)
        ]
        XCTAssertTrue(SoftwareArray.sharedInstance.canContinue(input))
    }

    func testCanContinue_no() {
        

        Preferences.sharedInstance.doneParsingPlist = true

        casperSplashMainController = MainViewController()
        let input = [
            Software(packageName: "test1", version: nil, status: .pending, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true),
            Software(packageName: "test2", version: nil, status: .success, iconPath: nil, displayName: nil, description: nil, canContinue: false, displayToUser: true)
        ]
        XCTAssertFalse(SoftwareArray.sharedInstance.canContinue(input))
    }
    
    
}
