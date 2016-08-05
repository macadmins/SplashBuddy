//
//  AppDelegate.swift
//  CasperSplash
//
//  Created by testpilotfinal on 02/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    var softwareStatusValueTransformer: SoftwareStatusValueTransformer?
    var casperSplashController: CasperSplashController!
    
    let jamfLog: String = "/var/log/jamf.log"
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        softwareStatusValueTransformer = SoftwareStatusValueTransformer()
        NSValueTransformer.setValueTransformer(softwareStatusValueTransformer, forName: "SoftwareStatusValueTransformer")
        
        casperSplashController = CasperSplashController(windowNibName: "CasperSplashController")
        casperSplashController?.showWindow(self)
        
        prefs.logFileHandle = NSFileHandle(forReadingAtPath: jamfLog)

        prefs.getPreferencesApplications(&casperSplashController.softwareArray)
        
        #if DEBUG
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
        #else
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
        #endif
        
        
        //dump(prefs.userDefaults)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    func readTimer() -> Void {
        let readQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
        dispatch_async(readQueue) { 
            if let lines = readLinesFromFile(prefs.logFileHandle) {
                for line in lines {
                    dispatch_async(dispatch_get_main_queue(), { 
                        modifySoftwareFromLine(line, softwareArray: &self.casperSplashController.softwareArray)
                    })
                    
                }
            }
        }
        #if DEBUG
            //dump(prefs.softwareArray)
        #endif
    }


}

