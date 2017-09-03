//
//  ContinueAction.swift
//  SplashBuddy
//
//  Created by Francois Levaux on 28.07.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

struct ContinueButton {
    enum Action {
        case Restart
        case Logout
        case Shutdown
        case LaunchProgram(path: String)
        case Quit
        case Hidden
        
        static func from(string: String) -> Action {
            
            switch string.lowercased() {
                
            case "restart":
                return .Restart
                
            case "shutdown":
                return .Shutdown
                
            case "logout":
                return .Logout
                
            case "quit":
                return .Quit
                
            case "hidden":
                return .Hidden
                
            default:
                if FileManager.default.fileExists(atPath: string) {
                    return .LaunchProgram(path: string)
                } else {
                    Log.write(string: "Cannot find application at path: \(string)", cat: .ContinueButton, level: .error)
                    return .Quit
                }
                
            }
        }
        
        var localizedName: String {
            switch self {
            case .Restart: return NSLocalizedString("Restart", comment: "Label of the button for Restart")
            case .Shutdown: return NSLocalizedString("Shutdown", comment: "Label of the button for Shutdown")
            case .Logout: return NSLocalizedString("Logout", comment: "Label of the button for Logout")
            case .Quit: return NSLocalizedString("Quit", comment: "Label of the button for Quit")
            default: return NSLocalizedString("Continue", comment: "Label of the button for Continue")
                
            }
        }
        
        var isHidden: Bool {
            switch self {
            case .Hidden:
                return true
            default:
                return false
            }
        }
        var applicationPath: String? {
            switch self {
            case .LaunchProgram(let path):
                return path
            default:
                return nil
            }
        }
        
        func pressed(_ sender: AnyObject) {
            switch self {
                
                
            case .Restart:
                do {
                    try LoginWindow.restart()
                } catch {
                    Log.write(string: "Error: \(error.localizedDescription)", cat: .ContinueButton, level: .error)
                }
                
                
            case .Shutdown:
                do {
                    try LoginWindow.shutdown()
                } catch {
                    Log.write(string: "Error: \(error.localizedDescription)", cat: .ContinueButton, level: .error)
                }
                
                
            case .Logout:
                do {
                    try LoginWindow.logout()
                } catch {
                    Log.write(string: "Error: \(error.localizedDescription)", cat: .ContinueButton, level: .error)
                }
 
                
            case .Hidden:
                fallthrough
            
                
            case .Quit:
                NSApplication.shared.terminate(self)
                
                
            default:
                
                guard let applicationPath = applicationPath else {
                    Log.write(string: "Cannot get Application Path", cat: .ContinueButton, level: .error)
                    NSApplication.shared.terminate(self)
                    return
                }
                if NSWorkspace.shared.launchApplication(applicationPath) {
                    Log.write(string: "Successfully launched application \(applicationPath)", cat: .ContinueButton, level: .info)
                    NSApplication.shared.terminate(self)
                } else {
                    NSApplication.shared.terminate(self)
                    Log.write(string: "Couldn't launch application \(applicationPath)", cat: .ContinueButton, level: .error)
                }
            }
        }
    }
}
