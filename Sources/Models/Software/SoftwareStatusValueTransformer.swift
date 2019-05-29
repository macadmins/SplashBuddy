//
//  Copyright © 2018-present Amaris Technologies GmbH. All rights reserved.
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
            return NSImage(named: NSImage.Name(stringLiteral: "NSStatusUnavailable"))

        case Software.SoftwareStatus.installing.rawValue:
            return NSImage(named: NSImage.Name(stringLiteral: "NSStatusPartiallyAvailable"))

        case Software.SoftwareStatus.pending.rawValue:
            return NSImage(named: NSImage.Name(stringLiteral: "NSStatusNone"))

        case Software.SoftwareStatus.success.rawValue:
            return NSImage(named: NSImage.Name(stringLiteral: "NSStatusAvailable"))

        default:
            return NSImage(named: NSImage.Name(stringLiteral: "NSStatusNone"))
        }
    }
}
