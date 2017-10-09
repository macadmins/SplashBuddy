//
//  AppDelegate.swift
//  SplashBuddy
//
//  Created by ftiff on 02/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    var softwareStatusValueTransformer: SoftwareStatusValueTransformer?
    var mainWindowController: MainWindowController!
    var windows = [NSWindow]()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        
        // Value Transformer for Software Status
        // We use it to map the software status (.pending…) with color images (orange…) in the Software TableView
        
        softwareStatusValueTransformer = SoftwareStatusValueTransformer()
        ValueTransformer.setValueTransformer(softwareStatusValueTransformer,
                                             forName: NSValueTransformerName(rawValue: "SoftwareStatusValueTransformer"))
        
        
        // Disable relaunch on login. This should be controlled by a LaunchAgent.
        NSApp.disableRelaunchOnLogin()
        
        // Create Background Controller (the window behind) only displays for Release
        // Change this in Edit Scheme -> Run -> Info
        
        #if !DEBUG
            
            for screen in NSScreen.screens {
                
                let view = NSVisualEffectView()
                view.blendingMode = .behindWindow
                view.material = .dark
                view.state = .active
                
                let window = NSWindow(contentRect: screen.frame,
                                      styleMask: .fullSizeContentView,
                                      backing: .buffered,
                                      defer: true)
                window.backgroundColor = .white
                window.contentView = view
                window.makeKeyAndOrderFront(self)
                
                windows.append(window)
            }
            
            NSApp.hideOtherApplications(self)
            NSApp.presentationOptions = [ .disableProcessSwitching,
                                         .hideDock,
                                         .hideMenuBar,
                                         .disableForceQuit,
                                         .disableSessionTermination ]
        #endif
        
        
        
        // Get preferences from UserDefaults
        Preferences.sharedInstance.getPreferencesApplications()
        Parser.sharedInstance.readTimer()
        
        
        
    }
    
    @IBAction func quitAndSetSBDone(_ sender: Any) {
        Preferences.sharedInstance.setupDone = true
        NSApp.terminate(self)
    }
    
    
}

