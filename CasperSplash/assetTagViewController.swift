//
//  assetTagViewController.swift
//  CasperSplash
//
//  Created by Morgan, Tyler on 12/19/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa
import ServiceManagement

class assetTagViewController: NSViewController, ProcessProtocol {

    @IBOutlet weak var titleText: NSTextField!
    @IBOutlet weak var warningText: NSTextField!
    @IBOutlet weak var assetField: NSTextField!
    
    var xpcHelperConnection: NSXPCConnection?
    var helperAuthorization: NSData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        titleText.stringValue = "Please enter your asset tag below."
        warningText.isHidden = true
        assetField.placeholderString = "Asset Tag - xxxxxx"
    }
    
    
    @IBAction func assetTagContinue(_ sender: Any) {
        if (assetField.stringValue.lengthOfBytes(using: .ascii) < 7 && assetField.stringValue.lengthOfBytes(using: .ascii) > 3){
            dismiss(self)
            self.installHelper()
            shouldInstallHelper(callback: {
                installed in
                if !installed {
                    self.installHelper()
                }
            })
            
            let xpcService = self.helperConnection.remoteObjectProxyWithErrorHandler() { error -> Void in print("XPCService error: %@", error)} as? HelperProtocol
            xpcService?.setAssetTag(asset_tag: assetField.stringValue)
            
        }else{
            warningText.stringValue = "Please enter the asset tag located on your device."
            warningText.isHidden = false
            assetField.stringValue = ""
        }
    }
    
    //  Add ProcessProtocol to class
    
    private var authRef:AuthorizationRef? = nil
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    private lazy var helperConnection: NSXPCConnection = {
        if (self.xpcHelperConnection == nil){
            self.xpcHelperConnection = NSXPCConnection(machServiceName:HelperConstants.machServiceName, options:NSXPCConnection.Options.privileged)
            self.xpcHelperConnection!.exportedObject = self
            self.xpcHelperConnection!.exportedInterface = NSXPCInterface(with:ProcessProtocol.self)
            self.xpcHelperConnection!.remoteObjectInterface = NSXPCInterface(with:HelperProtocol.self)
            self.xpcHelperConnection!.invalidationHandler = {
                self.xpcHelperConnection!.invalidationHandler = nil
                OperationQueue.main.addOperation(){
                    self.xpcHelperConnection = nil
                    NSLog("XPC Connection Invalidated\n")
                }
            }
        }
        self.xpcHelperConnection?.resume()
        return self.xpcHelperConnection!
    }()
    
    func shouldInstallHelper(callback: @escaping (Bool) -> Void){
        
        let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LaunchServices/\(HelperConstants.machServiceName)")
        let helperBundleInfo = CFBundleCopyInfoDictionaryForURL(helperURL as CFURL!)
        if helperBundleInfo != nil {
            let helperInfo = helperBundleInfo as! NSDictionary
            let helperVersion = helperInfo["CFBundleVersion"] as! String
            
            print("Helper: Bundle Version => \(helperVersion)")
            
            let helper = self.helperConnection.remoteObjectProxyWithErrorHandler({
                _ in callback(false)
            }) as! HelperProtocol
            
            helper.getVersion(reply: {
                installedVersion in
                print("Helper: Installed Version => \(installedVersion)")
                callback(helperVersion == installedVersion)
            })
        } else {
            callback(false)
        }
    }
    
    func installHelper(){
        let authItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value:UnsafeMutableRawPointer(bitPattern: 0), flags: 0)
        var authItems = [authItem]
        var authRights:AuthorizationRights = AuthorizationRights(count: UInt32(authItems.count), items:&authItems)
        let authFlags: AuthorizationFlags = [
            [],
            .extendRights,
            .interactionAllowed,
            .preAuthorize
        ]
        
        let status = AuthorizationCreate(&authRights, nil, authFlags, &self.authRef)
        var error = NSError.init(domain: NSOSStatusErrorDomain, code: 0, userInfo: nil)
        if (status != errAuthorizationSuccess){
            error = NSError(domain:NSOSStatusErrorDomain, code:Int(status), userInfo:nil)
            NSLog("Authorization error: \(error)")
        } else {
            var cfError: Unmanaged<CFError>? = nil
            if !SMJobBless(kSMDomainSystemLaunchd, HelperConstants.machServiceName as CFString, authRef, &cfError) {
                let blessError = cfError!.takeRetainedValue() as Error
                NSLog("Bless Error: \(blessError)")
            } else {
                NSLog("\(HelperConstants.machServiceName) installed successfully")
            }
        }
    }
    
    func printHelperVersion(){
        let xpcService = self.helperConnection.remoteObjectProxyWithErrorHandler() { error -> Void in
            print("XPCService error: %@", error)
            } as? HelperProtocol
        
        xpcService?.getVersion(reply: {
            str in
            print("Helper: Current Version => \(str)")
        })
    }

}
