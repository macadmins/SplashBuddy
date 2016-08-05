//
//  Preferences.swift
//  CasperSplash
//
//  Created by testpilotfinal on 03/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

let prefs = Preferences()

/**
 Preferences() keeps the relevant preferences
 */
class Preferences {
    /// Absolute Path to assets. Relative paths will be appended.
    var assetPath: String?
    
    /**  
     Post Install Script
     
     - precondition: `assetPath` and `postInstallAssetPath` need to be set in User Defaults
     */
    var postInstallScript: Script?
    
    /// Relative path to index.html
    var htmlPath: String?
    
    /// User defaults. Should always use standardUserDefaults() if not testing.
    var userDefaults: NSUserDefaults?
    
    var logFileHandle: NSFileHandle?
    /// if nsUserDefaults defaults to NSUserDefaults.standardUserDefaults()
    
    init(nsUserDefaults: NSUserDefaults?=nil) {
        
        //softwareArray = [Software]()
        
        if nsUserDefaults == nil {
            self.userDefaults = NSUserDefaults.standardUserDefaults()
        } else {
            self.userDefaults = nsUserDefaults
        }
        
        if let assetPath = getPreferencesAssetPath() {
            self.assetPath = assetPath
        }
        
        if let assetPath = self.assetPath, postInstallPath = getPreferencesPostInstallPath() {
            self.postInstallScript = Script(absolutePath: assetPath + "/" + postInstallPath)
        }
        
        if let htmlPath = getPreferencesHtmlPath() {
            self.htmlPath = htmlPath
        }
        
        
    }
    
    func getPreferencesAssetPath() -> String? {
        return self.userDefaults?.stringForKey("assetPath")
    }
    
    func getPreferencesPostInstallPath() -> String? {
        return self.userDefaults?.stringForKey("postInstallAssetPath")
    }
    
    func getPreferencesHtmlPath() -> String? {
        return self.userDefaults?.stringForKey("htmlPath")
    }

    /**
     Absolute path to html index
     - returns: Absolute Path if set in preferences, otherwise the placeholder.
     */
    var htmlAbsolutePath: String? {
        get {
            if let assetPath = self.assetPath, htmlPath = self.htmlPath {
                return "\(assetPath)/\(htmlPath)"
            } else {
                return NSBundle.mainBundle().pathForResource("index", ofType: "html")
            }
        }
    }
    
//    Optional([{
//    canContinue = 0;
//    description = SSO;
//    displayName = "Enterprise Connect";
//    iconRelativePath = "ec_32x32.png";
//    packageName = "Enterprise Connect";
//    }])
    
    /// Generates Software objects from Preferences
    func getPreferencesApplications(inout _softwareArray: [Software]) {
        if let applicationsArray = self.userDefaults?.arrayForKey("applicationsArray"){
            for application in applicationsArray {
                if let application = application as? NSDictionary {
                    if let
                        displayName: String = application["displayName"] as? String,
                        description = application["description"] as? String,
                        name = application["packageName"] as? String,
                        assetPath = self.assetPath,
                        iconPath = application["iconRelativePath"] as? String,
                        canContinue = application["canContinue"] as? String{
                        
                        var canContinueBool: Bool
                        if canContinue == "1" {
                            canContinueBool = true
                        } else {
                            canContinueBool = false
                        }
                        
                        
                        let software = Software(name: name, version: nil, status: .Pending, iconPath: "\(assetPath)/\(iconPath)", displayName: displayName, description: description, canContinue: canContinueBool, displayToUser: true)
                        //dump(software)
                        
                        // FIXME: Can I work without a global array?
                        _softwareArray.append(software)
                    } else {
                        // FIXME
                       NSLog("applicationsArray: application item is malformed or assetPath is missing")
                        #if DEBUG
                        dump(application)
                        #endif
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




