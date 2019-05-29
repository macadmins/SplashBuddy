//
//  Copyright © 2018-present Amaris Technologies GmbH. All rights reserved.
//

import Foundation

struct Tools {

    static func initRegex() -> [Software.SoftwareStatus: NSRegularExpression?] {

        let reOptions = NSRegularExpression.Options.anchorsMatchLines

        // Installing
        let reInstalling: NSRegularExpression?

        do {
            try reInstalling = NSRegularExpression(
                pattern: "(?<=Installing )([a-zA-Z0-9._ ]*)-([a-zA-Z0-9._]*).pkg...$",
                options: reOptions
            )
        } catch {
            reInstalling = nil
        }

        // Failure
        let reFailure: NSRegularExpression?

        do {
            try reFailure = NSRegularExpression(
                pattern: "(?<=Installation failed. The installer reported: installer: Package name is )([a-zA-Z0-9._ ]*)-([a-zA-Z0-9._]*)$",
                options: reOptions
            )
        } catch {
            reFailure = nil
        }

        // Success
        let reSuccess: NSRegularExpression?

        do {
            try reSuccess = NSRegularExpression(
                pattern: "(?<=Successfully installed )([a-zA-Z0-9._ ]*)-([a-zA-Z0-9._]*).pkg",
                options: reOptions
            )
        } catch {
            reSuccess = nil
        }

        return [
            .success: reSuccess,
            .failed: reFailure,
            .installing: reInstalling
        ]
    }

    /**
     Try to get a Bool from an Any (String, Int or Bool)

     - returns:
     - True if 1, "1" or True
     - False if any other value
     - nil if cannot cast to String, Int or Bool.

     - parameter object: Any? (String, Int or Bool)
     */
    static func getBool(from object: Any?) -> Bool? {
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

    static func getFileHandle(from file: String = "/var/log/jamf.log") -> FileHandle? {
        do {
            return try FileHandle(forReadingFrom: URL(fileURLWithPath: file, isDirectory: false))
        } catch {
            Log.write(string: "Cannot read \(file)",
                cat: "Preferences",
                level: .error)
            return nil
        }
    }
}
