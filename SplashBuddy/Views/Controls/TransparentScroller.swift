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

import AppKit

/// To have scrollers play well on a vibrant background
class TransparentScroller: NSScroller {

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.set()
        NSBezierPath(rect: dirtyRect).fill()

        self.drawKnob()
    }
}
