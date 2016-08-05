//
//  SoftwareStatusValueTransformer.swift
//  CasperSplash
//
//  Created by testpilotfinal on 05/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class SoftwareStatusValueTransformer: NSValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSImage.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {

        if let value: Int = value?.integerValue {
            switch value {
            case Software.SoftwareStatus.Failed.rawValue:
                return NSImage(imageLiteral: "NSStatusUnavailable")
            case Software.SoftwareStatus.Installing.rawValue:
                return NSImage(imageLiteral: "NSStatusPartiallyAvailable")
            case Software.SoftwareStatus.Pending.rawValue:
                return NSImage(imageLiteral: "NSStatusNone")
            case Software.SoftwareStatus.Success.rawValue:
                return NSImage(imageLiteral: "NSStatusAvailable")
            default:
                return NSImage(imageLiteral: "NSStatusNone")
            }
        } else {
            return nil
        }
    }
}
