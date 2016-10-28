//
//  AppDelegate.swift
//  CasperSplash
//
//  Created by testpilotfinal on 02/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, StreamDelegate {

    
    var softwareStatusValueTransformer: SoftwareStatusValueTransformer?
    var casperSplashController: CasperSplashController!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        
        
        // Value Transformer for Software Status
        softwareStatusValueTransformer = SoftwareStatusValueTransformer()
        ValueTransformer.setValueTransformer(softwareStatusValueTransformer, forName: NSValueTransformerName(rawValue: "SoftwareStatusValueTransformer"))
        
//        
//        let mainDisplayRect = NSScreen.main()?.frame
//        let fullScreenWindow = NSWindow.init(contentRect: mainDisplayRect!, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreType.buffered, defer: true)
//        fullScreenWindow.backgroundColor = NSColor.blue
//        
//        fullScreenWindow.isOpaque = false
//        
////        let myRect = NSMakeRect(0.0, 0.0, (mainDisplayRect?.size.width)!, (mainDisplayRect?.size.height)!)
////        let fullScreenView = NSVisualEffectView.init(frame: myRect)
////        fullScreenWindow.contentView = fullScreenView
//        
//        //fullScreenWindow.level = Int(CGWindowLevelForKey(.normalWindow))
//        fullScreenWindow.makeKeyAndOrderFront(self)
        
        // Create controller and Initialize Preferences
        casperSplashController = CasperSplashController(windowNibName: "CasperSplashController")
        
        Preferences.sharedInstance.logFileHandle = FileHandle(forReadingAtPath: Preferences.sharedInstance.jamfLog)
        Preferences.sharedInstance.getPreferencesApplications(&self.casperSplashController.softwareArray)

        casperSplashController?.showWindow(self)
        
        
        
        // We use a timer to parse jamf.log
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)


    }

    func readTimer() -> Void {
        //let readQueue = DispatchQueue(label: "io.fti.CasperSplash.readQueue", attributes: .qosBackground, target: nil)
        DispatchQueue.global(qos: .background).async {
            for line in readLinesFromFile(Preferences.sharedInstance.logFileHandle)! {
                if let software = getSoftwareFromRegex(line) {
                    DispatchQueue.main.async {
                        modifySoftwareArray(fromSoftware: software, softwareArray: &self.casperSplashController.softwareArray)
                        
                        self.casperSplashController.checkSoftwareStatus()
                    }
                }
            }
        }
    }
}

