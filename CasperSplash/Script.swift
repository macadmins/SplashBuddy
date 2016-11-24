//
//  Script.swift
//  CasperSplash
//
//  Created by testpilotfinal on 04/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class Script {
    let absolutePath: String
    
    init(absolutePath: String) {
        self.absolutePath = absolutePath
    }
    
    func execute(_ completionHandler: @escaping (_ isSuccessful: Bool) -> ()) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task: Process = Process()
            task.launchPath = "/bin/bash"
            task.arguments = [self.absolutePath]
            task.terminationHandler = { task in DispatchQueue.global().async {
                if task.terminationStatus == 0 {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
            }
            
            task.launch()
        }
    }
}
