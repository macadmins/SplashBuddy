//
//  HelperAuthorization.swift
//  CasperSplash
//
//  Created by Morgan, Tyler on 12/19/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Foundation

//
//  HelperAuthorization.swift
//  priv-helper-demo
//
//  Created by Morgan, Tyler on 12/19/16.
//  Copyright © 2016 Morgan, Tyler. All rights reserved.
//

import Foundation
import ServiceManagement

struct CommandKeyAuth {
    static let commandName = "authRightName"
    static let commandDefault = "authRightDefault"
    static let commandDescription = "authRightDescription"
}

class HelperAuthorization: NSObject {
    
    func commandInfo() -> Dictionary<String, Any> {
        let adminRights = kAuthorizationRuleAuthenticateAsAdmin
        let sCommandInfo: [String:Dictionary<String,Any>] =
            [
                NSStringFromSelector(#selector(HelperProtocol.setAssetTag(asset_tag:)))  :
                    [CommandKeyAuth.commandName : "io.fti.CasperSplash.helper.setAssetTag", CommandKeyAuth.commandDefault : adminRights, CommandKeyAuth.commandDescription: "TheDescription"]
        ]
        return sCommandInfo
    }
    
    func authorizationRightForCommand(selectorString:String) -> String {
        // TO FIX
        return selectorString
    }
    
    func authorizeHelper() -> NSData? {
        
        var status:OSStatus
        var authData: NSData
        var authRef:AuthorizationRef?
        var authRefExtForm:AuthorizationExternalForm = AuthorizationExternalForm.init()
        
        //  Create empty authRef
        status = AuthorizationCreate(nil, nil, AuthorizationFlags(), &authRef)
        if (status != OSStatus(errAuthorizationSuccess)){
            print("AuthorizationCreate failed.")
            return nil;
        }
        
        status = AuthorizationMakeExternalForm(authRef!, &authRefExtForm)
        if ((authRef) != nil){
            self.setupAuthorizationRights(authRef: authRef!)
        }
        
        authData = NSData.init(bytes: &authRefExtForm, length: kAuthorizationExternalFormLength)
        if ((authRef) != nil){
            self.setupAuthorizationRights(authRef: authRef!)
        }
        return authData
    }
    
    func checkAuthorization(authData: NSData?) -> Bool{
        /* THIS IS WHERE I'M WORKING CURRENTLY
         var status:OSStatus
         var authRef:AuthorizationRef?
         
         if authData?.length == 0 || authData?.length != kAuthorizationExternalFormLength {
         print("authData is wrong")
         return false
         }
         
         // create array of appropriate length:
         var array = [Int8](repeating: 0, count: kAuthorizationExternalFormLength)
         
         // copy bytes into array
         authData?.getBytes(&array, length:kAuthorizationExternalFormLength * MemoryLayout<AuthorizationExternalForm>.size)
         
         var tuple = UnsafeMutablePointer<(Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)>.allocate(capacity: 1)
         memcpy(tuple, array, array.count)
         
         var authRefExtForm:AuthorizationExternalForm = AuthorizationExternalForm.init(bytes: tuple)
         
         status = AuthorizationCreateFromExternalForm(&authRefExtForm, &authRef)
         if (status == errAuthorizationSuccess) {
         print("Worked")
         }
         
         print("checkingAuthorization")
         */
        return true
    }
    
    func setupAuthorizationRights(authRef: AuthorizationRef) -> Void {
        self.enumerateAuthorizationRights(right: {
            commandName, commandDefault, commandDescription in
            
            var status: OSStatus
            var currentRight: CFDictionary?
            
            status = AuthorizationRightGet((commandName as NSString).utf8String!, &currentRight)
            if (status == errAuthorizationDenied){
                
                status = AuthorizationRightSet(authRef, (commandName as NSString).utf8String!, commandDefault as! CFString, commandDescription as CFString, nil, "Common" as! CFString)
                
                if (status != errAuthorizationSuccess) {
                    let errorMessage = SecCopyErrorMessageString(status, nil)
                    print(errorMessage ?? "Error adding authorization right: \(commandName)")
                }
            }
        })
    }
    
    func enumerateAuthorizationRights(right: (_ commandName: String, _ commandDefault: Any, _ commandDescription: String) -> ()) {
        for commandInfoDict in self.commandInfo().values {
            
            guard let commandDict = commandInfoDict as? Dictionary<String, Any> else {
                print("Not a dict!")
                return
            }
            
            guard let commandName = commandDict[CommandKeyAuth.commandName] as? String else{
                print("Command name error")
                return
            }
            
            let commandDefault = commandDict[CommandKeyAuth.commandDefault] as Any
            
            guard let commandDescription = commandDict[CommandKeyAuth.commandDescription] as? String else{
                print("Command description error")
                return
            }
            
            right(commandName, commandDefault, commandDescription)
        }
    }
}
