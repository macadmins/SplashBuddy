//
//  Regexes.swift
//  CasperWait
//
//  Created by François on 10/02/16.
//  Copyright © 2016 François Levaux. All rights reserved.
//

import Foundation

/** 
 Initialize Regexes
 
 - returns: A Dictionary of status: regex
 */

func initRegex() -> Dictionary<Software.SoftwareStatus, NSRegularExpression?> {
    
    let re_options = NSRegularExpression.Options.anchorsMatchLines
    
    
    
    
    // Installing
    
    let re_installing: NSRegularExpression?
    
    do {
        
        try re_installing = NSRegularExpression(
            pattern: "(?<=Installing )([a-zA-Z0-9._ ]*)-([a-zA-Z0-9._]*).pkg...$",
            options: re_options
        )
        
    } catch {
        re_installing = nil
    }

    
    
    
    // Failure
    let re_failure: NSRegularExpression?
    
    do {
        
        try re_failure = NSRegularExpression(
            pattern: "(?<=Installation failed. The installer reported: installer: Package name is )([a-zA-Z0-9._ ]*)-([a-zA-Z0-9._]*)$",
            options: re_options
        )
        
    } catch {
        re_failure = nil
    }
    
    
    
    
    // Success
    let re_success: NSRegularExpression?
    
    do {
        
        try re_success = NSRegularExpression(
            pattern: "(?<=Successfully installed )([a-zA-Z0-9._ ]*)-([a-zA-Z0-9._]*).pkg",
            options: re_options
        )
        
    } catch {
        re_success = nil
    }
    
    
    
    
    return [
        .success: re_success,
        .failed: re_failure,
        .installing: re_installing
    ]
}
