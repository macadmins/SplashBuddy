//
//  MainViewController_Actions.swift
//  SplashBuddy
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
        
        continueButton.isEnabled = false
    }
    
    @objc func clearLabel() {
        statusLabel.stringValue = ""
    }
    
    @objc func errorWhileInstalling() {
        continueButton.isEnabled = true
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

    @objc func canContinue() {
        continueButton.isEnabled = true
    }
    
    @objc func doneInstalling() {
        indeterminateProgressIndicator.stopAnimation(self)
        indeterminateProgressIndicator.isHidden = true
        
        installingLabel.stringValue = ""
    }
    
    @objc func allSuccess() {
        statusLabel.textColor = .labelColor
        statusLabel.stringValue = NSLocalizedString(
            "All applications were installed. Please click continue.",
            comment: "All applications were installed. Please click continue.")
    }
    

    
    
    
}
