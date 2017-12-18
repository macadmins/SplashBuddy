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
        Preferences.sharedInstance.errorWhileInstalling = true
        
        guard let error = SoftwareArray.sharedInstance.localizedErrorStatus else {
            return
        }
        statusLabel.textColor = .red
        statusLabel.stringValue = error
    }

    /// all critical software is installed
    @objc func canContinue() {
        Preferences.sharedInstance.criticalDone = true
        self.continueButton.isEnabled = true
    }
    
    /// all software is installed (failed or success)
    @objc func doneInstalling() {
        Preferences.sharedInstance.allInstalled = true
        indeterminateProgressIndicator.stopAnimation(self)
        indeterminateProgressIndicator.isHidden = true
        if (Preferences.sharedInstance.labMode) {
            self.sidebarView.isHidden = true
            if let labComplete = Preferences.sharedInstance.labComplete {
                self.webView.loadFileURL(labComplete, allowingReadAccessTo: Preferences.sharedInstance.assetPath)
            } else {
                let errorMsg = NSLocalizedString("Please create a complete.html file in your presentation.bundle located in /Library/Application Support/SplashBuddy", comment: "Displayed when cannot load HTML bundle")
                self.webView.loadHTMLString(errorMsg, baseURL: nil)
            }
        }
    }
    
    /// all software is sucessfully installed
    @objc func allSuccess() {
        Preferences.sharedInstance.allSuccessfullyInstalled = true
        statusLabel.textColor = .labelColor
        statusLabel.stringValue = Preferences.sharedInstance.continueAction.localizedSuccessStatus
    }
    

    
    
    
}
