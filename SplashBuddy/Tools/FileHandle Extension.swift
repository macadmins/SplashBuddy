//
//  FileHandle Extension.swift
//  SplashBuddy
//
//  Created by Francois Levaux on 28.02.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Foundation

extension FileHandle  {
    func readLines() -> [String]? {
        return String(data: self.readDataToEndOfFile(), encoding: String.Encoding.utf8)?.components(separatedBy: "\n")
        
    }
}
