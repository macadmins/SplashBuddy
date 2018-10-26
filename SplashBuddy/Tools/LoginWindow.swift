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

class LoginWindow {

    static func sleep() throws {
        Log.write(string: "System will Sleep", cat: "LoginWindow sendEvent", level: .info)
        try self.sendEvent(eventCode: kAESleep)
    }

    static func shutdown() throws {
        Log.write(string: "System will Shutdown", cat: "LoginWindow sendEvent", level: .info)
        try self.sendEvent(eventCode: kAEShutDown)
    }

    static func logout() throws {
        Log.write(string: "System will Logout user", cat: "LoginWindow sendEvent", level: .info)
        try self.sendEvent(eventCode: kAEReallyLogOut)
    }

    static func restart() throws {
        Log.write(string: "System will Restart", cat: "LoginWindow sendEvent", level: .info)
        try self.sendEvent(eventCode: kAERestart)
    }

    static private func sendEvent(eventCode: OSType) throws {
        // https://developer.apple.com/library/content/qa/qa1134/_index.html
        // https://stackoverflow.com/questions/37783016/sending-appleevent-fails-with-sandbox

        /*
         * You must have the following exeptions in your .entitlements file:
         *
         *  <key>com.apple.security.temporary-exception.apple-events</key>
         *  <array>
         *      <string>com.apple.loginwindow</string>
         *  </array>
         *
         */

        var kPSNOfSystemProcess = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kSystemProcess))
        var targetDesc = AEAddressDesc()
        var status = OSStatus()
        var error = OSErr()

        error = AECreateDesc(keyProcessSerialNumber, &kPSNOfSystemProcess, MemoryLayout<ProcessSerialNumber>.size, &targetDesc)

        if error != noErr {
            Log.write(string: "Error creating Desc", cat: "LoginWindow sendEvent", level: .error)
            throw NSError(domain: "AECreateDesc", code: Int(error), userInfo: nil)
        }

        var event = AppleEvent()
        error = AECreateAppleEvent(kCoreEventClass,
                                   eventCode,
                                   &targetDesc,
                                   AEReturnID(kAutoGenerateReturnID),
                                   AETransactionID(kAnyTransactionID),
                                   &event)

        if error != noErr {
            Log.write(string: "Error creating AppleEvent", cat: "LoginWindow sendEvent", level: .error)
            throw NSError(domain: "AECreateAppleEvent", code: Int(error), userInfo: nil)
        }

        AEDisposeDesc(&targetDesc)

        var reply = AppleEvent()

        status = AESendMessage(&event,
                               &reply,
                               AESendMode(kAENoReply),
                               1000)

        if status != OSStatus(0) {
            Log.write(string: "Error sending AppleEvent", cat: "LoginWindow sendEvent", level: .error)
            throw NSError(domain: "AESendMessage", code: Int(status), userInfo: nil)
        }

        AEDisposeDesc(&event)
        AEDisposeDesc(&reply)
    }
}
