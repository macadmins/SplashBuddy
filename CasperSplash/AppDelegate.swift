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
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        softwareStatusValueTransformer = SoftwareStatusValueTransformer()
        ValueTransformer.setValueTransformer(softwareStatusValueTransformer, forName: "SoftwareStatusValueTransformer" as ValueTransformerName)
        
        casperSplashController = CasperSplashController(windowNibName: "CasperSplashController")
        casperSplashController?.showWindow(self)
        
        Preferences.sharedInstance.logFileHandle = FileHandle(forReadingAtPath: jamfLog)

        Preferences.sharedInstance.getPreferencesApplications(&casperSplashController.softwareArray)
        
        #if DEBUG
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
        #else
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
        #endif
        

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    func readTimer() -> Void {
        NSLog("readTimercalled")
        let readQueue = DispatchQueue(label: "io.fti.CasperSplash.readQueue", attributes: .qosBackground, target: nil)
        
        if let lines = readLinesFromFile(Preferences.sharedInstance.logFileHandle) {
            readQueue.async {
                for line in lines {
                    
                    // Testing in background if lines should be changed before calling modifySoftwareFromLine
                    // greatly improves user experience
                    if let software = getSoftwareFromRegex(line) {
                        DispatchQueue.main.sync(execute: {
                            modifySoftwareArray(fromSoftware: software, softwareArray: &self.casperSplashController.softwareArray)
                            self.casperSplashController.checkContinue()
                            
                            
                        })
                    }
                }
            }
        }
    }
}

