//
//  Copyright © 2018-present Amaris Technologies GmbH. All rights reserved.
//

import AppKit

/// To have scrollers play well on a vibrant background
class TransparentScroller: NSScroller {

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.set()
        NSBezierPath(rect: dirtyRect).fill()

        self.drawKnob()
    }
}
