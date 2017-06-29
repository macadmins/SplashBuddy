//
//  MainWindow.swift
//  SplashBuddy
//
//  Created by Francois Levaux on 29.06.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa


// Windows without title bars cannot become Key & Main by default. We need to override this behaviour.
// This allows text input in the WKWebView

class MainWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
