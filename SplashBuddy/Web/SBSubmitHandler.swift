//
//  SBSubmitHandler.swift
//  SplashBuddy
//
//  Created by momo on 12/7/17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa
import WebKit

class SBSubmitHandler: NSObject, WKScriptMessageHandler {
    @available(OSX 10.10, *)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let jsonString = message.body as? String else {
            Log.write(string: "Cannot read User Input data", cat: "UserInput", level: .error)
            return
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            Log.write(string: "Cannot cast User Input to data", cat: "UserInput", level: .error)
            return
        }
        
        let obj = try! JSONDecoder().decode(UserInput.self, from: jsonData)
        
        if let assetTag = obj.assetTag {
            FileManager.default.createFile(atPath: "assetTag.txt", contents: assetTag.data(using: .utf8)!, attributes: nil)
        }
        
        if let computerName = obj.computerName {
            FileManager.default.createFile(atPath: "computerName.txt", contents: computerName.data(using: .utf8)!, attributes: nil)
        }
        
        if let assetTag = obj.assetTag, let computerName = obj.computerName {
          NotificationCenter.default.post(name: NSNotification.Name("formSubmitted"), object: self, userInfo: ["assetTag": assetTag, "computerName": computerName])
        }
        
        

    }
}
