//
//  Log.swift
//  SplashBuddy
//
//  Created by Morgan, Tyler on 3/3/17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Foundation
import os

/**
 Performs logging using os_log if on 10.12.x or newer, or NSLog if on older versions.
 
  - authors: Tyler Morgan
  - note: This is only going to be used until 10.11 is no longer supported in the environments.
  - version: 1.0.0
 */
class Log {
    
    enum Categories: String {
        case Software
        case Preferences
        case UserInput
        case LoginWindowEvent
        case UI
        case ContinueButton
    }
    /**
     Used in conjunction with OSLogType to produce the correct log type for OSLog, but also provide the same level of logging for NSLog as well.
     */
    enum Level: UInt8 {
        case debug = 2, error = 16, fault = 17, info = 1
    }
    /**
     Writes to the log using the correct logging methods for the OS.
     
     - parameters:
        -   string: A string that will be entered into the log
        -   cat: The category of the logging, like UI, Foundation, etc.
        -   level: The level of the logging; info, debug, error, fault. Leave blank for default logging.
     */
    static func write(string: String, cat: Categories, level: Level?) {
        let appName = "io.fti.SplashBuddy"
        if #available(OSX 10.12, *) {
            //  On only OSX 10.12 or newer
            let log = OSLog(subsystem: appName, category: cat.rawValue)
            if level == .debug {
                os_log("%{public}@", log: log, type: .debug, string)
            } else if level == .error {
                os_log("%{public}@", log: log, type: .error, string)
            } else if level == .fault {
                os_log("%{public}@", log: log, type: .fault, string)
            } else if level == .info {
                os_log("%{public}@", log: log, type: .info, string)
            } else {
                os_log("%{public}@", log: log, type: .default, string)
            }
        } else {
            // Fallback on earlier versions
            if level == .debug {
                NSLog(" [\(cat.rawValue)] DEBUG: \(string)")
            } else if level == .error {
                NSLog(" [\(cat.rawValue)] ERROR: \(string)")
            } else if level == .fault {
                NSLog(" [\(cat.rawValue)] FAULT: \(string)")
            } else if level == .info {
                NSLog(" [\(cat.rawValue)] INFO: \(string)")
            } else {
                NSLog(" [\(cat.rawValue)] \(string)")
            }
        }
    }
}
