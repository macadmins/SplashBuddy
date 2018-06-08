//
//  MainViewController.swift
//  SplashBuddy
//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Cocoa
import WebKit

class MainViewController: NSViewController, NSTableViewDataSource {

    @IBOutlet var webView: WKWebView!
    @IBOutlet var softwareTableView: NSTableView!
    @IBOutlet weak var indeterminateProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var continueButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet var mainView: NSView!
    @IBOutlet weak var statusView: NSView!
    @IBOutlet weak var sidebarView: NSView!

    // Predicate used by Storyboard to filter which software to display
    @objc let predicate = NSPredicate(format: "displayToUser = true")

    override func awakeFromNib() {
        // https://developer.apple.com/library/content/qa/qa1871/_index.html

        if self.representedObject == nil {
            self.representedObject = SoftwareArray.sharedInstance
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        // Setup the view
        self.mainView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        self.mainView.layer?.cornerRadius = 10
        self.mainView.layer?.shadowRadius = 2
        self.mainView.layer?.borderWidth = 0.2

        // Setup the web view
        self.webView.layer?.isOpaque = true

        // Setup the Continue Button
        self.continueButton.title = Preferences.sharedInstance.continueAction.localizedName

        // Setup the Notifications

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.errorWhileInstalling),
                                               name: SoftwareArray.StateNotification.errorWhileInstalling.notification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.canContinue),
                                               name: SoftwareArray.StateNotification.canContinue.notification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.doneInstalling),
                                               name: SoftwareArray.StateNotification.doneInstalling.notification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.resetStatusLabel),
                                               name: SoftwareArray.StateNotification.processing.notification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.allSuccess),
                                               name: SoftwareArray.StateNotification.allSuccess.notification,
                                               object: nil)
    }

    override func viewDidAppear() {
        // Setup the initial state of objects
        self.setupInstalling()

        // Display Alert if /var/log/jamf.log doesn't exist
        guard Preferences.sharedInstance.logFileHandle != nil else {
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
            DispatchQueue.main.async {
                self.sendButton.isHidden = false
                self.continueButton.isHidden = true
            }
            self.webView.loadFileURL(form, allowingReadAccessTo: Preferences.sharedInstance.assetPath)
       else if let html = Preferences.sharedInstance.html {
            DispatchQueue.main.async {
                self.continueButton.isHidden = Preferences.sharedInstance.continueAction.isHidden
            }

            self.webView.loadFileURL(html, allowingReadAccessTo: Preferences.sharedInstance.assetPath)
        } else {
            let errorMsg = NSLocalizedString("error.create_missing_bundle")
        }
    }
    
    @IBAction func pressedContinueButton(_ sender: AnyObject) {
        
        Preferences.sharedInstance.setupDone = true
        NSApplication.shared.terminate(self)
        
    }
    
    @IBOutlet weak var sendButton: NSButton!
    @IBAction func evalForm(_ sender: Any) {
        let js = """
            function sb() {
              var sbValues = {}; // Return value array

              //  Input Element Processing
              var sbItems = document.getElementsByTagName('input');
              for (var i=0; i < sbItems.length; i++) {
                //  Input elements which are text type
                if (sbItems.item(i).type == "text") {
                  sbValues[sbItems.item(i).name] = sbItems.item(i).value;
                }
                //  Input elements which are checkbox type
                else if (sbItems.item(i).type == "checkbox") {
                  if (document.getElementsByName(sbItems.item(i).name).length > 1) {  //  More than one checkbox detected
                    var checkboxElements = document.getElementsByName(sbItems.item(i).name);
                    //  Begin processing for checkbox elements
                    for (var x=0; x < checkboxElements.length; x++) {
                      if (checkboxElements.item(x).checked) {
                        sbValues[checkboxElements.item(x).name] = checkboxElements.item(x).value;
                      }
                      else {
                        console.log("Not checked"); //  For debugging
                      }
                    } //  End proccessing for checkbox elements
                  }
                  else {  //  Single checkbox detected returning true or false
                    if (sbItems.item(i).checked) sbValues[sbItems.item(i).name] = "TRUE";
                    else sbValues[sbItems.item(i).name] = "FALSE";
                  }
                }
                //  Input elements which are radio type
                else if (sbItems.item(i).type == "radio") {
                  if (document.getElementsByName(sbItems.item(i).name).length > 1) {  //  More than one radio detected
                    var radioElements = document.getElementsByName(sbItems.item(i).name);
                    //  Begin processing for radio elements
                    for (var x=0; x < radioElements.length; x++) {
                      if (radioElements.item(x).checked) {
                        sbValues[radioElements.item(x).name] = radioElements.item(x).value;
                      } else {
                        console.log("Not selected");  //  For debugging
                      }
                    } //  End processing for radio elements
                  }
                  else {  //  Single radio checkbox detected returning true or false
                    if (sbItems.item(i).checked) sbValues[sbItems.item(i).name] = "TRUE";
                    else sbValues[sbItems.item(i).name] = "FALSE";
                  }
                }
                else {
                  console.log(sbITems.item(i).type);  //  For debugging
                }
              }
              //  Select elements
              sbItems = document.getElementsByTagName('select');
              for (var i=0; i < sbItems.length; i++) {
                if (sbItems.item(i).options[sbItems.item(i).selectedIndex] != undefined) {
                  sbValues[sbItems.item(i).name] = sbItems.item(i).options[sbItems.item(i).selectedIndex].value;
                }
              }

              var reqElements = document.querySelectorAll('[sbReq=true]');
              for (var i=0; i < reqElements.length; i++) {
                var key = sbValues[reqElements.item(i).name];
                if (key == null || key == undefined || key == "") {
                  throw "Not all required elements filled out";
                } else {
                  console.log("Value for "+reqElements.item(i).name+" found with "+key);
                }
              }
              return sbValues;
            }
            JSON.stringify(sb());
        """
        
        webView.evaluateJavaScript(js) {
            (data: Any?, error: Error?) in
            if error != nil {
                Log.write(string: "Error getting User Input", cat: "UserInput", level: .error)
                return
            }
            
            guard let jsonString = data as? String else {
                Log.write(string: "Cannot read User Input data", cat: "UserInput", level: .error)
                return
            }
            
            guard let jsonData = jsonString.data(using: .utf8) else {
                Log.write(string: "Cannot cast User Input to data", cat: "UserInput", level: .error)
                return
            }
            
            /*let obj = try! JSONDecoder().decode(UserInput.self, from: jsonData)
            
            if let assetTag = obj.assetTag {
                FileManager.default.createFile(atPath: "assetTag.txt", contents: assetTag.data(using: .utf8)!, attributes: nil)
            }
            
            if let computerName = obj.computerName {
                FileManager.default.createFile(atPath: "computerName.txt", contents: computerName.data(using: .utf8)!, attributes: nil)
            }*/
            
            let obj = try! JSONSerialization.jsonObject(with: jsonData, options: [])
            for item in obj as! NSDictionary {
                Log.write(string: "Writing value to \(item.key) with value of \(item.value)", cat: "UserInput", level: .debug)
                FileManager.default.createFile(atPath: "\(item.key).txt", contents: (item.value as? String ?? "").data(using: .utf8), attributes: nil)
            }
            
            DispatchQueue.main.async {
                self.sendButton.isHidden = true
                self.continueButton.isHidden = false
                
                if let html = Preferences.sharedInstance.html {
                    self.webView.loadFileURL(html, allowingReadAccessTo: Preferences.sharedInstance.assetPath)
                } else {
            self.webView.loadHTMLString(errorMsg, baseURL: nil)
                }
            }
            
            Log.write(string: "DONE: Form Javascript Evaluation", cat: .UserInput, level: .debug)
            print("Successfully completed form");

        }
    }
}
