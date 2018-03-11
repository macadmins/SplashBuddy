//
//  SoftwareArray.swift
//  SplashBuddy
//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Cocoa

class SoftwareArray: NSObject {

    static let sharedInstance = SoftwareArray()

    @objc dynamic var array = [Software]() {
        didSet {
            self.checkSoftwareStatus()
        }
    }

    enum StateNotification: String {

        /// An error was detected (even if software is not in `applicationArray`)
        case errorWhileInstalling

        /// All critical software were installed
        case canContinue

        /// All software were installed (either failed or success)
        case doneInstalling

        /// All software were installed successfully
        case allSuccess

        /// SplashBuddy will start processing the log
        case setupInstalling

        /// SplashBuddy is processing the log
        case processing

        var notification: Notification.Name {
            return Notification.Name(rawValue: self.rawValue)
        }
    }

    /// Returns a localized error or nil if no error
    var localizedErrorStatus: String? {
        let _failedSoftwareArray = SoftwareArray.sharedInstance.failedSoftwareArray()

        if _failedSoftwareArray.count == 1 {

            if let failedDisplayName = _failedSoftwareArray[0].displayName {
                return String.localizedStringWithFormat(NSLocalizedString(
                    "%@ failed to install. Support has been notified.",
                    comment: "A specific application failed to install"), failedDisplayName)

            } else {
                return NSLocalizedString(
                    "An application failed to install. Support has been notified.",
                    comment: "One (unnamed) application failed to install")
            }
        } else if _failedSoftwareArray.count > 1 {
            return NSLocalizedString(
                "Some applications failed to install. Support has been notified.",
                comment: "More than one application failed to install")

        } else {
            return nil
        }
    }

    internal func failedSoftwareArray(_ array: [Software] = SoftwareArray.sharedInstance.array) -> [Software] {
        return array.filter({ $0.status == .failed })
    }

    internal func canContinue(_ array: [Software] = SoftwareArray.sharedInstance.array) -> Bool {
        guard Preferences.sharedInstance.doneParsingPlist == true else {
            return false
        }

        let criticalSoftwareArray = array.filter({ $0.canContinue == false })

        return criticalSoftwareArray.filter({ $0.status == .success }).count == criticalSoftwareArray.count
    }

    internal func allDone(_ array: [Software] = SoftwareArray.sharedInstance.array) -> Bool {
        let displayedSoftwareArray = array.filter({ $0.displayToUser == true })
        return displayedSoftwareArray
            .filter({ $0.status == .success || $0.status == .failed })
            .count == displayedSoftwareArray.count
    }

    /// Check SoftwareArray and send the relevant notifications
    func checkSoftwareStatus() {
        if self.canContinue() {
            NotificationCenter.default.post(name: SoftwareArray.StateNotification.canContinue.notification, object: nil)
        }

        if self.allDone() {
            NotificationCenter.default.post(name: SoftwareArray.StateNotification.doneInstalling.notification, object: nil)

            if self.failedSoftwareArray().isEmpty {
                NotificationCenter.default.post(name: SoftwareArray.StateNotification.allSuccess.notification, object: nil)
                return
            }
        }

        var notificationName: NSNotification.Name
        if !self.failedSoftwareArray().isEmpty {
            notificationName = SoftwareArray.StateNotification.errorWhileInstalling.notification
        } else {
            notificationName = SoftwareArray.StateNotification.processing.notification
        }

        NotificationCenter.default.post(name: notificationName, object: nil)
    }
}
