// SplashBuddy

/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

extension MainViewController {

    /// User pressed the continue (or restart, logout…) button
    @IBAction func pressedContinueButton(_ sender: AnyObject) {
        Preferences.sharedInstance.setupDone = true
        Preferences.sharedInstance.continueAction.pressed(sender)
    }

    /// Set the initial state of the view
    func setupInstalling() {
//        self.sideBarView.isHidden = true
//        self.bottomView.isHidden = true
        
        if Preferences.sharedInstance.hideSidebar {
//            self.activeProgressIndicator = self.bottomProgressIndicator
//            self.activeStatusLabel = self.bottomStatusLabel
//            self.activeContinueButton = self.bottomContinueButton
//            self.activeView = self.bottomView
            self.sideBarView.isHidden = true
        } else {
            self.sideBarProgressIndicator?.startAnimation(self)
            self.sideBarProgressIndicator?.isHidden = false
            
            self.activeStatusLabel.isHidden = false
            self.activeStatusLabel.stringValue = NSLocalizedString("actions.preparing_your_mac")
            
            self.sideBarContinueButton.isEnabled = false
            self.sideBarContinueButton.isHidden = true
        }
        
        
        
//        self.activeView.isHidden = false
    }

    /// reset the status label to "We are preparing your Mac…"
    @objc func resetStatusLabel() {
        activeStatusLabel.stringValue = NSLocalizedString("actions.preparing_your_mac")
    }

    /// sets the status label to display an error
    @objc func errorWhileInstalling() {
        Preferences.sharedInstance.errorWhileInstalling = true

        guard let error = SoftwareArray.sharedInstance.localizedErrorStatus else {
            return
        }
        activeStatusLabel.textColor = .red
        activeStatusLabel.stringValue = error
        activeStatusLabel.isHidden = false
    }

    /// all critical software is installed
    @objc func canContinue() {
        Preferences.sharedInstance.criticalDone = true
        self.sideBarContinueButton.isEnabled = true
        self.sideBarContinueButton.isHidden = false
    }

    /// all software is installed (failed or success)
    @objc func doneInstalling() {
        Preferences.sharedInstance.allInstalled = true
        sideBarProgressIndicator.stopAnimation(self)
        sideBarProgressIndicator.isHidden = true

        if Preferences.sharedInstance.labMode {
//            self.activeView.isHidden = true
            self.sideBarView.isHidden = true
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
        activeStatusLabel.textColor = .labelColor
        activeStatusLabel.stringValue = Preferences.sharedInstance.continueAction.localizedSuccessStatus
    }
}
