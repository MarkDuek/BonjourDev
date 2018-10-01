//
//  Client.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import Socket


class Client: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    
    var delegate: ClientDelegate!
    
    // MARK: - BONJOUR VARIABLES -
    
    //    private var serviceServer: NetService!
    var serviceBrowser: NetServiceBrowser!
    var servicesArray: NSMutableArray!
    
    // MARK: - SOCKET VARIABLES -
    
    var socket: Socket!
    static let bufferSize = 100000000
    
    ///////========== Client ==========////////
    func searchForServerClient() {
        Bonjour.shared.searchForServer(client: delegate)
    }
    // MARK: - SOCKET METHODS -
    //
    // ===================== SOCKET METHODS ================================
    //
    
    /// Tries to connect with a server with the ip and port
    ///
    /// - Parameters:
    ///   - ip: String that represents the ip you want to connect
    ///   - port: Int that represents the port you want to connect
    func connect(ip: String, port: Int) {
        
        // Creates a new socket
        do {
            
            try socket = Socket.create(family: .inet)
        } catch let error {
            print(error)
            print("Can`t create socket")
            return
        }
        
        // Tries connecting to a server with the given ip and port
        do {
            //            print("\(ip) e \(port)")
            try self.socket.connect(to: ip, port: Int32(port))
            self.delegate?.didConnectWithServer()
            
        } catch let error {
            print(error)
            print("Can`t connect to given server")
            return
        }
        
        // Thread to listen to the Server
        let queue = DispatchQueue(label: "kiwi Cliente", qos: .utility)
        
        queue.async {
            
            var readData = Data(capacity: Client.bufferSize)
            var isRunning = true
            
            repeat {
                
                // If socket has been disconnected the thread must stop
                if !self.socket.isConnected {
                    print("Disconnected")
                    
                    isRunning = false
                    return
                }
                
                do {
                    let bytesRead = try self.socket.read(into: &readData)
                    
                    // In case something was read
                    if bytesRead > 0{
                        
                        do {
                            // Decoding Data to Json
                            let decoded = try JSONSerialization.jsonObject(with: readData, options: [.allowFragments]) as! [String:Any]
                            
                            self.delegate?.didReceiveClientInfo(receivedDict: decoded)
                            readData.count = 0
                            
                        } catch let error {
                            print(error)
                            print("Could not decode Data")
                            
                        }
                    }
                } catch let error {
                    print(error)
                    print("Can`t read server")
                }
                
            } while isRunning
        }
    }
    
    
    /// Sending data to the server
    ///
    /// - Parameter data: Data you want to send
    func send(dictionary: [String: Any]){
        
        print(dictionary)
        
        let data: Data
        
        // Converting dictionary to Data
        do {
            data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        } catch let error {
            print(error)
            print("Can`t convert to data")
            
            return
        }
        
        // Sending to the server socket
        do {
            try socket.write(from: data)
        } catch let error {
            print(error)
            print("Wasn't able to write")
        }
    }
    
    
    /// Close client socket
    func closeClientSocket() {
        socket.close()
    }
}

// MARK: - CLIENTDELEGATE -

protocol ClientDelegate {
    
    /// Called when the client connects with the server
    func didConnectWithServer()
    
    /// Called every time the client receives a message. It already makes the decoding to a dictionary of [String:Any]
    ///
    /// - Parameter receivedDict: Data received already decoded
    func didReceiveClientInfo(receivedDict: [String:Any])
    
    /// Called when a bonjour service has been found
    func serviceFound(service: NetService)
    
    /// Called when the service is resolved
    ///
    /// - Parameter resolvedNetService: the resolved service
    func didResolveService(resolvedNetService: NetService)
    
    /// Called when the resolve method failed
    ///
    /// - Parameter netService: the unresolved service
    func didNotResolveService(netService: NetService)
    
    /// Called when the text Record was changed
    ///
    /// - Parameter newData: the new text record of the service
    func didUpdateTxtRecord(newData: Data)
    
    /// Called when the service that
    ///
    /// - Parameter netService: x
    func didLostService(netService: NetService)
}

extension ClientDelegate {
    
    func didConnectWithServer() { print("didConnectWithServer") }
    func didReceiveClientInfo(receivedDict: [String:Any]) {}
    func serviceFound(service: NetService) {}
    func didResolveService(resolvedNetService: NetService) {print("resolve extension")}
    func didNotResolveService(netService: NetService) {}
    func didUpdateTxtRecord(newData: Data) {}
    func didLostService(netService: NetService) {}
}
