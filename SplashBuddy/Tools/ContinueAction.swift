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
            case .restart: return NSLocalizedString("btn.restart")
            case .shutdown: return NSLocalizedString("btn.shutdown")
            case .logout: return NSLocalizedString("btn.logout")
            case .quit: return NSLocalizedString("btn.quit")
            default: return NSLocalizedString("btn.continue")
            }
        }

        var localizedSuccessStatus: String {
            switch self {
            case .restart: return NSLocalizedString("actions.apps_installed_restart")

            case .shutdown: return NSLocalizedString("actions.apps_installed_shutdown")

            case .logout: return NSLocalizedString("actions.apps_installed_logout")

            case .quit: return NSLocalizedString("actions.apps_installed_quit")

            case .hidden: return NSLocalizedString("actions.apps_installed_finishing")

            default: return NSLocalizedString("actions.apps_installed_continue")
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
