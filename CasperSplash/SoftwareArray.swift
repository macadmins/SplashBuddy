//
//  SoftwareArray.swift
//  CasperSplash
//
//  Created by Francois Levaux on 02.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa


class SoftwareArray: NSObject {
    
    static let sharedInstance = SoftwareArray()
    
    dynamic var array = [Software]() {
        didSet {
            self.checkSoftwareStatus()
        }
    }
    
    
    func failedSoftwareArray(_ _array: [Software] = SoftwareArray.sharedInstance.array) -> [Software] {
        return _array.filter({ $0.status == .failed })
    }
    
    func canContinue(_ _array: [Software] = SoftwareArray.sharedInstance.array) -> Bool {
        let criticalSoftwareArray = _array.filter({ $0.canContinue == false })
        return criticalSoftwareArray.filter({ $0.status == .success }).count == criticalSoftwareArray.count
    }
    
    func allInstalled(_ _array: [Software] = SoftwareArray.sharedInstance.array) -> Bool {
        let displayedSoftwareArray = _array.filter({ $0.displayToUser == true })
        return displayedSoftwareArray.filter({ $0.status == .success }).count == displayedSoftwareArray.count
    }

    
    func checkSoftwareStatus() {
        
        if self.failedSoftwareArray().count > 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "errorWhileInstalling"), object: nil)
        }
        
        if self.canContinue() {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "canContinue"), object: nil)
        }
        
        if self.allInstalled() {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "doneInstalling"), object: nil)
        }
        
    }

}
