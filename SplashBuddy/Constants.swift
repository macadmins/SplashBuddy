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

struct Constants {
    static let AppName = "SplashBuddy"
    static let SetupDone = ".\(Constants.AppName)Done"
    static let FormDone = ".\(Constants.AppName)FormDone"
    
    struct Insiders {
        static let JAMF = "JAMFInsider"
    }
    
    struct Defaults {
        static let JAMFLogPath = "/var/log/jamf.log"
    }
    
    struct Testing {
        static let Asset = "TSTAssetPath"
        static let JAMFLog = "TSTJamfLog"
    }
}
