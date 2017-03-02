//
//  MainViewController_Actions.swift
//  CasperSplash
//
//  Created by Francois Levaux on 02.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Foundation

extension CasperSplashMainViewController {
    
    func SetupInstalling() {
        indeterminateProgressIndicator.startAnimation(self)
        indeterminateProgressIndicator.isHidden = false
        
        installingLabel.stringValue = "Installing…"
        
        statusLabel.stringValue = ""
        
        continueButton?.isEnabled = false
    }
    
    
    
    func errorWhileInstalling(_failedSoftwareArray: [Software]) {
        indeterminateProgressIndicator.isHidden = true
        installingLabel.stringValue = ""
        continueButton?.isEnabled = true
        statusLabel.textColor = .red
        
        if _failedSoftwareArray.count == 1 {
            
            let failedDisplayName = _failedSoftwareArray[0].displayName ?? "An application"
            statusLabel.stringValue = "\(failedDisplayName) failed to install. Support has been notified."
            
            
        } else {
            statusLabel.stringValue = "Some applications failed to install. Support has been notified."
        }
        
    }

    
    
    func doneInstallingCriticalSoftware() {
        continueButton?.isEnabled = true
    }
    
    
    
    func doneInstalling() {
        indeterminateProgressIndicator.isHidden = true
        installingLabel.stringValue = ""
        statusLabel.textColor = .green
        statusLabel.stringValue = "All applications were installed. Please click continue."
    }
    

    
    func checkSoftwareStatus() {
        if failedSoftwareArray(softwareArray).count > 0 {
            errorWhileInstalling(_failedSoftwareArray: failedSoftwareArray(softwareArray))
        } else if canContinue(softwareArray) {
            doneInstallingCriticalSoftware()
        } else {
            SetupInstalling()
        }
        
        if allInstalled(softwareArray) {
            doneInstalling()
        }
    }
    
    
}
