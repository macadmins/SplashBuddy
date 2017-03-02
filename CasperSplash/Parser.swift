//
//  Parser.swift
//  CasperSplash
//
//  Created by Francois Levaux on 02.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Foundation

class Parser: NSObject {
    
    static let sharedInstance = Parser()
    
    override init() {
        super.init()
        
        // Setup Timer to parse log
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
        
        
    }
    
    func readTimer() -> Void {
        
        DispatchQueue.global(qos: .background).async {
            
            guard let logFileHandle = Preferences.sharedInstance.logFileHandle else {
                NSLog("Cannot open /var/log/jamf.log")
                return
            }
            
            guard let lines = logFileHandle.readLines() else {
                return
            }
            
            
            for line in lines {
                if let software = Software(from: line) {
                    
                    DispatchQueue.main.async {
                        SoftwareArray.sharedInstance.array.modify(with: software)
                        
                    }
                    
                }
            }
            
        }
        
    }
}
