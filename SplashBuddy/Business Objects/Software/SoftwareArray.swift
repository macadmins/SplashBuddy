//
//  SoftwareArray.swift
//  SplashBuddy
//
//  Created by Francois Levaux on 02.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa


class SoftwareArray: NSObject {
    
    static let sharedInstance = SoftwareArray()
    
    @objc dynamic var array = [Software]() {
        didSet {
            self.checkSoftwareStatus()
        }
    }
    
    enum StateNotification: String {
        
        /// An error was detected (even if software is not in `applicationArray`)
        case ErrorWhileInstalling
        
        /// All critical software were installed
        case CanContinue
        
        /// All software were installed (either failed or success)
        case DoneInstalling
        
        /// All software were installed successfully
        case AllSuccess
        
        /// SplashBuddy will start processing the log
        case SetupInstalling
        
        /// SplashBuddy is processing the log
        case Processing
        
        var notification: Notification.Name {
            return Notification.Name(rawValue: self.rawValue)
        }
    }
    
    /// Returns a localized error or nil if no error
    var localizedErrorStatus: String? {
        get {
            let _failedSoftwareArray = SoftwareArray.sharedInstance.failedSoftwareArray()
            
            if _failedSoftwareArray.count == 1 {
                
                if let failedDisplayName = _failedSoftwareArray[0].displayName {
                    return String.localizedStringWithFormat(NSLocalizedString(
                        "%@ failed to install. Support has been notified.",
                        comment: "A specific application failed to install"), failedDisplayName)
                    
                } else {
                    return NSLocalizedString(
                        "An application failed to install. Support has been notified.",
                        comment: "One (unnamed) application failed to install")
                }
                
                
            } else if _failedSoftwareArray.count > 1 {
                return NSLocalizedString(
                    "Some applications failed to install. Support has been notified.",
                    comment: "More than one application failed to install")
                
            } else {
                return nil
            }
        }
    }
    
    internal func failedSoftwareArray(_ _array: [Software] = SoftwareArray.sharedInstance.array) -> [Software] {
       return _array.filter({ $0.status == .failed })
    }
    
    internal func canContinue(_ _array: [Software] = SoftwareArray.sharedInstance.array) -> Bool {
        guard Preferences.sharedInstance.doneParsingPlist == true else {
            return false
        }
        let criticalSoftwareArray = _array.filter({ $0.canContinue == false })
        return criticalSoftwareArray.filter({ $0.status == .success }).count == criticalSoftwareArray.count
    }
    
    internal func allDone(_ _array: [Software] = SoftwareArray.sharedInstance.array) -> Bool {
        let displayedSoftwareArray = _array.filter({ $0.displayToUser == true })
        return displayedSoftwareArray.filter({ $0.status == .success || $0.status == .failed }).count == displayedSoftwareArray.count
    }

    
    /// Check SoftwareArray and send the relevant notifications
    func checkSoftwareStatus() {
        
        if self.canContinue() {
            NotificationCenter.default.post(name: SoftwareArray.StateNotification.CanContinue.notification, object: nil)
        }
        
        if self.allDone() {
            
            NotificationCenter.default.post(name: SoftwareArray.StateNotification.DoneInstalling.notification, object: nil)
            
            if self.failedSoftwareArray().count == 0 {
                NotificationCenter.default.post(name: SoftwareArray.StateNotification.AllSuccess.notification, object: nil)
                return
            }
        }
        
        if self.failedSoftwareArray().count > 0 {
            NotificationCenter.default.post(name: SoftwareArray.StateNotification.ErrorWhileInstalling.notification, object: nil)
        } else {
            NotificationCenter.default.post(name: SoftwareArray.StateNotification.Processing.notification, object: nil)

        }

        

        
    }

}
