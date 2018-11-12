//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Cocoa
import WebKit

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Display Front Window
        guard let window = self.window else {
            Log.write(string: "Cannot get main window", cat: "UI", level: .error)
            return
        }

        if Preferences.sharedInstance.background {
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        }

        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.canBecomeVisibleWithoutLogin = true
    }
}
