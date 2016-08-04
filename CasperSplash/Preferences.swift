//
//  Preferences.swift
//  CasperSplash
//
//  Created by testpilotfinal on 03/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

let prefs = Preferences(nsUserDefaults: NSUserDefaults.standardUserDefaults())


class Preferences {
    var assetPath: String?
    var postInstallPath: String?
    var htmlPath: String?
    var userDefaults: NSUserDefaults?
    
    init(nsUserDefaults: NSUserDefaults) {
        self.userDefaults = nsUserDefaults
        
        if let assetPath = getPreferencesAssetPath() {
            self.assetPath = assetPath
        }
        
        if let postInstallPath = getPreferencesPostInstallPath() {
            self.postInstallPath = postInstallPath
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
    
    var postInstallAbsolutePath: String {
        get {
            if let assetPath = self.assetPath, postInstallPath = self.postInstallPath {
                return "\(assetPath)/\(postInstallPath)"
            } else {
                return ""
            }
        }
    }
    
    var htmlAbsolutePath: String? {
        get {
            if let assetPath = self.assetPath, htmlPath = self.htmlPath {
                return "\(assetPath)/\(htmlPath)"
            } else {
                return NSBundle.mainBundle().pathForResource("index", ofType: "html")
            }
        }
    }
    
    
    
    func getPreferencesApplications() {
        if let applicationsArray = self.userDefaults?.arrayForKey("applicationsArray"){
            for application in applicationsArray {
                if let application = application as? NSDictionary {
                    if let
                        displayName: String = application["displayName"] as? String,
                        description = application["description"] as? String,
                        name = application["packageName"] as? String,
                        assetPath = self.assetPath,
                        iconPath = application["iconRelativePath"] as? String,
                        canContinue = application["canContinue"] as? Bool{
                        
                        softwareArray.append(Software(name: name, version: nil, status: .Pending, iconPath: "\(assetPath)/\(iconPath)", displayName: displayName, description: description, canContinue: canContinue, displayToUser: true))
                    }
                }
            }
        }
    }

}




