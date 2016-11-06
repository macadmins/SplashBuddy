//
//  CasperSplashController.swift
//  CasperSplash
//
//  Created by testpilotfinal on 04/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa
import WebKit



class CasperSplashController: NSWindowController, NSTableViewDataSource {
    
    @IBOutlet var theWindow: NSWindow!
    @IBOutlet weak var theWindowView: NSView!
    @IBOutlet var webView: CasperSplashWebView!
    @IBOutlet var softwareTableView: NSTableView!
    @IBOutlet weak var indeterminateProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var continueButton: NSButton?
    @IBOutlet var softwareArrayController: NSArrayController!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var installingLabel: NSTextField!
    
    @IBOutlet var backgroundWindow: NSWindow!
    
    dynamic var softwareArray = [Software]()
    let predicate = NSPredicate.init(format: "displayToUser = true")
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Create Background Window
        let mainDisplayRect = NSScreen.main()?.frame
        backgroundWindow.contentRect(forFrameRect: mainDisplayRect!)
        backgroundWindow.setFrame((NSScreen.main()?.frame)!, display: true)
        backgroundWindow.setFrameOrigin((NSScreen.main()?.frame.origin)!)
        backgroundWindow.level = Int(CGWindowLevelForKey(.maximumWindow) - 1 )
        backgroundWindow.canBecomeVisibleWithoutLogin = true

        // Display Front Window
        theWindow.level = Int(CGWindowLevelForKey(.maximumWindow))
        theWindow.canBecomeVisibleWithoutLogin = true
        theWindowView.layer?.cornerRadius = 10.00
        
        // Setup Web View
        self.webView.layer?.borderWidth = 1.0
        self.webView.layer?.borderColor = NSColor.lightGray.cgColor
        self.webView.layer?.isOpaque = true
        
        if let indexHtmlPath = Preferences.sharedInstance.htmlAbsolutePath {
            webView.mainFrame.load(URLRequest(url: URL(fileURLWithPath: indexHtmlPath)))
        }

        SetupInstalling()

    }
    
    @IBAction func pressedContinueButton(_ sender: AnyObject) {
        
        let prefs2 = Preferences.sharedInstance.postInstallScript
        prefs2?.execute({ (isSuccessful) in
            if !isSuccessful {
                NSLog("Couldn't execute postInstall Script")
            }
            NSApplication.shared().terminate(self)
        })
        
    }
    
    func SetupInstalling() {
        indeterminateProgressIndicator.startAnimation(self)
        statusLabel.stringValue = ""
        continueButton?.isEnabled = false
    }
    
    func errorWhileInstalling(_failedSoftwareArray: [Software]) {
        indeterminateProgressIndicator.isHidden = true
        installingLabel.stringValue = ""
        continueButton?.isEnabled = true
        statusLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        
        if _failedSoftwareArray.count == 1 {
            if let failedDisplayName = _failedSoftwareArray[0].displayName {
                statusLabel.stringValue = "\(failedDisplayName) failed to install. Support has been notified."
            } else {
                statusLabel.stringValue = "An application failed to install. Support has been notified."
            }
            
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
        statusLabel.textColor = #colorLiteral(red: 0.2818343937, green: 0.5693024397, blue: 0.1281824261, alpha: 1)
        statusLabel.stringValue = "All applications were installed. Please click continue."
    }
    
    
    func failedSoftwareArray(_ _softwareArray: [Software]) -> [Software] {
        return _softwareArray.filter({ $0.status == .failed })
    }
    
    func canContinue(_ _softwareArray: [Software]) -> Bool {
        let criticalSoftwareArray = _softwareArray.filter({ $0.canContinue == false })
        return criticalSoftwareArray.filter({ $0.status == .success }).count == criticalSoftwareArray.count
    }
    
    func allInstalled(_ _softwareArray: [Software]) -> Bool {
        let displayedSoftwareArray = _softwareArray.filter({ $0.displayToUser == true })
        return displayedSoftwareArray.filter({ $0.status == .success }).count == displayedSoftwareArray.count
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
