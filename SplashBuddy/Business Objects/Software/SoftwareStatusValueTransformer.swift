//
//  SoftwareStatusValueTransformer.swift
//  SplashBuddy
//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Cocoa

/// Used to bridge SoftwareStatus to an NSImage
class SoftwareStatusValueTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSImage.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return false
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Int else {
            return nil
        }

        switch value {
        case Software.SoftwareStatus.failed.rawValue:
            return NSImage(named: NSImage.Name(rawValue: "NSStatusUnavailable"))

        case Software.SoftwareStatus.installing.rawValue:
            return NSImage(named: NSImage.Name(rawValue: "NSStatusPartiallyAvailable"))

        case Software.SoftwareStatus.pending.rawValue:
            return NSImage(named: NSImage.Name(rawValue: "NSStatusNone"))

        case Software.SoftwareStatus.success.rawValue:
            return NSImage(named: NSImage.Name(rawValue: "NSStatusAvailable"))

        default:
            return NSImage(named: NSImage.Name(rawValue: "NSStatusNone"))
        }
    }
}
