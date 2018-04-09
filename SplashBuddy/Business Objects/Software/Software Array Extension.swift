//
//  Software Array Extension.swift
//  SplashBuddy
//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Foundation

extension Array where Element: Software {

    /**
     * Modify SoftwareArray from Software
     *
     * If similar element exists, modifies it. Otherwise adds a new element.
     **/
    mutating func modify(with software: Software) {
        // If Software already exists, replace status and package version

        if let index = self.index(where: {$0.packageName == software.packageName}) {
            self[index].status = software.status
            self[index].packageVersion = software.packageVersion
        } else {
            if let element = software as? Element {
                self.append(element)
            }
        }
    }

    /**
     * Modify SoftwareArray from a line (String)
     *
     * If similar element exists, modifies it. Otherwise adds a new element.
     **/
    mutating func modify(from line: String) {
        guard let software = Software(from: line) else {
            return // we don't care
        }

        if let index = self.index(where: {$0.packageName == software.packageName}) {
            self[index].status = software.status
            self[index].packageVersion = software.packageVersion
        } else {
            if let element = software as? Element {
                self.append(element)
            }
        }
    }
}
