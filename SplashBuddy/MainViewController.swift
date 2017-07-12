//
//  MainViewController.swift
//  SplashBuddy
//
//  Created by François Levaux on 24.11.16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa
import WebKit

class MainViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet var softwareTableView: NSTableView!
    @IBOutlet weak var indeterminateProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var continueButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var installingLabel: NSTextField!
    @IBOutlet var mainView: NSView!
    @IBOutlet weak var statusView: NSView!
    
    lazy var userInputHandler: SBSubmitHandler = {
        return SBSubmitHandler()
    }()
    
    lazy var customEventHandler: SBTriggerHandler = {
        return SBTriggerHandler()
    }()
   
    // Predicate used by Storyboard to filter which software to display
    @objc let predicate = NSPredicate(format: "displayToUser = true")
    
    override func awakeFromNib() {
        
        // https://developer.apple.com/library/content/qa/qa1871/_index.html
        
        if (self.representedObject == nil) {
            self.representedObject = SoftwareArray.sharedInstance
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        webView.configuration.userContentController.add(userInputHandler, name: "splashbuddy")
        webView.configuration.userContentController.add(customEventHandler, name: "trigger")
        
        // Setup the view
        self.mainView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        self.mainView.layer?.cornerRadius = 10
        self.mainView.layer?.shadowOpacity = 0.5
        self.mainView.layer?.shadowRadius = 2
        self.mainView.layer?.borderWidth = 0.2
        
        // Setup the web view
        self.webView.layer?.borderWidth = 1.0
        self.webView.layer?.borderColor = NSColor.lightGray.cgColor
        self.webView.layer?.isOpaque = true
        
        
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.formSubmitted),
                                               name: NSNotification.Name(rawValue: "formSubmitted"),
                                               object: nil)
        

 
    }

    override func viewDidAppear() {
        
        // Setup the initial state of objects
        self.setupInstalling()

        // Display Alert if /var/log/jamf.log doesn't exist
        
        guard (Preferences.sharedInstance.logFileHandle != nil) else {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Jamf is not installed correctly"
            alert.informativeText = "/var/log/jamf.log is missing"
            alert.addButton(withTitle: "Quit")
            alert.beginSheetModal(for: self.view.window!) { (_) in
                self.pressedContinueButton(self)
            }
            return
        }
        
        
        // Display the html file
        if let form = Preferences.sharedInstance.form {
            self.webView.loadFileURL(form, allowingReadAccessTo: Preferences.sharedInstance.assetPath)
        } else if let html = Preferences.sharedInstance.html {
            self.webView.loadFileURL(html, allowingReadAccessTo: Preferences.sharedInstance.assetPath)
        } else {
            self.webView.loadHTMLString("Please create a bundle in /Library/Application Support/SplashBuddy", baseURL: nil)
        }
    }
    
    @objc func formSubmitted(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.sendButton.isHidden = true
            
            if let html = Preferences.sharedInstance.html {
                self.webView.loadFileURL(html, allowingReadAccessTo: Preferences.sharedInstance.assetPath)
            } else {
                self.webView.loadHTMLString("Please create a bundle in /Library/Application Support/SplashBuddy", baseURL: nil)
            }
        }
    }
    
    @IBAction func pressedContinueButton(_ sender: AnyObject) {
        
        Preferences.sharedInstance.setupDone = true
        NSApplication.shared.terminate(self)
        
    }
    
    @IBOutlet weak var sendButton: NSButton!

}
