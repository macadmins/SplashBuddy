//
//  Preferences.swift
//  CasperSplash
//
//  Created by ftiff on 03/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

//let prefs = Preferences()

/**
 Preferences() keeps the relevant preferences
 */
class Preferences {
    
    
    
    static let sharedInstance = Preferences()
    
    let logFileHandle: FileHandle?
    
    let jamfLog = "/var/log/jamf.log"
    //lazy var logFileHandle: FileHandle? = FileHandle(forReadingAtPath: Preferences.sharedInstance.jamfLog)
    
    
    /// Absolute Path to assets. Relative paths will be appended.
    var assetPath: String?
    
    
    // Relative Paths
    var postInstallScript: Script?
    var htmlPath: String?
    
    
    /// User defaults. Should always use standardUserDefaults() if not testing.
    var userDefaults: UserDefaults?
    
    
    
    
    init(nsUserDefaults: UserDefaults? = UserDefaults.standard) {
        
        self.userDefaults = nsUserDefaults
        
        do {
            self.logFileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: self.jamfLog, isDirectory: false))
        } catch {
            dump(error)
            self.logFileHandle = nil
        }
        
        if let assetPath = getPreferencesAssetPath() {
            self.assetPath = assetPath
        } else {
            Log.write(string: "Cannot get assetPath from io.fti.CasperSplash.plist", cat: "Foundation", level: .error)
        }
        
        
        if let assetPath = self.assetPath, let postInstallPath = getPreferencesPostInstallPath() {
            self.postInstallScript = Script(absolutePath: assetPath + "/" + postInstallPath)
        } else {
            Log.write(string: "Cannot get postInstallAssetPath from io.fti.CasperSplash.plist", cat: "Foundation", level: .error)
        }
        
        
        if let htmlPath = getPreferencesHtmlPath() {
            self.htmlPath = htmlPath
        } else {
            Log.write(string: "Cannot get htmlPath from io.fti.CasperSplash.plist", cat: "Foundation", level: .error)
        }
        
        
    }
    
    func getPreferencesAssetPath() -> String? {
        return self.userDefaults?.string(forKey: "assetPath")
    }
    
    func getPreferencesPostInstallPath() -> String? {
        return self.userDefaults?.string(forKey: "postInstallAssetPath")
    }
    
    func getPreferencesHtmlPath() -> String? {
        return self.userDefaults?.string(forKey: "htmlPath")
    }
    
    
    /**
     Absolute path to html index
     - returns: Absolute Path if set in preferences, otherwise the placeholder.
     */
    var htmlAbsolutePath: String? {
        get {
            if let assetPath = self.assetPath, let htmlPath = self.htmlPath {
                return "\(assetPath)/\(htmlPath)"
            } else {
                return Bundle.main.path(forResource: "index", ofType: "html")
            }
        }
    }
    
    
    func extractSoftware(from dict: NSDictionary) -> Software? {
        
        guard let name = dict["packageName"] as? String else {
            Log.write(string: "Error reading name from an application in io.fti.CasperSplash", cat: "Foundation", level: .error)
            return nil
        }
        
        guard let displayName: String = dict["displayName"] as? String else {
            Log.write(string: "Error reading displayName from application \(name) in io.fti.CasperSplash", cat: "Foundation", level: .error)
            return nil
        }
        
        guard let description: String = dict["description"] as? String else {
            Log.write(string: "Error reading description from application \(name) in io.fti.CasperSplash", cat: "Foundation", level: .error)
            return nil
        }
        
        guard let iconRelativePath: String = dict["iconRelativePath"] as? String else {
            Log.write(string: "Error reading iconRelativePath from application \(name) in io.fti.CasperSplash", cat: "Foundation", level: .error)
            return nil
        }
        
        guard let canContinueBool: Bool = getBool(from: dict["canContinue"]) else {
            Log.write(string: "Error reading canContinueBool from application \(name) in io.fti.CasperSplash", cat: "Foundation", level: .error)
            return nil
        }
        
        guard let assetPath: String = self.assetPath else {
            Log.write(string: "Error reading asset path", cat: "Foundation", level: .error)
            return nil
        }
        
        let iconPath = assetPath + "/" + iconRelativePath
        
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
            Log.write(string: "Couldn't find applicationsArray in io.fti.CasperSplash", cat: "Foundation", level: .error)
            return
        }
        
        for application in applicationsArray {
            guard let application = application as? NSDictionary else {
                Log.write(string: "applicationsArray: application is malformed", cat: "Foundation", level: .error)
                return
            }
            if let software = extractSoftware(from: application) {
                SoftwareArray.sharedInstance.array.append(software)
            }
        }
        
    }
}




