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
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Display Front Window
        
        #if !DEBUG
        self.window?.level = Int(CGWindowLevelForKey(.maximumWindow))
        #endif
        
        self.window?.isOpaque = false
        self.window?.backgroundColor = NSColor.clear
    }
    

    
}
