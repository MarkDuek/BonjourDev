//
//  Bonjour.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import Socket

///Bonjour Service blueprint of methods
protocol BonjourService {
    
    var serviceBrowser: NetServiceBrowser { get }
    var servicesArray: NSMutableArray   { get }
    var clientDelegate: ClientDelegate?  { get }
    var serverDelegate: ServerDelegate?  { get }
    
    /**
     Resolves given service in a TimeInterval, when done the delagate function AddressResolved will be called.

        - Parameters:
            - service: NetService you want to resolve.
            - timeout: TImeInterval the function as to resolve the given service.
     */
    func resolveService(_ service: NetService, with timeout: TimeInterval)

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool)

    func netServiceDidResolveAddress(_ sender: NetService)

    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber])

    func netService(_ sender: NetService, didUpdateTXTRecord data: Data)
}

//MARK: - Declaration

///Class in charge of publishing and discovering services on the network.
class Bonjour: NSObject, NetServiceBrowserDelegate, NetServiceDelegate, BonjourService {
   
    static var shared: Bonjour = Bonjour()

    //MARK: - Properties
    
    var jsonObject: [String:String]!

    //MARK: BonjourService Properties
    
    var serviceBrowser = NetServiceBrowser()
    
    var servicesArray: NSMutableArray = []
    
    var clientDelegate: ClientDelegate?
    
    var serverDelegate: ServerDelegate?
    
    //MARK: - Methods
    
    func searchForServer(client: ClientDelegate){
        clientDelegate = client
        
        // Empty the array of services
        if servicesArray != [] {
            servicesArray.removeAllObjects()
        } else {
            servicesArray = NSMutableArray()
        }
        
        serviceBrowser = NetServiceBrowser()
        serviceBrowser.delegate = self
        
        // Starts the search for servers
        let bonjourName = "_testeDevPlusUltra._tcp"
        debugPrint("Bonjour: Looking for bonjour: \(bonjourName)")
        
        serviceBrowser.searchForServices(ofType: bonjourName, inDomain: "")
    }

    //MARK: - Bonjour Methods

    func resolveService(_ service: NetService, with timeout: TimeInterval){
        
        // Tries to resolve a service
        service.resolve(withTimeout: timeout)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
          
        // Adding service to the array of services
        servicesArray.add(service)
        service.delegate = self
        
        // Calls the serviceFound delegate function
        self.clientDelegate?.serviceFound(service: service)
        
        debugPrint("Bonjour: Browser found service")
      }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        
        // Calls delegate passing the resolved NetService
        self.clientDelegate?.didResolveService(resolvedNetService: sender)

        debugPrint("Bonjour: Did resolve address")
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        
        self.clientDelegate?.didNotResolveService(netService: sender)
    }
    
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        print("did update txt")
        self.clientDelegate?.didUpdateTxtRecord(newData: data)
    }
    
    //MARK: - Net Service delegates
    
    // Server
    
    func didPublishBonjour(netService: NetService) {debugPrint(#function)
        
        debugPrint("txt Record Information")
        debugPrint(IPChecker.getIP())
        debugPrint(String(netService.port))
        
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

    // MARK: - Other Methods

    /// Function responsable to pass the IP address of the device
    ///
    /// - Returns: IP address of the connected wifi as a String or 'nil'
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
}


