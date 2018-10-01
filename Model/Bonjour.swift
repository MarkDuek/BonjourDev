//
//  Bonjour.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import Socket

class Bonjour: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    
    static var shared: Bonjour = Bonjour()
    
    var serviceBrowser: NetServiceBrowser!
    var servicesArray: NSMutableArray!
    var clientDelegate: ClientDelegate!
    var serverDelegate: ServerDelegate!
    var serverService: NetService!

    var jsonObject: [String:String]!
    
//    func ConectWithBonjour(service: NetService ) {
//        serverService = service
//        serverService.delegate = self
//        serverService.publish()
//    }
    
    func searchForServer(client: ClientDelegate){
        clientDelegate = client
        // Empty the array of services
        if servicesArray != nil {
            servicesArray.removeAllObjects()
        } else {
            servicesArray = NSMutableArray()
        }
        
        serviceBrowser = NetServiceBrowser()
        serviceBrowser.delegate = self
        
        // Starts the search for servers
        
        let bonjourName = "_testeDevPlusUltra._tcp"
        print("procurando por bonjour: \(bonjourName)")
        
        serviceBrowser.searchForServices(ofType: bonjourName, inDomain: "")
    }
    
    ///////========== Bounjour Methods ==============///////
    
    /// Function of the delegate that is called everytime a server is found
    ///
    /// - Parameters:
    ///   - browser:
    ///   - service: Server Found
    ///   - moreComing:
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("browser: Did find service")
        
        // Adding service to the array of services
        servicesArray.add(service)
        service.delegate = self
        
        // Calls the serviceFound delegate function
        self.clientDelegate?.serviceFound(service: service)
    }
    
    /// Resolves a given service in 10 seconds maximum when done the delagate function AddressResolved will be called
    ///
    /// - Parameter service: Service to resolve
    func resolveService(_ service: NetService, with timeout: TimeInterval){
        
        // Tries to resolve a service
        service.resolve(withTimeout: timeout)
    }
    
    /// Function called when the address is resolved
    ///
    /// - Parameter sender: Service of the server
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("did resolve address")
        
        // calls delegate passing the resolved NetService
        self.clientDelegate?.didResolveService(resolvedNetService: sender)
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        
        self.clientDelegate?.didNotResolveService(netService: sender)
    }
    
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        print("did update txt")
        self.clientDelegate?.didUpdateTxtRecord(newData: data)
    }
    
    // MARK: - Net Service delegates -
    //
    // ===================== NET SERVICE DELEGATES ================================
    //
    ////////// ========== Server ========= ///////////////
    func didPublishBonjour(netService: NetService) {debugPrint(#function)
        
        print("Printando as informacoes do txtRecord")
        print(IPChecker.getIP())
        print(String(netService.port))
        
        jsonObject = [
            "State": "aguardando",
            "Ip" : IPChecker.getIP(),
            "Port" : String(netService.port),
            "Name" : UIDevice.current.name,
            "cor": "1"
        ]
        
        print("Novo TXTRecord")
        print(jsonObject)
        
        let data = SocketManager.shared.decodeDictionary(toData: jsonObject)
        
        print(data)
        netService.setTXTRecord(data)
        print("did set TXT record")
        
    }
    
    func netServiceDidPublish(_ sender: NetService) {
        
        self.serverDelegate?.didPublishBonjour(netService: sender)
    }
}

