//
//  Copyright © 2018-present Amaris Technologies GmbH. All rights reserved.
//

import Cocoa
import WebKit

class MainViewController: NSViewController, NSTableViewDataSource {

    private let evaluationJavascript = """
            function sb() {
              var sbValues = {}; // Init empty array
              /*
              -----------------------
              | Input Processing    |
              -----------------------
              Supported inputs:
              - Single Checkbox
              - Group Checkbox
              - Radio
              - Text
              */
              var sbItems = document.getElementsByTagName('input');
              for (var i = 0; i < sbItems.length; i++) {
                //  Input items that are text type
                var currentItem = sbItems.item(i);
                if (currentItem.type == "text") {
                  sbValues[currentItem.name] = currentItem.value;
                }
                //  Input items that are checkbox
                else if (currentItem.type == "checkbox") {
                  //  Checks if more than one checkbox is in a group.
                  if (document.getElementsByName(currentItem.name).length > 1) {
                    var checkboxElements = document.getElementsByName(currentItem.name);
                    //  Begin processing checkbox items
                    for (var x = 0; x < checkboxElements.length; x++) {
                      if (checkboxElements.item(x).checked) {
                        sbValues[checkboxElements.item(x).name] = checkboxElements.item(x).value;
                      } else {
                        console.log("Not checked"); //  for debugging
                      }
                    }
                    //  End processing items
                  } else {
                    //  Single checkbox detected
                    if (currentItem.getAttribute('sbbool') == "true") {
                      if (currentItem.checked) sbValues[currentItem.name] = "TRUE";
                      else sbValues[currentItem.name] = "FALSE";
                    } else {
                      if (currentItem.checked) sbValues[currentItem.name] = currentItem.value;
                    }
                  }
                }
                //  Input items that are radios
                else if (currentItem.type == "radio") {
                  if (document.getElementsByName(currentItem.name).length > 1) {
                    var radioElements = document.getElementsByName(currentItem.name);
                    //  Begin processing for radio elements
                    for (var x = 0; x < radioElements.length; x++) {
                      if (radioElements.item(x).checked) {
                        sbValues[radioElements.item(x).name] = radioElements.item(x).value;
                      } else {
                        console.log("Not selected");
                      }
                    }
                    //  End processing items
                  } else {
                    if (currentItem.getAttribute('sbbool') == "true") {
                      if (currentItem.checked) sbValues[currentItem.name] = "TRUE";
                      else sbValues[currentItem.name] = "FALSE";
                    } else {
                      if (currentItem.checked) sbValues[currentItem.name] = currentItem.value
                    }
                  }
                } else {
                  console.log(currentItem.type);
                }
              }
              /*
              ---------------------
              | Select processing |
              ---------------------
              Processes the Select elements for the selected Option tag
              */
              sbItems = document.getElementsByTagName('select');
              for (var i = 0; i < sbItems.length; i++) {
                if (sbItems.item(i).options[sbItems.item(i).selectedIndex] != undefined) {
                  var value = sbItems.item(i).options[sbItems.item(i).selectedIndex].getAttribute('value');
                  if (value != undefined && value != "") sbValues[sbItems.item(i).name] = value;
                }
              }

              /*
              ---------------------
              | Requirement Check |
              ---------------------
              Checks to see if the required elements are filled by the "sbReq" attribute
              */
              var reqElements = document.querySelectorAll('[sbReq=true]');
              for (var i = 0; i < reqElements.length; i++) {
                var key = sbValues[reqElements.item(i).name];
                if (key == null || key == undefined || key == "") {
                  throw "Not all required elements filled out";
                } else {
                  console.log("Value for " + reqElements.item(i).name + " found with " + key);
                }
              }

              return sbValues;
            }
            JSON.stringify(sb());
        """

    @IBOutlet var webView: WKWebView!
    @IBOutlet var stackView: NSStackView!
    @IBOutlet weak var indeterminateProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var continueButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet var mainView: NSView!
    @IBOutlet weak var statusView: NSView!
    @IBOutlet weak var sidebarView: NSView!

    var sendButton = NSButton(title: NSLocalizedString("btn.send"), target: self, action: nil)

