//
//  MainWindowController.swift
//  CasperSplash
//
//  Created by ftiff on 04/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa
import WebKit



class MainWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Display Front Window
        
        guard let window = self.window else {
            NSLog("Cannot get main window")
            return
        }
        
        #if !DEBUG
        window.level = Int(CGWindowLevelForKey(.maximumWindow))
        #endif
        
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
    }
    

    
}
