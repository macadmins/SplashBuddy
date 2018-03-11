//
//  ContinueAction.swift
//  SplashBuddy
//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Cocoa

struct ContinueButton {

    /// Restart, Logout, Shutdown, Quit, Hidden or a path to an application
    enum Action {
        case restart
        case logout
        case shutdown
        case launchProgram(path: String)
        case quit
        case hidden

        static func from(string: String) -> Action {
            switch string.lowercased() {

            case "restart":
                return .restart

            case "shutdown":
                return .shutdown

            case "logout":
                return .logout

            case "quit":
                return .quit

            case "hidden":
                return .hidden

            default:
                if FileManager.default.fileExists(atPath: string) {
                    return .launchProgram(path: string)
                } else {
                    Log.write(string: "Cannot find application at path: \(string)", cat: "ContinueButton", level: .error)
                    return .quit
                }
            }
        }

        var localizedName: String {
            switch self {
            case .restart: return NSLocalizedString("Restart", comment: "Label of the button for Restart")
            case .shutdown: return NSLocalizedString("Shutdown", comment: "Label of the button for Shutdown")
            case .logout: return NSLocalizedString("Logout", comment: "Label of the button for Logout")
            case .quit: return NSLocalizedString("Quit", comment: "Label of the button for Quit")
            default: return NSLocalizedString("Continue", comment: "Label of the button for Continue")
            }
        }

        var localizedSuccessStatus: String {
            switch self {
            case .restart: return NSLocalizedString(
                "All applications were installed. Please click on Restart.",
                comment: "Everything was ok. Asking user to click on the button")

            case .shutdown: return NSLocalizedString(
                "All applications were installed. Please click on Shutdown.",
                comment: "Everything was ok. Asking user to click on the button")

            case .logout: return NSLocalizedString(
                "All applications were installed. Please click on Logout.",
                comment: "Everything was ok. Asking user to click on the button")

            case .quit: return NSLocalizedString(
                "All applications were installed. Please click on Quit.",
                comment: "Everything was ok. Asking user to click on the button")

            case .hidden: return NSLocalizedString(
                "All applications were installed. Finishing installation…",
                comment: "Everything was ok. There's no button. An automated action will happen (like force restart)")

            default: return NSLocalizedString(
                "All applications were installed. Please click on Continue.",
                comment: "Everything was ok. Asking user to click on the button")
            }
        }

        var isHidden: Bool {
            switch self {
            case .hidden:
                return true
            default:
                return false
            }
        }

        var applicationPath: String? {
            switch self {
            case .launchProgram(let path):
                return path
            default:
                return nil
            }
        }

        func pressed(_ sender: AnyObject) {
            switch self {
            case .restart:
                do {
                    try LoginWindow.restart()
                } catch {
                    Log.write(string: error.localizedDescription, cat: "ContinueAction", level: .error)
                }

            case .shutdown:
                do {
                    try LoginWindow.shutdown()
                } catch {
                    Log.write(string: error.localizedDescription, cat: "ContinueAction", level: .error)
                }

            case .logout:
                do {
                    try LoginWindow.logout()
                } catch {
                    Log.write(string: error.localizedDescription, cat: "ContinueAction", level: .error)
                }

            case .hidden, .quit:
                NSApplication.shared.terminate(self)

            default:
                guard let applicationPath = applicationPath else {
                    Log.write(string: "Cannot get Application Path", cat: "ContinueButton", level: .error)
                    NSApplication.shared.terminate(self)
                    return
                }

                if NSWorkspace.shared.launchApplication(applicationPath) {
                    Log.write(string: "Successfully launched application \(applicationPath)", cat: "ContinueButton", level: .info)
                    NSApplication.shared.terminate(self)
                } else {
                    NSApplication.shared.terminate(self)
                    Log.write(string: "Couldn't launch application \(applicationPath)", cat: "ContinueButton", level: .error)
                }
            }
        }
    }
}
