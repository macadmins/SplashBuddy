//
//  SoftwareArray.swift
//  CasperSplash
//
//  Created by Francois Levaux on 02.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa


class SoftwareArray: NSObject {
    
    static let sharedInstance = SoftwareArray()
    
    dynamic var array = [Software]()
    
}
