//
//  CasperSplashBackgroundController.swift
//  CasperSplash
//
//  Created by ftiff on 24.11.16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class CasperSplashBackgroundController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let backgroundWindow = self.window else {
            NSLog("Cannot get background window")
            return
        }
        
        guard let mainDisplayRect = NSScreen.main()?.frame else {
            NSLog("Cannot get main screen dimensions")
            return
        }
        
        backgroundWindow.contentRect(forFrameRect: mainDisplayRect)
        backgroundWindow.setFrame(mainDisplayRect, display: true)
        backgroundWindow.setFrameOrigin(mainDisplayRect.origin)
        backgroundWindow.level = Int(CGWindowLevelForKey(.maximumWindow) - 1 )
        
    }
    
}
