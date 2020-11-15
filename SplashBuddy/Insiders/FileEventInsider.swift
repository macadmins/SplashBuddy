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

import Foundation

class FileEventInsider: InsiderProtocol {
    internal let userDefaults: UserDefaults
    
    let eventerPath: String
    let eventSource: DispatchSourceFileSystemObject?
    
    init(userDefaults: UserDefaults, withEventerPath eventerPath: String) {
        self.userDefaults = userDefaults
        self.eventerPath = eventerPath
        
        guard FileManager.default.fileExists(atPath: eventerPath) else {
            Log.write(string: "Source file \(eventerPath) does not exist",
                cat: "Preferences",
                level: .error)
            self.eventSource = nil
            return
        }
        
        let fileDescriptor = open(eventerPath, O_EVTONLY)
        
        guard fileDescriptor > 0 else {
            Log.write(string: "Unable to read \(eventerPath)",
                cat: "Preferences",
                level: .error)
            self.eventSource = nil
            return
        }
        
        self.eventSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .all, queue: DispatchQueue.global(qos: .background))
    }
    
    convenience init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.init(userDefaults: userDefaults, withEventerPath: "")
    }
    
    func run() throws {
        self.eventSource?.setEventHandler(handler: {
            self.handleEvent()
        })
        DispatchQueue.global(qos: .background).async {
            self.handleEvent()
        }
    }
    
    func handleEvent()  {
        return
    }
}
