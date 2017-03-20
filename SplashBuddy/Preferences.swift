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
    
    internal let jamfLog = "/var/log/jamf.log"
    internal let assetPath = "/Library/Application Support/SplashBuddy"
    
    
    
    //-----------------------------------------------------------------------------------
    /// INIT
    //-----------------------------------------------------------------------------------
    
    init(nsUserDefaults: UserDefaults? = UserDefaults.standard) {
        
        self.userDefaults = nsUserDefaults
        
        do {
            self.logFileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: self.jamfLog, isDirectory: false))
        } catch {
            Log.write(string: "Cannot read /var/log/jamf.log",
                      cat: "Preferences",
                      level: .error)
            self.logFileHandle = nil
        }
        
        

        
        // HTML Path
        
        if let htmlPath = getPreferencesHtmlPath() {
            self.htmlPath = htmlPath
        } else {
            Log.write(string: "Cannot get htmlPath from io.fti.SplashBuddy.plist",
                      cat: "Preferences",
                      level: .info)
        }
        
        
        // Legacy
        
        if getPreferencesAssetPath() != nil {
            Log.write(string: "assetPath is now fixed to /Library/Application Support/SplashBuddy",
                      cat: "Preferences",
                      level: .info)
        }
        
        
    }

    
    
    
    //-----------------------------------------------------------------------------------
    // HTML Path
    //-----------------------------------------------------------------------------------
    
    internal var htmlPath: String?
    
    func getPreferencesHtmlPath() -> String? {
        return self.userDefaults?.string(forKey: "htmlPath")
    }
    
    /**
     Absolute path to html index
     - returns: Absolute Path if set in preferences, otherwise the placeholder.
     */
    public var htmlAbsolutePath: String {
        get {
            
            if let htmlPath = self.htmlPath {
                let htmlAbsolutePath = assetPath + "/" + htmlPath
                if FileManager.default.fileExists(atPath: htmlAbsolutePath) {
                    return htmlAbsolutePath
                }
            }
            
            return Bundle.main.path(forResource: "index", ofType: "html")!
            
        }
    }
    
    
    /// User defaults. Should always use standardUserDefaults() if not testing.
    var userDefaults: UserDefaults?
    
    
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
        
        
        let iconPath = self.assetPath + "/" + iconRelativePath
        
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
        guard let applicationsArray = self.userDefaults?.array(forKey: "applicationsArray") else {
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
        
    }
    

    
    
    //-----------------------------------------------------------------------------------
    // Legacy
    //-----------------------------------------------------------------------------------
    
    func getPreferencesAssetPath() -> String? {
        return self.userDefaults?.string(forKey: "assetPath")
    }
    
    
    
    

}




