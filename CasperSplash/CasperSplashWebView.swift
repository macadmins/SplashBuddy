//
//  CasperSplashWebView.swift
//  CasperSplash
//
//  Created by ftiff on 04/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa
import WebKit

class CasperSplashWebView: WebView {

    override func viewWillDraw() {
        self.layer?.borderWidth = 1.0
        self.layer?.borderWidth = 1.0
        self.layer?.borderColor = NSColor.lightGray.cgColor
        self.layer?.isOpaque = true
        
        if let indexHtmlPath = Preferences.sharedInstance.htmlAbsolutePath {
            self.mainFrame.load(URLRequest(url: URL(fileURLWithPath: indexHtmlPath)))
        } else {
            NSLog("Cannot get HTML Path!")
        }
    }
}
