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

class GenericInsider {
    internal let userDefaults: UserDefaults
    let logFileHandle: FileHandle?
    
    let logPath: String
    
    init(userDefaults: UserDefaults, withLogPath logPath: String) {
        self.userDefaults = userDefaults
        self.logPath = logPath
        
        // TSTJamfLog is meant for unit testing only.
        do {
            self.logFileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: logPath, isDirectory: false))
        } catch {
            Log.write(string: "Cannot read \(logPath)",
                cat: "Preferences",
                level: .error)
            self.logFileHandle = nil
        }
    }
    
    convenience init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.init(userDefaults: userDefaults, withLogPath: "")
    }
    
    func run() {
        guard let logFileHandle = self.logFileHandle else {
            Log.write(string: "Cannot check logFileHandle", cat: "Preferences", level: .error)
            return
        }
        
        logFileHandle.readabilityHandler = { fileHandle in
            let data = fileHandle.readDataToEndOfFile()
            
            guard let string = String(data: data, encoding: .utf8) else {
                return
            }
            
            for line in string.split(separator: "\n") {
                if let software = Software(from: String(line), with: self.regexes()) {
                    DispatchQueue.main.async {
                        SoftwareArray.sharedInstance.array.modify(with: software)
                    }
                }
            }
        }
    }
    
    func regexes() -> [Software.SoftwareStatus: NSRegularExpression?] {
        return [Software.SoftwareStatus: NSRegularExpression?]()
    }
}
