//
//  Software.swift
//  CasperSplash
//
//  Created by testpilotfinal on 02/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa


class Software: Equatable {

    enum SoftwareStatus: String {
        case Installing, Success, Failed
    }

    
    let name: String
    let version: String
    var status: SoftwareStatus
    var icon: NSImage?
    
    init(name: String, version: String, status: SoftwareStatus) {
        self.name = name
        self.version = version
        self.status = status
    }
    
    
    func isEqual(rhs: Software) -> Bool {
        return self == rhs
    }
}

func == (lhs: Software, rhs: Software) -> Bool {
    return lhs.name == rhs.name && lhs.version == rhs.version && lhs.status == rhs.status
}
