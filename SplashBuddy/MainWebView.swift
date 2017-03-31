//
//  CasperSplashWebView.swift
//  SplashBuddy
//
//  Created by ftiff on 04/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa
import WebKit

class MainWebView: WebView {

    override func viewWillDraw() {
        self.layer?.borderWidth = 1.0
        self.layer?.borderWidth = 1.0
        self.layer?.borderColor = NSColor.lightGray.cgColor
        self.layer?.isOpaque = true
        
        //  Sets preferences to match IB
        //  NOTE: Possible issue with the IBOutlet connection
        if Preferences.sharedInstance.javascript ?? false {
            self.preferences.isJavaScriptEnabled = true
        } else {
            self.preferences.isJavaScriptEnabled = false
        }
        if Preferences.sharedInstance.java ?? false {
            self.preferences.isJavaEnabled = true
        } else {
            self.preferences.isJavaEnabled = false
        }
        self.preferences.javaScriptCanOpenWindowsAutomatically = false
        self.preferences.loadsImagesAutomatically = true
        self.preferences.allowsAnimatedImages = false
        self.preferences.allowsAnimatedImageLooping = false
        
        
        // An attempt at returning a localized version, if exists.
        // presentation.html -> presentation_fr.html
        
        
        let full_url = URL(fileURLWithPath: Preferences.sharedInstance.htmlAbsolutePath)
        let extension_path = full_url.pathExtension
        let base_path = full_url.deletingPathExtension().path
        let languageCode = NSLocale.current.languageCode ?? "en"
        
        let localized_path = "\(base_path)_\(languageCode).\(extension_path)"
        
        if FileManager().fileExists(atPath: localized_path) {
            self.mainFrame.load(URLRequest(url: URL(fileURLWithPath: localized_path)))
        } else {
            self.mainFrame.load(URLRequest(url: URL(fileURLWithPath: Preferences.sharedInstance.htmlAbsolutePath)))
        }
    }
}
