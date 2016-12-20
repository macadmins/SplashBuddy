//
//  Preferences.swift
//  CasperSplash
//
//  Created by testpilotfinal on 03/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

//let prefs = Preferences()

/**
 Preferences() keeps the relevant preferences
 */
class Preferences {
    
    static let sharedInstance = Preferences()
    
    let jamfLog = "/var/log/jamf.log"
    
    /// Absolute Path to assets. Relative paths will be appended.
    var assetPath: String?
    
    // Relative Paths
    var postInstallScript: Script?
    var htmlPath: String?
    
    
    //  Asset Values
    var assetTagRequire: Bool?
    
    /// User defaults. Should always use standardUserDefaults() if not testing.
    var userDefaults: UserDefaults?
    
    lazy var logFileHandle: FileHandle? = FileHandle(forReadingAtPath: Preferences.sharedInstance.jamfLog)
    
    
    init(nsUserDefaults: UserDefaults? = UserDefaults.standard) {
        
        self.userDefaults = nsUserDefaults
        
        if let assetPath = getPreferencesAssetPath() {
            self.assetPath = assetPath
        }
        
        if let assetPath = self.assetPath, let postInstallPath = getPreferencesPostInstallPath() {
            self.postInstallScript = Script(absolutePath: assetPath + "/" + postInstallPath)
        }
        
        if let htmlPath = getPreferencesHtmlPath() {
            self.htmlPath = htmlPath
        }
        
        if let assetTagRequire = getAssetTagRequired(){
            self.assetTagRequire = assetTagRequire
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

    func getAssetTagRequired() -> Bool? {
        return self.userDefaults?.bool(forKey: "requireAssetTag")
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
    
    
    /// Generates Software objects from Preferences
    func getPreferencesApplications(_ _softwareArray: inout [Software]) {
        if let applicationsArray = self.userDefaults?.array(forKey: "applicationsArray"){
            for application in applicationsArray {
                if let application = application as? NSDictionary {
                    if let displayName: String = application["displayName"] as? String,
                        let description = application["description"] as? String,
                        let name = application["packageName"] as? String,
                        let assetPath = self.assetPath,
                        let iconPath = application["iconRelativePath"] as? String {
                        
                        
                        // In practice, canContinue is sometimes seen as int, sometimes as String
                        // This workaround helps to be more flexible
                        var canContinueBool: Bool
                        
                        if let canContinue = application["canContinue"] as? Int {
                            
                            if canContinue == 1 {
                                canContinueBool = true
                            } else {
                                canContinueBool = false
                            }
                        } else if let canContinue = application["canContinue"] as? String {
                            
                            if canContinue == "1" {
                                canContinueBool = true
                            } else {
                                canContinueBool = false
                            }
                        } else if let canContinue = application["canContinue"] as? Bool {
                            
                            canContinueBool = canContinue
                        } else {
                            break
                        }
                        
                        
                        let software = Software(name: name, version: nil, status: .pending, iconPath: "\(assetPath)/\(iconPath)", displayName: displayName, description: description, canContinue: canContinueBool, displayToUser: true)
                        //dump(software)
                        
                        // FIXME: Can I work without a global array?
                        _softwareArray.append(software)
                    } else {
                        // FIXME
                       NSLog("applicationsArray: application item is malformed or assetPath is missing")
                    }
                } else {
                    NSLog("applicationsArray: application is malformed")
                }
            }
        } else {
            NSLog("Couldn't find applicationsArray in user defaults")
        }
    }

}




