//
//  Software.swift
//  CasperSplash
//
//  Created by testpilotfinal on 02/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa


class Software: NSObject {

    enum SoftwareStatus: String {
        
        case Installing, Success, Failed
        
    }

    let name: String
    let version: String
    var status: SoftwareStatus
    
    init(name: String, version: String, status: SoftwareStatus) {
        self.name = name
        self.version = version
        self.status = status
    }
    
}
