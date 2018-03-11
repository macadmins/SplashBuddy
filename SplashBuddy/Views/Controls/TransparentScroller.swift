//
//  TransparentScroller.swift
//  SplashBuddy
//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
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
