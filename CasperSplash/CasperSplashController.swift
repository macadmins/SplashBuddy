//
//  CasperSplashController.swift
//  CasperSplash
//
//  Created by testpilotfinal on 04/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa
import WebKit

class CasperSplashController: NSWindowController {

    @IBOutlet var webView: CasperSplashWebView!
    @IBOutlet weak var indeterminateProgressIndicator: NSProgressIndicator!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        dump(prefs)
        if let indexHtmlPath = prefs.htmlAbsolutePath {
            webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: indexHtmlPath)))
        }
        
        self.webView.layer?.borderWidth = 1.0
        self.webView.layer?.borderColor = NSColor.lightGrayColor().CGColor

        
        
        indeterminateProgressIndicator.startAnimation(self)
    }
    
   
}
