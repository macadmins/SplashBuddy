//
//  SoftwareArray.swift
//  CasperSplash
//
//  Created by François Levaux on 24.11.16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class SoftwareArray: NSObject {

    static let sharedInstance = SoftwareArray()
    
    dynamic var array: [Software]
    
    override init() {
        self.array = [Software]()
    }
}
