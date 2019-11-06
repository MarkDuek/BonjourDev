//
//  Client.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import Socket

///Class that have all methods from client side.
class Client: NSObject {
    
    //MARK: - Properties
    
    ///Client Socket
    var socket: Socket!
    static let bufferSize = 100000000

    //MARK: Client Delegate Propertie
    
    var delegate: ClientDelegate!

    //MARK: - Methods
 
    /**
        Searches for a server.
     */
    func searchForServerClient() {
        Bonjour.shared.searchForServer(client: delegate)
    }
    
    /**
    Tries to connect with a server using an ip and port.
    
    - Parameters:
      - ip: String that represents the ip you want to connect
      - port: Int that represents the port you want to connect
 
     */
    func connect(ip: String, port: Int) {
        
        // Creates a new socket/Users/rodrigobukowitz/Desktop/Socket_Bonjour_Parte_Client.m4v
        do {
            
            try socket = Socket.create(family: .inet)
        } catch let error {
            debugPrint("Client: Can`t create socket")
            debugPrint(error)

            return
        }
        
        // Tries connecting to a server with the given ip and port
        do {
            //            print("\(ip) e \(port)")
            try self.socket.connect(to: ip, port: Int32(port))
            self.delegate?.didConnectWithServer()
            
        } catch let error {
            debugPrint("Client: Can`t connect to given server")
            debugPrint(error)

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
                    debugPrint("Client: Disconnected")
                    
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
                            debugPrint("Client: Could not decode Data")
                            print(error)
                            
                        }
                    }
                } catch let error {
                    debugPrint("Client: Can`t read server")
                    debugPrint(error)

                }
                
            } while isRunning
        }
    }
    
    /**
    Sending data to the server.
        
    - Parameter data: Data you want to send
    */
    func send(dictionary: [String: Any]){
        
        debugPrint("Client: Sending:",dictionary)
        
        let data: Data
        
        // Converting dictionary to Data
        do {
            data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        } catch let error {
            debugPrint("Client: Can`t convert to data")
            debugPrint(error)

            return
        }
        
        // Sending to the server socket
        do {
            try socket.write(from: data)
        } catch let error {
            debugPrint("Client: Wasn't able to write")
            debugPrint(error)

        }
    }
    
    /**
    Closes client socket.
    */
    func closeClientSocket() {
        socket.close()
    }
}

// MARK: - Client Delegate

protocol ClientDelegate {
    /**
    Called when the client connects with the server.
     
    */
    func didConnectWithServer()
    
    /**
    Called every time the client receives a message. It already makes the decoding to a dictionary of [String:Any]

    - Parameter receivedDict: Data received already decoded
    */
    func didReceiveClientInfo(receivedDict: [String:Any])
    
    /**
    Called when a bonjour service has been found
 
     - Parameter netService: Service that was found

    */
    func serviceFound(service: NetService)
    
    /**
    Called when the service is resolved

    - Parameter resolvedNetService: The resolved service
    */
    func didResolveService(resolvedNetService: NetService)
    /**
    Called when the resolve method failed

    - Parameter netService: The unresolved service
     */
    func didNotResolveService(netService: NetService)
    /**
    Called when the text Record was changed

    - Parameter newData: New text record of the service
     */
    func didUpdateTxtRecord(newData: Data)
    /**
    Called when the service that was connected was lost.

    - Parameter netService: Service that was lost.
     */
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
