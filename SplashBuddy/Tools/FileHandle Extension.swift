//
//  FileHandle Extension.swift
//  SplashBuddy
//
//  Created by Francois Levaux on 28.02.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Foundation

extension FileHandle  {
    
    /// returns an array of lines to the end of file
    func readLines() -> [String]? {
        return String(data: self.readDataToEndOfFile(), encoding: String.Encoding.utf8)?.components(separatedBy: "\n")
        
    }
}
