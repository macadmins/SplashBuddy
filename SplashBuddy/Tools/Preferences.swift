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
    internal var logFileHandle: FileHandle?
    public var doneParsingPlist: Bool = false
    
    internal let userDefaults: UserDefaults
    

    
    
    
    //-----------------------------------------------------------------------------------
    // MARK: - INIT
    //-----------------------------------------------------------------------------------
    
    init(nsUserDefaults: UserDefaults = UserDefaults.standard) {
        
        self.userDefaults = nsUserDefaults
        
        
        // Do not change asset path (see comment on var assetPath: URL below)
        // TSTAssetPath is meant for unit testing only.
        if let assetPath = self.userDefaults.string(forKey: "TSTAssetPath") {
            self.assetPath = URL(fileURLWithPath: assetPath, isDirectory: true)
        } else {
            self.assetPath = URL(fileURLWithPath: "/Library/Application Support/SplashBuddy", isDirectory: true)
        }
        
        // TSTJamfLog is meant for unit testing only.
        if let jamfLogPath: String = self.userDefaults.string(forKey: "TSTJamfLog") {
            self.logFileHandle = self.getFileHandle(from: jamfLogPath)
        } else {
            self.logFileHandle = self.getFileHandle()
        }
        
        
        
        // Start parsing the log file
        
        guard let logFileHandle = self.logFileHandle else {
            Log.write(string: "Cannot check logFileHandle", cat: "Preferences", level: .error)
            return
        }
        
        logFileHandle.readabilityHandler = { fileHandle in
            
            let data = fileHandle.readDataToEndOfFile()
            
            guard let string = String(data: data, encoding: .utf8) else {
                return
            }
            
            for line in string.split(separator: "\n") {
                
                if let software = Software(from: String(line)) {
                    
                    DispatchQueue.main.async {
                        SoftwareArray.sharedInstance.array.modify(with: software)
                        
                    }
                }
            }
        }
    }
    
    internal func getFileHandle(from file: String = "/var/log/jamf.log") -> FileHandle? {
        do {
            return try FileHandle(forReadingFrom: URL(fileURLWithPath: file, isDirectory: false))
        } catch {
            Log.write(string: "Cannot read \(file)",
                      cat: "Preferences",
                      level: .error)
            return nil
        }
    }
    
    //-----------------------------------------------------------------------------------
    // MARK: - Asset Path
    //-----------------------------------------------------------------------------------
    
    /**
     * Returns the path to all the assets used by SplashBuddy
     *
     * - important: If you decide to change the asset path, make sure you update the entitlements,
     * or the WKWebView will display white.
     */
    
    var assetPath: URL
    
    
    //-----------------------------------------------------------------------------------
    // MARK: - Continue Button
    //-----------------------------------------------------------------------------------
    
    /**
     * Action when the user clicks on the continue button
     *
     * It can either be:
     * - Restart
     * - Logout
     * - Shutdown
     * - Quit
     * - Hidden
     * - a path to an application (eg. `/Applications/Safari.app`)
     */
    public var continueAction: ContinueButton.Action {
        get {
            let action: String = self.userDefaults.string(forKey: "continueAction") ?? "quit"
            return ContinueButton.Action.from(string: action)
            
        }
    }
    
    
    
    //-----------------------------------------------------------------------------------
    // MARK: - Options
    //-----------------------------------------------------------------------------------
    
    
    /// set to `true` to hide sidebar
    public var sidebar: Bool {
        get {
            return self.userDefaults.bool(forKey: "hideSidebar")
        }
    }
    
    /// set to `true` to hide background behind main window (for debugging)
    public var background: Bool {
        get {
            return !self.userDefaults.bool(forKey: "hideBackground")
        }
    }
    
    /// set to `true` to enable Big Notification
    public var labMode: Bool {
        get {
            return self.userDefaults.bool(forKey: "labMode")
        }
    }
    
    //-----------------------------------------------------------------------------------
    // MARK: - HTML Path
    //-----------------------------------------------------------------------------------
    
    /**
     * Returns the path to the HTML bundle
     *
     * - important: If you decide to change the asset path, make sure you update the entitlements,
     * or the WKWebView will display white.
     */
    public var assetBundle: Bundle? {
        get {
            return Bundle.init(url: self.assetPath.appendingPathComponent("presentation.bundle"))
        }
    }
    
    /// Returns `index.html` with the right localization
    public var html: URL? {
        get {
            return self.assetBundle?.url(forResource: "index", withExtension: "html")
        }
    }
    
    /// Returns `complete.html` with the right localization
    public var labComplete: URL? {
        get {
            return self.assetBundle?.url(forResource: "complete", withExtension: "html")
        }
    }
 
    
    //-----------------------------------------------------------------------------------
    // MARK: - Tag files
    //-----------------------------------------------------------------------------------
    
    
    /// All critical software are installed
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
    // MARK: - Software
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
            
        }
        
        return nil
    
    }
    
    enum Errors: Error {
        case NoApplicationArray
        case MalformedApplication
    }
    
    /// Generates Software objects from Preferences
    func getPreferencesApplications() throws {
        guard let applicationsArray = self.userDefaults.array(forKey: "applicationsArray") else {
            throw Preferences.Errors.NoApplicationArray
        }
        
        for application in applicationsArray {
            guard let application = application as? NSDictionary else {
                throw Preferences.Errors.MalformedApplication
            }
            if let software = extractSoftware(from: application) {
                SoftwareArray.sharedInstance.array.append(software)
            }
        }
        
        self.doneParsingPlist = true
        
    }
    
    
    
    
    

}




