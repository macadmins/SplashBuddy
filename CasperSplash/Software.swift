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
        case Installing, Success, Failed, Pending
    }

    
    let packageName: String
    var packageVersion: String?
    var status: SoftwareStatus
    var icon: NSImage?
    var displayName: String?
    var description: String?
    var canContinue: Bool
    var displayToUser: Bool
    
    init(name: String,
         version: String? = nil,
         status: SoftwareStatus = .Pending,
         iconPath: String? = nil,
         displayName: String? = nil,
         description: String? = nil,
         canContinue: Bool = true,
         displayToUser: Bool = false) {
        
        self.packageName = name
        self.packageVersion = version
        self.status = status
        self.canContinue = canContinue
        self.displayToUser = displayToUser
        
        if iconPath != nil {
            setIcon(iconPath!)
        }
        
        if displayName != nil {
            self.displayName = displayName
        }
        
        if description != nil {
            self.description = description
        }

    }
    
    func setIcon(iconPath: String) {
        let image = NSImage(contentsOfFile: iconPath)
        self.icon = image
    }
    
    func isEqual(rhs: Software) -> Bool {
        return self == rhs
    }
    
    
}

func == (lhs: Software, rhs: Software) -> Bool {
    return lhs.packageName == rhs.packageName && lhs.packageVersion == rhs.packageVersion && lhs.status == rhs.status
}

func modifyGlobalSoftwareFromFile(path: String) -> Void {
    if let lines = readLinesFromFile(path) {
        for line in lines {
            modifySoftwareFromLine(line, softwareArray: &softwareArray)
        }
    }
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
        
        // If Software already exists, replace status and package version
        if let index = softwareArray.indexOf({$0.packageName == software.packageName}) {
            softwareArray[index].status = software.status
            softwareArray[index].packageVersion = software.packageVersion
        } else {
            softwareArray.append(software)
        }
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