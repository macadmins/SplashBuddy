// SplashBuddy

/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Cocoa

/**
 Object that will hold the definition of a software.
 
 The goal here is to:
 1. Create a Software object from the plist (MacAdmin supplied Software)
 2. Parse the log and either:
    - Modify the Software object (if it already exists)
    - Create a new Software object.
 
 */

infix operator ~=

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

    @objc dynamic var packageNames: [String]
    @objc dynamic var status: SoftwareStatus
    @objc dynamic var icon: NSImage?
    @objc dynamic var displayName: String?
    @objc dynamic var desc: String?
    @objc dynamic var canContinue: Bool
    @objc dynamic var displayToUser: Bool
    
    override var description: String {
        
        return "<\(String(describing: type(of:self))): displayName=\(String(describing: self.displayName)), status=\(self.status.rawValue), canContinue=\(self.canContinue)>"
    }

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

    init(packageNames: [String],
         status: SoftwareStatus = .pending,
         iconPath: String? = nil,
         displayName: String? = nil,
         description: String? = nil,
         canContinue: Bool = true,
         displayToUser: Bool = false) {

        self.packageNames = packageNames
        self.status = status
        self.canContinue = canContinue
        self.displayToUser = displayToUser
        self.displayName = displayName
        self.desc = description

        if let iconPath = iconPath {
            self.icon = NSImage(contentsOfFile: iconPath)
        } else {
            self.icon = NSImage(named: NSImage.Name.folder)
        }
    }
    
    convenience init(packageName: String,
                     status: SoftwareStatus = .pending,
                     iconPath: String? = nil,
                     displayName: String? = nil,
                     description: String? = nil,
                     canContinue: Bool = true,
                     displayToUser: Bool = false) {
        self.init(packageNames: [packageName], status: status, iconPath: iconPath, displayName: displayName, description: description, canContinue: canContinue, displayToUser: displayToUser)
    }
    
    static func ==(lhs: Software, rhs: Software) -> Bool {
        return lhs.packageNames == rhs.packageNames && lhs.status == rhs.status
    }
    
    static func ~=(lhs: Software, rhs: Software) -> Bool {
        for name in rhs.packageNames {
            if lhs.packageNames.contains(name) {
                return true
            }
        }
        return false
    }
}
