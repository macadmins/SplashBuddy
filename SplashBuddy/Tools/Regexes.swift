//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Foundation

/** 
 Initialize Regexes
 
 - returns: A Dictionary of status: regex
 */

func initRegex() -> [Software.SoftwareStatus: NSRegularExpression?] {

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
