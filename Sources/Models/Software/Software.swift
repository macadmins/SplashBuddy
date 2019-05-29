//
//  Copyright © 2018-present Amaris Technologies GmbH. All rights reserved.
//

import Cocoa

/**
 Object that will hold the definition of a software.
 
 The goal here is to:
 1. Create a Software object from the plist (MacAdmin supplied Software)
 2. Parse the log and either:
    - Modify the Software object (if it already exists)
    - Create a new Software object.
 
 */

class Software: NSObject {

    /**
     Status of the software.
     Default is .pending, other cases will be set while parsing the log
     */
    @objc enum SoftwareStatus: Int {
        case installing = 0
        case success = 1
        case failed = 2
        case pending = 3
    }

    @objc dynamic var packageName: String
    @objc dynamic var packageVersion: String?
    @objc dynamic var status: SoftwareStatus
    @objc dynamic var icon: NSImage?
    @objc dynamic var displayName: String?
    @objc dynamic var desc: String?
    @objc dynamic var canContinue: Bool
    @objc dynamic var displayToUser: Bool

    /**
     Manually initializes a Software Object
     
     - note: Only packageName is required to parse, displayName, description and displayToUser will have to be set later to properly show it on the GUI.

     - parameter packageName: *packageName*-packageVersion.pkg
     - parameter version: Optional
     - parameter iconPath: Optional
     - parameter displayName: Name displayed to user
     - parameter description: Second line underneath name
     - parameter canContinue: if set to false, the Software will block the "Continue" button until installed
     - parameter displayToUser: set to True to display in GUI
     */
    init(packageName: String,
         version: String? = nil,
         status: SoftwareStatus = .pending,
         iconPath: String? = nil,
         displayName: String? = nil,
         description: String? = nil,
         canContinue: Bool = true,
         displayToUser: Bool = false) {

        self.packageName = packageName
        self.packageVersion = version
        self.status = status
        self.canContinue = canContinue
        self.displayToUser = displayToUser
        self.displayName = displayName
        desc = description

        if let iconPath = iconPath {
            icon = NSImage(contentsOfFile: iconPath)
        } else {
            icon = NSImage(named: NSImage.folderName)
        }
    }

    /**
     Initializes a Software Object from a String
     
     - note: Only packageName is required to parse, displayName, description and displayToUser will have to be set later to properly show it on the GUI.
     
     - parameter packageName: *packageName*-packageVersion.pkg
     - parameter version: Optional
     - parameter iconPath: Optional
     - parameter displayName: Name displayed to user
     - parameter description: Second line underneath name
     - parameter canContinue: if set to false, the Software will block the "Continue" button until installed
     - parameter displayToUser: set to True to display in GUI
     */
    convenience init?(from line: String) {

        var name: String?
        var version: String?
        var status: SoftwareStatus?

        for (regexStatus, regex) in Tools.initRegex() {
            status = regexStatus

            let matches = regex!.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))

            if !matches.isEmpty {
                name = (line as NSString).substring(with: matches[0].range(at: 1))
                version = (line as NSString).substring(with: matches[0].range(at: 2))
                break
            }
        }

        if let packageName = name, let packageVersion = version, let packageStatus = status {
            self.init(packageName: packageName, version: packageVersion, status: packageStatus)
        } else {
            return nil
        }
    }

    convenience init?(from dictionary: NSDictionary, assetPath: URL) {
        guard let name = dictionary["packageName"] as? String else {
            Log.write(string: "Error reading name from an application in io.fti.SplashBuddy",
                      cat: "Preferences",
                      level: .error)
            return nil
        }

        guard let displayName: String = dictionary["displayName"] as? String else {
            Log.write(string: "Error reading displayName from application \(name) in io.fti.SplashBuddy",
                cat: "Preferences",
                level: .error)
            return nil
        }

        guard let description: String = dictionary["description"] as? String else {
            Log.write(string: "Error reading description from application \(name) in io.fti.SplashBuddy",
                cat: "Preferences",
                level: .error)
            return nil
        }

        guard let iconRelativePath: String = dictionary["iconRelativePath"] as? String else {
            Log.write(string: "Error reading iconRelativePath from application \(name) in io.fti.SplashBuddy",
                cat: "Preferences",
                level: .error)
            return nil
        }

        guard let canContinueBool: Bool = Tools.getBool(from: dictionary["canContinue"]) else {
            Log.write(string: "Error reading canContinueBool from application \(name) in io.fti.SplashBuddy",
                cat: "Preferences",
                level: .error)
            return nil
        }

        let iconPath = assetPath.appendingPathComponent(iconRelativePath).path

        self.init(packageName: name,
                  version: nil,
                  status: .pending,
                  iconPath: iconPath,
                  displayName: displayName,
                  description: description,
                  canContinue: canContinueBool,
                  displayToUser: true)
    }
}

// MARK: - Equatable

extension Software {

    static func == (lhs: Software, rhs: Software) -> Bool {
        return lhs.packageName == rhs.packageName && lhs.packageVersion == rhs.packageVersion && lhs.status == rhs.status
    }
}
