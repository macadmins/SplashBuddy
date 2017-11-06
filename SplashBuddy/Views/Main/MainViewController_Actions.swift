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
        
        statusLabel.isHidden = false
        statusLabel.stringValue = NSLocalizedString("We are preparing your Mac…", comment: "Displayed above progress bar")
        
        self.sidebarView.isHidden = Preferences.sharedInstance.sidebar
        
        self.continueButton.isEnabled = false
    }
    
    @objc func clearLabel() {
        statusLabel.stringValue = NSLocalizedString("We are preparing your Mac…", comment: "Displayed above progress bar")
        statusLabel.textColor = .black
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
        Preferences.sharedInstance.setupDone = true
        self.continueButton.isEnabled = true
    }
    
    @objc func doneInstalling() {
        indeterminateProgressIndicator.stopAnimation(self)
        indeterminateProgressIndicator.isHidden = true
    }
    
    @objc func allSuccess() {
        statusLabel.textColor = .labelColor
        statusLabel.stringValue = Preferences.sharedInstance.continueAction.localizedSuccessStatus
    }
    

    
    
    
}
