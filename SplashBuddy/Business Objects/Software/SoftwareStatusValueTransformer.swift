// SplashBuddy

/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
