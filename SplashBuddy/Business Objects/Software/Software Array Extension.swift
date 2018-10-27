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

extension Array where Element: Software {

    /**
     * Update SoftwareArray from Software
     *
     * If similar element exists, update it.
     * Otherwise do nothing, we wont create undeclared and unecessary software
     **/
    mutating func updateInfo(for software: Software) {
        // If Software already exists, update status and package version

        if let index = self.index(where: {$0.packageNames == software.packageNames}) {
            self[index].status = software.status
            if let version = software.packageVersion {
                self[index].packageVersion = version
            }
        }
    }

}
