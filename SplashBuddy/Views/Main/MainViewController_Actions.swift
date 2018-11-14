//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
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
        statusLabel.stringValue = NSLocalizedString("actions.preparing_your_mac")

        sidebarView.isHidden = Preferences.sharedInstance.sidebar

        continueButton.isEnabled = false
    }

    /// reset the status label to "We are preparing your Mac…"
    @objc func resetStatusLabel() {
        statusLabel.stringValue = NSLocalizedString("actions.preparing_your_mac")
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

        if Preferences.sharedInstance.labMode {
            self.sidebarView.isHidden = true
            if let labComplete = Preferences.sharedInstance.labComplete {
                self.webView.loadFileURL(labComplete, allowingReadAccessTo: Preferences.sharedInstance.assetPath)
            } else {
                let errorMsg = NSLocalizedString("error.create_complete_html_file")
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
