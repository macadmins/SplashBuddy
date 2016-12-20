//
//  CasperSplashBackgroundController.swift
//  CasperSplash
//
//  Created by François Levaux on 24.11.16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class CasperSplashBackgroundController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let backgroundWindow = self.window {
            let mainDisplayRect = NSScreen.main()?.frame
            backgroundWindow.contentRect(forFrameRect: mainDisplayRect!)
            backgroundWindow.setFrame((NSScreen.main()?.frame)!, display: true)
            backgroundWindow.setFrameOrigin((NSScreen.main()?.frame.origin)!)
            backgroundWindow.level = Int(CGWindowLevelForKey(.maximumWindow) - 2)
        }
    }

}
