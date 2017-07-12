//
//  SBTriggerHandler.swift
//  SplashBuddy
//
//  Created by momo on 12/7/17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa
import WebKit

class SBTriggerHandler: NSObject, WKScriptMessageHandler {
    @available(OSX 10.10, *)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let triggerName = message.body as? String {
            do {
                let jamfBinary = try NSUserUnixTask(url: URL(fileURLWithPath: "/usr/local/bin/jamf"))
                jamfBinary.execute(withArguments: ["policy", "-event", triggerName]) {
                    (err: Error?) in
                    
                    
                }
            }
            catch {
                print("could not execute trigger")
            }
        }
    }
}
