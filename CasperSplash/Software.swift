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
        case installing = 0
        
        // test Success
        case success = 1
        case failed = 2
        case pending = 3
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
         status: SoftwareStatus = .pending,
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
            self.icon = NSImage(named: NSImageNameFolder) //NSImage (literal: NSImageNameFolder)
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

func modifySoftwareArrayFromFile(_ fileHandle: FileHandle?, softwareArray: inout [Software]) -> Void {
    if let lines = readLinesFromFile(fileHandle) {
        for line in lines {
            modifySoftwareFromLine(line, softwareArray: &softwareArray)
        }
    }
}

func fileToSoftware(_ fileHandle: FileHandle?) -> [Software] {
    var result = [Software]()
    
    // Create an array of lines
    if let lines = readLinesFromFile(fileHandle) {
        for line in lines {
            modifySoftwareFromLine(line, softwareArray: &result)
        }
    }
    return result
}

func readLinesFromFile(_ fileHandle: FileHandle?) -> [String]? {
    if let log = fileHandle {
        return String(data: log.readDataToEndOfFile(), encoding: String.Encoding.utf8)?.components(separatedBy: "\n")
    } else {
        NSLog("Error reading file.")
        return nil
    }
    
}

func modifySoftwareFromLine(_ line: String, softwareArray: inout [Software]) {
    
    if let software = getSoftwareFromRegex(line) {
        // If Software already exists, replace status and package version
        if let index = softwareArray.index(where: {$0.packageName == software.packageName}) {
            softwareArray[index].status = software.status
            softwareArray[index].packageVersion = software.packageVersion
        } else {
            softwareArray.append(software)
        }
    }
    
    
}
func modifySoftwareArray(fromSoftware software: Software, softwareArray: inout [Software]) {
    
    // If Software already exists, replace status and package version
    if let index = softwareArray.index(where: {$0.packageName == software.packageName}) {
        softwareArray[index].status = software.status
        softwareArray[index].packageVersion = software.packageVersion
    } else {
        softwareArray.append(software)
    }
    
    
}


func getSoftwareFromRegex(_ line: String) -> Software? {
    for (status, regex) in initRegex() {
        
        let matches = regex!.matches(in: line, options: [], range: NSMakeRange(0, line.characters.count))
        
        if !matches.isEmpty {
            let name = (line as NSString).substring(with: matches[0].range(at: 1))
            let version = (line as NSString).substring(with: matches[0].range(at: 2))
            return Software(name: name, version: version, status: status)
        }
    }
    return nil
}
