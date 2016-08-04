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

    var casperSplashController: CasperSplashController?
    
    let jamfLog: String = "/var/log/jamf.log"
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        casperSplashController = CasperSplashController(windowNibName: "CasperSplashController")
        casperSplashController?.showWindow(self)
        

        
        #if DEBUG
            //NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
        #else
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
        #endif
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    func readTimer() -> Void {
        if let lines = readLinesFromFile(jamfLog) {
            for line in lines {
                modifySoftwareFromLine(line, softwareArray: &softwareArray)
            }
        }
        #if DEBUG
            dump(softwareArray)
        #endif
    }


}

