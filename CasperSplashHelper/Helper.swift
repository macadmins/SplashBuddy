//
//  Helper.swift
//  CasperSplash
//
//  Created by Morgan, Tyler on 12/19/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Foundation
import ServiceManagement

class Helper: NSObject, HelperProtocol, NSXPCListenerDelegate{
    
    private var connections = [NSXPCConnection]()
    private var listener: NSXPCListener
    private var shouldQuit = false
    private var shouldQuitCheckInterval = 1.0
    
    override init(){
        self.listener = NSXPCListener(machServiceName: HelperConstants.machServiceName)
        super.init()
        self.listener.delegate = self
    }
    
    func run(){
        self.listener.resume()
        while !shouldQuit {
            RunLoop.current.run(until: Date.init(timeIntervalSinceNow: shouldQuitCheckInterval))
        }
    }
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        
        /*
         *  Mark: Add a check to prevent anyone from connecting
         */
        
        newConnection.remoteObjectInterface = NSXPCInterface(with: ProcessProtocol.self)
        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        newConnection.exportedObject = self
        newConnection.invalidationHandler = (() -> Void)? {
            if let indexValue = self.connections.index(of: newConnection) {
                self.connections.remove(at: indexValue)
            }
            if self.connections.count == 0 {
                self.shouldQuit = true
            }
        }
        self.connections.append(newConnection)
        newConnection.resume()
        return true
    }
    
    func getVersion(reply: (String) -> Void) {
        reply(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)
    }
    
    //  Edit: Add helper's functions below.
    func setAssetTag(asset_tag: String,reply: @escaping (NSNumber) -> Void) {
        let command = "/usr/bin/sudo"
        var args = ["/usr/sbin/nvram","asset-tag=\(asset_tag)"]
        runTask(command: command, arguments: args,reply: { (exitStatus) in
            let remoteObject = self.connection().remoteObjectProxy as? ProcessProtocol
            remoteObject?.log(stdOut: "Exit code: \(exitStatus)")
        })
        
        args = ["/usr/local/bin/jamf","recon","-assetTag",asset_tag]
        runTask(command: command, arguments: args,reply: { (exitStatus) in
            let remoteObject = self.connection().remoteObjectProxy as? ProcessProtocol
            remoteObject?.log(stdOut: "Exit code: \(exitStatus)")
        })
    }
    
    
    private func connection() -> NSXPCConnection{
        //  Mark: This is a stub to get the last connection, if mutliple connections should be supported, this should be handled differently.
        return self.connections.last!
    }
    
    private func runTask(command: String, arguments: Array<String>, reply:@escaping ((NSNumber)->Void)) -> Void{
        
        let task: Process = Process()
        let stdOut: Pipe = Pipe()
        
        let stdOutHandler = { (file: FileHandle!) -> Void in
            let data = file.availableData
            guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                else {return}
            
            let remoteObject = self.connection().remoteObjectProxy as? ProcessProtocol
            remoteObject?.log(stdOut: output as String)
        }
        
        stdOut.fileHandleForReading.readabilityHandler = stdOutHandler
        
        let stdErr: Pipe = Pipe()
        let stdErrHandler = { (file: FileHandle) -> Void in
            let data = file.availableData
            guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                else{return}
            let remoteObject = self.connection().remoteObjectProxy as? ProcessProtocol
            remoteObject?.log(stdErr: output as String)
        }
        
        stdErr.fileHandleForReading.readabilityHandler = stdErrHandler
        
        task.launchPath = command
        task.arguments = arguments
        task.standardOutput = stdOut
        task.standardError = stdErr
        
        task.terminationHandler = {task in
            reply(NSNumber(value: task.terminationStatus))
        }
        
        task.launch()
    }
}