    // Predicate used by Storyboard to filter which software to display
    @objc let predicate = NSPredicate(format: "displayToUser = true")

    private let enterKeyJS = """
    window.onload = function() {
        document.body.onkeydown = function(e) {
            if (e.keyCode == "13") {
                window.location.href = "formdone://";
            }
        }
    }
    """

    internal func formEnterKey() {
        evalForm(sendButton)
    }

    override func awakeFromNib() {
        // https://developer.apple.com/library/content/qa/qa1871/_index.html

        if representedObject == nil {
            representedObject = SoftwareArray.sharedInstance
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupLayout()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

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
        setupInstalling()

        // Display Alert if /var/log/jamf.log doesn't exist
        guard Preferences.sharedInstance.logFileHandle != nil else {
            if let currentWindow = view.window {
                let alert = NSAlert()

                alert.alertStyle = .critical
                alert.messageText = "Jamf is not installed correctly"
                alert.informativeText = "/var/log/jamf.log is missing"
                alert.addButton(withTitle: "Quit")
                alert.beginSheetModal(for: currentWindow) { [unowned self] _ in
                    self.pressedContinueButton(self)
                }
            }

            return
        }

        // Display the html file
        if Preferences.sharedInstance.form != nil && !Preferences.sharedInstance.formDone {
            guard let form = Preferences.sharedInstance.form else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.sendButton.isHidden = false
                strongSelf.continueButton.isHidden = true
            }

            webView.loadFileURL(form, allowingReadAccessTo: Preferences.sharedInstance.assetPath)

            Log.write(string: "Injecting Javascript.", cat: "UserInput", level: .debug)

            webView.evaluateJavaScript(self.enterKeyJS, completionHandler: nil)
        } else if let html = Preferences.sharedInstance.html {
            if Preferences.sharedInstance.formDone {
                Log.write(string: "Form already completed.", cat: "UserInput", level: .debug)
            }

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.continueButton.isHidden = Preferences.sharedInstance.continueAction.isHidden
            }

            webView.loadFileURL(html, allowingReadAccessTo: Preferences.sharedInstance.assetPath)
        } else {
            webView.loadHTMLString(NSLocalizedString("error.create_missing_bundle"), baseURL: nil)
        }
    }

    // MARK: - Functions

    func setupViews() {
        // Main view
        mainView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        mainView.layer?.cornerRadius = 10
        mainView.layer?.shadowRadius = 2
        mainView.layer?.borderWidth = 0.2

        // Web view
        webView.layer?.isOpaque = true

        // Continue Button
        continueButton.title = Preferences.sharedInstance.continueAction.localizedName

        // Send button
        sendButton.isHidden = true
        sendButton.action = #selector(evalForm)
        view.addSubview(sendButton)
    }

    func setupLayout() {
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(equalTo: stackView.trailingAnchor),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor)
        ])
    }

    @IBAction func evalForm(_ sender: Any) {
        webView.evaluateJavaScript(evaluationJavascript) { [weak self] (data: Any?, error: Error?) in
            guard let strongSelf = self else { return }

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

            guard let obj = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? NSDictionary else {
                return
            }

            for item in obj {
                Log.write(string: "Writing value to \(item.key) with value of \(item.value)", cat: "UserInput", level: .debug)
                FileManager.default.createFile(atPath: "\(item.key).txt", contents: (item.value as? String ?? "").data(using: .utf8), attributes: nil)
            }

            DispatchQueue.main.async {
                strongSelf.sendButton.isHidden = true
                strongSelf.continueButton.isHidden = false

                if let html = Preferences.sharedInstance.html {
                    strongSelf.webView.loadFileURL(html, allowingReadAccessTo: Preferences.sharedInstance.assetPath)
                } else {
                    strongSelf.webView.loadHTMLString(NSLocalizedString("error.create_missing_bundle"), baseURL: nil)
                }
            }

            Log.write(string: "DONE: Form Javascript Evaluation", cat: "UI", level: .debug)
            Log.write(string: "Form complete, writing to .SplashBuddyFormDone", cat: "UI", level: .debug)
            Preferences.sharedInstance.formDone = true
        }
    }
}
