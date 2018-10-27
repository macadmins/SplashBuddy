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

class InstallerInsider : GenericInsider {
    class InstallerLineChecker: InsiderLineChecker {
        func check(line: String) throws -> Software.SoftwareStatus? {
            if (line.contains("PackageKit: Extracting file")) {
                return Software.SoftwareStatus.installing
            } else if (line.contains(" Installed ")) {
                return Software.SoftwareStatus.success
            } else if (line.contains("PackageKit: Install Failed")) {
                return Software.SoftwareStatus.failed
            }
            
            return nil
        }
    }
    
    convenience init(userDefaults: UserDefaults = UserDefaults.standard) {
        let installerLogPath = userDefaults.string(forKey: Constants.Testing.InstallerLog) ?? Constants.Defaults.InstallerLogPath
        self.init(userDefaults: userDefaults, withLogPath: installerLogPath)
    }
    
    override func lineChecker() throws -> InsiderLineChecker {
        return InstallerLineChecker()
    }
}
