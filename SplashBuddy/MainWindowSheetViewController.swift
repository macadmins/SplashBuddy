//
//  File.swift
//  SplashBuddy
//
//  Created by Francois Levaux on 15.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class MainWindowSheetViewController: NSViewController {
    
    @IBAction func btn_quitApp(_ sender: Any) {
        Preferences.sharedInstance.setupDone = true
        self.dismiss(nil)
        NSApplication.shared().terminate(self)
    }
}
