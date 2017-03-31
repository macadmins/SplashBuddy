//
//  PreferencesTests.swift
//  SplashBuddy
//
//  Created by Francois Levaux on 03-03-17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

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
        testUserDefaults!.set(assetPath, forKey: "assetPath")
        
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        
    }
    
    override func tearDown() {
        
        super.tearDown()
        
        testPrefs = nil
        testUserDefaults.removeSuite(named: "testing")
        testUserDefaults = nil
        SoftwareArray.sharedInstance.array.removeAll()
        
    }
    
    func testUserDefaults_assetPath() {
        
        let output = Bundle(for: type(of: self)).bundlePath + "/Contents/Resources"
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        XCTAssertEqual(testPrefs.assetPath, output)
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
        
        testPrefs.getPreferencesApplications()
        
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
        
        testPrefs.getPreferencesApplications()
        
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
            ],[
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
        
        testPrefs.getPreferencesApplications()
        
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
        testPrefs.getPreferencesApplications()
        
        XCTAssertTrue(SoftwareArray.sharedInstance.array.isEmpty)
    }
    
    func testUserDefaults_CanParseSoftwareFromFile() {
        let path = Bundle(for: type(of: self)).path(forResource: "jamf_1", ofType: "txt")
        
        let input = [[
            "displayName": "Suceeded",
            "description": "test",
            "packageName": "Success021",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
            ]]
        // Setup user defaults
        
        testUserDefaults!.set(input, forKey: "applicationsArray")
        
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        testPrefs.getPreferencesApplications()
        
        let fileHandle = FileHandle(forReadingAtPath: path!)
        SoftwareArray.sharedInstance.array.modify(from: fileHandle!)
        
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.packageName, "Success021")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.packageVersion, "0.21")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.status, Software.SoftwareStatus.success)
        XCTAssert(type(of: SoftwareArray.sharedInstance.array.first!.icon!) == NSImage.self)
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.displayName, "Suceeded")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.desc, "test")
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.canContinue, true)
        XCTAssertEqual(SoftwareArray.sharedInstance.array.first!.displayToUser, true)
        
        testUserDefaults.removeObject(forKey: "applicationsArray")
        XCTAssertNil(testUserDefaults.object(forKey: "applicationsArray"))
    }
    
    
    func testUserDefaults_HTMLFullPath() {
        
        let input = "index.html"
        testUserDefaults.set(input, forKey: "htmlPath")
        let output = Bundle.main.resourcePath! + "/" + input
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        
        XCTAssertEqual(testPrefs.htmlAbsolutePath, output)
        
        testUserDefaults.removeObject(forKey: "postInstallAssetPath")
        XCTAssertNil(testUserDefaults.object(forKey: "postInstallAssetPath"))
    }
    
    func testUserDefaults_HTMLFullPathEmpty() {
        testPrefs = Preferences(nsUserDefaults: testUserDefaults)
        let output = Bundle.main.resourcePath! + "/index.html"
        
        XCTAssertEqual(testPrefs.htmlAbsolutePath, output)
    }

    
    func test_extractSoftware() {
        
        let input: Dictionary = [
            "displayName": "Enterprise Connect",
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
            ] as [String : Any]
        
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
    
    func test_extractSoftware_no_displayName() {
        
        let input: Dictionary = [
            "description": "SSO",
            "packageName": "Enterprise Connect",
            "iconRelativePath": "ec_32x32.png",
            "canContinue": 1
            ] as [String : Any]
        
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
            ] as [String : Any]
        
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
            ] as [String : Any]
        
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
            ] as [String : Any]
        
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
            ] as [String : Any]
        
        let nsDict = NSDictionary(dictionary: input)
        let result = testPrefs.extractSoftware(from: nsDict)
        
        
        XCTAssertNil(result)
    }
    
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
