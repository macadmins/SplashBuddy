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

class SoftwareArray: NSObject {

    static let sharedInstance = SoftwareArray()
    let serialQueue = DispatchQueue(label: "SoftwareArray")

    @objc dynamic var array = [Software]()
    
    func updateInfo(for software: Software) {
        if let index = array.index(where: {
            let set1 = Set($0.packageNames)
            let set2 = Set(software.packageNames)
            return set1.intersection(set2).count > 0
        }) {
            if self.array[index].status.rawValue < software.status.rawValue {
                serialQueue.sync {
                    self.array[index].status = software.status
                    self.checkSoftwareStatus()
                }
            }
        }
    }
    
    func append(software: Software) {
        serialQueue.sync {
            self.array.append(software)
            self.checkSoftwareStatus()
        }
    }
    
    func iterate(operation: @escaping (Software) -> Void) {
        serialQueue.sync {
            for software in self.array {
                DispatchQueue.main.async {
                    operation(software)
                }
            }
        }
    }

    enum StateNotification: String {
        /// An error was detected (even if software is not in `applicationArray`)
        case errorWhileInstalling = "ErrorWhileInstalling"

        /// All critical software were installed
        case canContinue = "CanContinue"

        /// All software were installed (either failed or success)
        case doneInstalling = "DoneInstalling"

        /// All software were installed successfully
        case allSuccess = "AllSuccess"

        /// SplashBuddy will start processing the log
        case setupInstalling = "SetupInstalling"

        /// SplashBuddy is processing the log
        case processing = "Processing"

        var notification: Notification.Name {
            return Notification.Name(rawValue: self.rawValue)
        }
    }

    /// Returns a localized error or nil if no error
    var localizedErrorStatus: String? {
        let failedSoftwareArray = SoftwareArray.sharedInstance.failedSoftwareArray()

        if failedSoftwareArray.count == 1 {

            if let failedDisplayName = failedSoftwareArray[0].displayName {
                return String.localizedStringWithFormat(NSLocalizedString("error.failed_specific_app_install"), failedDisplayName)

            } else {
                return NSLocalizedString("error.failed_unknown_app_install")
            }
        } else if failedSoftwareArray.count > 1 {
            return NSLocalizedString("error.failed_multiple_app_install")

        } else {
            return nil
        }
    }

    internal func failedSoftwareArray(_ array: [Software] = SoftwareArray.sharedInstance.array) -> [Software] {
        var localArray = [Software]()
        serialQueue.sync {
            localArray = array.filter({ $0.status == .failed })
        }
        return localArray
    }

    internal func canContinue(_ array: [Software] = SoftwareArray.sharedInstance.array) -> Bool {
        guard Preferences.sharedInstance.doneParsingPlist == true else {
            return false
        }
        
        var result = false
        serialQueue.sync {
            let criticalSoftwareArray = array.filter({ $0.canContinue == false })
            
            result = criticalSoftwareArray.filter({ $0.status == .success }).count == criticalSoftwareArray.count
        }
        return result
    }

    internal func allDone(_ array: [Software] = SoftwareArray.sharedInstance.array) -> Bool {
        let displayedSoftwareArray = array.filter({ $0.displayToUser == true })
        return displayedSoftwareArray
            .filter({ $0.status == .success || $0.status == .failed })
            .count == displayedSoftwareArray.count
    }

    /// Check SoftwareArray and send the relevant notifications
    func checkSoftwareStatus() {
        DispatchQueue.main.async {
            if self.canContinue() {
                NotificationCenter.default.post(name: SoftwareArray.StateNotification.canContinue.notification, object: nil)
            }
            
            if self.allDone() {
                NotificationCenter.default.post(name: SoftwareArray.StateNotification.doneInstalling.notification, object: nil)
                
                if self.failedSoftwareArray().isEmpty {
                    NotificationCenter.default.post(name: SoftwareArray.StateNotification.allSuccess.notification, object: nil)
                    return
                }
            }
            
            var notificationName: NSNotification.Name
            if !self.failedSoftwareArray().isEmpty {
                notificationName = SoftwareArray.StateNotification.errorWhileInstalling.notification
            } else {
                notificationName = SoftwareArray.StateNotification.processing.notification
            }
            
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
}
