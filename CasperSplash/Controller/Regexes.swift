//
//  Regexes.swift
//  CasperWait
//
//  Created by François on 10/02/16.
//  Copyright © 2016 François Levaux. All rights reserved.
//

import Foundation

// Initialize Regexes
func initRegex() -> Dictionary<Software.SoftwareStatus, NSRegularExpression?> {
    let re_options = NSRegularExpressionOptions.AnchorsMatchLines
    let re_installing: NSRegularExpression?
    do {
        try re_installing = NSRegularExpression(pattern: "(?<=Installing )([a-zA-Z0-9._ ]*)-([a-zA-Z0-9._]*).pkg...$", options: re_options)
    } catch {
        re_installing = nil
    }
    
    let re_failure: NSRegularExpression?
    do {
        try re_failure = NSRegularExpression(pattern: "(?<=Installation failed. The installer reported: installer: Package name is )([a-zA-Z0-9._ ]*)-([a-zA-Z0-9._]*)$", options: re_options)
        
    } catch {
        re_failure = nil
    }
    
    let re_success: NSRegularExpression?
    do {
        try re_success = NSRegularExpression(pattern: "(?<=Successfully installed )([a-zA-Z0-9._ ]*)-([a-zA-Z0-9._]*).pkg", options: re_options)
    } catch {
        re_success = nil
    }
    return [
        Software.SoftwareStatus.Success: re_success,
        Software.SoftwareStatus.Failed: re_failure,
        Software.SoftwareStatus.Installing: re_installing
    ]
}