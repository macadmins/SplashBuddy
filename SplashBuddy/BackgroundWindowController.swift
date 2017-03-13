//
//  BackgroundWindowController.swift
//  SplashBuddy
//
//  Created by ftiff on 24.11.16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class BackgroundWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let backgroundWindow = self.window else {
            Log.write(string: "Cannot get background window", cat: "UI", level: .error)
            return
        }
        
        guard let mainDisplayRect = NSScreen.main()?.frame else {
            Log.write(string: "Cannot get main screen dimensions", cat: "UI", level: .error)
            return
        }
        
        backgroundWindow.contentRect(forFrameRect: mainDisplayRect)
        backgroundWindow.setFrame(mainDisplayRect, display: true)
        backgroundWindow.setFrameOrigin(mainDisplayRect.origin)
        backgroundWindow.level = Int(CGWindowLevelForKey(.maximumWindow) - 1 )
        
    }
    
}
