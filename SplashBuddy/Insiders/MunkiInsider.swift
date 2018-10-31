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

class MunkiInsider: FileEventInsider {

    convenience init(userDefaults: UserDefaults = UserDefaults.standard) {
        let reportPath = userDefaults.string(forKey: Constants.Testing.MunkiReport) ?? Constants.Defaults.MunkiReportPath
        self.init(userDefaults: userDefaults, withEventerPath: reportPath)
    }
    
    override func handleEvent() {
        guard let munkiReport = NSDictionary(contentsOfFile: eventerPath) else {
            return
        }
        
        if let itemsToInstall = munkiReport.object(forKey: "ItemsToInstall") as? [NSDictionary] {
            for itemToInstall in itemsToInstall {
                if let itemName = itemToInstall.object(forKey: "name") as? String {
                    let software = Software(packageName: itemName)
                    software.status = .installing
                    SoftwareArray.sharedInstance.updateInfo(for: software)
                }
            }
        }
        
        if let installResults = munkiReport.object(forKey: "InstallResults") as? [NSDictionary] {
            for installResult in installResults {
                if let itemName = installResult.object(forKey: "name") as? String, let installStatus = installResult.object(forKey: "status") as? Int {
                    let software = Software(packageName: itemName)
                    software.status = installStatus == 0 ? .installing : .failed
                    SoftwareArray.sharedInstance.updateInfo(for: software)
                }
            }
        }
        
        if let installedItems = munkiReport.object(forKey: "InstalledItems") as? [String] {
            for installedItem in installedItems {
                let software = Software(packageName: installedItem)
                software.status = .success
                SoftwareArray.sharedInstance.updateInfo(for: software)
            }
        }
    }
}
