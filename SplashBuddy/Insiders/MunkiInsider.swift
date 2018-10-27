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

class MunkiInsider : GenericInsider {
    class MunkiLineChecker: InsiderLineChecker {
        func check(line: String) throws -> Software.SoftwareStatus? {
            if line.contains(" Installing ") {
                return Software.SoftwareStatus.installing
            } else if line.contains(" Install of ") && line.contains("was successful.") {
                return Software.SoftwareStatus.success
            } else if line.lowercased().contains("failed") {
                return Software.SoftwareStatus.failed
            }
            
            return nil
        }
    }
    
    convenience init(userDefaults: UserDefaults = UserDefaults.standard) {
        let munkiLogPath = userDefaults.string(forKey: Constants.Testing.MunkiLog) ?? Constants.Defaults.MunkiLogPath
        self.init(userDefaults: userDefaults, withLogPath: munkiLogPath)
    }
    
    override func lineChecker() throws -> InsiderLineChecker {
        return MunkiLineChecker()
    }
}
