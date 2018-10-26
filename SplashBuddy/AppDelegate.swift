// SplashBuddy

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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var softwareStatusValueTransformer: SoftwareStatusValueTransformer?
    var mainWindowController: MainWindowController!
    var windows = [NSWindow]()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // For continue button Restart, Shutdown and Logout.
        NSApp.disableRelaunchOnLogin()

        // Value Transformer for Software Status
        // We use it to map the software status (.pending…) with color images (orange…) in the Software TableView

        softwareStatusValueTransformer = SoftwareStatusValueTransformer()
        ValueTransformer.setValueTransformer(softwareStatusValueTransformer,
                                             forName: NSValueTransformerName(rawValue: "SoftwareStatusValueTransformer"))

        // Create Background Controller (the window behind)
        // Hide it with `SplashBuddy.app/Contents/MacOS/SplashBuddy -hideBackground true`

        if Preferences.sharedInstance.background {
            for screen in NSScreen.screens {
                let view = NSVisualEffectView()
                view.blendingMode = .behindWindow
                view.material = .dark
                view.state = .active

                let window = NSWindow(contentRect: screen.frame,
                                      styleMask: .fullSizeContentView,
                                      backing: .buffered,
                                      defer: true)
                window.backgroundColor = .white
                window.contentView = view
                window.makeKeyAndOrderFront(self)
                window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)) - 1)
                windows.append(window)
            }

            NSApp.hideOtherApplications(self)
            NSApp.presentationOptions = [ .disableProcessSwitching,
                                         .hideDock,
                                         .hideMenuBar,
                                         .disableForceQuit,
                                         .disableSessionTermination ]
        }

        // Get preferences from UserDefaults
        do {
            try Preferences.sharedInstance.getPreferencesApplications()
        } catch Preferences.Errors.malformedApplication {
            Log.write(string: "applicationsArray: application is malformed",
                    cat: "Preferences",
                    level: .error)
        } catch Preferences.Errors.noApplicationArray {
            Log.write(string: "Couldn't find applicationsArray in io.fti.SplashBuddy",
                      cat: "Preferences",
                      level: .error)
        } catch {
            Log.write(string: "Unknown error while reading Applications",
                      cat: "Preferences",
                      level: .error)
        }

        // Clear all global tag files
        Preferences.sharedInstance.allInstalled = false
        Preferences.sharedInstance.allSuccessfullyInstalled = false
        Preferences.sharedInstance.criticalDone = false
        Preferences.sharedInstance.errorWhileInstalling = false
    }

    @IBAction func quitAndSetSBDone(_ sender: Any) {
        Preferences.sharedInstance.setupDone = true
        NSApp.terminate(self)
    }
}
