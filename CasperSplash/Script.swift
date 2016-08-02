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
    
    func execute(_ completionHandler: (isSuccessful: Bool) -> ()) {
        
        let queue = DispatchQueue(label: "io.fti.CasperSplash.Script", attributes: .qosUserInitiated, target: nil)
        
        queue.async {
            let task: Task = Task()
            task.launchPath = "/bin/bash"
            task.arguments = [self.absolutePath]
            task.terminationHandler = { task in DispatchQueue.main.async(execute: {
                if task.terminationStatus == 0 {
                    completionHandler(isSuccessful: true)
                } else {
                    completionHandler(isSuccessful: false)
                }
            })
            }
            
            task.launch()
        }
    }
}
