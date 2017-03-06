//
//  MainViewController_Actions.swift
//  CasperSplash
//
//  Created by Francois Levaux on 02.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Foundation

extension MainViewController {
    
    func setupInstalling() {
        indeterminateProgressIndicator.startAnimation(self)
        indeterminateProgressIndicator.isHidden = false
        
        installingLabel.stringValue = NSLocalizedString("Installing…", comment: "")
        
        statusLabel.stringValue = ""
        
        continueButton?.isEnabled = false
    }
    
    
    
    func errorWhileInstalling() {
        indeterminateProgressIndicator.isHidden = true
        installingLabel.stringValue = ""
        continueButton?.isEnabled = true
        statusLabel.textColor = .red
        
        let _failedSoftwareArray = SoftwareArray.sharedInstance.failedSoftwareArray()
        
        if _failedSoftwareArray.count == 1 {
            
            if let failedDisplayName = _failedSoftwareArray[0].displayName {
                statusLabel.stringValue = String.localizedStringWithFormat(NSLocalizedString(
                    "%@ failed to install. Support has been notified.",
                    comment: "A specific application failed to install"), failedDisplayName)
                
            } else {
                statusLabel.stringValue = NSLocalizedString(
                    "An application failed to install. Support has been notified.",
                    comment: "One (unnamed) application failed to install")
            }
            
            
        } else {
            statusLabel.stringValue = NSLocalizedString(
                "Some applications failed to install. Support has been notified.",
                comment: "More than one application failed to install")
        }
        
    }

    
    
    func canContinue() {
        continueButton?.isEnabled = true
    }
    
    
    
    func doneInstalling() {
        indeterminateProgressIndicator.isHidden = true
        installingLabel.stringValue = ""
        statusLabel.textColor = .green
        statusLabel.stringValue = NSLocalizedString(
            "All applications were installed. Please click continue.",
            comment: "All applications were installed. Please click continue.")
    }
    

    
    
    
}
