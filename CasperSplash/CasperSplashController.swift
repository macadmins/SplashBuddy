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
    @IBOutlet var webView: CasperSplashWebView!
    @IBOutlet var softwareTableView: NSTableView!
    @IBOutlet weak var indeterminateProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var continueButton: NSButton?
    @IBOutlet var softwareArrayController: NSArrayController!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var installingLabel: NSTextField!
    
    dynamic var softwareArray = [Software]()
    let predicate = Predicate.init(format: "displayToUser = true")
    
    override func windowDidLoad() {
        super.windowDidLoad()

        theWindow.collectionBehavior = NSWindowCollectionBehavior.fullScreenPrimary
        theWindow.toggleFullScreen(self)
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
       
        //dump(prefs)
        if let indexHtmlPath = Preferences.sharedInstance.htmlAbsolutePath {
            webView.mainFrame.load(URLRequest(url: URL(fileURLWithPath: indexHtmlPath)))
        }
        
        self.webView.layer?.borderWidth = 1.0
        self.webView.layer?.borderColor = NSColor.lightGray().cgColor
        self.webView.layer?.isOpaque = true
        self.webView.layer?.backgroundColor = NSColor.clear().cgColor
        

        indeterminateProgressIndicator.startAnimation(self)
        statusLabel.stringValue = ""
        continueButton?.isEnabled = false
        
    }
    
    @IBAction func pressedContinueButton(_ sender: AnyObject) {

        Preferences.sharedInstance.postInstallScript?.execute({ (isSuccessful) in
            if !isSuccessful {
                NSLog("Couldn't execute postInstall Script")
            }
            NSApplication.shared().terminate(self)
        })

    }
   
    func doneInstalling() {
        indeterminateProgressIndicator.isHidden = true
        installingLabel.stringValue = ""
        continueButton?.isEnabled = true
        statusLabel.stringValue = "All applications were installed. Please click continue."
    }
    func checkContinue() {

        if Set(softwareArray.filter({ $0.canContinue == false && $0.status == .success}).map({ $0.status.rawValue })).count == 1 {
            doneInstalling()
            
        } else {
            continueButton?.isEnabled = false
            statusLabel.stringValue = ""
        }
    }
}
