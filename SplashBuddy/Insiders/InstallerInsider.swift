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

func initInstallerRegex() throws -> [Software.SoftwareStatus: [NSRegularExpression]] {
    
    let re_options = NSRegularExpression.Options.anchorsMatchLines
    
    // Installing
    let re_installing: [NSRegularExpression]
    
    try re_installing = [NSRegularExpression(
        pattern: "(?<=PackageKit: Extracting file).*\\#([a-zA-Z0-9._]*)\\.pkg",
        options: re_options
    )]
    
    // Failure
    let re_failure: [NSRegularExpression]
    
    try re_failure = [NSRegularExpression(
        pattern: "(?<=Installation failed. The installer reported: installer: Package name is )([a-zA-Z0-9._ ]*)-([a-zA-Z0-9._]*)$",
        options: re_options
    )]
    
    // Success
    let re_success: [NSRegularExpression]
    
    try re_success = [NSRegularExpression(
        pattern: "(?<=Installed )\"([a-zA-Z0-9._ ]*)\" \\(([a-zA-Z0-9._ ]*)\\)",
        options: re_options
    )]
    
    return [
        .success: re_success,
        .failed: re_failure,
        .installing: re_installing
    ]
}

class InstallerInsider : GenericInsider {
    convenience init(userDefaults: UserDefaults = UserDefaults.standard) {
        let installerLogPath = userDefaults.string(forKey: Constants.Testing.InstallerLog) ?? Constants.Defaults.InstallerLogPath
        self.init(userDefaults: userDefaults, withLogPath: installerLogPath)
    }
    
    override func regexes() throws -> [Software.SoftwareStatus: [NSRegularExpression]] {
        return try initInstallerRegex()
    }
}
