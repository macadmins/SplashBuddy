//
//  Preferences.swift
//  SplashBuddy
//
//  Created by ftiff on 03/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

/**
 Preferences() keeps the relevant preferences
 */
class Preferences {
    
    
    
    static let sharedInstance = Preferences()
    public let logFileHandle: FileHandle?
    public var doneParsingPlist: Bool = false
    
    internal let userDefaults: UserDefaults
    internal let jamfLog = "/var/log/jamf.log"
    

    
    
    
    //-----------------------------------------------------------------------------------
    /// INIT
    //-----------------------------------------------------------------------------------
    
    init(nsUserDefaults: UserDefaults = UserDefaults.standard) {
        
        self.userDefaults = nsUserDefaults
        
        do {
            self.logFileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: self.jamfLog, isDirectory: false))
        } catch {
            Log.write(string: "Cannot read /var/log/jamf.log",
                      cat: "Preferences",
                      level: .error)
            self.logFileHandle = nil
        }
        
        // Do not change asset path (see comment on var assetPath: URL below)
        // TSTAssetPath is meant for unit testing only.
        if let assetPath = self.userDefaults.string(forKey: "TSTAssetPath") {
            self.assetPath = URL(fileURLWithPath: assetPath, isDirectory: true)
        } else {
            self.assetPath = URL(fileURLWithPath: "/Library/Application Support/SplashBuddy", isDirectory: true)
        }
        
        
        
        
    }
    
    
    //-----------------------------------------------------------------------------------
    // Asset Path
    //-----------------------------------------------------------------------------------
    
    // If you decide to change the asset path, make sure you update the entitlements,
    // or the WKWebView will display white.
    
    var assetPath: URL
    
    
    //-----------------------------------------------------------------------------------
    // Options
    //-----------------------------------------------------------------------------------
    
    public var sidebar: Bool {
        get {
            return self.userDefaults.bool(forKey: "hideSidebar")
        }
    }
    
    //-----------------------------------------------------------------------------------
    // HTML Path
    //-----------------------------------------------------------------------------------
    
    public var assetBundle: Bundle? {
        get {
            return Bundle.init(url: self.assetPath.appendingPathComponent("presentation.bundle"))
        }
    }
    
    public var html: URL? {
        get {
            return self.assetBundle?.url(forResource: "index", withExtension: "html")
        }
    }
    
    public var form: URL? {
        get {
            return self.assetBundle?.url(forResource: "form", withExtension: "html")
        }
    }
    
    
    var setupDone: Bool {
        get {
            return FileManager.default.fileExists(atPath: "Library/.SplashBuddyDone")
        }
        
        set(myValue) {
            if myValue == true {
                FileManager.default.createFile(atPath: "Library/.SplashBuddyDone", contents: nil, attributes: nil)
            } else {
                do {
                    try FileManager.default.removeItem(atPath: "Library/.SplashBuddyDone")
                } catch {
                    Log.write(string: "Couldn't remove .SplashBuddyDone",
                              cat: "Preferences",
                              level: .info)
                }
                
            }
        }
    }
    
    
    
    //-----------------------------------------------------------------------------------
    // Software
    //-----------------------------------------------------------------------------------
    
    func extractSoftware(from dict: NSDictionary) -> Software? {
        
        guard let name = dict["packageName"] as? String else {
            Log.write(string: "Error reading name from an application in io.fti.SplashBuddy",
                      cat: "Preferences",
                      level: .error)
            return nil
        }
        
        guard let displayName: String = dict["displayName"] as? String else {
            Log.write(string: "Error reading displayName from application \(name) in io.fti.SplashBuddy",
                      cat: "Preferences",
                      level: .error)
            return nil
        }
        
        guard let description: String = dict["description"] as? String else {
            Log.write(string: "Error reading description from application \(name) in io.fti.SplashBuddy",
                      cat: "Preferences",
                      level: .error)
            return nil
        }
        
        guard let iconRelativePath: String = dict["iconRelativePath"] as? String else {
            Log.write(string: "Error reading iconRelativePath from application \(name) in io.fti.SplashBuddy",
                      cat: "Preferences",
                      level: .error)
            return nil
        }
        
        guard let canContinueBool: Bool = getBool(from: dict["canContinue"]) else {
            Log.write(string: "Error reading canContinueBool from application \(name) in io.fti.SplashBuddy",
                      cat: "Preferences",
                      level: .error)
            return nil
        }
        
        
        let iconPath = self.assetPath.appendingPathComponent(iconRelativePath).path
        
        return Software(packageName: name,
                        version: nil,
                        status: .pending,
                        iconPath: iconPath,
                        displayName: displayName,
                        description: description,
                        canContinue: canContinueBool,
                        displayToUser: true)
        
    }
    

    /**
     Try to get a Bool from an Any (String, Int or Bool)
     
     - returns: 
        - True if 1, "1" or True
        - False if any other value
        - nil if cannot cast to String, Int or Bool.
     
     - parameter object: Any? (String, Int or Bool)
     */
    func getBool(from object: Any?) -> Bool? {
        
        // In practice, canContinue is sometimes seen as int, sometimes as String
        // This workaround helps to be more flexible
        
        
        if let canContinue = object as? Int {
            
            return (canContinue == 1)
            
        } else if let canContinue = object as? String {
            
            return (canContinue == "1")
            
        } else if let canContinue = object as? Bool {
            
            return canContinue
            
        } else {
            return nil
        }
    }
    
    /// Generates Software objects from Preferences
    func getPreferencesApplications() {
        guard let applicationsArray = self.userDefaults.array(forKey: "applicationsArray") else {
            Log.write(string: "Couldn't find applicationsArray in io.fti.SplashBuddy",
                      cat: "Preferences",
                      level: .error)
            return
        }
        
        for application in applicationsArray {
            guard let application = application as? NSDictionary else {
                Log.write(string: "applicationsArray: application is malformed",
                          cat: "Preferences",
                          level: .error)
                return
            }
            if let software = extractSoftware(from: application) {
                SoftwareArray.sharedInstance.array.append(software)
            }
        }
        
        self.doneParsingPlist = true
        
    }
    
    
    
    
    

}




