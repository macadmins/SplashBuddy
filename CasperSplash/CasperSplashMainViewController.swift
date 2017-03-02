//
//  CasperSplashMainViewController.swift
//  CasperSplash
//
//  Created by François Levaux on 24.11.16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class CasperSplashMainViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet var webView: CasperSplashWebView!
    @IBOutlet var softwareTableView: NSTableView!
    @IBOutlet weak var indeterminateProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var continueButton: NSButton?
    @IBOutlet var softwareArrayController: NSArrayController!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var installingLabel: NSTextField!
    @IBOutlet var mainView: NSView!
    @IBOutlet weak var statusView: NSView!
    
    dynamic var softwareArray = [Software]()
    
    
    // Predicate used by Storyboard to filter which software to display
    let predicate = NSPredicate.init(format: "displayToUser = true")
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        
        // Setup the view
        self.mainView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        self.mainView.layer?.cornerRadius = 10
        self.mainView.layer?.shadowOpacity = 0.5
        self.mainView.layer?.shadowRadius = 2
        self.mainView.layer?.borderWidth = 0.2
        
        // Setup the initial state of objects
        SetupInstalling()
        
        // Get preferences from UserDefaults
        Preferences.sharedInstance.getPreferencesApplications(&softwareArray)

        // Setup Timer to parse log
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
        

 
    }

    
    @IBAction func pressedContinueButton(_ sender: AnyObject) {
        
        guard let postInstallScript = Preferences.sharedInstance.postInstallScript else {
            NSLog("Couldn't get postInstall Script")
            NSApplication.shared().terminate(self)
            return
        }
        
        postInstallScript.execute({ (isSuccessful) in
            
            if !isSuccessful { NSLog("Couldn't execute postInstall Script") }
            
            NSApplication.shared().terminate(self)
            
        })
        
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
    
    

    
    
    func readTimer() -> Void {
        
        DispatchQueue.global(qos: .background).async {
            if let logFileHandle = Preferences.sharedInstance.logFileHandle {
                if let lines = logFileHandle.readLines() {
                    for line in lines {
                        if let software = Software(from: line) {
                            DispatchQueue.main.async {
                                self.softwareArray.modify(with: software)
                                
                                self.checkSoftwareStatus()
                            }
                        }
                    }
                }
                
            }
        }
    }

    
    
}
