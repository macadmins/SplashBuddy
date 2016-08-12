//
//  SoftwareStatusValueTransformer.swift
//  CasperSplash
//
//  Created by testpilotfinal on 05/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class SoftwareStatusValueTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSImage.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(_ value: AnyObject?) -> AnyObject? {

        if let value: Int = value?.intValue {
            switch value {
            case Software.SoftwareStatus.failed.rawValue:
                return NSImage(named: "NSStatusUnavailable")
            case Software.SoftwareStatus.installing.rawValue:
                return NSImage(named: "NSStatusPartiallyAvailable")
            case Software.SoftwareStatus.pending.rawValue:
                return NSImage(named: "NSStatusNone")
            case Software.SoftwareStatus.success.rawValue:
                return NSImage(named: "NSStatusAvailable")
            default:
                return NSImage(named: "NSStatusNone")
            }
        } else {
            return nil
        }
    }
}
