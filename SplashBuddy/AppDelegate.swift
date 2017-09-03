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
        
        // For continue button Restart, Shutdown and Logout.
        NSApp.disableRelaunchOnLogin()
        
        // Value Transformer for Software Status
        // We use it to map the software status (.pending…) with color images (orange…) in the Software TableView
        
        softwareStatusValueTransformer = SoftwareStatusValueTransformer()
        ValueTransformer.setValueTransformer(softwareStatusValueTransformer,
                                             forName: NSValueTransformerName(rawValue: "SoftwareStatusValueTransformer"))
        
        // Create Background Controller (the window behind)
        // Hide it with `SplashBuddy.app/Contents/MacOS/SplashBuddy -hideBackground true`
        
        if Preferences.sharedInstance.background {
            
            Log.write(string: "START: Background Window",
                      cat: .UI,
                      level: .debug)
            
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
            
            Log.write(string: "DONE: Background Window",
                      cat: .UI,
                      level: .debug)
            
            Log.write(string: "Hide other applications",
                      cat: .UI,
                      level: .debug)
            NSApp.hideOtherApplications(self)
            
            Log.write(string: "Disable process switching, dock, menubar, forcequit and session termination",
                      cat: .UI,
                      level: .debug)

            NSApp.presentationOptions = [ .disableProcessSwitching,
                                         .hideDock,
                                         .hideMenuBar,
                                         .disableForceQuit,
                                         .disableSessionTermination ]
        }
        
        
        
        // Get preferences from UserDefaults
        do {
            try Preferences.sharedInstance.getPreferencesApplications()
        } catch Preferences.Errors.MalformedApplication {
            Log.write(string: "applicationsArray: application is malformed",
                    cat: .Preferences,
                    level: .error)
        } catch Preferences.Errors.NoApplicationArray {
            Log.write(string: "Couldn't find applicationsArray in io.fti.SplashBuddy",
                      cat: .Preferences,
                      level: .error)
        } catch {
            Log.write(string: "Unknown error while reading Applications",
                      cat: .Preferences,
                      level: .error)
        }
        Parser.sharedInstance.readTimer()
        
        
        
    }
    
    @IBAction func quitAndSetSBDone(_ sender: Any) {
        Log.write(string: "Quitting SplashBuddy and setting .SplashBuddyDone",
                  cat: .UI,
                  level: .debug)

        Preferences.sharedInstance.setupDone = true
        NSApp.terminate(self)
    }
    
    
}

