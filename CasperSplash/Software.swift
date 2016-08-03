//
//  Software.swift
//  CasperSplash
//
//  Created by testpilotfinal on 02/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

var softwareArray = [Software]()

class Software: Equatable {

    enum SoftwareStatus: String {
        case Installing, Success, Failed
    }

    
    let name: String
    let version: String
    var status: SoftwareStatus
    var icon: NSImage?
    var displayName: String?
    var description: String?
    var canContinue: Bool
    
    init(name: String, version: String, status: SoftwareStatus, iconPath: String?=nil, canContinue: Bool=true) {
        self.name = name
        self.version = version
        self.status = status
        self.canContinue = canContinue
        
        if iconPath != nil {
            self.icon = NSImage.init(contentsOfFile: iconPath!)
        }
    }
    
    
    func isEqual(rhs: Software) -> Bool {
        return self == rhs
    }
    
    
}

func == (lhs: Software, rhs: Software) -> Bool {
    return lhs.name == rhs.name && lhs.version == rhs.version && lhs.status == rhs.status
}

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
    if let log = NSFileHandle(forReadingAtPath: path) {
        return String(data: log.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)?.componentsSeparatedByString("\n")
    } else {
        NSLog("Non-existent path: \(path)")
        return nil
    }
    
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