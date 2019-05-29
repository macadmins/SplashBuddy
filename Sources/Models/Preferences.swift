//
//  Copyright © 2018-present Amaris Technologies GmbH. All rights reserved.
//

import Cocoa

/// Preferences() keeps the relevant preferences
final class Preferences {

    // MARK: - Constants

    enum Errors: Error {
        case noApplicationArray
        case malformedApplication
    }

    static let sharedInstance = Preferences()

    // MARK: - Properties

    internal var logFileHandle: FileHandle?
    public var doneParsingPlist: Bool = false

    internal let userDefaults: UserDefaults

    // MARK: - Initialization

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults

        // Do not change asset path (see comment on var assetPath: URL below)
        // TSTAssetPath is meant for unit testing only.
        if let assetPath = self.userDefaults.string(forKey: "TSTAssetPath") {
            self.assetPath = URL(fileURLWithPath: assetPath, isDirectory: true)
        } else {
            assetPath = URL(fileURLWithPath: "/Library/Application Support/SplashBuddy", isDirectory: true)
        }

        // TSTJamfLog is meant for unit testing only.
        if let jamfLogPath: String = self.userDefaults.string(forKey: "TSTJamfLog") {
            logFileHandle = Tools.getFileHandle(from: jamfLogPath)
        } else {
            logFileHandle = Tools.getFileHandle()
        }

        // Start parsing the log file

        guard let logFileHandle = self.logFileHandle else {
            Log.write(string: "Cannot check logFileHandle", cat: "Preferences", level: .error)
            return
        }

        logFileHandle.readabilityHandler = { fileHandle in
            guard let string = String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8) else {
                return
            }

            for line in string.split(separator: "\n") {
                if let software = Software(from: String(line)) {
                    DispatchQueue.main.async {
                        SoftwareArray.sharedInstance.array.modify(with: software)
                    }
                }
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
        guard let bundle = assetBundle else {
            return nil
        }

        return bundle.url(forResource: "form", withExtension: "html")
    }

    //-----------------------------------------------------------------------------------
    // MARK: - Tag files
    //-----------------------------------------------------------------------------------

    /// All softwares are installed
    var setupDone: Bool {
        get {
            return FileManager.default.fileExists(atPath: "Library/.SplashBuddyDone")
        }

        set(myValue) {
            if myValue == true {
                FileManager.default.createFile(atPath: "Library/.SplashBuddyDone", contents: nil, attributes: nil)
            } else {
                do {
                    try FileManager.default.removeItem(atPath: "Library/.SplashBuddyDone")
                } catch {
                    Log.write(string: "Couldn't remove .SplashBuddyDone",
                              cat: "Preferences",
                              level: .info)
                }
            }
        }
    }

    var formDone: Bool {
        get {
            return FileManager.default.fileExists(atPath: "Library/.SplashBuddyFormDone")
        }

        set(myValue) {
            if myValue == true {
                FileManager.default.createFile(atPath: "Library/.SplashBuddyFormDone", contents: nil, attributes: nil)
            } else {
                do {
                    try FileManager.default.removeItem(atPath: "Library/.SplashBuddyFormDone")
                } catch {
                    Log.write(string: "Couldn't remove .SplashBuddyFormDone", cat: "Preferences", level: .info)
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
        if !FileManager.default.fileExists(atPath: "/private/tmp/SplashBuddy/", isDirectory: &YES) {
            do {
                try FileManager.default.createDirectory(atPath: "/private/tmp/SplashBuddy",
                                                        withIntermediateDirectories: false,
                                                        attributes: [
                                                            .groupOwnerAccountID: 20,
                                                            .posixPermissions: 0o777
                    ])
            } catch {
                Log.write(string: "Cannot create /private/tmp/SplashBuddy/",
                          cat: "Preferences",
                          level: .error)
                fatalError("Cannot create /private/tmp/SplashBuddy/")
            }
        }
    }

    private func checkTagFile(named: TagFile) -> Bool {
        return FileManager.default.fileExists(atPath: "/private/tmp/SplashBuddy/.".appending(named.rawValue))
    }

    private func createOrDeleteTagFile(named: TagFile, create: Bool) {
        createSplashBuddyTmpIfNeeded()

        if create == true {
            if FileManager.default.createFile(atPath: "/private/tmp/SplashBuddy/.".appending(named.rawValue),
                                              contents: nil,
                                              attributes: [
                                                .groupOwnerAccountID: 20,
                                                .posixPermissions: 0o777
                ]) {
                Log.write(string: "Created .".appending(named.rawValue),
                          cat: "Preferences",
                          level: .info)
            } else {
                Log.write(string: "Couldn't create .".appending(named.rawValue), cat: "Preferences", level: .error)
                do {
                    try FileManager.default.removeItem(atPath: "Library/.SplashBuddyFormDone")
                } catch {

                }
            }

        } else {
            do {
                try FileManager.default.removeItem(atPath: "/private/tmp/SplashBuddy/.".appending(named.rawValue))
            } catch {
                Log.write(string: "Couldn't remove .".appending(named.rawValue), cat: "Preferences", level: .info)
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

    /// Generates Software objects from Preferences
    func getApplicationsFromPreferences() throws {
        guard let applicationsArray = userDefaults.array(forKey: "applicationsArray") else {
            throw Preferences.Errors.noApplicationArray
        }

        for application in applicationsArray {
            guard let application = application as? NSDictionary else {
                throw Preferences.Errors.malformedApplication
            }

            if let software = Software(from: application, assetPath: assetPath) {
                SoftwareArray.sharedInstance.array.append(software)
            }
        }

        doneParsingPlist = true
        Log.write(string: "DONE Parsing applicationsArray", cat: "Preferences", level: .debug)
    }
}
