//
//  Server.swift
//  BonjourDev
//
//  Created by Mark Duek on 27/09/18.
//  Copyright © 2018 Mark Duek. All rights reserved.
//

import Foundation
import Socket

///NSObject Server class that conforms to NetServiceDelegate
class Server: NSObject, NetServiceDelegate {
    
    //MARK: - Properties
    
    //MARK: Socket Properties
    
    ///Server socket
    var socket: Socket!
    ///Clients sockets
    var clientSockets: [Socket] = []
    ///Server running verifier
    var serverIsRunning = true
    ///Server port
    var port: Int!
    static let bufferSize = 100000000
    
    //MARK: Bonjour Properties
    
    var serviceServer: NetService!
    
    //MARK: Server Delegate Propertie
    
    var delegate: ServerDelegate?
    
    //MARK: - Deinit
    
    deinit {
        socket = nil
        clientSockets = []
        serverIsRunning = true
    }
    
    //MARK: - Methods
    
    /**
     Creates and publish a bonjour Service.
      
        - Parameter lobbyName: Name of the lobby
     */
    func createService(lobbyName: String){
        
        serviceServer = NetService(domain: "", type: "_testeDevPlusUltra._tcp", name: lobbyName, port: 2023)
        
        port = serviceServer.port
        runServer(port: port)
        
        if let serviceServer = serviceServer {
            
            serviceServer.delegate = self
            serviceServer.publish()
            Bonjour.shared.didPublishBonjour(netService: serviceServer)
        }
        
        debugPrint("Server: Service \(serviceServer.name) created and published.")
        debugPrint("Server:", "Service information", "Domain: \(serviceServer.domain)", "Type: \(serviceServer.type) ","Name: \(serviceServer.name)", "Port: \(serviceServer.port)", separator: "\n")
    }
        
    /**
    Creates a socket and a Thread to listen to the port for new clients to connect. Calling the function addNewConnection when found.
     
     - Parameter port: The port to which the server will listen.
     */
    func runServer(port: Int){
        
        self.port = port
        
        do {
            // Create an IPV6 socket
            try self.socket = Socket.create(family: .inet)
            
        } catch let error {
            debugPrint("Couldn`t create socket")
            debugPrint (error)

            return
        }
        
        // Opening port for connection
        do {
            try self.socket.listen(on: self.port)
            debugPrint("Listening on port: \(self.socket.listeningPort)")
        } catch let error {
            debugPrint("Can`t listen to port: \(self.port)")
            debugPrint(error)
            return
        }
        
        // Thread to find new clients trying to connect
        let queue = DispatchQueue(label: "Listening clients thread", qos: .utility)
        queue.async {
            
            self.delegate?.didCreateServer()
            
            repeat {
                
                do {
                    let clientSocket = try self.socket.acceptClientConnection()
                    print("Accepted new client")
                    print("New client is: \(clientSocket.remoteHostname)")
                    self.addNewConnection(clientSocket: clientSocket)

                } catch let error {
                    print(error)
                    print("Can`t accept new client")
                }
            } while self.serverIsRunning
        }
    }
    
    /**
     Connects a new client socket to the server.
     
     - Parameter clientSocket: Socket of the client you want to connect.
     */
    func addNewConnection(clientSocket: Socket) {
        
        // Adding the new client to the array
        self.clientSockets.append(clientSocket)
        
        // Creating thread to listen to the new client
        let queue = DispatchQueue(label: "Listening for client \(clientSocket.remoteHostname))", qos: .background)
        
        queue.async {
            
            var readData = Data(capacity: Server.bufferSize)
            var isRunning = true
            
            repeat {
                
                // If socket has been disconnected the thread must stop
                if !clientSocket.isConnected {
                    debugPrint("Server: Socket was disconnected while trying")
                    
                    isRunning = false
                    return
                }
                
                do {
                    let bytesRead = try clientSocket.read(into: &readData)
                    
                    debugPrint("Server: Will send: \(readData)")
                    // If there was a new message to be read
                    if bytesRead > 0 {
                        
                        do {
                            // Decoding Data to Json
                            let decoded = try JSONSerialization.jsonObject(with: readData, options: []) as! [String : Any]
                            
                            self.delegate?.didReceiveServerInfo(receivedDict: decoded)
                            
                            readData.count = 0
                            
                        } catch let error {
                            debugPrint("Something went wrong when decoding data")
                            debugPrint(error)
                        }
                    }
                } catch let error {
                    debugPrint("Server: Unable to read \(clientSocket.remoteHostname)")
                    debugPrint(error)
                    return
                }
                
            } while isRunning
        }
        
    }
    
    /**
     Close one of the sockets

        - Parameters:
            - socket: the socket that must be closed
            - index: index of the socket that must be closed
     */
    func closeIndividualSocket(_ socket: Socket, index: Int) {
        clientSockets.remove(at: index)
        socket.close()
    }
    
    
    /**
     Close all sockets connected to the socket removes all sockets from the array of sockets and close the server Scoket
 
     */
    func closeServerSockets(){
        
        debugPrint(#function)
        serverIsRunning = false
        clientSockets.forEach { (clientSocket) in
            clientSocket.close()
        }
        clientSockets.removeAll()
        socket.close()
    }

}

protocol ServerDelegate {
    /**
    Called every time the server receives a message. It already makes the decoding to a dictionary of [String:Any]
    
    - Parameter receivedDict: Data received already decoded
    */
    func didReceiveServerInfo(receivedDict: [String:Any])
    
    /**
    Called when the bonjour has been published. Prints Bonjour and NetService informations.
    
     -  Parameter netService: NetSerice that will be published.
    */
    func didPublishBonjour(netService: NetService)
    
    /**
    Called when the server has been created. Prints Server informations.
      
    */
    func didCreateServer()
}

extension ServerDelegate {
    
    func didReceiveServerInfo(receivedDict: [String:Any]) {}
    
    func didPublishBonjour(netService: NetService) {}
    
    func didCreateServer() {}
}
