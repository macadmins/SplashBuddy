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
    
    func fileToSoftware(path: String) -> [Software] {
        var result = [Software]()
        
        // Create an array of lines
        if let lines = readLinesFromFile(path) {
            for line in lines {
                modifySoftwareFromLine(line, softwareArray: &result)
            }
        }
        return result
    }
    
    func readLinesFromFile(path: String) -> [String]? {
            let log = NSFileHandle(forReadingAtPath: path)
            return String(data: log!.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)?.componentsSeparatedByString("\n")
    }
    
    func modifySoftwareFromLine(line: String, inout softwareArray: [Software]) {
        if let software = getSoftwareFromRegex(line) {
            
            // If Software already exists, replace it
            if let index = softwareArray.indexOf({$0.name == software.name}) {
                softwareArray.removeAtIndex(index)
            }
            softwareArray.append(software)
        }
    }
    
    func getSoftwareFromRegex(line: String) -> Software? {
        for (status, regex) in initRegex() {
            
            let matches = regex!.matchesInString(line, options: [], range: NSMakeRange(0, line.characters.count))
            
            if !matches.isEmpty {
                let name = (line as NSString).substringWithRange(matches[0].rangeAtIndex(1))
                let version = (line as NSString).substringWithRange(matches[0].rangeAtIndex(2))
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

