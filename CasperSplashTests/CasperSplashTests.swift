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
    
    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    // Packages Installing
    func testRegexInstallingPackage_Name() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installing EnterpriseConnect-1.5.3.pkg..."
        let output = "EnterpriseConnect"
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.name, output)
    }
    
    func testRegexInstallingPackage_Version() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installing EnterpriseConnect-1.5.3.pkg..."
        let output = "1.5.3"
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.version, output)
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
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.name, output)
    }
    
    func testRegexSuccessfullyInstalledPackage_Version() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Successfully installed EnterpriseConnect-1.5.3.pkg."
        let output = "1.5.3"
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.version, output)
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
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.name, output)
    }
    
    func testRegexFailedInstall_Version() {
        let input = "Wed Mar 16 13:31:20 François's Mac mini jamf[2874]: Installation failed. The installer reported: installer: Package name is EnterpriseConnect-1.5.3"
        let output = "1.5.3"
        
        XCTAssertEqual(getSoftwareFromRegex(input)!.version, output)
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

        XCTAssertEqual(readLinesFromFile(path!)!, output)
    }
    
    func testReadFromFile_CanParseSoftwareFromFile() {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("jamf_1", ofType: "txt")
        let output = [
            Software(name: "Success021", version: "0.21", status: .Success),
            Software(name: "Failed153", version: "1.5.3", status: .Failed),
            Software(name: "Installing022", version: "0.22", status: .Installing)
        ]
        let results = fileToSoftware(path!)

        XCTAssertEqual(results, output)
    }
    
    func testReadFromFile_NonExistentFile() {
        let path = "/nonexistent"
        XCTAssertNil(readLinesFromFile(path))
    }
    
    func testAddIcon_CheckIfNSImage() {
        let path = NSBundle(forClass: self.dynamicType).pathForImageResource("ec_32x32")
        //let output = NSImage(byReferencingFile: path!)

        XCTAssert(Software(name: "EC", version: "1.6.2", status: .Installing, iconPath: path).icon!.dynamicType == NSImage().dynamicType)
    }
    
    func testAddIcon_WithIncorrectResource() {
        let path = NSBundle(forClass: self.dynamicType).pathForImageResource("nonexistent")
        //let output = NSImage(byReferencingFile: path!)
        
        XCTAssertNil(Software(name: "EC", version: "1.6.2", status: .Installing, iconPath: path).icon)
    }
}
