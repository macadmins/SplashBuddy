//
//  Software.swift
//  CasperSplash
//
//  Created by testpilotfinal on 02/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

/**
 My new class
 
*/
class Software: NSObject {


    /**
     Status of the software.
     Default is .Pending, other cases will be set while parsing the log
    */
    @objc enum SoftwareStatus: Int {
        // test Installing
        case Installing = 0
        
        // test Success
        case Success = 1
        case Failed = 2
        case Pending = 3
    }
    

    dynamic let packageName: String
    dynamic var packageVersion: String?
    dynamic var status: SoftwareStatus
    dynamic var icon: NSImage?
    dynamic var displayName: String?
    dynamic var desc: String?
    dynamic var canContinue: Bool
    dynamic var displayToUser: Bool
    
    /// MARK: Initializers
    
    /**
     Initializes a Software Object
     
     - note: Only packageName is required to parse, displayName, description and displayToUser will have to be set later to properly show it on the GUI.
     
     - todo: rename "name" to "packageName"
     
     - parameters:
        - packageName: name of the package (packageName-packageVersion.pkg)
     */

    
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
        
        if let iconPath = iconPath {
            self.icon = NSImage(contentsOfFile: iconPath)
        } else {
            self.icon = NSImage(imageLiteral: NSImageNameFolder)
        }
        
        if let displayName = displayName {
            self.displayName = displayName
        }
        
        if let description = description {
            self.desc = description
        }

    }
    
//    /// Compare two Software objects
//    func isEqual(rhs: Software) -> Bool {
//        return self == rhs
//    }
    
    
}

func == (lhs: Software, rhs: Software) -> Bool {
    return lhs.packageName == rhs.packageName && lhs.packageVersion == rhs.packageVersion && lhs.status == rhs.status
}

func modifySoftwareArrayFromFile(fileHandle: NSFileHandle?, inout softwareArray: [Software]) -> Void {
    if let lines = readLinesFromFile(fileHandle) {
        for line in lines {
            modifySoftwareFromLine(line, softwareArray: &softwareArray)
        }
    }
}

func fileToSoftware(fileHandle: NSFileHandle?) -> [Software] {
    var result = [Software]()
    
    // Create an array of lines
    if let lines = readLinesFromFile(fileHandle) {
        for line in lines {
            modifySoftwareFromLine(line, softwareArray: &result)
        }
    }
    return result
}

func readLinesFromFile(fileHandle: NSFileHandle?) -> [String]? {
    if let log = fileHandle {
        return String(data: log.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)?.componentsSeparatedByString("\n")
    } else {
        NSLog("Error reading file.")
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