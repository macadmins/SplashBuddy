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
        case ErrorWhileInstalling
        case CanContinue
        case DoneInstalling
        case SetupInstalling
        case Processing
        case AllSuccess
        
        var notification: Notification.Name {
            return Notification.Name(rawValue: self.rawValue)
        }
    }
    
    func failedSoftwareArray(_ _array: [Software] = SoftwareArray.sharedInstance.array) -> [Software] {
       return _array.filter({ $0.status == .failed })
    }
    
    func canContinue(_ _array: [Software] = SoftwareArray.sharedInstance.array) -> Bool {
        guard Preferences.sharedInstance.doneParsingPlist == true else {
            return false
        }
        let criticalSoftwareArray = _array.filter({ $0.canContinue == false })
        return criticalSoftwareArray.filter({ $0.status == .success }).count == criticalSoftwareArray.count
    }
    
    func allDone(_ _array: [Software] = SoftwareArray.sharedInstance.array) -> Bool {
        let displayedSoftwareArray = _array.filter({ $0.displayToUser == true })
        return displayedSoftwareArray.filter({ $0.status == .success || $0.status == .failed }).count == displayedSoftwareArray.count
    }

    
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
