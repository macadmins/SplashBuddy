//
//  MainViewController_Actions.swift
//  SplashBuddy
//
//  Created by Francois Levaux on 02.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Foundation

extension MainViewController {
    
    @objc func setupInstalling() {
        indeterminateProgressIndicator.startAnimation(self)
        indeterminateProgressIndicator.isHidden = false
        
        statusLabel.isHidden = false
        statusLabel.stringValue = "We are preparing your Mac…"
        
        self.sidebarView.isHidden = Preferences.sharedInstance.sidebar
        
        self.continueButton.isHidden = true
        self.continueButton.isEnabled = false
    }
    
    
    
    @objc func errorWhileInstalling() {
        Log.write(string: "Error(s) while installing", cat: .UI, level: .debug)

        indeterminateProgressIndicator.isHidden = true
        self.continueButton.isEnabled = true
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
        Log.write(string: "Enabling Continue Button", cat: .UI, level: .info)

        self.continueButton.isEnabled = true
    }
    
    
    
    @objc func doneInstalling() {
        Log.write(string: "All apps are done installing", cat: .Software, level: .info)

        indeterminateProgressIndicator.isHidden = true
        statusLabel.textColor = .labelColor
        statusLabel.stringValue = NSLocalizedString(
            "All applications were installed. Please click continue.",
            comment: "All applications were installed. Please click continue.")
    }
    

    
    
    
}
