//
//  MainViewController_Actions.swift
//  SplashBuddy
//
//  Created by Francois Levaux on 02.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Foundation

extension MainViewController {
    
    /// User pressed the continue (or restart, logout…) button
    @IBAction func pressedContinueButton(_ sender: AnyObject) {
        
        Preferences.sharedInstance.setupDone = true
        Preferences.sharedInstance.continueAction.pressed(sender)
        
    }
    
    /// Set the initial state of the view
    func setupInstalling() {
        indeterminateProgressIndicator.startAnimation(self)
        indeterminateProgressIndicator.isHidden = false
        
        statusLabel.isHidden = false
        statusLabel.stringValue = NSLocalizedString("We are preparing your Mac…", comment: "Displayed above progress bar")
        
        self.sidebarView.isHidden = Preferences.sharedInstance.sidebar
        
        self.continueButton.isEnabled = false
    }
    
    /// reset the status label to "We are preparing your Mac…"
    @objc func resetStatusLabel() {
        statusLabel.stringValue = NSLocalizedString("We are preparing your Mac…", comment: "Displayed above progress bar")
        statusLabel.textColor = .black
    }
    
    /// sets the status label to display an error
    @objc func errorWhileInstalling() {
        guard let error = SoftwareArray.sharedInstance.localizedErrorStatus else {
            return
        }
        statusLabel.textColor = .red
        statusLabel.stringValue = error
    }

    /// all critical software is installed
    @objc func canContinue() {
        Preferences.sharedInstance.setupDone = true
        self.continueButton.isEnabled = true
    }
    
    /// all software is installed (failed or success)
    @objc func doneInstalling() {
        indeterminateProgressIndicator.stopAnimation(self)
        indeterminateProgressIndicator.isHidden = true
    }
    
    /// all software is sucessfully installed
    @objc func allSuccess() {
        statusLabel.textColor = .labelColor
        statusLabel.stringValue = Preferences.sharedInstance.continueAction.localizedSuccessStatus
    }
    

    
    
    
}
