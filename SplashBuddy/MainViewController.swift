//
//  MainViewController.swift
//  SplashBuddy
//
//  Created by François Levaux on 24.11.16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet var webView: MainWebView!
    @IBOutlet var softwareTableView: NSTableView!
    @IBOutlet weak var indeterminateProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var continueButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var installingLabel: NSTextField!
    @IBOutlet var mainView: NSView!
    @IBOutlet weak var statusView: NSView!
   
    // Predicate used by Storyboard to filter which software to display
    let predicate = NSPredicate.init(format: "displayToUser = true")
    
    override func awakeFromNib() {
        
        // https://developer.apple.com/library/content/qa/qa1871/_index.html
        
        if (self.representedObject == nil) {
            self.representedObject = SoftwareArray.sharedInstance
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        
        // Setup the view
        self.mainView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        self.mainView.layer?.cornerRadius = 10
        self.mainView.layer?.shadowOpacity = 0.5
        self.mainView.layer?.shadowRadius = 2
        self.mainView.layer?.borderWidth = 0.2
        
        
        
        // Setup the Notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.errorWhileInstalling),
                                               name: NSNotification.Name(rawValue: "errorWhileInstalling"),
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.canContinue),
                                               name: NSNotification.Name(rawValue: "canContinue"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.doneInstalling),
                                               name: NSNotification.Name(rawValue: "doneInstalling"),
                                               object: nil)
        
        
        

 
    }

    override func viewDidAppear() {
        
        // Setup the initial state of objects
        self.setupInstalling()

        // Display Alert if /var/log/jamf.log doesn't exist
        
        if Preferences.sharedInstance.logFileHandle == nil {
            let alert = NSAlert()
            
            alert.alertStyle = .critical
            alert.messageText = "Jamf is not installed correctly"
            alert.informativeText = "/var/log/jamf.log is missing"
            alert.addButton(withTitle: "Quit")
            
            alert.beginSheetModal(for: self.view.window!) { (response) in
                self.pressedContinueButton(self)
            }
            
        }
        
    }
    
    @IBAction func pressedContinueButton(_ sender: AnyObject) {
        
        Preferences.sharedInstance.setupDone = true
        NSApplication.shared().terminate(self)
        
    }
    
    
    
    
    

    
    


    
    
}
