//
//  AppDelegate.swift
//  CasperSplash
//
//  Created by ftiff on 02/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    var softwareStatusValueTransformer: SoftwareStatusValueTransformer?
    var casperSplashController: CasperSplashController!
    var casperSplashBackgroundController: CasperSplashBackgroundController!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        
        
        // Value Transformer for Software Status
        // We use it to map the software status (.pending…) with color images (orange…) in the Software TableView
        
        softwareStatusValueTransformer = SoftwareStatusValueTransformer()
        ValueTransformer.setValueTransformer(softwareStatusValueTransformer,
                                             forName: NSValueTransformerName(rawValue: "SoftwareStatusValueTransformer"))
        
        
        
        // Create Main Controller (the front window)
        
        let storyboard = NSStoryboard(name: "CasperSplashController", bundle: nil)
        casperSplashController = storyboard.instantiateController(withIdentifier: "mainWindow") as! CasperSplashController
        casperSplashController.showWindow(self)
        
        
        
        
        // Create Background Controller (the window behind) only displays for Release
        // Change this in Edit Scheme -> Run -> Info
        
        #if !DEBUG
        casperSplashBackgroundController = storyboard.instantiateController(withIdentifier: "backgroundWindow") as! CasperSplashBackgroundController
        casperSplashBackgroundController.showWindow(self)
        #endif


        
        

    }
    

 }

