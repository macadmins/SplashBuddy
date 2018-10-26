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

import Cocoa

/**
 Preferences() keeps the relevant preferences
 */
class Preferences {

    static let sharedInstance = Preferences()
    internal var logFileHandle: FileHandle?
    public var doneParsingPlist: Bool = false

    internal let userDefaults: UserDefaults
    
    internal let temporaryFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(Constants.AppName, isDirectory: true)
    internal let setupDoneURL = (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.SetupDone))!
    internal let formDoneURL = (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.FormDone))!

    public var insiderError: Bool = false
    public var insiderErrorMessage: String = ""
    public var insiderErrorInfo: String = ""
    
    //-----------------------------------------------------------------------------------
    // MARK: - INIT
    //-----------------------------------------------------------------------------------

    init(nsUserDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = nsUserDefaults
        
        // Do not change asset path (see comment on var assetPath: URL below)
        // TSTAssetPath is meant for unit testing only.
        if let assetPath = self.userDefaults.string(forKey: Constants.Testing.Asset) {
            self.assetPath = URL(fileURLWithPath: assetPath, isDirectory: true)
        } else {
            self.assetPath = (FileManager.default.urls(for: .applicationSupportDirectory, in: .localDomainMask).first?.appendingPathComponent(Constants.AppName, isDirectory: true))!
        }
        
        if self.userDefaults.bool(forKey: Constants.Insiders.JAMF) {
            DispatchQueue.global(qos: .background).async {
                let insider = JAMFInsider(nsUserDefaults: self.userDefaults)
                guard insider.logFileHandle != nil else {
                    self.insiderError = true
                    self.insiderErrorMessage = "Jamf is not installed correctly"
                    self.insiderErrorInfo = "/var/log/jamf.log is missing"
                    return
                }
                insider.run()
            }
        }
    }

    //-----------------------------------------------------------------------------------
    // MARK: - Asset Path
    //-----------------------------------------------------------------------------------

    /**
     * Returns the path to all the assets used by SplashBuddy
     *
     * - important: If you decide to change the asset path, make sure you update the entitlements,
     * or the WKWebView will display white.
     */
    var assetPath: URL

    //-----------------------------------------------------------------------------------
    // MARK: - Continue Button
    //-----------------------------------------------------------------------------------

    /**
     * Action when the user clicks on the continue button
     *
     * It can either be:
     * - Restart
     * - Logout
     * - Shutdown
     * - Quit
     * - Hidden
     * - a path to an application (eg. `/Applications/Safari.app`)
     */
    public var continueAction: ContinueButton.Action {
        let action: String = self.userDefaults.string(forKey: "continueAction") ?? "quit"
        return ContinueButton.Action.from(string: action)
    }

    //-----------------------------------------------------------------------------------
    // MARK: - Options
    //-----------------------------------------------------------------------------------

    /// set to `true` to hide sidebar
    public var sidebar: Bool {
        return self.userDefaults.bool(forKey: "hideSidebar")
    }

    /// set to `true` to hide background behind main window (for debugging)
    public var background: Bool {
        return !self.userDefaults.bool(forKey: "hideBackground")
    }

    /// set to `true` to enable Big Notification
    public var labMode: Bool {
        return self.userDefaults.bool(forKey: "labMode")
    }

    //-----------------------------------------------------------------------------------
    // MARK: - HTML Path
    //-----------------------------------------------------------------------------------

    /**
     * Returns the path to the HTML bundle
     *
     * - important: If you decide to change the asset path, make sure you update the entitlements,
     * or the WKWebView will display white.
     */
    public var assetBundle: Bundle? {
        return Bundle.init(url: self.assetPath.appendingPathComponent("presentation.bundle"))
    }

    /// Returns `index.html` with the right localization
    public var html: URL? {
        return self.assetBundle?.url(forResource: "index", withExtension: "html")
    }

    /// Returns `complete.html` with the right localization
    public var labComplete: URL? {
        return self.assetBundle?.url(forResource: "complete", withExtension: "html")
    }

    public var form: URL? {
        return self.assetBundle?.url(forResource: "form", withExtension: "html")
    }

    //-----------------------------------------------------------------------------------
    // MARK: - Tag files
    //-----------------------------------------------------------------------------------

    /// All softwares are installed
    var setupDone: Bool {
        get {
            return FileManager.default.fileExists(atPath: self.setupDoneURL.path)
        }

        set(myValue) {
            if myValue == true {
                FileManager.default.createFile(atPath: self.setupDoneURL.path, contents: nil, attributes: nil)
            } else {
                do {
                    try FileManager.default.removeItem(atPath: self.setupDoneURL.path)
                } catch {
                    Log.write(string: "Couldn't remove \(self.setupDoneURL.path))",
                              cat: "Preferences",
                              level: .info)
                }
            }
        }
    }

    var formDone: Bool {
        get {
            return FileManager.default.fileExists(atPath: self.formDoneURL.path)
        }

        set(myValue) {
            if myValue == true {
                FileManager.default.createFile(atPath: self.formDoneURL.path, contents: nil, attributes: nil)
            } else {
                do {
                    try FileManager.default.removeItem(atPath: self.formDoneURL.path)
                } catch {
                    Log.write(string: "Couldn't remove \(self.formDoneURL.path)", cat: "Preferences", level: .info)
                }
            }
        }
    }

    private enum TagFile: String {
        case criticalDone = "CriticalDone"
        case errorWhileInstalling = "ErrorWhileInstalling"
        case allInstalled = "AllInstalled"
        case allSuccessfullyInstalled = "AllSuccessfullyInstalled"
    }

    private func createSplashBuddyTmpIfNeeded() {
        var YES: ObjCBool = true
        if !FileManager.default.fileExists(atPath: self.temporaryFolderURL.path, isDirectory: &YES) {
            do {
                try FileManager.default.createDirectory(at: self.temporaryFolderURL,
                                                        withIntermediateDirectories: false,
                                                        attributes: [
                                                            .groupOwnerAccountID: 20,
                                                            .posixPermissions: 0o777
                    ])
            } catch {
                Log.write(string: "Cannot create \(self.temporaryFolderURL.path)",
                          cat: "Preferences",
                          level: .error)
                fatalError("Cannot create \(self.temporaryFolderURL.path)")
            }
        }
    }

    private func checkTagFile(named: TagFile) -> Bool {
        return FileManager.default.fileExists(atPath: self.temporaryFolderURL.appendingPathComponent(named.rawValue).path)
    }

    private func createOrDeleteTagFile(named: TagFile, create: Bool) {
        createSplashBuddyTmpIfNeeded()

        let filePath = self.temporaryFolderURL.appendingPathComponent(named.rawValue).path
        if create == true {
            if FileManager.default.createFile(atPath: filePath,
                                              contents: nil,
                                              attributes: [
                                                .groupOwnerAccountID: 20,
                                                .posixPermissions: 0o777
                ]) {
                Log.write(string: "Created \(filePath)",
                          cat: "Preferences",
                          level: .info)
            } else {
                Log.write(string: "Couldn't create \(filePath)", cat: "Preferences", level: .error)
                do {
                    try FileManager.default.removeItem(atPath: self.formDoneURL.path)
                } catch {

                }
            }

        } else {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                Log.write(string: "Couldn't remove \(filePath)", cat: "Preferences", level: .info)
            }
        }
    }

    /// All critical softwares are installed
    var criticalDone: Bool {
        get {
            return checkTagFile(named: .criticalDone)
        }

        set(myValue) {
            createOrDeleteTagFile(named: .criticalDone, create: myValue)
        }
    }

    /// Errors while installing
    var errorWhileInstalling: Bool {
        get {
            return checkTagFile(named: .errorWhileInstalling)
        }

        set(myValue) {
            createOrDeleteTagFile(named: .errorWhileInstalling, create: myValue)
        }
    }

    /// all software is installed (failed or success)
    var allInstalled: Bool {
        get {
            return checkTagFile(named: .allInstalled)
        }

        set(myValue) {
            createOrDeleteTagFile(named: .allInstalled, create: myValue)
        }
    }

    /// all software is sucessfully installed
    var allSuccessfullyInstalled: Bool {
        get {
            return checkTagFile(named: .allSuccessfullyInstalled)
        }

        set(myValue) {
            createOrDeleteTagFile(named: .allSuccessfullyInstalled, create: myValue)
        }
    }

    //-----------------------------------------------------------------------------------
    // MARK: - Software
    //-----------------------------------------------------------------------------------

    func extractSoftware(from dict: NSDictionary) -> Software? {
        guard let name = dict["packageName"] as? String else {
            Log.write(string: "Error reading name from an application in io.fti.SplashBuddy",
                      cat: "Preferences",
                      level: .error)
            return nil
        }

        guard let displayName: String = dict["displayName"] as? String else {
            Log.write(string: "Error reading displayName from application \(name) in io.fti.SplashBuddy",
                cat: "Preferences",
                level: .error)
            return nil
        }

        guard let description: String = dict["description"] as? String else {
            Log.write(string: "Error reading description from application \(name) in io.fti.SplashBuddy",
                cat: "Preferences",
                level: .error)
            return nil
        }

        guard let iconRelativePath: String = dict["iconRelativePath"] as? String else {
            Log.write(string: "Error reading iconRelativePath from application \(name) in io.fti.SplashBuddy",
                cat: "Preferences",
                level: .error)
            return nil
        }

        guard let canContinueBool: Bool = getBool(from: dict["canContinue"]) else {
            Log.write(string: "Error reading canContinueBool from application \(name) in io.fti.SplashBuddy",
                cat: "Preferences",
                level: .error)
            return nil
        }

        let iconPath = self.assetPath.appendingPathComponent(iconRelativePath).path

        return Software(packageName: name,
                        version: nil,
                        status: .pending,
                        iconPath: iconPath,
                        displayName: displayName,
                        description: description,
                        canContinue: canContinueBool,
                        displayToUser: true)
    }

    /**
     Try to get a Bool from an Any (String, Int or Bool)
     
     - returns: 
     - True if 1, "1" or True
     - False if any other value
     - nil if cannot cast to String, Int or Bool.
     
     - parameter object: Any? (String, Int or Bool)
     */
    func getBool(from object: Any?) -> Bool? {
        // In practice, canContinue is sometimes seen as int, sometimes as String
        // This workaround helps to be more flexible

        if let canContinue = object as? Int {
            return (canContinue == 1)
        } else if let canContinue = object as? String {
            return (canContinue == "1")
        } else if let canContinue = object as? Bool {
            return canContinue
        }

        return nil
    }

    enum Errors: Error {
        case noApplicationArray
        case malformedApplication
    }

    /// Generates Software objects from Preferences
    func getPreferencesApplications() throws {
        guard let applicationsArray = self.userDefaults.array(forKey: "applicationsArray") else {
            throw Preferences.Errors.noApplicationArray
        }

        for application in applicationsArray {
            guard let application = application as? NSDictionary else {
                throw Preferences.Errors.malformedApplication
            }
            if let software = extractSoftware(from: application) {
                SoftwareArray.sharedInstance.array.append(software)
            }
        }

        self.doneParsingPlist = true
        Log.write(string: "DONE Parsing applicationsArray", cat: "Preferences", level: .debug)
    }
}
