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

    @IBOutlet weak var window: NSWindow!

    
    func getSoftwareFromRegex(line: String) -> Software? {
        for (status, regex) in initRegex() {
            let matches = regex!.matchesInString(line, options: [], range: NSMakeRange(0, line.characters.count))
            if !matches.isEmpty {
                let name = (line as NSString).substringWithRange(matches[0].rangeAtIndex(1))
                let version = (line as NSString).substringWithRange(matches[0].rangeAtIndex(2))
                debugPrint(name, version)
                
                return Software(name: name, version: version, status: status)
                
            }
        }
        return nil
    }
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

