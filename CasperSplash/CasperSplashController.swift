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
    
    //dynamic var softwareArray = [Software]()
    dynamic var softwareArray = [Software]()
    let predicate = NSPredicate.init(format: "displayToUser = true")
    override func windowDidLoad() {
        super.windowDidLoad()

        theWindow.collectionBehavior = NSWindowCollectionBehavior.FullScreenPrimary
        theWindow.toggleFullScreen(self)
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
       
        //dump(prefs)
        if let indexHtmlPath = prefs.htmlAbsolutePath {
            webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: indexHtmlPath)))
        }
        
        self.webView.layer?.borderWidth = 1.0
        self.webView.layer?.borderColor = NSColor.lightGrayColor().CGColor
        self.webView.layer?.opaque = true
        self.webView.layer?.backgroundColor = NSColor.clearColor().CGColor
        

        indeterminateProgressIndicator.startAnimation(self)
        statusLabel.stringValue = ""
        
        //self.softwareArray.append(Software(name: "Druva", displayName: "Druva", description: "Backup", status: .Failed))
        
        //self.softwareArray.append(Software(name: "Junos Pulse", displayName: "Junos Pulse", description: "VPN", status: .Pending))
    }
    
    @IBAction func pressedContinueButton(sender: AnyObject) {
        self.softwareArray.append(Software(name: "TEST3", displayName: "test3", description: "youpi3", status: .Success))
    }
   
}
