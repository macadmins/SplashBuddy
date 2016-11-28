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
    
    
    
    dynamic var packageName: String
    dynamic var packageVersion: String?
    dynamic var status: SoftwareStatus
    dynamic var icon: NSImage?
    dynamic var displayName: String?
    dynamic var desc: String?
    dynamic var canContinue: Bool
    dynamic var displayToUser: Bool
    
    dynamic var packageInfo: String {
        return "\(self.packageName) (\(self.packageVersion))"
    }
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
    
    convenience init?(from line: String) {
        
        var name: String?
        var version: String?
        var status: SoftwareStatus?
        
        for (regexStatus, regex) in initRegex() {
            
            status = regexStatus
            
            let matches = regex!.matches(in: line, options: [], range: NSMakeRange(0, line.characters.count))
            
            if !matches.isEmpty {
                name = (line as NSString).substring(with: matches[0].rangeAt(1))
                version = (line as NSString).substring(with: matches[0].rangeAt(2))
                break
            }
        }
        
        if let packageName = name, let packageVersion = version, let packageStatus = status {
            self.init(name: packageName, version: packageVersion, status: packageStatus)
        } else {
            return nil
        }
    }

}

func == (lhs: Software, rhs: Software) -> Bool {
    return lhs.packageName == rhs.packageName && lhs.packageVersion == rhs.packageVersion && lhs.status == rhs.status
}

func readLines(from fileHandle: FileHandle) -> [String]? {
    return String(data: fileHandle.readDataToEndOfFile(), encoding: String.Encoding.utf8)?.components(separatedBy: "\n")
    
}



extension Array where Element:Software {
    
    mutating func modify(with software: Software) {
        
        // If Software already exists, replace status and package version
        if let index = self.index(where: {$0.packageName == software.packageName}) {
            self[index].status = software.status
            self[index].packageVersion = software.packageVersion
        } else {
            self.append(software as! Element)
        }
    }
    
    mutating func modify(from line: String) {
        if let software = Software(from: line) {
            // If Software already exists, replace status and package version
            if let index = self.index(where: {$0.packageName == software.packageName}) {
                self[index].status = software.status
                self[index].packageVersion = software.packageVersion
            } else {
                self.append(software as! Element)
            }
        }
    }
    mutating func modify(from file: FileHandle) {
        if let lines = readLines(from: file) {
            for line in lines {
                self.modify(from: line)
            }
        }
    }
}
