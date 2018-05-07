//
//  NSLocalizedStringExtensions.swift
//  SplashBuddy
//
//  Created by Damien Rivet on 25.04.18.
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Foundation

public func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}
