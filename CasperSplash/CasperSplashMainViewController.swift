//
//  CasperSplashMainViewController.swift
//  CasperSplash
//
//  Created by François Levaux on 24.11.16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class CasperSplashMainViewController: NSViewController, NSTableViewDataSource {

//    @IBOutlet var theWindow: NSWindow!
//    @IBOutlet weak var theWindowView: NSView!
    @IBOutlet var webView: CasperSplashWebView!
    @IBOutlet var softwareTableView: NSTableView!
    @IBOutlet weak var indeterminateProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var continueButton: NSButton?
    @IBOutlet var softwareArrayController: NSArrayController!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var installingLabel: NSTextField!
//    
    @IBOutlet var mainView: NSView!
    @IBOutlet weak var statusView: NSView!
    
    var mainWindowController: CasperSplashController!

    dynamic var softwareArray = SoftwareArray.sharedInstance.array
    let predicate = NSPredicate.init(format: "displayToUser = true")
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Do view setup here.
    
        self.mainView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        self.mainView.layer?.cornerRadius = 10
        self.mainView.layer?.shadowOpacity = 0.5
        self.mainView.layer?.shadowRadius = 2
        self.mainView.layer?.borderWidth = 0.2
        
        
        mainWindowController = (self.view.window?.windowController)! as! CasperSplashController
        checkSoftwareStatus()
        
        //SoftwareArray.sharedInstance.addObserver(self, forKeyPath: "array", options: .new, context: nil)
        
    // Setup Web View
        self.webView.layer?.borderWidth = 1.0
        self.webView.layer?.borderColor = NSColor.lightGray.cgColor
        self.webView.layer?.isOpaque = true
        
        if let indexHtmlPath = Preferences.sharedInstance.htmlAbsolutePath {
            webView.mainFrame.load(URLRequest(url: URL(fileURLWithPath: indexHtmlPath)))
        }
    
    SetupInstalling()
        
        //Preferences.sharedInstance.logFileHandle = FileHandle(forReadingAtPath: Preferences.sharedInstance.jamfLog)
        Preferences.sharedInstance.getPreferencesApplications(&softwareArray)
        
        //let appDelegate = NSApp.delegate as! AppDelegate
    Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
    
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
    indeterminateProgressIndicator.isHidden = false
    
    installingLabel.stringValue = "Installing…"
    
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
    
    
    
    func readTimer() -> Void {
        
        DispatchQueue.global(qos: .background).async {
            if let logFileHandle = Preferences.sharedInstance.logFileHandle {
                if let lines = readLinesFromFile(logFileHandle) {
                    for line in lines {
                        if let software = getSoftwareFromRegex(line) {
                            DispatchQueue.main.async {
                                modifySoftwareArray(fromSoftware: software, softwareArray: &self.softwareArray)
                                
                                self.checkSoftwareStatus()
                            }
                        }
                    }
                }
                
            }
        }
    }


}
